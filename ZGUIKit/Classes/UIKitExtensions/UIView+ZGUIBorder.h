/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIView+ZGUIBorder.h
//  ZGUIKit
//
//  Created by MoLice on 2020/6/28.
//  Copyright © 2020 ZGUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, ZGUIViewBorderPosition) {
    ZGUIViewBorderPositionNone      = 0,
    ZGUIViewBorderPositionTop       = 1 << 0,
    ZGUIViewBorderPositionLeft      = 1 << 1,
    ZGUIViewBorderPositionBottom    = 1 << 2,
    ZGUIViewBorderPositionRight     = 1 << 3
};

typedef NS_ENUM(NSUInteger, ZGUIViewBorderLocation) {
    ZGUIViewBorderLocationInside,
    ZGUIViewBorderLocationCenter,
    ZGUIViewBorderLocationOutside
};

/**
*  UIView (ZGUIBorder) 为 UIView 方便地显示某几个方向上的边框。
*
*  系统的默认实现里，要为 UIView 加边框一般是通过 view.layer 来实现，view.layer 会给四条边都加上边框，如果你只想为其中某几条加上边框就很麻烦，于是 UIView (ZGUIBorder) 提供了 zgui_borderPosition 来解决这个问题。
*  @warning 注意如果你需要为 UIView 四条边都加上边框，请使用系统默认的 view.layer 来实现，而不要用 UIView (ZGUIBorder)，会浪费资源，这也是为什么 ZGUIViewBorderPosition 不提供一个 ZGUIViewBorderPositionAll 枚举值的原因。
*/
@interface UIView (ZGUIBorder)

/// 设置边框的位置，默认为 ZGUIViewBorderLocationInside，与 view.layer.border 一致。
@property(nonatomic, assign) ZGUIViewBorderLocation zgui_borderLocation;

/// 设置边框类型，支持组合，例如：`borderPosition = ZGUIViewBorderPositionTop|ZGUIViewBorderPositionBottom`。默认为 ZGUIViewBorderPositionNone。
@property(nonatomic, assign) ZGUIViewBorderPosition zgui_borderPosition;

/// 边框的大小，默认为PixelOne。请注意修改 zgui_borderPosition 的值以将边框显示出来。
@property(nonatomic, assign) IBInspectable CGFloat zgui_borderWidth;

/// 边框的颜色，默认为UIColorSeparator。请注意修改 zgui_borderPosition 的值以将边框显示出来。
@property(nullable, nonatomic, strong) IBInspectable UIColor *zgui_borderColor;

/// 虚线 : dashPhase默认是0，且当dashPattern设置了才有效
/// zgui_dashPhase 表示虚线起始的偏移，zgui_dashPattern 可以传一个数组，表示“lineWidth，lineSpacing，lineWidth，lineSpacing...”的顺序，至少传 2 个。
@property(nonatomic, assign) CGFloat zgui_dashPhase;
@property(nullable, nonatomic, copy) NSArray<NSNumber *> *zgui_dashPattern;

/// border的layer
@property(nullable, nonatomic, strong) CAShapeLayer *zgui_borderLayer;

@end

NS_ASSUME_NONNULL_END
