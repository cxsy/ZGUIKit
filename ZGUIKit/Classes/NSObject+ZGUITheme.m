//
//  NSObject+ZGUITheme.m
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/5.
//

#import "NSObject+ZGUITheme.h"
#import "ZGUIThemeManager.h"
#import <objc/runtime.h>

static void *ZGUINSObjectDeallocHelperKey;
static const CGFloat ZGUIAnimationDuration = .3f;

typedef void (^ZGUINSObjectDeallocBlock)(void);

@interface ZGUIDeallocHelper : NSObject

@property (nonatomic, copy) ZGUINSObjectDeallocBlock deallocBlock;

@end

@implementation ZGUIDeallocHelper

- (void)dealloc {
    if (self.deallocBlock) {
        self.deallocBlock();
        self.deallocBlock = nil;
    }
}

@end

@implementation NSObject (ZGUITheme)

- (NSMutableDictionary<NSString *, ZGUIColorPicker *> *)zgui_pickers {
    NSMutableDictionary<NSString *, ZGUIColorPicker *> *pickers = objc_getAssociatedObject(self, @selector(zgui_pickers));
    if (!pickers) {
        @autoreleasepool {
            // Need to removeObserver in dealloc
            if (objc_getAssociatedObject(self, &ZGUINSObjectDeallocHelperKey) == nil) {
                // NOTE: need to be __unsafe_unretained because __weak var will be reset to nil in dealloc
                __unsafe_unretained typeof(self) weakSelf = self;
                ZGUIDeallocHelper *deallocHelper = [[ZGUIDeallocHelper alloc] init];
                deallocHelper.deallocBlock = ^{
                    [[NSNotificationCenter defaultCenter] removeObserver:weakSelf];
                };
                objc_setAssociatedObject(self, &ZGUINSObjectDeallocHelperKey, deallocHelper, OBJC_ASSOCIATION_ASSIGN);
            }
        }

        pickers = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, @selector(zgui_pickers), pickers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onThemeDidChange)
                                                     name:ZGGUIThemeDidChangeNotification
                                                   object:nil];
    }
    return pickers;
}

- (void)onThemeDidChange {
    [self.zgui_pickers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull selector, ZGUIColorPicker * _Nonnull picker, BOOL * _Nonnull stop) {
        SEL sel = NSSelectorFromString(selector);
        UIColor *result = picker.themedColor;
        [UIView animateWithDuration:ZGUIAnimationDuration
                         animations:^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:sel withObject:result];
#pragma clang diagnostic pop
        }];
    }];
}

@end
