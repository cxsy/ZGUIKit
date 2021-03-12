//
//  UIVisualEffectView+ZGUI.m
//  ZGUIKit
//
//  Created by MoLice on 2020/7/15.
//  Copyright © 2020 ZGUI Team. All rights reserved.
//

#import "UIVisualEffectView+ZGUI.h"
#import "ZGUICore.h"
#import "CALayer+ZGUI.h"

@interface UIView (ZGUI_VisualEffectView)

// 为了方便，这个属性声明在 UIView 里，但实际上只有两个私有的 Visual View 会用到
@property(nonatomic, assign) BOOL zguive_keepHidden;
@end

@interface UIVisualEffectView ()

@property(nonatomic, strong) CALayer *zguive_foregroundLayer;
@property(nonatomic, assign, readonly) BOOL zguive_showsForegroundLayer;
@end

@implementation UIVisualEffectView (ZGUI)

ZGUISynthesizeIdStrongProperty(zguive_foregroundLayer, setZguive_foregroundLayer)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UIVisualEffectView class], @selector(didAddSubview:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIVisualEffectView *selfObject, UIView *firstArgv) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIView *);
                originSelectorIMP = (void (*)(id, SEL, UIView *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                [selfObject zguive_updateSubviews];
            };
        });
        
        ExtendImplementationOfVoidMethodWithoutArguments([UIVisualEffectView class], @selector(layoutSubviews), ^(UIVisualEffectView *selfObject) {
            if (selfObject.zguive_showsForegroundLayer) {
                selfObject.zguive_foregroundLayer.frame = selfObject.bounds;
            }
        });
    });
}

static char kAssociatedObjectKey_foregroundColor;
- (void)setZgui_foregroundColor:(UIColor *)zgui_foregroundColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_foregroundColor, zgui_foregroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (zgui_foregroundColor && !self.zguive_foregroundLayer) {
        self.zguive_foregroundLayer = [CALayer layer];
        [self.zguive_foregroundLayer zgui_removeDefaultAnimations];
        [self.layer addSublayer:self.zguive_foregroundLayer];
    }
    if (self.zguive_foregroundLayer) {
        self.zguive_foregroundLayer.backgroundColor = zgui_foregroundColor.CGColor;
        self.zguive_foregroundLayer.hidden = !zgui_foregroundColor;
        [self zguive_updateSubviews];
        [self setNeedsLayout];
    }
}

- (UIColor *)zgui_foregroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_foregroundColor);
}

- (BOOL)zguive_showsForegroundLayer {
    return self.zguive_foregroundLayer && !self.zguive_foregroundLayer.hidden;
}

- (void)zguive_updateSubviews {
    if (self.zguive_foregroundLayer) {
        
        // 先放在最背后，然后在遇到磨砂的 backdropLayer 时再放到它前面，因为有些情况下可能不存在 backdropLayer（例如 effect = nil 或者 effect 为 UIVibrancyEffect）
        [self.layer zgui_sendSublayerToBack:self.zguive_foregroundLayer];
        for (NSInteger i = 0; i < self.layer.sublayers.count; i++) {
            CALayer *sublayer = self.layer.sublayers[i];
            if ([NSStringFromClass(sublayer.class) isEqualToString:@"UICABackdropLayer"]) {
                [self.layer insertSublayer:self.zguive_foregroundLayer above:sublayer];
                break;
            }
        }
        
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *className = NSStringFromClass(subview.class);
            if ([className isEqualToString:@"_UIVisualEffectSubview"] || [className isEqualToString:@"_UIVisualEffectFilterView"]) {
                subview.zguive_keepHidden = !self.zguive_foregroundLayer.hidden;
            }
        }];
    }
}

@end

@implementation UIView (ZGUI_VisualEffectView)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        id (^block)(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) = ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, BOOL firstArgv) {
                
                if (selfObject.zguive_keepHidden) {
                    firstArgv = YES;
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        };
        // iOS 10 这两个 class 都有，iOS 11 开始只用第一个，后面那个不存在了
        OverrideImplementation(NSClassFromString(@"_UIVisualEffectSubview"), @selector(setHidden:), block);
        OverrideImplementation(NSClassFromString(@"_UIVisualEffectFilterView"), @selector(setHidden:), block);
    });
}

static char kAssociatedObjectKey_keepHidden;
- (void)setZguive_keepHidden:(BOOL)zguive_keepHidden {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_keepHidden, @(zguive_keepHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    // 从语义来看，当 keepHidden = NO 时，并不意味着 hidden 就一定要为 NO，但为了方便添加了 foregroundColor 后再去除 foregroundColor 时做一些恢复性质的操作，这里就实现成 keepHidden = NO 时 hidden = NO
    self.hidden = zguive_keepHidden;
}

- (BOOL)zguive_keepHidden {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_keepHidden)) boolValue];
}

@end
