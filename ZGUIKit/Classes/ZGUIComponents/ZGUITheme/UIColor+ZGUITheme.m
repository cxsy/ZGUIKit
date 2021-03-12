/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UIColor+ZGUITheme.m
//  ZGUIKit
//
//  Created by MoLice on 2019/J/20.
//

#import "UIColor+ZGUITheme.h"
#import "ZGUIThemeManager.h"
#import "ZGUICore.h"
#import "NSMethodSignature+ZGUI.h"
#import "UIColor+ZGUI.h"
#import "ZGUIThemePrivate.h"
#import "ZGUIThemeManagerCenter.h"

@implementation ZGUIThemeColor

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 随着 iOS 版本的迭代，需要不断检查 UIDynamicColor 对比 UIColor 多出来的方法是哪些，然后在 ZGUIThemeColor 里补齐，否则可能出现”unrecognized selector sent to instance“的 crash
        // https://github.com/Tencent/QMUI_iOS/issues/791
#ifdef DEBUG
        if (@available(iOS 13.0, *)) {
            Class dynamicColorClass = NSClassFromString(@"UIDynamicColor");
            NSMutableSet<NSString *> *unrecognizedSelectors = NSMutableSet.new;
            NSDictionary<NSString *, NSMutableSet<NSString *> *> *methods = @{
                NSStringFromClass(UIColor.class): NSMutableSet.new,
                NSStringFromClass(dynamicColorClass): NSMutableSet.new,
                NSStringFromClass(self): NSMutableSet.new
            };
            [methods enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull classString, NSMutableSet<NSString *> * _Nonnull methods, BOOL * _Nonnull stop) {
                [NSObject zgui_enumrateInstanceMethodsOfClass:NSClassFromString(classString) includingInherited:NO usingBlock:^(Method  _Nonnull method, SEL  _Nonnull selector) {
                    [methods addObject:NSStringFromSelector(selector)];
                }];
            }];
            [methods[NSStringFromClass(UIColor.class)] enumerateObjectsUsingBlock:^(NSString * _Nonnull selectorString, BOOL * _Nonnull stop) {
                if ([methods[NSStringFromClass(dynamicColorClass)] containsObject:selectorString]) {
                    [methods[NSStringFromClass(dynamicColorClass)] removeObject:selectorString];
                }
            }];
            [methods[NSStringFromClass(dynamicColorClass)] enumerateObjectsUsingBlock:^(NSString * _Nonnull selectorString, BOOL * _Nonnull stop) {
                if (![methods[NSStringFromClass(self)] containsObject:selectorString]) {
                    [unrecognizedSelectors addObject:selectorString];
                }
            }];
            if (unrecognizedSelectors.count > 0) {
//                ZGUILogWarn(NSStringFromClass(self), @"%@ 还需要实现以下方法：%@", NSStringFromClass(self), unrecognizedSelectors);
            }
        }
#endif
    });
}

#pragma mark - Override

- (void)set {
    [self.zgui_rawColor set];
}

- (void)setFill {
    [self.zgui_rawColor setFill];
}

- (void)setStroke {
    [self.zgui_rawColor setStroke];
}

- (BOOL)getWhite:(CGFloat *)white alpha:(CGFloat *)alpha {
    return [self.zgui_rawColor getWhite:white alpha:alpha];
}

- (BOOL)getHue:(CGFloat *)hue saturation:(CGFloat *)saturation brightness:(CGFloat *)brightness alpha:(CGFloat *)alpha {
    return [self.zgui_rawColor getHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

- (BOOL)getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha {
    return [self.zgui_rawColor getRed:red green:green blue:blue alpha:alpha];
}

- (UIColor *)colorWithAlphaComponent:(CGFloat)alpha {
    return [UIColor zgui_colorWithThemeProvider:^UIColor * _Nonnull(__kindof ZGUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme) {
        return [self.themeProvider(manager, identifier, theme) colorWithAlphaComponent:alpha];
    }];
}

- (CGFloat)alphaComponent {
    return self.zgui_rawColor.zgui_alpha;
}

- (CGColorRef)CGColor {
    CGColorRef colorRef = [UIColor colorWithCGColor:self.zgui_rawColor.CGColor].CGColor;
    [(__bridge id)(colorRef) zgui_bindObject:self forKey:ZGUICGColorOriginalColorBindKey];
    return colorRef;
}

- (NSString *)colorSpaceName {
    return [((ZGUIThemeColor *)self.zgui_rawColor) colorSpaceName];
}

- (id)copyWithZone:(NSZone *)zone {
    ZGUIThemeColor *color = [[self class] allocWithZone:zone];
    color.managerName = self.managerName;
    color.themeProvider = self.themeProvider;
    return color;
}

- (BOOL)isEqual:(id)object {
    return self == object;// 例如在 UIView setTintColor: 时会比较两个 color 是否相等，如果相等，则不会触发 tintColor 的更新。由于 dynamicColor 实际的返回色值随时可能变化，所以即便当前的 zgui_rawColor 值相等，也不应该认为两个 dynamicColor 相等（有可能 themeProvider block 内的逻辑不一致，只是其中的某个条件下 return 的 zgui_rawColor 恰好相同而已），所以这里直接返回 NO。
}

- (NSUInteger)hash {
    return (NSUInteger)self.themeProvider;// 与 UIDynamicProviderColor 相同
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, zgui_rawColor = %@", [super description], self.zgui_rawColor];
}

- (UIColor *)_highContrastDynamicColor {
    return self;
}

- (UIColor *)_resolvedColorWithTraitCollection:(UITraitCollection *)traitCollection {
    return self.zgui_rawColor;
}

#pragma mark - <ZGUIDynamicColorProtocol>

@dynamic zgui_isDynamicColor;

- (UIColor *)zgui_rawColor {
    ZGUIThemeManager *manager = [ZGUIThemeManagerCenter themeManagerWithName:self.managerName];
    UIColor *color = self.themeProvider(manager, manager.currentThemeIdentifier, manager.currentTheme);
    UIColor *result = color.zgui_rawColor;
    return result;
}

- (BOOL)zgui_isZGUIDynamicColor {
    return YES;
}

// _isDynamic 是系统私有的方法，实现它有两个作用：
// 1. 在某些方法里（例如 UIView.backgroundColor），系统会判断当前的 color 是否为 _isDynamic，如果是，则返回 color 本身，如果否，则返回 color 的 CGColor，因此如果 ZGUIThemeColor 不实现 _isDynamic 的话，`a.backgroundColor = b.backgroundColor`这种写法就会出错，因为从 `b.backgroundColor` 获取到的 color 已经是用 CGColor 重新创建的系统 UIColor，而非 ZGUIThemeColor 了。
// 2. 当 iOS 13 系统设置里的 Dark Mode 发生切换时，系统会自动刷新带有 _isDynamic 方法的 color 对象，当然这个对 ZGUI 而言作用不大，因为 ZGUIThemeManager 有自己一套刷新逻辑，且很少有人会用 ZGUIThemeColor 但却只依赖于 iOS 13 系统来刷新界面。
// 注意，ZGUIThemeColor 是 UIColor 的直接子类，只有这种关系才能这样直接定义并重写，不能在 UIColor Category 里定义，否则可能污染 UIDynamicColor 里的 _isDynamic 的实现
- (BOOL)_isDynamic {
    return !!self.themeProvider;
}

@end

@implementation UIColor (ZGUITheme)

+ (instancetype)zgui_colorWithThemeProvider:(UIColor * _Nonnull (^)(__kindof ZGUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    return [self zgui_colorWithThemeManagerName:ZGUIThemeManagerNameDefault provider:provider];
}

+ (UIColor *)zgui_colorWithThemeManagerName:(__kindof NSObject<NSCopying> *)name provider:(UIColor * _Nonnull (^)(__kindof ZGUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    ZGUIThemeColor *color = ZGUIThemeColor.new;
    color.managerName = name;
    color.themeProvider = provider;
    return color;
}

@end
