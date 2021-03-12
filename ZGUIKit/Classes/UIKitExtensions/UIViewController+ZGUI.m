/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIViewController+ZGUI.m
//  zgui
//
//  Created by ZGUI Team on 16/1/12.
//

#import "UIViewController+ZGUI.h"
#import "UINavigationController+ZGUI.h"
#import "ZGUICore.h"
#import "UIInterface+ZGUI.h"
#import "NSObject+ZGUI.h"
#import "UIView+ZGUI.h"

NSNotificationName const ZGUIAppSizeWillChangeNotification = @"ZGUIAppSizeWillChangeNotification";
NSString *const ZGUIPrecedingAppSizeUserInfoKey = @"ZGUIPrecedingAppSizeUserInfoKey";
NSString *const ZGUIFollowingAppSizeUserInfoKey = @"ZGUIFollowingAppSizeUserInfoKey";

@interface UIViewController ()

@property(nonatomic, strong) UINavigationBar *transitionNavigationBar;// by molice 对应 UIViewController (NavigationBarTransition) 里的 transitionNavigationBar，为了让这个属性在这里可以被访问到，有点 hack，具体请查看 https://github.com/Tencent/QMUI_iOS/issues/268

@end

@implementation UIViewController (ZGUI)

ZGUISynthesizeIdCopyProperty(zgui_visibleStateDidChangeBlock, setZgui_visibleStateDidChangeBlock)
ZGUISynthesizeIdCopyProperty(zgui_prefersStatusBarHiddenBlock, setZgui_prefersStatusBarHiddenBlock)
ZGUISynthesizeIdCopyProperty(zgui_preferredStatusBarStyleBlock, setZgui_preferredStatusBarStyleBlock)
ZGUISynthesizeIdCopyProperty(zgui_preferredStatusBarUpdateAnimationBlock, setZgui_preferredStatusBarUpdateAnimationBlock)
ZGUISynthesizeIdCopyProperty(zgui_prefersHomeIndicatorAutoHiddenBlock, setZgui_prefersHomeIndicatorAutoHiddenBlock)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        ExchangeImplementations([UIViewController class], @selector(description), @selector(zguivc_description));
        
        ExtendImplementationOfVoidMethodWithoutArguments([UIViewController class], @selector(viewDidLoad), ^(UIViewController *selfObject) {
            selfObject.zgui_visibleState = ZGUIViewControllerViewDidLoad;
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewWillAppear:), BOOL, ^(UIViewController *selfObject, BOOL animated) {
            selfObject.zgui_visibleState = ZGUIViewControllerWillAppear;
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewDidAppear:), BOOL, ^(UIViewController *selfObject, BOOL animated) {
            selfObject.zgui_visibleState = ZGUIViewControllerDidAppear;
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewWillDisappear:), BOOL, ^(UIViewController *selfObject, BOOL animated) {
            selfObject.zgui_visibleState = ZGUIViewControllerWillDisappear;
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewDidDisappear:), BOOL, ^(UIViewController *selfObject, BOOL animated) {
            selfObject.zgui_visibleState = ZGUIViewControllerDidDisappear;
        });
        
        OverrideImplementation([UIViewController class], @selector(viewWillTransitionToSize:withTransitionCoordinator:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject, CGSize size, id<UIViewControllerTransitionCoordinator> coordinator) {
                
                if (selfObject == UIApplication.sharedApplication.delegate.window.rootViewController) {
                    CGSize originalSize = selfObject.view.frame.size;
                    BOOL sizeChanged = !CGSizeEqualToSize(originalSize, size);
                    if (sizeChanged) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:ZGUIAppSizeWillChangeNotification object:nil userInfo:@{ZGUIPrecedingAppSizeUserInfoKey: @(originalSize), ZGUIFollowingAppSizeUserInfoKey: @(size)}];
                    }
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGSize, id<UIViewControllerTransitionCoordinator>);
                originSelectorIMP = (void (*)(id, SEL, CGSize, id<UIViewControllerTransitionCoordinator>))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, size, coordinator);
            };
        });
        
        // 修复 iOS 11 及以后，UIScrollView 无法自动适配不透明的 tabBar，导致底部 inset 错误的问题
        // https://github.com/Tencent/QMUI_iOS/issues/218
        if (@available(iOS 11, *)) {
            if (!ZGUICMIActivated || ShouldFixTabBarSafeAreaInsetsBug) {
                OverrideImplementation([UIViewController class], NSSelectorFromString([NSString stringWithFormat:@"_%@:%@:%@:",@"setContentOverlayInsets", @"andLeftMargin", @"rightMargin"]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^(UIViewController *selfObject, UIEdgeInsets insets, CGFloat leftMargin, CGFloat rightMargin) {

                        UITabBarController *tabBarController = selfObject.tabBarController;
                        UITabBar *tabBar = tabBarController.tabBar;
                        if (tabBarController
                            && tabBar
                            && selfObject.navigationController.parentViewController == tabBarController
                            && selfObject.parentViewController == selfObject.navigationController // 过滤掉那些自己添加的 childViewController 的情况
                            && !tabBar.hidden
                            && !selfObject.hidesBottomBarWhenPushed
                            && selfObject.isViewLoaded) {
                            CGRect viewRectInTabBarController = [selfObject.view convertRect:selfObject.view.bounds toView:tabBarController.view];

                            // 发现在 iOS 13.3 及以下，在 extendedLayoutIncludesOpaqueBars = YES 的情况下，理论上任何时候 vc.view 都应该撑满整个 tabBarController.view，但从没带 tabBar 的界面 pop 到带 tabBar 的界面过程中，navController.view.height 会被改得小一点，导致 safeAreaInsets.bottom 出现错误的中间值，引发 UIScrollView.contentInset 的错误变化，后续就算 contentInset 恢复正确，contentOffset 也无法恢复，所以这里直接过滤掉中间的错误值
                            // （但无法保证每个场景下这样的值都是错的，或许某些少见的场景里，navController.view.height 就是不会铺满整个 tabBarController.view.height 呢？）
                            // https://github.com/Tencent/QMUI_iOS/issues/934
                            if (@available(iOS 13.4, *)) {
                            } else {
                                if ((
                                     (!tabBar.translucent && selfObject.extendedLayoutIncludesOpaqueBars)
                                     || tabBar.translucent
                                     )
                                    && selfObject.edgesForExtendedLayout & UIRectEdgeBottom
                                    && !CGFloatEqualToFloat(CGRectGetHeight(viewRectInTabBarController), CGRectGetHeight(tabBarController.view.bounds))) {
                                    return;
                                }
                            }

                            // pop 转场动画过程中有些时候 tabBar 尚未被加到 view 层级树里，所以这里做个判断，避免出现 convertRect 警告
                            CGRect barRectInTabBarController = tabBar.window ? [tabBar convertRect:tabBar.bounds toView:tabBarController.view] : tabBar.frame;
                            CGFloat correctInsetBottom = MAX(CGRectGetMaxY(viewRectInTabBarController) - CGRectGetMinY(barRectInTabBarController), 0);
                            insets.bottom = correctInsetBottom;
                        }

                        // call super
                        void (*originSelectorIMP)(id, SEL, UIEdgeInsets, CGFloat, CGFloat);
                        originSelectorIMP = (void (*)(id, SEL, UIEdgeInsets, CGFloat, CGFloat))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD, insets, leftMargin, rightMargin);
                    };
                });
            }
        }
        
        if (@available(iOS 11.0, *)) {
            // iOS 11 及以后不 override prefersStatusBarHidden 而是通过私有方法来实现，是因为系统会先通过 +[UIViewController doesOverrideViewControllerMethod:inBaseClass:] 方法来判断当前的 UIViewController 有没有重写 prefersStatusBarHidden 方法，有的话才会去调用 prefersStatusBarHidden，而如果我们用 swizzle 的方式去重写 prefersStatusBarHidden，系统依然会认为你没有重写该方法，于是不会调用，于是 block 无效。对于 iOS 10 及以前的系统没有这种逻辑，所以没问题。
            // 特别的，只有 hidden 操作有这种逻辑，而 style、animation 等操作不管在哪个 iOS 版本里都是没有这种逻辑的
            OverrideImplementation([UIViewController class], NSSelectorFromString(@"_preferredStatusBarVisibility"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^NSInteger(UIViewController *selfObject) {
                    // 为了保证重写 prefersStatusBarHidden 的优先级比 block 高，这里要判断一下 zgui_hasOverrideUIKitMethod 的值
                    if (![selfObject zgui_hasOverrideUIKitMethod:@selector(prefersStatusBarHidden)] && selfObject.zgui_prefersStatusBarHiddenBlock) {
                        return selfObject.zgui_prefersStatusBarHiddenBlock() ? 1 : 2;// 系统返回的 1 表示隐藏，2 表示显示，0 不清楚含义
                    }

                    // call super
                    NSInteger (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (NSInteger (*)(id, SEL))originalIMPProvider();
                    NSInteger result = originSelectorIMP(selfObject, originCMD);
                    return result;
                };
            });
        } else {
            OverrideImplementation([UIViewController class], @selector(prefersStatusBarHidden), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^BOOL(UIViewController *selfObject) {
                    if (selfObject.zgui_prefersStatusBarHiddenBlock) {
                        return selfObject.zgui_prefersStatusBarHiddenBlock();
                    }

                    // call super
                    BOOL (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (BOOL (*)(id, SEL))originalIMPProvider();
                    BOOL result = originSelectorIMP(selfObject, originCMD);
                    return result;
                };
            });
        }
        
        OverrideImplementation([UIViewController class], @selector(preferredStatusBarStyle), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UIStatusBarStyle(UIViewController *selfObject) {
                if (selfObject.zgui_preferredStatusBarStyleBlock) {
                    return selfObject.zgui_preferredStatusBarStyleBlock();
                }
                
                // call super
                UIStatusBarStyle (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (UIStatusBarStyle (*)(id, SEL))originalIMPProvider();
                UIStatusBarStyle result = originSelectorIMP(selfObject, originCMD);
                return result;
            };
        });
        
        OverrideImplementation([UIViewController class], @selector(preferredStatusBarUpdateAnimation), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UIStatusBarAnimation(UIViewController *selfObject) {
                if (selfObject.zgui_preferredStatusBarUpdateAnimationBlock) {
                    return selfObject.zgui_preferredStatusBarUpdateAnimationBlock();
                }
                
                // call super
                UIStatusBarAnimation (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (UIStatusBarAnimation (*)(id, SEL))originalIMPProvider();
                UIStatusBarAnimation result = originSelectorIMP(selfObject, originCMD);
                return result;
            };
        });
        
        if (@available(iOS 11.0, *)) {
            OverrideImplementation([UIViewController class], @selector(prefersHomeIndicatorAutoHidden), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^BOOL(UIViewController *selfObject) {
                    if (selfObject.zgui_prefersHomeIndicatorAutoHiddenBlock) {
                        return selfObject.zgui_prefersHomeIndicatorAutoHiddenBlock();
                    }
                    
                    // call super
                    BOOL (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (BOOL (*)(id, SEL))originalIMPProvider();
                    BOOL result = originSelectorIMP(selfObject, originCMD);
                    return result;
                };
            });
        }
    });
}

- (NSString *)zguivc_description {
    if (![NSThread isMainThread]) {
        return [self zguivc_description];
    }
    
    NSString *result = [NSString stringWithFormat:@"%@\nsuperclass:\t\t\t\t%@\ntitle:\t\t\t\t\t%@\nview:\t\t\t\t\t%@", [self zguivc_description], NSStringFromClass(self.superclass), self.title, [self isViewLoaded] ? self.view : nil];
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *navController = (UINavigationController *)self;
        NSString *navDescription = [NSString stringWithFormat:@"\nviewControllers(%@):\t\t%@\ntopViewController:\t\t%@\nvisibleViewController:\t%@", @(navController.viewControllers.count), [self descriptionWithViewControllers:navController.viewControllers], [navController.topViewController zguivc_description], [navController.visibleViewController zguivc_description]];
        result = [result stringByAppendingString:navDescription];
        
    } else if ([self isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController *tabBarController = (UITabBarController *)self;
        NSString *tabBarDescription = [NSString stringWithFormat:@"\nviewControllers(%@):\t\t%@\nselectedViewController(%@):\t%@", @(tabBarController.viewControllers.count), [self descriptionWithViewControllers:tabBarController.viewControllers], @(tabBarController.selectedIndex), [tabBarController.selectedViewController zguivc_description]];
        result = [result stringByAppendingString:tabBarDescription];
        
    }
    return result;
}

- (NSString *)descriptionWithViewControllers:(NSArray<UIViewController *> *)viewControllers {
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendString:@"(\n"];
    for (NSInteger i = 0, l = viewControllers.count; i < l; i++) {
        [string appendFormat:@"\t\t\t\t\t\t\t[%@]%@%@\n", @(i), [viewControllers[i] zguivc_description], i < l - 1 ? @"," : @""];
    }
    [string appendString:@"\t\t\t\t\t\t)"];
    return [string copy];
}

static char kAssociatedObjectKey_visibleState;
- (void)setZgui_visibleState:(ZGUIViewControllerVisibleState)zgui_visibleState {
    BOOL valueChanged = self.zgui_visibleState != zgui_visibleState;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_visibleState, @(zgui_visibleState), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (valueChanged && self.zgui_visibleStateDidChangeBlock) {
        self.zgui_visibleStateDidChangeBlock(self, zgui_visibleState);
    }
}

- (ZGUIViewControllerVisibleState)zgui_visibleState {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_visibleState)) unsignedIntegerValue];
}

- (UIViewController *)zgui_previousViewController {
    NSArray<UIViewController *> *viewControllers = self.navigationController.viewControllers;
    NSUInteger index = [viewControllers indexOfObject:self];
    if (index != NSNotFound && index > 0) {
        return viewControllers[index - 1];
    }
    return nil;
}

- (NSString *)zgui_previousViewControllerTitle {
    UIViewController *previousViewController = [self zgui_previousViewController];
    if (previousViewController) {
        return previousViewController.title ?: previousViewController.navigationItem.title;
    }
    return nil;
}

- (BOOL)zgui_isPresented {
    UIViewController *viewController = self;
    if (self.navigationController) {
        if (self.navigationController.zgui_rootViewController != self) {
            return NO;
        }
        viewController = self.navigationController;
    }
    BOOL result = viewController.presentingViewController.presentedViewController == viewController;
    return result;
}

- (UIViewController *)zgui_visibleViewControllerIfExist {
    
    if (self.presentedViewController) {
        return [self.presentedViewController zgui_visibleViewControllerIfExist];
    }
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [((UINavigationController *)self).visibleViewController zgui_visibleViewControllerIfExist];
    }
    
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [((UITabBarController *)self).selectedViewController zgui_visibleViewControllerIfExist];
    }
    
    if ([self zgui_isViewLoadedAndVisible]) {
        return self;
    } else {
//        ZGUILog(@"UIViewController (ZGUI)", @"zgui_visibleViewControllerIfExist:，找不到可见的viewController。self = %@, self.view = %@, self.view.window = %@", self, [self isViewLoaded] ? self.view : nil, [self isViewLoaded] ? self.view.window : nil);
        return nil;
    }
}

- (BOOL)zgui_isViewLoadedAndVisible {
    return self.isViewLoaded && self.view.zgui_visible;
}

- (CGFloat)zgui_navigationBarMaxYInViewCoordinator {
    if (!self.isViewLoaded) {
        return 0;
    }
    
    // 手势返回过程中 self.navigationController 已经不存在了，所以暂时通过遍历 view 层级的方式去获取到 navigationController 的引用
    UINavigationController *navigationController = self.navigationController;
    if (!navigationController) {
        navigationController = self.view.superview.superview.zgui_viewController;
        if (![navigationController isKindOfClass:[UINavigationController class]]) {
            navigationController = nil;
        }
    }
    
    if (!navigationController) {
        return 0;
    }
    
    UINavigationBar *navigationBar = navigationController.navigationBar;
    CGFloat barMinX = CGRectGetMinX(navigationBar.frame);
    CGFloat barPresentationMinX = CGRectGetMinX(navigationBar.layer.presentationLayer.frame);
    CGFloat superviewX = CGRectGetMinX(self.view.superview.frame);
    CGFloat superviewX2 = CGRectGetMinX(self.view.superview.superview.frame);
    
    if (self.zgui_navigationControllerPoppingInteracted) {
        if (barMinX != 0 && barMinX == barPresentationMinX) {
            // 返回到无 bar 的界面
            return 0;
        } else if (barMinX > 0) {
            if (self.zgui_willAppearByInteractivePopGestureRecognizer) {
                // 要手势返回去的那个界面隐藏了 bar
                return 0;
            }
        } else if (barMinX < 0) {
            // 正在手势返回的这个界面隐藏了 bar
            if (!self.zgui_willAppearByInteractivePopGestureRecognizer) {
                return 0;
            }
        } else {
            // 正在手势返回的这个界面隐藏了 bar
            if (barPresentationMinX != 0 && !self.zgui_willAppearByInteractivePopGestureRecognizer) {
                return 0;
            }
        }
    } else {
        if (barMinX > 0) {
            // 正在 pop 回无 bar 的界面
            if (superviewX2 <= 0) {
                // 即将回到的那个无 bar 的界面
                return 0;
            }
        } else if (barMinX < 0) {
            if (barPresentationMinX < 0) {
                // 从无 bar push 进无 bar 的界面
                return 0;
            }
            // 正在从有 bar 的界面 push 到无 bar 的界面（bar 被推到左边屏幕外，所以是负数）
            if (superviewX >= 0) {
                // 即将进入的那个无 bar 的界面
                return 0;
            }
        } else {
            if (superviewX < 0 && barPresentationMinX != 0) {
                // 无 bar push 进有 bar 的界面时，背后的那个无 bar 的界面
                return 0;
            }
            if (superviewX2 > 0 && barPresentationMinX < 0) {
                // 无 bar pop 回有 bar 的界面时，被 pop 掉的那个无 bar 的界面
                return 0;
            }
        }
    }
    
    CGRect navigationBarFrameInView = [self.view convertRect:navigationBar.frame fromView:navigationBar.superview];
    CGRect navigationBarFrame = CGRectIntersection(self.view.bounds, navigationBarFrameInView);
    
    // 两个 rect 如果不存在交集，CGRectIntersection 计算结果可能为非法的 rect，所以这里做个保护
    if (!CGRectIsValidated(navigationBarFrame)) {
        return 0;
    }
    
    CGFloat result = CGRectGetMaxY(navigationBarFrame);
    return result;
}

- (CGFloat)zgui_toolbarSpacingInViewCoordinator {
    if (!self.isViewLoaded) {
        return 0;
    }
    if (!self.navigationController.toolbar || self.navigationController.toolbarHidden) {
        return 0;
    }
    CGRect toolbarFrame = CGRectIntersection(self.view.bounds, [self.view convertRect:self.navigationController.toolbar.frame fromView:self.navigationController.toolbar.superview]);
    
    // 两个 rect 如果不存在交集，CGRectIntersection 计算结果可能为非法的 rect，所以这里做个保护
    if (!CGRectIsValidated(toolbarFrame)) {
        return 0;
    }
    
    CGFloat result = CGRectGetHeight(self.view.bounds) - CGRectGetMinY(toolbarFrame);
    return result;
}

- (CGFloat)zgui_tabBarSpacingInViewCoordinator {
    if (!self.isViewLoaded) {
        return 0;
    }
    if (!self.tabBarController.tabBar || self.tabBarController.tabBar.hidden) {
        return 0;
    }
    CGRect tabBarFrame = CGRectIntersection(self.view.bounds, [self.view convertRect:self.tabBarController.tabBar.frame fromView:self.tabBarController.tabBar.superview]);
    
    // 两个 rect 如果不存在交集，CGRectIntersection 计算结果可能为非法的 rect，所以这里做个保护
    if (!CGRectIsValidated(tabBarFrame)) {
        return 0;
    }
    
    CGFloat result = CGRectGetHeight(self.view.bounds) - CGRectGetMinY(tabBarFrame);
    return result;
}

- (BOOL)zgui_prefersStatusBarHidden {
    if (self.childViewControllerForStatusBarHidden) {
        return self.childViewControllerForStatusBarHidden.zgui_prefersStatusBarHidden;
    }
    return self.prefersStatusBarHidden;
}

- (UIStatusBarStyle)zgui_preferredStatusBarStyle {
    if (self.childViewControllerForStatusBarStyle) {
        return self.childViewControllerForStatusBarStyle.zgui_preferredStatusBarStyle;
    }
    return self.preferredStatusBarStyle;
}

- (BOOL)zgui_prefersLargeTitleDisplayed {
    if (@available(iOS 11.0, *)) {
        NSAssert(self.navigationController, @"必现在 navigationController 栈内才能正确判断");
        UINavigationBar *navigationBar = self.navigationController.navigationBar;
        if (!navigationBar.prefersLargeTitles) {
            return NO;
        }
        if (self.navigationItem.largeTitleDisplayMode == UINavigationItemLargeTitleDisplayModeAlways) {
            return YES;
        } else if (self.navigationItem.largeTitleDisplayMode == UINavigationItemLargeTitleDisplayModeNever) {
            return NO;
        } else if (self.navigationItem.largeTitleDisplayMode == UINavigationItemLargeTitleDisplayModeAutomatic) {
            if (self.navigationController.viewControllers.firstObject == self) {
                return YES;
            } else {
                UIViewController *previousViewController = self.navigationController.viewControllers[[self.navigationController.viewControllers indexOfObject:self] - 1];
                return previousViewController.zgui_prefersLargeTitleDisplayed == YES;
            }
        }
    }
    return NO;
}

- (BOOL)zgui_isDescendantOfViewController:(UIViewController *)viewController {
    UIViewController *parentViewController = self;
    while (parentViewController) {
        if (parentViewController == viewController) {
            return YES;
        }
        parentViewController = parentViewController.parentViewController;
    }
    return NO;
}

@end

@implementation UIViewController (Data)

ZGUISynthesizeIdCopyProperty(zgui_didAppearAndLoadDataBlock, setZgui_didAppearAndLoadDataBlock)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewDidAppear:), BOOL, ^(UIViewController *selfObject, BOOL animated) {
            if (selfObject.zgui_didAppearAndLoadDataBlock && selfObject.zgui_dataLoaded) {
                selfObject.zgui_didAppearAndLoadDataBlock();
                selfObject.zgui_didAppearAndLoadDataBlock = nil;
            }
        });
    });
}

static char kAssociatedObjectKey_dataLoaded;
- (void)setZgui_dataLoaded:(BOOL)zgui_dataLoaded {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dataLoaded, @(zgui_dataLoaded), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.zgui_didAppearAndLoadDataBlock && zgui_dataLoaded && self.zgui_visibleState >= ZGUIViewControllerDidAppear) {
        self.zgui_didAppearAndLoadDataBlock();
        self.zgui_didAppearAndLoadDataBlock = nil;
    }
}

- (BOOL)isZgui_dataLoaded {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dataLoaded)) boolValue];
}

@end

@implementation UIViewController (Runtime)

- (BOOL)zgui_hasOverrideUIKitMethod:(SEL)selector {
    // 排序依照 Xcode Interface Builder 里的控件排序，但保证子类在父类前面
    NSMutableArray<Class> *viewControllerSuperclasses = [[NSMutableArray alloc] initWithObjects:
                                               [UIImagePickerController class],
                                               [UINavigationController class],
                                               [UITableViewController class],
                                               [UICollectionViewController class],
                                               [UITabBarController class],
                                               [UISplitViewController class],
                                               [UIPageViewController class],
                                               [UIViewController class],
                                               nil];
    
    if (NSClassFromString(@"UIAlertController")) {
        [viewControllerSuperclasses addObject:[UIAlertController class]];
    }
    if (NSClassFromString(@"UISearchController")) {
        [viewControllerSuperclasses addObject:[UISearchController class]];
    }
    for (NSInteger i = 0, l = viewControllerSuperclasses.count; i < l; i++) {
        Class superclass = viewControllerSuperclasses[i];
        if ([self zgui_hasOverrideMethod:selector ofSuperclass:superclass]) {
            return YES;
        }
    }
    return NO;
}

@end

@implementation UIViewController (RotateDeviceOrientation)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 实现 AutomaticallyRotateDeviceOrientation 开关的功能
        ExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewWillAppear:), BOOL, ^(UIViewController *selfObject, BOOL animated) {
            if (!AutomaticallyRotateDeviceOrientation) {
                return;
            }
            
            // 某些情况下的 UIViewController 不具备决定设备方向的权利，具体请看 https://github.com/Tencent/QMUI_iOS/issues/291
            if (![selfObject zgui_shouldForceRotateDeviceOrientation]) {
                BOOL isRootViewController = [selfObject isViewLoaded] && selfObject.view.window.rootViewController == selfObject;
                BOOL isChildViewController = [selfObject.tabBarController.viewControllers containsObject:selfObject] || [selfObject.navigationController.viewControllers containsObject:selfObject] || [selfObject.splitViewController.viewControllers containsObject:selfObject];
                BOOL hasRightsOfRotateDeviceOrientaion = isRootViewController || isChildViewController;
                if (!hasRightsOfRotateDeviceOrientaion) {
                    return;
                }
            }
            
            
            UIInterfaceOrientation statusBarOrientation = UIApplication.sharedApplication.statusBarOrientation;
            UIDeviceOrientation deviceOrientationBeforeChangingByHelper = [ZGUIHelper sharedInstance].orientationBeforeChangingByHelper;
            BOOL shouldConsiderBeforeChanging = deviceOrientationBeforeChangingByHelper != UIDeviceOrientationUnknown;
            UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
            
            // 虽然这两者的 unknow 值是相同的，但在启动 App 时可能只有其中一个是 unknown
            if (statusBarOrientation == UIInterfaceOrientationUnknown || deviceOrientation == UIDeviceOrientationUnknown) return;
            
            // 如果当前设备方向和界面支持的方向不一致，则主动进行旋转
            UIDeviceOrientation deviceOrientationToRotate = [ZGUIHelper interfaceOrientationMask:selfObject.supportedInterfaceOrientations containsDeviceOrientation:deviceOrientation] ? deviceOrientation : [ZGUIHelper deviceOrientationWithInterfaceOrientationMask:selfObject.supportedInterfaceOrientations];
            
            // 之前没用私有接口修改过，那就按最标准的方式去旋转
            if (!shouldConsiderBeforeChanging) {
                if ([ZGUIHelper rotateToDeviceOrientation:deviceOrientationToRotate]) {
                    [ZGUIHelper sharedInstance].orientationBeforeChangingByHelper = deviceOrientation;
                } else {
                    [ZGUIHelper sharedInstance].orientationBeforeChangingByHelper = UIDeviceOrientationUnknown;
                }
                return;
            }
            
            // 用私有接口修改过方向，但下一个界面和当前界面方向不相同，则要把修改前记录下来的那个设备方向考虑进来
            deviceOrientationToRotate = [ZGUIHelper interfaceOrientationMask:selfObject.supportedInterfaceOrientations containsDeviceOrientation:deviceOrientationBeforeChangingByHelper] ? deviceOrientationBeforeChangingByHelper : [ZGUIHelper deviceOrientationWithInterfaceOrientationMask:selfObject.supportedInterfaceOrientations];
            [ZGUIHelper rotateToDeviceOrientation:deviceOrientationToRotate];
        });
    });
}

- (BOOL)zgui_shouldForceRotateDeviceOrientation {
    return NO;
}

@end

@implementation UIViewController (ZGUINavigationController)

ZGUISynthesizeBOOLProperty(zgui_navigationControllerPopGestureRecognizerChanging, setZgui_navigationControllerPopGestureRecognizerChanging)
ZGUISynthesizeBOOLProperty(zgui_poppingByInteractivePopGestureRecognizer, setZgui_poppingByInteractivePopGestureRecognizer)
ZGUISynthesizeBOOLProperty(zgui_willAppearByInteractivePopGestureRecognizer, setZgui_willAppearByInteractivePopGestureRecognizer)

- (BOOL)zgui_navigationControllerPoppingInteracted {
    return self.zgui_poppingByInteractivePopGestureRecognizer || self.zgui_willAppearByInteractivePopGestureRecognizer;
}

- (void)zgui_animateAlongsideTransition:(void (^ __nullable)(id <UIViewControllerTransitionCoordinatorContext>context))animation
                             completion:(void (^ __nullable)(id <UIViewControllerTransitionCoordinatorContext>context))completion {
    if (self.transitionCoordinator) {
        BOOL animationQueuedToRun = [self.transitionCoordinator animateAlongsideTransition:animation completion:completion];
        // 某些情况下传给 animateAlongsideTransition 的 animation 不会被执行，这时候要自己手动调用一下
        // 但即便如此，completion 也会在动画结束后才被调用，因此这样写不会导致 completion 比 animation block 先调用
        // 某些情况包含：从 B 手势返回 A 的过程中，取消手势，animation 不会被调用
        // https://github.com/Tencent/QMUI_iOS/issues/692
        if (!animationQueuedToRun && animation) {
            animation(nil);
        }
    } else {
        if (animation) animation(nil);
        if (completion) completion(nil);
    }
}

@end

@implementation ZGUIHelper (ViewController)

+ (nullable UIViewController *)visibleViewController {
    UIViewController *rootViewController = UIApplication.sharedApplication.delegate.window.rootViewController;
    UIViewController *visibleViewController = [rootViewController zgui_visibleViewControllerIfExist];
    return visibleViewController;
}

@end
