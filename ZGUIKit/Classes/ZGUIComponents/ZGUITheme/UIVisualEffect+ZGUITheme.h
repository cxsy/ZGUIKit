/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UIVisualEffect+ZGUITheme.h
//  ZGUIKit
//
//  Created by MoLice on 2019/7/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZGUIThemeManager;

@protocol ZGUIDynamicEffectProtocol <NSObject>

@required

/// 获取当前 UIVisualEffect 的实际 effect（返回的 effect 必定不是 dynamic image）
@property(nonatomic, strong, readonly) __kindof UIVisualEffect *zgui_rawEffect;

/// 标志当前 UIVisualEffect 对象是否为动态 effect（由 [UIVisualEffect zgui_effectWithThemeProvider:] 创建的 effect
@property(nonatomic, assign, readonly) BOOL zgui_isDynamicEffect;

@end

@interface UIVisualEffect (ZGUITheme) <ZGUIDynamicEffectProtocol>

/**
 生成一个动态的 UIVisualEffect 对象，每次使用该对象时都会动态根据当前的 ZGUIThemeManager 主题返回对应的 effect。
 @param provider 当 UIVisualEffect 被使用时，这个 provider 会被调用，返回对应当前主题的 effect 值。请不要在这个 block 里做耗时操作。
 @return 一个动态的 UIVisualEffect 对象，被使用时才会返回实际的 effect 效果
 */
+ (UIVisualEffect *)zgui_effectWithThemeProvider:(UIVisualEffect *(^)(__kindof ZGUIThemeManager *manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme))provider;

/**
 生成一个动态的 UIVisualEffect 对象，每次使用该对象时都会动态根据当前的 ZGUIThemeManager  name 和主题返回对应的 effect。
 @param name themeManager 的 name，用于区分不同维度的主题管理器
 @param provider 当 UIVisualEffect 被使用时，这个 provider 会被调用，返回对应当前主题的 effect 值。请不要在这个 block 里做耗时操作。
 @return 一个动态的 UIVisualEffect 对象，被使用时才会返回实际的 effect 效果
*/
+ (UIVisualEffect *)zgui_effectWithThemeManagerName:(__kindof NSObject<NSCopying> *)name provider:(UIVisualEffect *(^)(__kindof ZGUIThemeManager *manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme))provider;
@end

NS_ASSUME_NONNULL_END
