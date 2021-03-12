/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIView+ZGUI.m
//  zgui
//
//  Created by ZGUI Team on 15/7/20.
//

#import "UIView+ZGUI.h"
#import "ZGUICore.h"
#import "UIColor+ZGUI.h"
#import "NSObject+ZGUI.h"
#import "UIImage+ZGUI.h"
#import "NSNumber+ZGUI.h"
#import "UIViewController+ZGUI.h"
#import "ZGUIWeakObjectContainer.h"

@interface UIView ()

/// ZGUI_Debug
@property(nonatomic, assign, readwrite) BOOL zgui_hasDebugColor;
@end


@implementation UIView (ZGUI)

ZGUISynthesizeBOOLProperty(zgui_tintColorCustomized, setZgui_tintColorCustomized)
ZGUISynthesizeIdCopyProperty(zgui_frameWillChangeBlock, setZgui_frameWillChangeBlock)
ZGUISynthesizeIdCopyProperty(zgui_frameDidChangeBlock, setZgui_frameDidChangeBlock)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIView class], @selector(setTintColor:), UIColor *, ^(UIView *selfObject, UIColor *tintColor) {
            selfObject.zgui_tintColorCustomized = !!tintColor;
        });
        
        // 这个私有方法在 view 被调用 becomeFirstResponder 并且处于 window 上时，才会被调用，所以比 becomeFirstResponder 更适合用来检测
        ExtendImplementationOfVoidMethodWithSingleArgument([UIView class], NSSelectorFromString(@"_didChangeToFirstResponder:"), id, ^(UIView *selfObject, id firstArgv) {
            if (selfObject == firstArgv && [selfObject conformsToProtocol:@protocol(UITextInput)]) {
                // 像 ZGUIModalPresentationViewController 那种以 window 的形式展示浮层，浮层里的输入框 becomeFirstResponder 的场景，[window makeKeyAndVisible] 被调用后，就会立即走到这里，但此时该 window 尚不是 keyWindow，所以这里延迟到下一个 runloop 里再去判断
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (IS_DEBUG && ![selfObject isKindOfClass:[UIWindow class]] && selfObject.window && !selfObject.window.keyWindow) {
                        [selfObject ZGUISymbolicUIViewBecomeFirstResponderWithoutKeyWindow];
                    }
                });
            }
        });
    });
}

- (instancetype)zgui_initWithSize:(CGSize)size {
    return [self initWithFrame:CGRectMakeWithSize(size)];
}

- (void)setZgui_frameApplyTransform:(CGRect)zgui_frameApplyTransform {
    self.frame = CGRectApplyAffineTransformWithAnchorPoint(zgui_frameApplyTransform, self.transform, self.layer.anchorPoint);
}

- (CGRect)zgui_frameApplyTransform {
    return self.frame;
}

- (UIEdgeInsets)zgui_safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return self.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

- (void)zgui_removeAllSubviews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

static char kAssociatedObjectKey_outsideEdge;
- (void)setZgui_outsideEdge:(UIEdgeInsets)zgui_outsideEdge {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_outsideEdge, @(zgui_outsideEdge), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!UIEdgeInsetsEqualToEdgeInsets(zgui_outsideEdge, UIEdgeInsetsZero)) {
        [ZGUIHelper executeBlock:^{
            OverrideImplementation([UIView class], @selector(pointInside:withEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^BOOL(UIControl *selfObject, CGPoint point, UIEvent *event) {
                    
                    if (!UIEdgeInsetsEqualToEdgeInsets(selfObject.zgui_outsideEdge, UIEdgeInsetsZero)) {
                        CGRect rect = UIEdgeInsetsInsetRect(selfObject.bounds, selfObject.zgui_outsideEdge);
                        BOOL result = CGRectContainsPoint(rect, point);
                        return result;
                    }
                    
                    // call super
                    BOOL (*originSelectorIMP)(id, SEL, CGPoint, UIEvent *);
                    originSelectorIMP = (BOOL (*)(id, SEL, CGPoint, UIEvent *))originalIMPProvider();
                    BOOL result = originSelectorIMP(selfObject, originCMD, point, event);
                    return result;
                };
            });
        } oncePerIdentifier:@"UIView (ZGUI) outsideEdge"];
    }
}

- (UIEdgeInsets)zgui_outsideEdge {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_outsideEdge)) UIEdgeInsetsValue];
}

static char kAssociatedObjectKey_tintColorDidChangeBlock;
- (void)setZgui_tintColorDidChangeBlock:(void (^)(__kindof UIView * _Nonnull))zgui_tintColorDidChangeBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_tintColorDidChangeBlock, zgui_tintColorDidChangeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (zgui_tintColorDidChangeBlock) {
        [ZGUIHelper executeBlock:^{
            ExtendImplementationOfVoidMethodWithoutArguments([UIView class], @selector(tintColorDidChange), ^(UIView *selfObject) {
                if (selfObject.zgui_tintColorDidChangeBlock) {
                    selfObject.zgui_tintColorDidChangeBlock(selfObject);
                }
            });
        } oncePerIdentifier:@"UIView (ZGUI) tintColorDidChangeBlock"];
    }
}

- (void (^)(__kindof UIView * _Nonnull))zgui_tintColorDidChangeBlock {
    return (void (^)(__kindof UIView * _Nonnull))objc_getAssociatedObject(self, &kAssociatedObjectKey_tintColorDidChangeBlock);
}

static char kAssociatedObjectKey_hitTestBlock;
- (void)setZgui_hitTestBlock:(__kindof UIView * _Nonnull (^)(CGPoint, UIEvent * _Nonnull, __kindof UIView * _Nonnull))zgui_hitTestBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_hitTestBlock, zgui_hitTestBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [ZGUIHelper executeBlock:^{
        ExtendImplementationOfNonVoidMethodWithTwoArguments([UIView class], @selector(hitTest:withEvent:), CGPoint, UIEvent *, UIView *, ^UIView *(UIView *selfObject, CGPoint point, UIEvent *event, UIView *originReturnValue) {
            if (selfObject.zgui_hitTestBlock) {
                UIView *view = selfObject.zgui_hitTestBlock(point, event, originReturnValue);
                return view;
            }
            return originReturnValue;
        });
    } oncePerIdentifier:@"UIView (ZGUI) hitTestBlock"];
}

- (__kindof UIView * _Nonnull (^)(CGPoint, UIEvent * _Nonnull, __kindof UIView * _Nonnull))zgui_hitTestBlock {
    return (__kindof UIView * _Nonnull (^)(CGPoint, UIEvent * _Nonnull, __kindof UIView * _Nonnull))objc_getAssociatedObject(self, &kAssociatedObjectKey_hitTestBlock);
}

- (CGPoint)zgui_convertPoint:(CGPoint)point toView:(nullable UIView *)view {
    if (view) {
        return [view zgui_convertPoint:point fromView:view];
    }
    return [self convertPoint:point toView:view];
}

- (CGPoint)zgui_convertPoint:(CGPoint)point fromView:(nullable UIView *)view {
    UIWindow *selfWindow = [self isKindOfClass:[UIWindow class]] ? (UIWindow *)self : self.window;
    UIWindow *fromWindow = [view isKindOfClass:[UIWindow class]] ? (UIWindow *)view : view.window;
    if (selfWindow && fromWindow && selfWindow != fromWindow) {
        CGPoint pointInFromWindow = fromWindow == view ? point : [view convertPoint:point toView:nil];
        CGPoint pointInSelfWindow = [selfWindow convertPoint:pointInFromWindow fromWindow:fromWindow];
        CGPoint pointInSelf = selfWindow == self ? pointInSelfWindow : [self convertPoint:pointInSelfWindow fromView:nil];
        return pointInSelf;
    }
    return [self convertPoint:point fromView:view];
}

- (CGRect)zgui_convertRect:(CGRect)rect toView:(nullable UIView *)view {
    if (view) {
        return [view zgui_convertRect:rect fromView:self];
    }
    return [self convertRect:rect toView:view];
}

- (CGRect)zgui_convertRect:(CGRect)rect fromView:(nullable UIView *)view {
    UIWindow *selfWindow = [self isKindOfClass:[UIWindow class]] ? (UIWindow *)self : self.window;
    UIWindow *fromWindow = [view isKindOfClass:[UIWindow class]] ? (UIWindow *)view : view.window;
    if (selfWindow && fromWindow && selfWindow != fromWindow) {
        CGRect rectInFromWindow = fromWindow == view ? rect : [view convertRect:rect toView:nil];
        CGRect rectInSelfWindow = [selfWindow convertRect:rectInFromWindow fromWindow:fromWindow];
        CGRect rectInSelf = selfWindow == self ? rectInSelfWindow : [self convertRect:rectInSelfWindow fromView:nil];
        return rectInSelf;
    }
    return [self convertRect:rect fromView:view];
}

+ (void)zgui_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion {
    if (animated) {
        [UIView animateWithDuration:duration delay:delay options:options animations:animations completion:completion];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

+ (void)zgui_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration animations:(void (^ __nullable)(void))animations completion:(void (^)(BOOL finished))completion {
    if (animated) {
        [UIView animateWithDuration:duration animations:animations completion:completion];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

+ (void)zgui_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration animations:(void (^ __nullable)(void))animations {
    if (animated) {
        [UIView animateWithDuration:duration animations:animations];
    } else {
        if (animations) {
            animations();
        }
    }
}

+ (void)zgui_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {
    if (animated) {
        [UIView animateWithDuration:duration delay:delay usingSpringWithDamping:dampingRatio initialSpringVelocity:velocity options:options animations:animations completion:completion];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

- (void)ZGUISymbolicUIViewBecomeFirstResponderWithoutKeyWindow {
//    ZGUILogWarn(@"UIView (ZGUI)", @"尝试让一个处于非 keyWindow 上的 %@ becomeFirstResponder，可能导致界面显示异常，请添加 '%@' 的 Symbolic Breakpoint 以捕捉此类信息\n%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [NSThread callStackSymbols]);
}

@end

@implementation UIView (ZGUI_ViewController)

ZGUISynthesizeBOOLProperty(zgui_isControllerRootView, setZgui_isControllerRootView)

- (BOOL)zgui_visible {
    if (self.hidden || self.alpha <= 0.01) {
        return NO;
    }
    if (self.window) {
        return YES;
    }
    if ([self isKindOfClass:UIWindow.class]) {
        if (@available(iOS 13.0, *)) {
            return !!((UIWindow *)self).windowScene;
        } else {
            return YES;
        }
    }
    UIViewController *viewController = self.zgui_viewController;
    return viewController.zgui_visibleState >= ZGUIViewControllerWillAppear && viewController.zgui_visibleState < ZGUIViewControllerWillDisappear;
}

static char kAssociatedObjectKey_viewController;
- (void)setZgui_viewController:(__kindof UIViewController * _Nullable)zgui_viewController {
    ZGUIWeakObjectContainer *weakContainer = objc_getAssociatedObject(self, &kAssociatedObjectKey_viewController);
    if (!weakContainer) {
        weakContainer = [[ZGUIWeakObjectContainer alloc] init];
    }
    weakContainer.object = zgui_viewController;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_viewController, weakContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.zgui_isControllerRootView = !!zgui_viewController;
}

- (__kindof UIViewController *)zgui_viewController {
    if (self.zgui_isControllerRootView) {
        return (__kindof UIViewController *)((ZGUIWeakObjectContainer *)objc_getAssociatedObject(self, &kAssociatedObjectKey_viewController)).object;
    }
    return self.superview.zgui_viewController;
}

@end

@interface UIViewController (ZGUI_View)

@end

@implementation UIViewController (ZGUI_View)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithoutArguments([UIViewController class], @selector(viewDidLoad), ^(UIViewController *selfObject) {
            if (@available(iOS 11.0, *)) {
                selfObject.view.zgui_viewController = selfObject;
            } else {
                // 临时修复 iOS 10.0.2 上在输入框内切换输入法可能引发死循环的 bug，待查
                // https://github.com/Tencent/QMUI_iOS/issues/471
                ((UIView *)[selfObject zgui_valueForKey:@"_view"]).zgui_viewController = selfObject;
            }
        });
    });
}

@end


@implementation UIView (ZGUI_Runtime)

- (BOOL)zgui_hasOverrideUIKitMethod:(SEL)selector {
    // 排序依照 Xcode Interface Builder 里的控件排序，但保证子类在父类前面
    NSMutableArray<Class> *viewSuperclasses = [[NSMutableArray alloc] initWithObjects:
                                               [UIStackView class],
                                               [UILabel class],
                                               [UIButton class],
                                               [UISegmentedControl class],
                                               [UITextField class],
                                               [UISlider class],
                                               [UISwitch class],
                                               [UIActivityIndicatorView class],
                                               [UIProgressView class],
                                               [UIPageControl class],
                                               [UIStepper class],
                                               [UITableView class],
                                               [UITableViewCell class],
                                               [UIImageView class],
                                               [UICollectionView class],
                                               [UICollectionViewCell class],
                                               [UICollectionReusableView class],
                                               [UITextView class],
                                               [UIScrollView class],
                                               [UIDatePicker class],
                                               [UIPickerView class],
                                               [UIVisualEffectView class],
                                               // Apple 不再接受使用了 UIWebView 的 App 提交，所以这里去掉 UIWebView
                                               // https://github.com/Tencent/QMUI_iOS/issues/741
//                                               [UIWebView class],
                                               [UIWindow class],
                                               [UINavigationBar class],
                                               [UIToolbar class],
                                               [UITabBar class],
                                               [UISearchBar class],
                                               [UIControl class],
                                               [UIView class],
                                               nil];
    
    for (NSInteger i = 0, l = viewSuperclasses.count; i < l; i++) {
        Class superclass = viewSuperclasses[i];
        if ([self zgui_hasOverrideMethod:selector ofSuperclass:superclass]) {
            return YES;
        }
    }
    return NO;
}

@end


const CGFloat ZGUIViewSelfSizingHeight = INFINITY;

@implementation UIView (ZGUI_Layout)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        OverrideImplementation([UIView class], @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGRect frame) {
                
                // ZGUIViewSelfSizingHeight 的功能
                if (frame.size.width > 0 && isinf(frame.size.height)) {
                    CGFloat height = flat([selfObject sizeThatFits:CGSizeMake(CGRectGetWidth(frame), CGFLOAT_MAX)].height);
                    frame = CGRectSetHeight(frame, height);
                }
                
                // 对非法的 frame，Debug 下中 assert，Release 下会将其中的 NaN 改为 0，避免 crash
                if (CGRectIsNaN(frame)) {
//                    ZGUILogWarn(@"UIView (ZGUI)", @"%@ setFrame:%@，参数包含 NaN，已被拦截并处理为 0。%@", selfObject, NSStringFromCGRect(frame), [NSThread callStackSymbols]);
                    if (ZGUICMIActivated && !ShouldPrintZGUIWarnLogToConsole) {
                        NSAssert(NO, @"UIView setFrame: 出现 NaN");
                    }
                    if (!IS_DEBUG) {
                        frame = CGRectSafeValue(frame);
                    }
                }
                
                CGRect precedingFrame = selfObject.frame;
                BOOL valueChange = !CGRectEqualToRect(frame, precedingFrame);
                if (selfObject.zgui_frameWillChangeBlock && valueChange) {
                    frame = selfObject.zgui_frameWillChangeBlock(selfObject, frame);
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, frame);
                
                if (selfObject.zgui_frameDidChangeBlock && valueChange) {
                    selfObject.zgui_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });
        
        OverrideImplementation([UIView class], @selector(setBounds:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGRect bounds) {
                
                CGRect precedingFrame = selfObject.frame;
                CGRect precedingBounds = selfObject.bounds;
                BOOL valueChange = !CGSizeEqualToSize(bounds.size, precedingBounds.size);// bounds 只有 size 发生变化才会影响 frame
                if (selfObject.zgui_frameWillChangeBlock && valueChange) {
                    CGRect followingFrame = CGRectMake(CGRectGetMinX(precedingFrame) + CGFloatGetCenter(CGRectGetWidth(bounds), CGRectGetWidth(precedingFrame)), CGRectGetMinY(precedingFrame) + CGFloatGetCenter(CGRectGetHeight(bounds), CGRectGetHeight(precedingFrame)), bounds.size.width, bounds.size.height);
                    followingFrame = selfObject.zgui_frameWillChangeBlock(selfObject, followingFrame);
                    bounds = CGRectSetSize(bounds, followingFrame.size);
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, bounds);
                
                if (selfObject.zgui_frameDidChangeBlock && valueChange) {
                    selfObject.zgui_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });
        
        OverrideImplementation([UIView class], @selector(setCenter:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGPoint center) {
                
                CGRect precedingFrame = selfObject.frame;
                CGPoint precedingCenter = selfObject.center;
                BOOL valueChange = !CGPointEqualToPoint(center, precedingCenter);
                if (selfObject.zgui_frameWillChangeBlock && valueChange) {
                    CGRect followingFrame = CGRectSetXY(precedingFrame, center.x - CGRectGetWidth(selfObject.frame) / 2, center.y - CGRectGetHeight(selfObject.frame) / 2);
                    followingFrame = selfObject.zgui_frameWillChangeBlock(selfObject, followingFrame);
                    center = CGPointMake(CGRectGetMidX(followingFrame), CGRectGetMidY(followingFrame));
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGPoint);
                originSelectorIMP = (void (*)(id, SEL, CGPoint))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, center);
                
                if (selfObject.zgui_frameDidChangeBlock && valueChange) {
                    selfObject.zgui_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });
        
        OverrideImplementation([UIView class], @selector(setTransform:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGAffineTransform transform) {
                
                CGRect precedingFrame = selfObject.frame;
                CGAffineTransform precedingTransform = selfObject.transform;
                BOOL valueChange = !CGAffineTransformEqualToTransform(transform, precedingTransform);
                if (selfObject.zgui_frameWillChangeBlock && valueChange) {
                    CGRect followingFrame = CGRectApplyAffineTransformWithAnchorPoint(precedingFrame, transform, selfObject.layer.anchorPoint);
                    selfObject.zgui_frameWillChangeBlock(selfObject, followingFrame);// 对于 CGAffineTransform，无法根据修改后的 rect 来算出新的 transform，所以就不修改 transform 的值了
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGAffineTransform);
                originSelectorIMP = (void (*)(id, SEL, CGAffineTransform))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, transform);
                
                if (selfObject.zgui_frameDidChangeBlock && valueChange) {
                    selfObject.zgui_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });
    });
}

- (CGFloat)zgui_top {
    return CGRectGetMinY(self.frame);
}

- (void)setZgui_top:(CGFloat)top {
    self.frame = CGRectSetY(self.frame, top);
}

- (CGFloat)zgui_left {
    return CGRectGetMinX(self.frame);
}

- (void)setZgui_left:(CGFloat)left {
    self.frame = CGRectSetX(self.frame, left);
}

- (CGFloat)zgui_bottom {
    return CGRectGetMaxY(self.frame);
}

- (void)setZgui_bottom:(CGFloat)bottom {
    self.frame = CGRectSetY(self.frame, bottom - CGRectGetHeight(self.frame));
}

- (CGFloat)zgui_right {
    return CGRectGetMaxX(self.frame);
}

- (void)setZgui_right:(CGFloat)right {
    self.frame = CGRectSetX(self.frame, right - CGRectGetWidth(self.frame));
}

- (CGFloat)zgui_width {
    return CGRectGetWidth(self.frame);
}

- (void)setZgui_width:(CGFloat)width {
    self.frame = CGRectSetWidth(self.frame, width);
}

- (CGFloat)zgui_height {
    return CGRectGetHeight(self.frame);
}

- (void)setZgui_height:(CGFloat)height {
    self.frame = CGRectSetHeight(self.frame, height);
}

- (CGFloat)zgui_extendToTop {
    return self.zgui_top;
}

- (void)setZgui_extendToTop:(CGFloat)zgui_extendToTop {
    self.zgui_height = self.zgui_bottom - zgui_extendToTop;
    self.zgui_top = zgui_extendToTop;
}

- (CGFloat)zgui_extendToLeft {
    return self.zgui_left;
}

- (void)setZgui_extendToLeft:(CGFloat)zgui_extendToLeft {
    self.zgui_width = self.zgui_right - zgui_extendToLeft;
    self.zgui_left = zgui_extendToLeft;
}

- (CGFloat)zgui_extendToBottom {
    return self.zgui_bottom;
}

- (void)setZgui_extendToBottom:(CGFloat)zgui_extendToBottom {
    self.zgui_height = zgui_extendToBottom - self.zgui_top;
    self.zgui_bottom = zgui_extendToBottom;
}

- (CGFloat)zgui_extendToRight {
    return self.zgui_right;
}

- (void)setZgui_extendToRight:(CGFloat)zgui_extendToRight {
    self.zgui_width = zgui_extendToRight - self.zgui_left;
    self.zgui_right = zgui_extendToRight;
}

- (CGFloat)zgui_leftWhenCenterInSuperview {
    return CGFloatGetCenter(CGRectGetWidth(self.superview.bounds), CGRectGetWidth(self.frame));
}

- (CGFloat)zgui_topWhenCenterInSuperview {
    return CGFloatGetCenter(CGRectGetHeight(self.superview.bounds), CGRectGetHeight(self.frame));
}

@end


@implementation UIView (CGAffineTransform)

- (CGFloat)zgui_scaleX {
    return self.transform.a;
}

- (CGFloat)zgui_scaleY {
    return self.transform.d;
}

- (CGFloat)zgui_translationX {
    return self.transform.tx;
}

- (CGFloat)zgui_translationY {
    return self.transform.ty;
}

@end


@implementation UIView (ZGUI_Snapshotting)

- (UIImage *)zgui_snapshotLayerImage {
    return [UIImage zgui_imageWithView:self];
}

- (UIImage *)zgui_snapshotImageAfterScreenUpdates:(BOOL)afterScreenUpdates {
    return [UIImage zgui_imageWithView:self afterScreenUpdates:afterScreenUpdates];
}

@end


@implementation UIView (ZGUI_Debug)

ZGUISynthesizeBOOLProperty(zgui_needsDifferentDebugColor, setZgui_needsDifferentDebugColor)
ZGUISynthesizeBOOLProperty(zgui_hasDebugColor, setZgui_hasDebugColor)

static char kAssociatedObjectKey_shouldShowDebugColor;
- (void)setZgui_shouldShowDebugColor:(BOOL)zgui_shouldShowDebugColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shouldShowDebugColor, @(zgui_shouldShowDebugColor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (zgui_shouldShowDebugColor) {
        [ZGUIHelper executeBlock:^{
            ExtendImplementationOfVoidMethodWithoutArguments([UIView class], @selector(layoutSubviews), ^(UIView *selfObject) {
                if (selfObject.zgui_shouldShowDebugColor) {
                    selfObject.zgui_hasDebugColor = YES;
                    selfObject.backgroundColor = [selfObject debugColor];
                    [selfObject renderColorWithSubviews:selfObject.subviews];
                }
            });
        } oncePerIdentifier:@"UIView (ZGUIDebug) shouldShowDebugColor"];
        
        [self setNeedsLayout];
    }
}
- (BOOL)zgui_shouldShowDebugColor {
    BOOL flag = [objc_getAssociatedObject(self, &kAssociatedObjectKey_shouldShowDebugColor) boolValue];
    return flag;
}

static char kAssociatedObjectKey_layoutSubviewsBlock;
- (void)setZgui_layoutSubviewsBlock:(void (^)(__kindof UIView * _Nonnull))zgui_layoutSubviewsBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_layoutSubviewsBlock, zgui_layoutSubviewsBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    Class viewClass = self.class;
    [ZGUIHelper executeBlock:^{
        ExtendImplementationOfVoidMethodWithoutArguments(viewClass, @selector(layoutSubviews), ^(__kindof UIView *selfObject) {
            if (selfObject.zgui_layoutSubviewsBlock && [selfObject isMemberOfClass:viewClass]) {
                selfObject.zgui_layoutSubviewsBlock(selfObject);
            }
        });
    } oncePerIdentifier:[NSString stringWithFormat:@"UIView %@-%@", NSStringFromClass(viewClass), NSStringFromSelector(@selector(layoutSubviews))]];
}

- (void (^)(UIView * _Nonnull))zgui_layoutSubviewsBlock {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_layoutSubviewsBlock);
}

static char kAssociatedObjectKey_sizeThatFitsBlock;
- (void)setZgui_sizeThatFitsBlock:(CGSize (^)(__kindof UIView * _Nonnull, CGSize, CGSize))zgui_sizeThatFitsBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_sizeThatFitsBlock, zgui_sizeThatFitsBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if (!zgui_sizeThatFitsBlock) return;
    
    // Extend 每个实例对象的类是为了保证比子类的 sizeThatFits 逻辑要更晚调用
    Class viewClass = self.class;
    [ZGUIHelper executeBlock:^{
        ExtendImplementationOfNonVoidMethodWithSingleArgument(viewClass, @selector(sizeThatFits:), CGSize, CGSize, ^CGSize(UIView *selfObject, CGSize firstArgv, CGSize originReturnValue) {
            if (selfObject.zgui_sizeThatFitsBlock && [selfObject isMemberOfClass:viewClass]) {
                originReturnValue = selfObject.zgui_sizeThatFitsBlock(selfObject, firstArgv, originReturnValue);
            }
            return originReturnValue;
        });
    } oncePerIdentifier:[NSString stringWithFormat:@"UIView %@-%@", NSStringFromClass(viewClass), NSStringFromSelector(@selector(sizeThatFits:))]];
}

- (CGSize (^)(__kindof UIView * _Nonnull, CGSize, CGSize))zgui_sizeThatFitsBlock {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_sizeThatFitsBlock);
}

- (void)renderColorWithSubviews:(NSArray *)subviews {
    for (UIView *view in subviews) {
        if ([view isKindOfClass:[UIStackView class]]) {
            UIStackView *stackView = (UIStackView *)view;
            [self renderColorWithSubviews:stackView.arrangedSubviews];
        }
        view.zgui_hasDebugColor = YES;
        view.zgui_shouldShowDebugColor = self.zgui_shouldShowDebugColor;
        view.zgui_needsDifferentDebugColor = self.zgui_needsDifferentDebugColor;
        view.backgroundColor = [self debugColor];
    }
}

- (UIColor *)debugColor {
    if (!self.zgui_needsDifferentDebugColor) {
        return UIColorTestRed;
    } else {
        return [[UIColor zgui_randomColor] colorWithAlphaComponent:.3];
    }
}

@end
