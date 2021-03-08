//
//  UIView+ZGUITheme.m
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/5.
//

#import "UIView+ZGUITheme.h"
#import "ZGUIRuntime.h"
#import "UIColor+ZGUITheme.h"
#import "UIImage+ZGUITheme.h"
#import <objc/runtime.h>

CG_INLINE SEL
setterWithGetter(SEL getter) {
    NSString *getterString = NSStringFromSelector(getter);
    NSMutableString *setterString = [[NSMutableString alloc] initWithString:@"set"];
    NSString *capitalizedGetterString = [NSString stringWithFormat:@"%@%@", [getterString substringToIndex:1].uppercaseString, [getterString substringFromIndex:1]].copy;
    [setterString appendString:capitalizedGetterString];
    [setterString appendString:@":"];
    SEL setter = NSSelectorFromString(setterString);
    return setter;
}

static const CGFloat ZGUIAnimationDuration = .3f;

@interface UIView (ZGUITheme_private)

@property (nonatomic, copy, setter=zguiTheme_setThemeColorProperties:) NSMutableDictionary *zguiTheme_themeColorProperties;

@end

@implementation UIView (ZGUITheme_private)

- (NSMutableDictionary *)zguiTheme_themeColorProperties {
    return objc_getAssociatedObject(self, @selector(zguiTheme_themeColorProperties));
}

- (void)zguiTheme_setThemeColorProperties:(NSMutableDictionary *)themeColorProperties {
    objc_setAssociatedObject(self, @selector(zguiTheme_themeColorProperties), themeColorProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UIView class], @selector(setHidden:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, BOOL firstArgv) {
                
                BOOL valueChanged = selfObject.hidden != firstArgv;
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                if (valueChanged) {
                    [selfObject zgui_themeDidChangeShouldEnumeratorSubviews:YES];
                }
            };
        });
        
        OverrideImplementation([UIView class], @selector(setAlpha:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGFloat firstArgv) {
                
                BOOL willShow = selfObject.alpha <= 0 && firstArgv > 0.01;
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGFloat);
                originSelectorIMP = (void (*)(id, SEL, CGFloat))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                if (willShow) {
                    [selfObject zgui_themeDidChangeShouldEnumeratorSubviews:YES];
                }
            };
        });
        
        // 这几个 class 实现了自己的 didMoveToWindow 且没有调用 super，所以需要每个都替换一遍方法
        NSArray<Class> *classes = @[UIView.class,
                                    UICollectionView.class,
                                    UITextField.class,
                                    UISearchBar.class,
                                    NSClassFromString(@"UITableViewLabel")];
        if (NSClassFromString(@"WKWebView")) {
            classes = [classes arrayByAddingObject:NSClassFromString(@"WKWebView")];
        }
        [classes enumerateObjectsUsingBlock:^(Class  _Nonnull class, NSUInteger idx, BOOL * _Nonnull stop) {
            ExtendImplementationOfVoidMethodWithoutArguments(class, @selector(didMoveToWindow), ^(UIView *selfObject) {
                // enumerateSubviews 为 NO 是因为当某个 view 的 didMoveToWindow 被触发时，它的每个 subview 的 didMoveToWindow 也都会被触发，所以不需要遍历 subview 了
                if (selfObject.window) {
                    [selfObject zgui_themeDidChangeShouldEnumeratorSubviews:NO];
                }
            });
        }];
        
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIView class], @selector(initWithFrame:), CGRect, UIView *, ^UIView *(UIView *selfObject, CGRect frame, UIView *originReturnValue) {
            ({
                static NSDictionary<NSString *, NSArray<NSString *> *> *classRegisters = nil;
                if (!classRegisters) {
                    classRegisters = @{
                        NSStringFromClass(UIView.class):                             @[NSStringFromSelector(@selector(backgroundColor))],
                        NSStringFromClass(UIImageView.class):                        @[NSStringFromSelector(@selector(image))],
                    };
                }
                [classRegisters enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull classString, NSArray<NSString *> * _Nonnull getters, BOOL * _Nonnull stop) {
                    if ([selfObject isKindOfClass:NSClassFromString(classString)]) {
                        [selfObject qmui_registerThemeColorProperties:getters];
                    }
                }];
            });
            return originReturnValue;
        });
    });
}

- (void)qmui_registerThemeColorProperties:(NSArray<NSString *> *)getters {
    [getters enumerateObjectsUsingBlock:^(NSString * _Nonnull getterString, NSUInteger idx, BOOL * _Nonnull stop) {
        SEL getter = NSSelectorFromString(getterString);
        SEL setter = setterWithGetter(getter);
        NSString *setterString = NSStringFromSelector(setter);
        NSAssert([self respondsToSelector:getter], @"register theme color fails, %@ does not have method called %@", NSStringFromClass(self.class), getterString);
        NSAssert([self respondsToSelector:setter], @"register theme color fails, %@ does not have method called %@", NSStringFromClass(self.class), setterString);
        
        if (!self.zguiTheme_themeColorProperties) {
            self.zguiTheme_themeColorProperties = NSMutableDictionary.new;
        }
        self.zguiTheme_themeColorProperties[getterString] = setterString;
    }];
}

- (void)zgui_themeDidChangeShouldEnumeratorSubviews:(BOOL)shouldEnumeratorSubviews {
    [self zgui_onThemeDidChange];
    if (shouldEnumeratorSubviews) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            [subview zgui_themeDidChangeShouldEnumeratorSubviews:YES];
        }];
    }
}

- (BOOL)_zgui_visible {
    BOOL hidden = self.hidden;
    if ([self respondsToSelector:@selector(prepareForReuse)]) {
        hidden = NO;// UITableViewCell 在 prepareForReuse 前会被 setHidden:YES，然后再被 setHidden:NO，然而后者是无效的，执行完之后依然是 hidden 为 YES，导致认为非 visible 而无法触发 themeDidChange，所以这里对 UITableViewCell 做特殊处理
    }
    return !hidden && self.alpha > 0.01 && self.window;
}

- (void)zgui_onThemeDidChange {
    if (![self _zgui_visible]) {
        return;
    }
    // 常见的 view 在 QMUIThemePrivate 里注册了 getter，在这里被调用
    [self.zguiTheme_themeColorProperties enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull getterString, NSString * _Nonnull setterString, BOOL * _Nonnull stop) {
        
        SEL getter = NSSelectorFromString(getterString);
        SEL setter = NSSelectorFromString(setterString);
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id value = [self performSelector:getter];
        if (!value) return;
        BOOL isValidatedColor = [value isKindOfClass:ZGUIThemeColor.class];
        BOOL isValidatedImage = [value isKindOfClass:ZGUIThemeImage.class];
        if (isValidatedColor || isValidatedImage) {
            [UIView animateWithDuration:ZGUIAnimationDuration
                             animations:^{
                [self performSelector:setter withObject:value];
            }];
        }
        #pragma clang diagnostic pop
    }];
    
    static NSArray<Class> *needsDisplayClasses = nil;
    if (!needsDisplayClasses) needsDisplayClasses = @[UILabel.class, UITextField.class, UITextView.class];
    [needsDisplayClasses enumerateObjectsUsingBlock:^(Class  _Nonnull class, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self isKindOfClass:class]) [self setNeedsDisplay];
    }];
}

@end
