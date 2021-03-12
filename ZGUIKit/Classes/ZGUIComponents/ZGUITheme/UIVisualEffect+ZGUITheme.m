/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UIVisualEffect+ZGUITheme.m
//  ZGUIKit
//
//  Created by MoLice on 2019/7/20.
//

#import "UIVisualEffect+ZGUITheme.h"
#import "ZGUIThemeManager.h"
#import "ZGUIThemeManagerCenter.h"
#import "ZGUIThemePrivate.h"
#import "NSMethodSignature+ZGUI.h"
#import "ZGUICore.h"

@implementation ZGUIThemeVisualEffect

- (id)copyWithZone:(NSZone *)zone {
    ZGUIThemeVisualEffect *effect = [[self class] allocWithZone:zone];
    effect.managerName = self.managerName;
    effect.themeProvider = self.themeProvider;
    return effect;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *result = [super methodSignatureForSelector:aSelector];
    if (result) {
        return result;
    }
    
    result = [self.zgui_rawEffect methodSignatureForSelector:aSelector];
    if (result && [self.zgui_rawEffect respondsToSelector:aSelector]) {
        return result;
    }
    
    return [NSMethodSignature zgui_avoidExceptionSignature];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = anInvocation.selector;
    if ([self.zgui_rawEffect respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:self.zgui_rawEffect];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    return [self.zgui_rawEffect respondsToSelector:aSelector];
}

- (BOOL)isKindOfClass:(Class)aClass {
    if (aClass == ZGUIThemeVisualEffect.class) return YES;
    return [self.zgui_rawEffect isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    if (aClass == ZGUIThemeVisualEffect.class) return YES;
    return [self.zgui_rawEffect isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [self.zgui_rawEffect conformsToProtocol:aProtocol];
}

- (NSUInteger)hash {
    return (NSUInteger)self.themeProvider;
}

- (BOOL)isEqual:(id)object {
    return NO;
}

#pragma mark - <ZGUIDynamicEffectProtocol>

- (UIVisualEffect *)zgui_rawEffect {
    ZGUIThemeManager *manager = [ZGUIThemeManagerCenter themeManagerWithName:self.managerName];
    return self.themeProvider(manager, manager.currentThemeIdentifier, manager.currentTheme).zgui_rawEffect;
}

- (BOOL)zgui_isDynamicEffect {
    return YES;
}

@end

@implementation UIVisualEffect (ZGUITheme)

+ (UIVisualEffect *)zgui_effectWithThemeProvider:(UIVisualEffect * _Nonnull (^)(__kindof ZGUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    return [UIVisualEffect zgui_effectWithThemeManagerName:ZGUIThemeManagerNameDefault provider:provider];
}

+ (UIVisualEffect *)zgui_effectWithThemeManagerName:(__kindof NSObject<NSCopying> *)name provider:(UIVisualEffect * _Nonnull (^)(__kindof ZGUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    ZGUIThemeVisualEffect *effect = [[ZGUIThemeVisualEffect alloc] init];
    effect.managerName = name;
    effect.themeProvider = provider;
    return (UIVisualEffect *)effect;
}

#pragma mark - <ZGUIDynamicEffectProtocol>

- (UIVisualEffect *)zgui_rawEffect {
    return self;
}

- (BOOL)zgui_isDynamicEffect {
    return NO;
}

@end
