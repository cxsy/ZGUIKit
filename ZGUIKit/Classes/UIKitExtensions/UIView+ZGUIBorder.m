/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIView+ZGUIBorder.m
//  ZGUIKit
//
//  Created by MoLice on 2020/6/28.
//  Copyright © 2020 ZGUI Team. All rights reserved.
//

#import "UIView+ZGUIBorder.h"
#import "ZGUICore.h"
#import "CALayer+ZGUI.h"

@interface CAShapeLayer (ZGUIBorder)

@property(nonatomic, weak) UIView *_zguibd_targetBorderView;
@end

@implementation UIView (ZGUIBorder)

ZGUISynthesizeIdStrongProperty(zgui_borderLayer, setZgui_borderLayer)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIView class], @selector(initWithFrame:), CGRect, UIView *, ^UIView *(UIView *selfObject, CGRect frame, UIView *originReturnValue) {
            [selfObject _zguibd_setDefaultStyle];
            return originReturnValue;
        });
        
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIView class], @selector(initWithCoder:), NSCoder *, UIView *, ^UIView *(UIView *selfObject, NSCoder *aDecoder, UIView *originReturnValue) {
            [selfObject _zguibd_setDefaultStyle];
            return originReturnValue;
        });
    });
}

- (void)_zguibd_setDefaultStyle {
    self.zgui_borderWidth = PixelOne;
    self.zgui_borderColor = UIColorSeparator;
}

- (void)_zguibd_createBorderLayerIfNeeded {
    BOOL shouldShowBorder = self.zgui_borderWidth > 0 && self.zgui_borderColor && self.zgui_borderPosition != ZGUIViewBorderPositionNone;
    if (!shouldShowBorder) {
        self.zgui_borderLayer.hidden = YES;
        return;
    }
    
    [ZGUIHelper executeBlock:^{
        OverrideImplementation([UIView class], @selector(layoutSublayersOfLayer:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CALayer *firstArgv) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, CALayer *);
                originSelectorIMP = (void (*)(id, SEL, CALayer *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                if (!selfObject.zgui_borderLayer || selfObject.zgui_borderLayer.hidden) return;
                selfObject.zgui_borderLayer.frame = selfObject.bounds;
                [selfObject.layer zgui_bringSublayerToFront:selfObject.zgui_borderLayer];
                [selfObject.zgui_borderLayer setNeedsLayout];// 把布局刷新逻辑剥离到 layer 内，方便在子线程里直接刷新 layer，如果放在 UIView 内，子线程里就无法主动请求刷新了
            };
        });
    } oncePerIdentifier:@"UIView (ZGUIBorder) layoutSublayers"];
    
    if (!self.zgui_borderLayer) {
        self.zgui_borderLayer = [CAShapeLayer layer];
        self.zgui_borderLayer._zguibd_targetBorderView = self;
        [self.zgui_borderLayer zgui_removeDefaultAnimations];
        self.zgui_borderLayer.fillColor = UIColorClear.CGColor;
        [self.layer addSublayer:self.zgui_borderLayer];
    }
    self.zgui_borderLayer.lineWidth = self.zgui_borderWidth;
    self.zgui_borderLayer.strokeColor = self.zgui_borderColor.CGColor;
    self.zgui_borderLayer.lineDashPhase = self.zgui_dashPhase;
    self.zgui_borderLayer.lineDashPattern = self.zgui_dashPattern;
    self.zgui_borderLayer.hidden = NO;
}

static char kAssociatedObjectKey_borderLocation;
- (void)setZgui_borderLocation:(ZGUIViewBorderLocation)zgui_borderLocation {
    BOOL shouldUpdateLayout = self.zgui_borderLocation != zgui_borderLocation;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderLocation, @(zgui_borderLocation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _zguibd_createBorderLayerIfNeeded];
    if (shouldUpdateLayout) {
        [self setNeedsLayout];
    }
}

- (ZGUIViewBorderLocation)zgui_borderLocation {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderLocation)) unsignedIntegerValue];
}

static char kAssociatedObjectKey_borderPosition;
- (void)setZgui_borderPosition:(ZGUIViewBorderPosition)zgui_borderPosition {
    BOOL shouldUpdateLayout = self.zgui_borderPosition != zgui_borderPosition;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderPosition, @(zgui_borderPosition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _zguibd_createBorderLayerIfNeeded];
    if (shouldUpdateLayout) {
        [self setNeedsLayout];
    }
}

- (ZGUIViewBorderPosition)zgui_borderPosition {
    return (ZGUIViewBorderPosition)[objc_getAssociatedObject(self, &kAssociatedObjectKey_borderPosition) unsignedIntegerValue];
}

static char kAssociatedObjectKey_borderWidth;
- (void)setZgui_borderWidth:(CGFloat)zgui_borderWidth {
    BOOL shouldUpdateLayout = self.zgui_borderWidth != zgui_borderWidth;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderWidth, @(zgui_borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _zguibd_createBorderLayerIfNeeded];
    if (shouldUpdateLayout) {
        [self setNeedsLayout];
    }
}

- (CGFloat)zgui_borderWidth {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderWidth)) zgui_CGFloatValue];
}

static char kAssociatedObjectKey_borderColor;
- (void)setZgui_borderColor:(UIColor *)zgui_borderColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderColor, zgui_borderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _zguibd_createBorderLayerIfNeeded];
    [self setNeedsLayout];
}

- (UIColor *)zgui_borderColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderColor);
}

static char kAssociatedObjectKey_dashPhase;
- (void)setZgui_dashPhase:(CGFloat)zgui_dashPhase {
    BOOL shouldUpdateLayout = self.zgui_dashPhase != zgui_dashPhase;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPhase, @(zgui_dashPhase), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _zguibd_createBorderLayerIfNeeded];
    if (shouldUpdateLayout) {
        [self setNeedsLayout];
    }
}

- (CGFloat)zgui_dashPhase {
    return [(NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPhase) zgui_CGFloatValue];
}

static char kAssociatedObjectKey_dashPattern;
- (void)setZgui_dashPattern:(NSArray<NSNumber *> *)zgui_dashPattern {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPattern, zgui_dashPattern, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _zguibd_createBorderLayerIfNeeded];
    [self setNeedsLayout];
}

- (NSArray *)zgui_dashPattern {
    return (NSArray<NSNumber *> *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPattern);
}

@end

@implementation CAShapeLayer (ZGUIBorder)
ZGUISynthesizeIdWeakProperty(_zguibd_targetBorderView, set_zguibd_targetBorderView)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithoutArguments([CAShapeLayer class], @selector(layoutSublayers), ^(CAShapeLayer *selfObject) {
            if (!selfObject._zguibd_targetBorderView) return;
            
            UIView *view = selfObject._zguibd_targetBorderView;
            CGFloat borderWidth = selfObject.lineWidth;
            
            UIBezierPath *path = [UIBezierPath bezierPath];;
            
            CGFloat (^adjustsLocation)(CGFloat, CGFloat, CGFloat) = ^CGFloat(CGFloat inside, CGFloat center, CGFloat outside) {
                return view.zgui_borderLocation == ZGUIViewBorderLocationInside ? inside : (view.zgui_borderLocation == ZGUIViewBorderLocationCenter ? center : outside);
            };
            
            CGFloat lineOffset = adjustsLocation(borderWidth / 2.0, 0, -borderWidth / 2.0); // 为了像素对齐而做的偏移
            CGFloat lineCapOffset = adjustsLocation(0, borderWidth / 2.0, borderWidth); // 两条相邻的边框连接的位置
            
            BOOL shouldShowTopBorder = (view.zgui_borderPosition & ZGUIViewBorderPositionTop) == ZGUIViewBorderPositionTop;
            BOOL shouldShowLeftBorder = (view.zgui_borderPosition & ZGUIViewBorderPositionLeft) == ZGUIViewBorderPositionLeft;
            BOOL shouldShowBottomBorder = (view.zgui_borderPosition & ZGUIViewBorderPositionBottom) == ZGUIViewBorderPositionBottom;
            BOOL shouldShowRightBorder = (view.zgui_borderPosition & ZGUIViewBorderPositionRight) == ZGUIViewBorderPositionRight;
            
            UIBezierPath *topPath = [UIBezierPath bezierPath];
            UIBezierPath *leftPath = [UIBezierPath bezierPath];
            UIBezierPath *bottomPath = [UIBezierPath bezierPath];
            UIBezierPath *rightPath = [UIBezierPath bezierPath];
            
            if (view.layer.zgui_originCornerRadius > 0) {
                
                CGFloat cornerRadius = view.layer.zgui_originCornerRadius;
                
                if (view.layer.zgui_maskedCorners) {
                    if ((view.layer.zgui_maskedCorners & ZGUILayerMinXMinYCorner) == ZGUILayerMinXMinYCorner) {
                        [topPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.25 * M_PI endAngle:1.5 * M_PI clockwise:YES];
                        [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, lineOffset)];
                        [leftPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:-0.75 * M_PI endAngle:-1 * M_PI clockwise:NO];
                        [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) - cornerRadius)];
                    } else {
                        [topPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, lineOffset)];
                        [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, lineOffset)];
                        [leftPath moveToPoint:CGPointMake(lineOffset, shouldShowTopBorder ? -lineCapOffset : 0)];
                        [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) - cornerRadius)];
                    }
                    if ((view.layer.zgui_maskedCorners & ZGUILayerMinXMaxYCorner) == ZGUILayerMinXMaxYCorner) {
                        [leftPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1 * M_PI endAngle:-1.25 * M_PI clockwise:NO];
                        [bottomPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.25 * M_PI endAngle:-1.5 * M_PI clockwise:NO];
                        [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - lineOffset)];
                    } else {
                        [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                        CGFloat y = CGRectGetHeight(selfObject.bounds) - lineOffset;
                        [bottomPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, y)];
                        [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, y)];
                    }
                    if ((view.layer.zgui_maskedCorners & ZGUILayerMaxXMaxYCorner) == ZGUILayerMaxXMaxYCorner) {
                        [bottomPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.5 * M_PI endAngle:-1.75 * M_PI clockwise:NO];
                        [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.75 * M_PI endAngle:-2 * M_PI clockwise:NO];
                        [rightPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - lineOffset, cornerRadius)];
                    } else {
                        CGFloat y = CGRectGetHeight(selfObject.bounds) - lineOffset;
                        [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), y)];
                        CGFloat x = CGRectGetWidth(selfObject.bounds) - lineOffset;
                        [rightPath moveToPoint:CGPointMake(x, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                        [rightPath addLineToPoint:CGPointMake(x, cornerRadius)];
                    }
                    if ((view.layer.zgui_maskedCorners & ZGUILayerMaxXMinYCorner) == ZGUILayerMaxXMinYCorner) {
                        [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:0 * M_PI endAngle:-0.25 * M_PI clockwise:NO];
                        [topPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.5 * M_PI endAngle:1.75 * M_PI clockwise:YES];
                    } else {
                        CGFloat x = CGRectGetWidth(selfObject.bounds) - lineOffset;
                        [rightPath addLineToPoint:CGPointMake(x, shouldShowTopBorder ? -lineCapOffset : 0)];
                        [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), lineOffset)];
                    }
                } else {
                    [topPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.25 * M_PI endAngle:1.5 * M_PI clockwise:YES];
                    [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, lineOffset)];
                    [topPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.5 * M_PI endAngle:1.75 * M_PI clockwise:YES];
                    
                    [leftPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:-0.75 * M_PI endAngle:-1 * M_PI clockwise:NO];
                    [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) - cornerRadius)];
                    [leftPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1 * M_PI endAngle:-1.25 * M_PI clockwise:NO];
                    
                    [bottomPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.25 * M_PI endAngle:-1.5 * M_PI clockwise:NO];
                    [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - lineOffset)];
                    [bottomPath addArcWithCenter:CGPointMake(CGRectGetHeight(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.5 * M_PI endAngle:-1.75 * M_PI clockwise:NO];
                    
                    [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.75 * M_PI endAngle:-2 * M_PI clockwise:NO];
                    [rightPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - lineOffset, cornerRadius)];
                    [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:0 * M_PI endAngle:-0.25 * M_PI clockwise:NO];
                }
                
            } else {
                [topPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, lineOffset)];
                [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), lineOffset)];
                
                [leftPath moveToPoint:CGPointMake(lineOffset, shouldShowTopBorder ? -lineCapOffset : 0)];
                [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                
                CGFloat y = CGRectGetHeight(selfObject.bounds) - lineOffset;
                [bottomPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, y)];
                [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), y)];
                
                CGFloat x = CGRectGetWidth(selfObject.bounds) - lineOffset;
                [rightPath moveToPoint:CGPointMake(x, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                [rightPath addLineToPoint:CGPointMake(x, shouldShowTopBorder ? -lineCapOffset : 0)];
            }
            
            if (shouldShowTopBorder && ![topPath isEmpty]) {
                [path appendPath:topPath];
            }
            if (shouldShowLeftBorder && ![leftPath isEmpty]) {
                [path appendPath:leftPath];
            }
            if (shouldShowBottomBorder && ![bottomPath isEmpty]) {
                [path appendPath:bottomPath];
            }
            if (shouldShowRightBorder && ![rightPath isEmpty]) {
                [path appendPath:rightPath];
            }
            
            selfObject.path = path.CGPath;
        });
    });
}
@end
