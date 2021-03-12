/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  ZGUILab.h
//  ZGUIKit
//
//  Created by MoLice on 2019/J/8.
//

#ifndef ZGUILab_h
#define ZGUILab_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "ZGUICommonDefines.h"
#import "NSNumber+ZGUI.h"
#import "ZGUIWeakObjectContainer.h"

/**
 以下系列宏用于在 Category 里添加 property 时，可以在 @implementation 里一句代码完成 getter/setter 的声明。暂不支持在 getter/setter 里添加自定义的逻辑，需要自定义的情况请继续使用 Code Snippet 生成的代码。
 使用方式：
 @code
 @interface NSObject (CategoryName)
 @property(nonatomic, strong) type *strongObj;
 @property(nonatomic, weak) type *weakObj;
 @property(nonatomic, assign) CGRect rectValue;
 @end
 
 @implementation NSObject (CategoryName)
 
 // 注意 setter 不需要带冒号
 ZGUISynthesizeIdStrongProperty(strongObj, setStrongObj)
 ZGUISynthesizeIdWeakProperty(weakObj, setWeakObj)
 ZGUISynthesizeCGRectProperty(rectValue, setRectValue)
 
 @end
 @endcode
 */

#pragma mark - Meta Marcos

#define _ZGUISynthesizeId(_getterName, _setterName, _policy) \
_Pragma("clang diagnostic push") _Pragma(ClangWarningConcat("-Wmismatched-parameter-types")) _Pragma(ClangWarningConcat("-Wmismatched-return-types"))\
static char kAssociatedObjectKey_##_getterName;\
- (void)_setterName:(id)_getterName {\
    objc_setAssociatedObject(self, &kAssociatedObjectKey_##_getterName, _getterName, OBJC_ASSOCIATION_##_policy##_NONATOMIC);\
}\
\
- (id)_getterName {\
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_##_getterName);\
}\
_Pragma("clang diagnostic pop")

#define _ZGUISynthesizeWeakId(_getterName, _setterName) \
_Pragma("clang diagnostic push") _Pragma(ClangWarningConcat("-Wmismatched-parameter-types")) _Pragma(ClangWarningConcat("-Wmismatched-return-types"))\
static char kAssociatedObjectKey_##_getterName;\
- (void)_setterName:(id)_getterName {\
    objc_setAssociatedObject(self, &kAssociatedObjectKey_##_getterName, [[ZGUIWeakObjectContainer alloc] initWithObject:_getterName], OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}\
\
- (id)_getterName {\
    return ((ZGUIWeakObjectContainer *)objc_getAssociatedObject(self, &kAssociatedObjectKey_##_getterName)).object;\
}\
_Pragma("clang diagnostic pop")

#define _ZGUISynthesizeNonObject(_getterName, _setterName, _type, valueInitializer, valueGetter) \
_Pragma("clang diagnostic push") _Pragma(ClangWarningConcat("-Wmismatched-parameter-types")) _Pragma(ClangWarningConcat("-Wmismatched-return-types"))\
static char kAssociatedObjectKey_##_getterName;\
- (void)_setterName:(_type)_getterName {\
    objc_setAssociatedObject(self, &kAssociatedObjectKey_##_getterName, [NSNumber valueInitializer:_getterName], OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}\
\
- (_type)_getterName {\
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_##_getterName)) valueGetter];\
}\
_Pragma("clang diagnostic pop")




#pragma mark - Object Marcos

/// @property(nonatomic, strong) id xxx
#define ZGUISynthesizeIdStrongProperty(_getterName, _setterName) _ZGUISynthesizeId(_getterName, _setterName, RETAIN)

/// @property(nonatomic, weak) id xxx
#define ZGUISynthesizeIdWeakProperty(_getterName, _setterName) _ZGUISynthesizeWeakId(_getterName, _setterName)

/// @property(nonatomic, copy) id xxx
#define ZGUISynthesizeIdCopyProperty(_getterName, _setterName) _ZGUISynthesizeId(_getterName, _setterName, COPY)



#pragma mark - NonObject Marcos

/// @property(nonatomic, assign) Int xxx
#define ZGUISynthesizeIntProperty(_getterName, _setterName) _ZGUISynthesizeNonObject(_getterName, _setterName, int, numberWithInt, intValue)

/// @property(nonatomic, assign) unsigned int xxx
#define ZGUISynthesizeUnsignedIntProperty(_getterName, _setterName) _ZGUISynthesizeNonObject(_getterName, _setterName, unsigned int, numberWithUnsignedInt, unsignedIntValue)

/// @property(nonatomic, assign) float xxx
#define ZGUISynthesizeFloatProperty(_getterName, _setterName) _ZGUISynthesizeNonObject(_getterName, _setterName, float, numberWithFloat, floatValue)

/// @property(nonatomic, assign) double xxx
#define ZGUISynthesizeDoubleProperty(_getterName, _setterName) _ZGUISynthesizeNonObject(_getterName, _setterName, double, numberWithDouble, doubleValue)

/// @property(nonatomic, assign) BOOL xxx
#define ZGUISynthesizeBOOLProperty(_getterName, _setterName) _ZGUISynthesizeNonObject(_getterName, _setterName, BOOL, numberWithBool, boolValue)

/// @property(nonatomic, assign) NSInteger xxx
#define ZGUISynthesizeNSIntegerProperty(_getterName, _setterName) _ZGUISynthesizeNonObject(_getterName, _setterName, NSInteger, numberWithInteger, integerValue)

/// @property(nonatomic, assign) NSUInteger xxx
#define ZGUISynthesizeNSUIntegerProperty(_getterName, _setterName) _ZGUISynthesizeNonObject(_getterName, _setterName, NSUInteger, numberWithUnsignedInteger, unsignedIntegerValue)

/// @property(nonatomic, assign) CGFloat xxx
#define ZGUISynthesizeCGFloatProperty(_getterName, _setterName) _ZGUISynthesizeNonObject(_getterName, _setterName, CGFloat, numberWithDouble, zgui_CGFloatValue)

/// @property(nonatomic, assign) CGPoint xxx
#define ZGUISynthesizeCGPointProperty(_getterName, _setterName) _ZGUISynthesizeNonObject(_getterName, _setterName, CGPoint, valueWithCGPoint, CGPointValue)

/// @property(nonatomic, assign) CGSize xxx
#define ZGUISynthesizeCGSizeProperty(_getterName, _setterName) _ZGUISynthesizeNonObject(_getterName, _setterName, CGSize, valueWithCGSize, CGSizeValue)

/// @property(nonatomic, assign) CGRect xxx
#define ZGUISynthesizeCGRectProperty(_getterName, _setterName) _ZGUISynthesizeNonObject(_getterName, _setterName, CGRect, valueWithCGRect, CGRectValue)

/// @property(nonatomic, assign) UIEdgeInsets xxx
#define ZGUISynthesizeUIEdgeInsetsProperty(_getterName, _setterName) _ZGUISynthesizeNonObject(_getterName, _setterName, UIEdgeInsets, valueWithUIEdgeInsets, UIEdgeInsetsValue)

/// @property(nonatomic, assign) CGVector xxx
#define ZGUISynthesizeCGVectorProperty(_getterName, _setterName) _ZGUISynthesizeNonObject(_getterName, _setterName, CGVector, valueWithCGVector, CGVectorValue)

/// @property(nonatomic, assign) CGAffineTransform xxx
#define ZGUISynthesizeCGAffineTransformProperty(_getterName, _setterName) _ZGUISynthesizeNonObject(_getterName, _setterName, CGAffineTransform, valueWithCGAffineTransform, CGAffineTransformValue)

/// @property(nonatomic, assign) NSDirectionalEdgeInsets xxx
#define ZGUISynthesizeNSDirectionalEdgeInsetsProperty(_getterName, _setterName) _ZGUISynthesizeNonObject(_getterName, _setterName, NSDirectionalEdgeInsets, valueWithDirectionalEdgeInsets, NSDirectionalEdgeInsetsValue)

/// @property(nonatomic, assign) UIOffset xxx
#define ZGUISynthesizeUIOffsetProperty(_getterName, _setterName) _ZGUISynthesizeNonObject(_getterName, _setterName, UIOffset, valueWithUIOffset, UIOffsetValue)

#endif /* ZGUILab_h */
