/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UINavigationController+ZGUI.m
//  zgui
//
//  Created by ZGUI Team on 16/1/12.
//

#import "UINavigationController+ZGUI.h"
#import "ZGUICore.h"
#import "ZGUIWeakObjectContainer.h"
#import "UIViewController+ZGUI.h"

@interface _ZGUINavigationInteractiveGestureDelegator : NSObject <UIGestureRecognizerDelegate>

@property(nonatomic, weak, readonly) UINavigationController *parentViewController;
- (instancetype)initWithParentViewController:(UINavigationController *)parentViewController;
@end

@interface UINavigationController ()

@property(nonatomic, strong) NSMutableArray<ZGUINavigationActionDidChangeBlock> *zguinc_navigationActionDidChangeBlocks;
@property(nullable, nonatomic, readwrite) UIViewController *zgui_endedTransitionTopViewController;
@property(nullable, nonatomic, weak) id<UIGestureRecognizerDelegate> zgui_interactivePopGestureRecognizerDelegate;
@property(nullable, nonatomic, strong) _ZGUINavigationInteractiveGestureDelegator *zgui_interactiveGestureDelegator;
@end

@implementation UINavigationController (ZGUI)

ZGUISynthesizeIdStrongProperty(zguinc_navigationActionDidChangeBlocks, setZguinc_navigationActionDidChangeBlocks)
ZGUISynthesizeIdWeakProperty(zgui_endedTransitionTopViewController, setZgui_endedTransitionTopViewController)
ZGUISynthesizeIdWeakProperty(zgui_interactivePopGestureRecognizerDelegate, setZgui_interactivePopGestureRecognizerDelegate)
ZGUISynthesizeIdStrongProperty(zgui_interactiveGestureDelegator, setZgui_interactiveGestureDelegator)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        OverrideImplementation([UINavigationController class], @selector(initWithNibName:bundle:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UINavigationController *(UINavigationController *selfObject, NSString *firstArgv, NSBundle *secondArgv) {
                
                // call super
                UINavigationController *(*originSelectorIMP)(id, SEL, NSString *, NSBundle *);
                originSelectorIMP = (UINavigationController *(*)(id, SEL, NSString *, NSBundle *))originalIMPProvider();
                UINavigationController *result = originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);
                
                [selfObject zgui_didInitialize];
                
                return result;
            };
        });
        
        OverrideImplementation([UINavigationController class], @selector(initWithCoder:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UINavigationController *(UINavigationController *selfObject, NSCoder *firstArgv) {
                
                // call super
                UINavigationController *(*originSelectorIMP)(id, SEL, NSCoder *);
                originSelectorIMP = (UINavigationController *(*)(id, SEL, NSCoder *))originalIMPProvider();
                UINavigationController *result = originSelectorIMP(selfObject, originCMD, firstArgv);
                
                [selfObject zgui_didInitialize];
                
                return result;
            };
        });
        
        // iOS 12 及以前，initWithNavigationBarClass:toolbarClass:、initWithRootViewController: 会调用 initWithNibName:bundle:，所以这两个方法在 iOS 12 下不需要再次调用 zgui_didInitialize 了。
        if (@available(iOS 13.0, *)) {
            OverrideImplementation([UINavigationController class], @selector(initWithNavigationBarClass:toolbarClass:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UINavigationController *(UINavigationController *selfObject, Class firstArgv, Class secondArgv) {
                    
                    // call super
                    UINavigationController *(*originSelectorIMP)(id, SEL, Class, Class);
                    originSelectorIMP = (UINavigationController *(*)(id, SEL, Class, Class))originalIMPProvider();
                    UINavigationController *result = originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);
                    
                    [selfObject zgui_didInitialize];
                    
                    return result;
                };
            });
            
            OverrideImplementation([UINavigationController class], @selector(initWithRootViewController:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UINavigationController *(UINavigationController *selfObject, UIViewController *firstArgv) {
                    
                    // call super
                    UINavigationController *(*originSelectorIMP)(id, SEL, UIViewController *);
                    originSelectorIMP = (UINavigationController *(*)(id, SEL, UIViewController *))originalIMPProvider();
                    UINavigationController *result = originSelectorIMP(selfObject, originCMD, firstArgv);
                    
                    [selfObject zgui_didInitialize];
                    
                    return result;
                };
            });
        }
        
        
        ExtendImplementationOfVoidMethodWithoutArguments([UINavigationController class], @selector(viewDidLoad), ^(UINavigationController *selfObject) {
            selfObject.zgui_interactivePopGestureRecognizerDelegate = selfObject.interactivePopGestureRecognizer.delegate;
            selfObject.zgui_interactiveGestureDelegator = [[_ZGUINavigationInteractiveGestureDelegator alloc] initWithParentViewController:selfObject];
            selfObject.interactivePopGestureRecognizer.delegate = selfObject.zgui_interactiveGestureDelegator;
            
            // 根据 NavBarContainerClasses 的值来决定是否应用 bar.tintColor
            // tintColor 没有被添加 UI_APPEARANCE_SELECTOR，所以没有采用 UIAppearance 的方式去实现（虽然它实际上是支持的）
            if (ZGUICMIActivated) {
                BOOL shouldSetTintColor = NO;
                if (NavBarContainerClasses.count) {
                    for (Class class in NavBarContainerClasses) {
                        if ([selfObject isKindOfClass:class]) {
                            shouldSetTintColor = YES;
                            break;
                        }
                    }
                } else {
                    shouldSetTintColor = YES;
                }
                if (shouldSetTintColor) {
                    selfObject.navigationBar.tintColor = NavBarTintColor;
                }
            }
            if (ZGUICMIActivated) {
                BOOL shouldSetTintColor = NO;
                if (ToolBarContainerClasses.count) {
                    for (Class class in ToolBarContainerClasses) {
                        if ([selfObject isKindOfClass:class]) {
                            shouldSetTintColor = YES;
                            break;
                        }
                    }
                } else {
                    shouldSetTintColor = YES;
                }
                if (shouldSetTintColor) {
                    selfObject.toolbar.tintColor = ToolBarTintColor;
                }
            }
        });
        
        if (@available(iOS 11.0, *)) {
            OverrideImplementation(NSClassFromString([NSString zgui_stringByConcat:@"_", @"UINavigationBar", @"ContentView", nil]), NSSelectorFromString(@"__backButtonAction:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIView *selfObject, id firstArgv) {
                    
                    if ([selfObject.superview isKindOfClass:UINavigationBar.class]) {
                        UINavigationBar *bar = (UINavigationBar *)selfObject.superview;
                        if ([bar.delegate isKindOfClass:UINavigationController.class]) {
                            UINavigationController *navController = (UINavigationController *)bar.delegate;
                            BOOL canPopViewController = [navController canPopViewController:navController.topViewController byPopGesture:NO];
                            if (!canPopViewController) return;
                        }
                    }
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, id);
                    originSelectorIMP = (void (*)(id, SEL, id))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, firstArgv);
                };
            });
        } else {
            OverrideImplementation([UINavigationBar class], NSSelectorFromString(@"_shouldPopForTouchAtPoint:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^BOOL(UINavigationBar *selfObject, CGPoint firstArgv) {

                    // call super
                    BOOL (*originSelectorIMP)(id, SEL, CGPoint);
                    originSelectorIMP = (BOOL (*)(id, SEL, CGPoint))originalIMPProvider();
                    BOOL result = originSelectorIMP(selfObject, originCMD, firstArgv);

                    // 点击 navigationBar 任意地方都会触发这个方法，只有点到返回按钮时 result 才可能是 YES
                    if (result) {
                        if ([selfObject.delegate isKindOfClass:UINavigationController.class]) {
                            UINavigationController *navController = (UINavigationController *)selfObject.delegate;
                            BOOL canPopViewController = [navController canPopViewController:navController.topViewController byPopGesture:NO];
                            if (!canPopViewController) {
                                return NO;
                            }
                        }
                    }

                    return result;
                };
            });
        }
        
        OverrideImplementation([UINavigationController class], NSSelectorFromString(@"navigationTransitionView:didEndTransition:fromView:toView:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^void(UINavigationController *selfObject, UIView *transitionView, NSInteger transition, UIView *fromView, UIView *toView) {
                
                BOOL (*originSelectorIMP)(id, SEL, UIView *, NSInteger , UIView *, UIView *);
                originSelectorIMP = (BOOL (*)(id, SEL, UIView *, NSInteger , UIView *, UIView *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, transitionView, transition, fromView, toView);
                selfObject.zgui_endedTransitionTopViewController = selfObject.topViewController;
            };
        });
        
#pragma mark - pushViewController:animated:
        OverrideImplementation([UINavigationController class], @selector(pushViewController:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationController *selfObject, UIViewController *viewController, BOOL animated) {
                
                if (selfObject.presentedViewController) {
//                    ZGUILogWarn(NSStringFromClass(originClass), @"push 的时候 UINavigationController 存在一个盖在上面的 presentedViewController，可能导致一些 UINavigationControllerDelegate 不会被调用");
                }
                
                // call super
                void (^callSuperBlock)(void) = ^void(void) {
                    void (*originSelectorIMP)(id, SEL, UIViewController *, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, UIViewController *, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, viewController, animated);
                };
                
                BOOL willPushActually = viewController && ![viewController isKindOfClass:UITabBarController.class] && ![selfObject.viewControllers containsObject:viewController];
                
                if (!willPushActually) {
                    callSuperBlock();
                    return;
                }
                
                UIViewController *appearingViewController = viewController;
                NSArray<UIViewController *> *disappearingViewControllers = selfObject.topViewController ? @[selfObject.topViewController] : nil;
                
                [selfObject setZgui_navigationAction:ZGUINavigationActionWillPush animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                callSuperBlock();
                
                [selfObject setZgui_navigationAction:ZGUINavigationActionDidPush animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                [selfObject zgui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                    [selfObject setZgui_navigationAction:ZGUINavigationActionPushCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                    [selfObject setZgui_navigationAction:ZGUINavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];
                }];
            };
        });
        
#pragma mark - popViewControllerAnimated:
        OverrideImplementation([UINavigationController class], @selector(popViewControllerAnimated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UIViewController *(UINavigationController *selfObject, BOOL animated) {
                
                // call super
                UIViewController *(^callSuperBlock)(void) = ^UIViewController *(void) {
                    UIViewController *(*originSelectorIMP)(id, SEL, BOOL);
                    originSelectorIMP = (UIViewController *(*)(id, SEL, BOOL))originalIMPProvider();
                    UIViewController *result = originSelectorIMP(selfObject, originCMD, animated);
                    return result;
                };
                
                BOOL willPopActually = selfObject.viewControllers.count > 1;// 系统文档里说 rootViewController 是不能被 pop 的，当只剩下 rootViewController 时当前方法什么事都不会做
                
                if (!willPopActually) {
                    return callSuperBlock();
                }
                
                UIViewController *appearingViewController = selfObject.viewControllers[selfObject.viewControllers.count - 2];
                NSArray<UIViewController *> *disappearingViewControllers = selfObject.viewControllers.lastObject ? @[selfObject.viewControllers.lastObject] : nil;
                
                [selfObject setZgui_navigationAction:ZGUINavigationActionWillPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                UIViewController *result = callSuperBlock();
                
                NSAssert(result && disappearingViewControllers && disappearingViewControllers.firstObject == result, @"ZGUI 认为 popViewController 会成功，但实际上失败了");
                disappearingViewControllers = result ? @[result] : disappearingViewControllers;
                
                [selfObject setZgui_navigationAction:ZGUINavigationActionDidPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                [selfObject zgui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                    [selfObject setZgui_navigationAction:ZGUINavigationActionPopCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                    [selfObject setZgui_navigationAction:ZGUINavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];
                }];
                
                return result;
            };
        });
        
#pragma mark - popToViewController:animated:
        OverrideImplementation([UINavigationController class], @selector(popToViewController:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSArray<UIViewController *> *(UINavigationController *selfObject, UIViewController *viewController, BOOL animated) {
                
                // call super
                NSArray<UIViewController *> *(^callSuperBlock)(void) = ^NSArray<UIViewController *> *(void) {
                    NSArray<UIViewController *> *(*originSelectorIMP)(id, SEL, UIViewController *, BOOL);
                    originSelectorIMP = (NSArray<UIViewController *> * (*)(id, SEL, UIViewController *, BOOL))originalIMPProvider();
                    NSArray<UIViewController *> *poppedViewControllers = originSelectorIMP(selfObject, originCMD, viewController, animated);
                    return poppedViewControllers;
                };
                
                BOOL willPopActually = selfObject.viewControllers.count > 1 && [selfObject.viewControllers containsObject:viewController] && selfObject.topViewController != viewController;// 系统文档里说 rootViewController 是不能被 pop 的，当只剩下 rootViewController 时当前方法什么事都不会做
                
                if (!willPopActually) {
                    return callSuperBlock();
                }
                
                UIViewController *appearingViewController = viewController;
                NSArray<UIViewController *> *disappearingViewControllers = nil;
                NSUInteger index = [selfObject.viewControllers indexOfObject:appearingViewController];
                if (index != NSNotFound) {
                    disappearingViewControllers = [selfObject.viewControllers subarrayWithRange:NSMakeRange(index + 1, selfObject.viewControllers.count - index - 1)];
                }

                [selfObject setZgui_navigationAction:ZGUINavigationActionWillPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                NSArray<UIViewController *> *result = callSuperBlock();
                
                NSAssert([result isEqualToArray:disappearingViewControllers], @"ZGUI 计算得到的 popToViewController 结果和系统的不一致");
                disappearingViewControllers = result ?: disappearingViewControllers;
                
                [selfObject setZgui_navigationAction:ZGUINavigationActionDidPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                [selfObject zgui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                    [selfObject setZgui_navigationAction:ZGUINavigationActionPopCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                    [selfObject setZgui_navigationAction:ZGUINavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];
                }];
                
                return result;
            };
        });

#pragma mark - popToRootViewControllerAnimated:
        OverrideImplementation([UINavigationController class], @selector(popToRootViewControllerAnimated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSArray<UIViewController *> *(UINavigationController *selfObject, BOOL animated) {
                
                // call super
                NSArray<UIViewController *> *(^callSuperBlock)(void) = ^NSArray<UIViewController *> *(void) {
                    NSArray<UIViewController *> *(*originSelectorIMP)(id, SEL, BOOL);
                    originSelectorIMP = (NSArray<UIViewController *> * (*)(id, SEL, BOOL))originalIMPProvider();
                    NSArray<UIViewController *> *result = originSelectorIMP(selfObject, originCMD, animated);
                    return result;
                };
                
                BOOL willPopActually = selfObject.viewControllers.count > 1;
                
                if (!willPopActually) {
                    return callSuperBlock();
                }
                
                UIViewController *appearingViewController = selfObject.zgui_rootViewController;
                NSArray<UIViewController *> *disappearingViewControllers = [selfObject.viewControllers subarrayWithRange:NSMakeRange(1, selfObject.viewControllers.count - 1)];
                
                [selfObject setZgui_navigationAction:ZGUINavigationActionWillPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                NSArray<UIViewController *> *result = callSuperBlock();
                
                NSAssert([result isEqualToArray:disappearingViewControllers], @"ZGUI 计算得到的 popToRootViewController 结果和系统的不一致");
                disappearingViewControllers = result ?: disappearingViewControllers;
                
                [selfObject setZgui_navigationAction:ZGUINavigationActionDidPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                [selfObject zgui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                    [selfObject setZgui_navigationAction:ZGUINavigationActionPopCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                    [selfObject setZgui_navigationAction:ZGUINavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];
                }];
                
                return result;
            };
        });

#pragma mark - setViewControllers:animated:
        OverrideImplementation([UINavigationController class], @selector(setViewControllers:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationController *selfObject, NSArray<UIViewController *> *viewControllers, BOOL animated) {

                UIViewController *appearingViewController = selfObject.topViewController != viewControllers.lastObject ? viewControllers.lastObject : nil;// setViewControllers 执行前后 topViewController 没有变化，则赋值为 nil，表示没有任何界面有“重新显示”，这个 nil 的值也用于在 ZGUINavigationController 里实现 viewControllerKeepingAppearWhenSetViewControllersWithAnimated:
                NSMutableArray<UIViewController *> *disappearingViewControllers = selfObject.viewControllers.mutableCopy;
                [disappearingViewControllers removeObjectsInArray:viewControllers];
                disappearingViewControllers = disappearingViewControllers.count ? disappearingViewControllers : nil;

                [selfObject setZgui_navigationAction:ZGUINavigationActionWillSet animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];

                // call super
                void (*originSelectorIMP)(id, SEL, NSArray<UIViewController *> *, BOOL);
                originSelectorIMP = (void (*)(id, SEL, NSArray<UIViewController *> *, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, viewControllers, animated);

                [selfObject setZgui_navigationAction:ZGUINavigationActionDidSet animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];

                [selfObject zgui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                    [selfObject setZgui_navigationAction:ZGUINavigationActionSetCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                    [selfObject setZgui_navigationAction:ZGUINavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];
                }];
            };
        });
    });
}

- (void)zgui_didInitialize {
}

static char kAssociatedObjectKey_navigationAction;
- (void)setZgui_navigationAction:(ZGUINavigationAction)zgui_navigationAction
                        animated:(BOOL)animated
         appearingViewController:(UIViewController *)appearingViewController
     disappearingViewControllers:(NSArray<UIViewController *> *)disappearingViewControllers {
    BOOL valueChanged = self.zgui_navigationAction != zgui_navigationAction;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navigationAction, @(zgui_navigationAction), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (valueChanged && self.zguinc_navigationActionDidChangeBlocks.count) {
        [self.zguinc_navigationActionDidChangeBlocks enumerateObjectsUsingBlock:^(ZGUINavigationActionDidChangeBlock  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj(zgui_navigationAction, animated, self, appearingViewController, disappearingViewControllers);
        }];
    }
}

- (ZGUINavigationAction)zgui_navigationAction {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_navigationAction)) unsignedIntegerValue];
}

- (void)zgui_addNavigationActionDidChangeBlock:(ZGUINavigationActionDidChangeBlock)block {
    if (!self.zguinc_navigationActionDidChangeBlocks) {
        self.zguinc_navigationActionDidChangeBlocks = NSMutableArray.new;
    }
    [self.zguinc_navigationActionDidChangeBlocks addObject:block];
}

// TODO: molice 改为用 ZGUINavigationAction 判断
- (BOOL)zgui_isPushing {
    BOOL isPushing = self.zgui_navigationAction > ZGUINavigationActionWillPush && self.zgui_navigationAction <= ZGUINavigationActionPushCompleted;
    return isPushing;
}

// TODO: molice 改为用 ZGUINavigationAction 判断
- (BOOL)zgui_isPopping {
    BOOL isPopping = self.zgui_navigationAction > ZGUINavigationActionWillPop && self.zgui_navigationAction <= ZGUINavigationActionPopCompleted;
    return isPopping;
}

- (UIViewController *)zgui_topViewController {
    if (self.zgui_isPushing) {
        return self.topViewController;
    }
    return self.zgui_endedTransitionTopViewController ? self.zgui_endedTransitionTopViewController : self.topViewController;
}

- (nullable UIViewController *)zgui_rootViewController {
    return self.viewControllers.firstObject;
}

- (void)zgui_pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    // 要先进行转场操作才能产生 self.transitionCoordinator，然后才能用 zgui_animateAlongsideTransition:completion:，所以不能把转场操作放在 animation block 里。
    [self pushViewController:viewController animated:animated];
    if (completion) {
        [self zgui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            completion();
        }];
    }
}

- (UIViewController *)zgui_popViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    // 要先进行转场操作才能产生 self.transitionCoordinator，然后才能用 zgui_animateAlongsideTransition:completion:，所以不能把转场操作放在 animation block 里。
    UIViewController *result = [self popViewControllerAnimated:animated];
    if (completion) {
        [self zgui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            completion();
        }];
    }
    return result;
}

- (NSArray<UIViewController *> *)zgui_popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    // 要先进行转场操作才能产生 self.transitionCoordinator，然后才能用 zgui_animateAlongsideTransition:completion:，所以不能把转场操作放在 animation block 里。
    NSArray<UIViewController *> *result = [self popToViewController:viewController animated:animated];
    if (completion) {
        [self zgui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            completion();
        }];
    }
    return result;
}

- (NSArray<UIViewController *> *)zgui_popToRootViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    // 要先进行转场操作才能产生 self.transitionCoordinator，然后才能用 zgui_animateAlongsideTransition:completion:，所以不能把转场操作放在 animation block 里。
    NSArray<UIViewController *> *result = [self popToRootViewControllerAnimated:animated];
    if (completion) {
        [self zgui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            completion();
        }];
    }
    return result;
}

- (BOOL)canPopViewController:(UIViewController *)viewController byPopGesture:(BOOL)byPopGesture {
    BOOL canPopViewController = YES;
    
    if ([viewController respondsToSelector:@selector(shouldPopViewControllerByBackButtonOrPopGesture:)] &&
        [viewController shouldPopViewControllerByBackButtonOrPopGesture:byPopGesture] == NO) {
        canPopViewController = NO;
    }
    
    return canPopViewController;
}

- (BOOL)shouldForceEnableInteractivePopGestureRecognizer {
    UIViewController *viewController = [self topViewController];
    return self.viewControllers.count > 1 && self.interactivePopGestureRecognizer.enabled && [viewController respondsToSelector:@selector(forceEnableInteractivePopGestureRecognizer)] && [viewController forceEnableInteractivePopGestureRecognizer];
}

@end


@implementation _ZGUINavigationInteractiveGestureDelegator

- (instancetype)initWithParentViewController:(UINavigationController *)parentViewController {
    if (self = [super init]) {
        _parentViewController = parentViewController;
    }
    return self;
}

#pragma mark - <UIGestureRecognizerDelegate>

// iOS 13.4 开始会优先询问该方法，只有返回 YES 后才会继续后续的逻辑
- (BOOL)_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveEvent:(UIEvent *)event {
    if (gestureRecognizer == self.parentViewController.interactivePopGestureRecognizer) {
        NSObject <UIGestureRecognizerDelegate> *originGestureDelegate = self.parentViewController.zgui_interactivePopGestureRecognizerDelegate;
        if ([originGestureDelegate respondsToSelector:_cmd]) {
            BOOL originalValue = YES;
            [originGestureDelegate zgui_performSelector:_cmd withPrimitiveReturnValue:&originalValue arguments:&gestureRecognizer, &event, nil];
            if (!originalValue && [self.parentViewController shouldForceEnableInteractivePopGestureRecognizer]) {
                return YES;
            }
            return originalValue;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.parentViewController.interactivePopGestureRecognizer) {
        BOOL canPopViewController = [self.parentViewController canPopViewController:self.parentViewController.topViewController byPopGesture:YES];
        if (canPopViewController) {
            if ([self.parentViewController.zgui_interactivePopGestureRecognizerDelegate respondsToSelector:_cmd]) {
                return [self.parentViewController.zgui_interactivePopGestureRecognizerDelegate gestureRecognizerShouldBegin:gestureRecognizer];
            } else {
                return NO;
            }
        } else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.parentViewController.interactivePopGestureRecognizer) {
        id<UIGestureRecognizerDelegate>originGestureDelegate = self.parentViewController.zgui_interactivePopGestureRecognizerDelegate;
        if ([originGestureDelegate respondsToSelector:_cmd]) {
            BOOL originalValue = [originGestureDelegate gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
            if (!originalValue && [self.parentViewController shouldForceEnableInteractivePopGestureRecognizer]) {
                return YES;
            }
            return originalValue;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.parentViewController.interactivePopGestureRecognizer) {
        if ([self.parentViewController.zgui_interactivePopGestureRecognizerDelegate respondsToSelector:_cmd]) {
            return [self.parentViewController.zgui_interactivePopGestureRecognizerDelegate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
        }
    }
    return NO;
}

// 是否要gestureRecognizer检测失败了，才去检测otherGestureRecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.parentViewController.interactivePopGestureRecognizer) {
        // 如果只是实现了上面几个手势的delegate，那么返回的手势和当前界面上的scrollview或者其他存在的手势会冲突，所以如果判断是返回手势，则优先响应返回手势再响应其他手势。
        // 不知道为什么，系统竟然没有实现这个delegate，那么它是怎么处理返回手势和其他手势的优先级的
        return YES;
    }
    return NO;
}

@end


@implementation UIViewController (BackBarButtonSupport)
@end
