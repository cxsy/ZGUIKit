/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIScrollView+ZGUI.m
//  zgui
//
//  Created by ZGUI Team on 15/7/20.
//

#import "UIScrollView+ZGUI.h"
#import "ZGUICore.h"
#import "NSNumber+ZGUI.h"
#import "UIView+ZGUI.h"
#import "UIViewController+ZGUI.h"

@interface UIScrollView ()

@property(nonatomic, assign) CGFloat zguiscroll_lastInsetTopWhenScrollToTop;
@property(nonatomic, assign) BOOL zguiscroll_hasSetInitialContentInset;
@end

@implementation UIScrollView (ZGUI)

ZGUISynthesizeCGFloatProperty(zguiscroll_lastInsetTopWhenScrollToTop, setQmuiscroll_lastInsetTopWhenScrollToTop)
ZGUISynthesizeBOOLProperty(zguiscroll_hasSetInitialContentInset, setQmuiscroll_hasSetInitialContentInset)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        OverrideImplementation([UIScrollView class], @selector(description), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSString *(UIScrollView *selfObject) {
                // call super
                NSString *(*originSelectorIMP)(id, SEL);
                originSelectorIMP = (NSString *(*)(id, SEL))originalIMPProvider();
                NSString *result = originSelectorIMP(selfObject, originCMD);
                
                if (NSThread.isMainThread) {
                    result = ([NSString stringWithFormat:@"%@, contentInset = %@", result, NSStringFromUIEdgeInsets(selfObject.contentInset)]);
                    if (@available(iOS 13.0, *)) {
                        result = result.mutableCopy;
                    }
                }
                return result;
            };
        });
        
        if (@available(iOS 13.0, *)) {
            if (ZGUICMIActivated && AdjustScrollIndicatorInsetsByContentInsetAdjustment) {
                OverrideImplementation([UIScrollView class], @selector(setContentInsetAdjustmentBehavior:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^(UIScrollView *selfObject, UIScrollViewContentInsetAdjustmentBehavior firstArgv) {
                        
                        // call super
                        void (*originSelectorIMP)(id, SEL, UIScrollViewContentInsetAdjustmentBehavior);
                        originSelectorIMP = (void (*)(id, SEL, UIScrollViewContentInsetAdjustmentBehavior))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD, firstArgv);
                        
                        if (firstArgv == UIScrollViewContentInsetAdjustmentNever) {
                            selfObject.automaticallyAdjustsScrollIndicatorInsets = NO;
                        } else {
                            selfObject.automaticallyAdjustsScrollIndicatorInsets = YES;
                        }
                    };
                });
            }
        }
    });
}

- (BOOL)zgui_alreadyAtTop {
    if (((NSInteger)self.contentOffset.y) == -((NSInteger)self.zgui_contentInset.top)) {
        return YES;
    }
    
    return NO;
}

- (BOOL)zgui_alreadyAtBottom {
    if (!self.zgui_canScroll) {
        return YES;
    }
    
    if (((NSInteger)self.contentOffset.y) == ((NSInteger)self.contentSize.height + self.zgui_contentInset.bottom - CGRectGetHeight(self.bounds))) {
        return YES;
    }
    
    return NO;
}

- (UIEdgeInsets)zgui_contentInset {
    if (@available(iOS 11, *)) {
        return self.adjustedContentInset;
    } else {
        return self.contentInset;
    }
}

static char kAssociatedObjectKey_initialContentInset;
- (void)setQmui_initialContentInset:(UIEdgeInsets)zgui_initialContentInset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_initialContentInset, [NSValue valueWithUIEdgeInsets:zgui_initialContentInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.contentInset = zgui_initialContentInset;
    self.scrollIndicatorInsets = zgui_initialContentInset;
    if (!self.zguiscroll_hasSetInitialContentInset || !self.zgui_viewController || self.zgui_viewController.zgui_visibleState < ZGUIViewControllerDidAppear) {
        [self zgui_scrollToTopUponContentInsetTopChange];
    }
    self.zguiscroll_hasSetInitialContentInset = YES;
}

- (UIEdgeInsets)zgui_initialContentInset {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_initialContentInset)) UIEdgeInsetsValue];
}

- (BOOL)zgui_canScroll {
    // 没有高度就不用算了，肯定不可滚动，这里只是做个保护
    if (CGSizeIsEmpty(self.bounds.size)) {
        return NO;
    }
    BOOL canVerticalScroll = self.contentSize.height + UIEdgeInsetsGetVerticalValue(self.zgui_contentInset) > CGRectGetHeight(self.bounds);
    BOOL canHorizontalScoll = self.contentSize.width + UIEdgeInsetsGetHorizontalValue(self.zgui_contentInset) > CGRectGetWidth(self.bounds);
    return canVerticalScroll || canHorizontalScoll;
}

- (void)zgui_scrollToTopForce:(BOOL)force animated:(BOOL)animated {
    if (force || (!force && [self zgui_canScroll])) {
        [self setContentOffset:CGPointMake(-self.zgui_contentInset.left, -self.zgui_contentInset.top) animated:animated];
    }
}

- (void)zgui_scrollToTopAnimated:(BOOL)animated {
    [self zgui_scrollToTopForce:NO animated:animated];
}

- (void)zgui_scrollToTop {
    [self zgui_scrollToTopAnimated:NO];
}

- (void)zgui_scrollToTopUponContentInsetTopChange {
    if (self.zguiscroll_lastInsetTopWhenScrollToTop != self.contentInset.top) {
        [self zgui_scrollToTop];
        self.zguiscroll_lastInsetTopWhenScrollToTop = self.contentInset.top;
    }
}

- (void)zgui_scrollToBottomAnimated:(BOOL)animated {
    if ([self zgui_canScroll]) {
        [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentSize.height + self.zgui_contentInset.bottom - CGRectGetHeight(self.bounds)) animated:animated];
    }
}

- (void)zgui_scrollToBottom {
    [self zgui_scrollToBottomAnimated:NO];
}

- (void)zgui_stopDeceleratingIfNeeded {
    if (self.decelerating) {
        [self setContentOffset:self.contentOffset animated:NO];
    }
}

- (void)zgui_setContentInset:(UIEdgeInsets)contentInset animated:(BOOL)animated {
    [UIView zgui_animateWithAnimated:animated duration:.25 delay:0 options:ZGUIViewAnimationOptionsCurveOut animations:^{
        self.contentInset = contentInset;
    } completion:nil];
}

@end
