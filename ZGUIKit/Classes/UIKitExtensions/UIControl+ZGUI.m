/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIControl+ZGUI.m
//  zgui
//
//  Created by ZGUI Team on 15/7/20.
//

#import "UIControl+ZGUI.h"
#import "ZGUICore.h"

@interface UIControl ()

@property(nonatomic,assign) BOOL zguictl_canSetHighlighted;
@property(nonatomic,assign) NSInteger zguictl_touchEndCount;
@end

@implementation UIControl (ZGUI)

ZGUISynthesizeBOOLProperty(zguictl_canSetHighlighted, setZguictl_canSetHighlighted)
ZGUISynthesizeNSIntegerProperty(zguictl_touchEndCount, setZguictl_touchEndCount)

#pragma mark - Automatically Adjust Touch Highlighted In ScrollView

static char kAssociatedObjectKey_automaticallyAdjustTouchHighlightedInScrollView;
- (void)setZgui_automaticallyAdjustTouchHighlightedInScrollView:(BOOL)zgui_automaticallyAdjustTouchHighlightedInScrollView {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_automaticallyAdjustTouchHighlightedInScrollView, @(zgui_automaticallyAdjustTouchHighlightedInScrollView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (zgui_automaticallyAdjustTouchHighlightedInScrollView) {
        [ZGUIHelper executeBlock:^{
            OverrideImplementation([UIControl class], @selector(touchesBegan:withEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIControl *selfObject, NSSet *touches, UIEvent *event) {
                    
                    // call super
                    void (^callSuperBlock)(void) = ^{
                        void (*originSelectorIMP)(id, SEL, NSSet *, UIEvent *);
                        originSelectorIMP = (void (*)(id, SEL, NSSet *, UIEvent *))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD, touches, event);
                    };
                    
                    selfObject.zguictl_touchEndCount = 0;
                    if (selfObject.zgui_automaticallyAdjustTouchHighlightedInScrollView) {
                        selfObject.zguictl_canSetHighlighted = YES;
                        callSuperBlock();
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            if (selfObject.zguictl_canSetHighlighted) {
                                [selfObject setHighlighted:YES];
                            }
                        });
                    } else {
                        callSuperBlock();
                    }
                };
            });
            
            OverrideImplementation([UIControl class], @selector(touchesMoved:withEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIControl *selfObject, NSSet *touches, UIEvent *event) {
                    
                    if (selfObject.zgui_automaticallyAdjustTouchHighlightedInScrollView) {
                        selfObject.zguictl_canSetHighlighted = NO;
                    }
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, NSSet *, UIEvent *);
                    originSelectorIMP = (void (*)(id, SEL, NSSet *, UIEvent *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, touches, event);
                };
            });
            
            OverrideImplementation([UIControl class], @selector(touchesEnded:withEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIControl *selfObject, NSSet *touches, UIEvent *event) {
                    
                    if (selfObject.zgui_automaticallyAdjustTouchHighlightedInScrollView) {
                        selfObject.zguictl_canSetHighlighted = NO;
                        if (selfObject.touchInside) {
                            [selfObject setHighlighted:YES];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                // 如果延迟时间太长，会导致快速点击两次，事件会触发两次
                                // 对于 3D Touch 的机器，如果点击按钮的时候在按钮上停留事件稍微长一点点，那么 touchesEnded 会被调用两次
                                // 把 super touchEnded 放到延迟里调用会导致长按无法触发点击，先这么改，再想想怎么办。// [selfObject zgui_touchesEnded:touches withEvent:event];
                                [selfObject sendActionsForAllTouchEventsIfCan];
                                if (selfObject.highlighted) {
                                    [selfObject setHighlighted:NO];
                                }
                            });
                        } else {
                            [selfObject setHighlighted:NO];
                        }
                        return;
                    }
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, NSSet *, UIEvent *);
                    originSelectorIMP = (void (*)(id, SEL, NSSet *, UIEvent *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, touches, event);
                };
            });
            
            OverrideImplementation([UIControl class], @selector(touchesCancelled:withEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIControl *selfObject, NSSet *touches, UIEvent *event) {
                    
                    // call super
                    void (^callSuperBlock)(void) = ^{
                        void (*originSelectorIMP)(id, SEL, NSSet *, UIEvent *);
                        originSelectorIMP = (void (*)(id, SEL, NSSet *, UIEvent *))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD, touches, event);
                    };
                    
                    if (selfObject.zgui_automaticallyAdjustTouchHighlightedInScrollView) {
                        selfObject.zguictl_canSetHighlighted = NO;
                        callSuperBlock();
                        if (selfObject.highlighted) {
                            [selfObject setHighlighted:NO];
                        }
                        return;
                    }
                    callSuperBlock();
                };
            });
        } oncePerIdentifier:@"UIControl automaticallyAdjustTouchHighlightedInScrollView"];
    }
}

- (BOOL)zgui_automaticallyAdjustTouchHighlightedInScrollView {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_automaticallyAdjustTouchHighlightedInScrollView)) boolValue];
}

// 这段代码需要以一个独立的方法存在，因为一旦有坑，外面可以直接通过runtime调用这个方法
// 但，不要开放到.h文件里，理论上外面不应该用到它
- (void)sendActionsForAllTouchEventsIfCan {
    self.zguictl_touchEndCount += 1;
    if (self.zguictl_touchEndCount == 1) {
        [self sendActionsForControlEvents:UIControlEventAllTouchEvents];
    }
}

#pragma mark - Prevents Repeated TouchUpInside Event

static char kAssociatedObjectKey_preventsRepeatedTouchUpInsideEvent;
- (void)setZgui_preventsRepeatedTouchUpInsideEvent:(BOOL)zgui_preventsRepeatedTouchUpInsideEvent {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_preventsRepeatedTouchUpInsideEvent, @(zgui_preventsRepeatedTouchUpInsideEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (zgui_preventsRepeatedTouchUpInsideEvent) {
        [ZGUIHelper executeBlock:^{
            
            OverrideImplementation([UIControl class], @selector(sendAction:to:forEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIControl *selfObject, SEL action, id target, UIEvent *event) {
                    
                    if (selfObject.zgui_preventsRepeatedTouchUpInsideEvent) {
                        NSArray<NSString *> *actions = [selfObject actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
                        if (!actions) {
                            // iOS 10 UIBarButtonItem 里的 UINavigationButton 点击事件用的是 UIControlEventPrimaryActionTriggered
                            actions = [selfObject actionsForTarget:target forControlEvent:UIControlEventPrimaryActionTriggered];
                        }
                        if ([actions containsObject:NSStringFromSelector(action)]) {
                            UITouch *touch = event.allTouches.anyObject;
                            if (touch.tapCount > 1) {
                                return;
                            }
                        }
                    }
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, SEL, id, UIEvent *);
                    originSelectorIMP = (void (*)(id, SEL, SEL, id, UIEvent *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, action, target, event);
                };
            });
        } oncePerIdentifier:@"UIControl preventsRepeatedTouchUpInsideEvent"];
    }
}

- (BOOL)zgui_preventsRepeatedTouchUpInsideEvent {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_preventsRepeatedTouchUpInsideEvent)) boolValue];
}

#pragma mark - Highlighted Block

static char kAssociatedObjectKey_setHighlightedBlock;
- (void)setZgui_setHighlightedBlock:(void (^)(BOOL))zgui_setHighlightedBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_setHighlightedBlock, zgui_setHighlightedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (zgui_setHighlightedBlock) {
        [ZGUIHelper executeBlock:^{
            ExtendImplementationOfVoidMethodWithSingleArgument([UIControl class], @selector(setHighlighted:), BOOL, ^(UIControl *selfObject, BOOL highlighted) {
                if (selfObject.zgui_setHighlightedBlock) {
                    selfObject.zgui_setHighlightedBlock(highlighted);
                }
            });
        } oncePerIdentifier:@"UIControl setHighlighted:"];
    }
}

- (void (^)(BOOL))zgui_setHighlightedBlock {
    return (void (^)(BOOL))objc_getAssociatedObject(self, &kAssociatedObjectKey_setHighlightedBlock);
}

#pragma mark - Tap Block

static char kAssociatedObjectKey_tapBlock;
- (void)setZgui_tapBlock:(void (^)(__kindof UIControl *))zgui_tapBlock {
    if (zgui_tapBlock) {
        [ZGUIHelper executeBlock:^{
            OverrideImplementation([UIControl class], @selector(removeTarget:action:forControlEvents:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIControl *selfObject, id target, SEL action, UIControlEvents controlEvents) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, id, SEL, UIControlEvents);
                    originSelectorIMP = (void (*)(id, SEL, id, SEL, UIControlEvents))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, target, action, controlEvents);
                    
                    BOOL isTouchUpInsideEvent = controlEvents & UIControlEventTouchUpInside;
                    BOOL shouldRemoveTouchUpInsideSelector = (action == @selector(zgui_handleTouchUpInside:)) || (target == selfObject && !action) || (!target && !action);
                    if (isTouchUpInsideEvent && shouldRemoveTouchUpInsideSelector) {
                        // 避免触发 setter 又反过来 removeTarget，然后就死循环了
                        objc_setAssociatedObject(selfObject, &kAssociatedObjectKey_tapBlock, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
                    }
                };
            });
        } oncePerIdentifier:@"UIControl tapBlock"];
    }
    
    SEL action = @selector(zgui_handleTouchUpInside:);
    if (!zgui_tapBlock) {
        [self removeTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    }
    objc_setAssociatedObject(self, &kAssociatedObjectKey_tapBlock, zgui_tapBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof UIControl *))zgui_tapBlock {
    return (void (^)(__kindof UIControl *))objc_getAssociatedObject(self, &kAssociatedObjectKey_tapBlock);
}

- (void)zgui_handleTouchUpInside:(__kindof UIControl *)sender {
    if (self.zgui_tapBlock) {
        self.zgui_tapBlock(self);
    }
}

@end
