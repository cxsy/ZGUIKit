/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIFont+ZGUI.m
//  zgui
//
//  Created by ZGUI Team on 15/7/20.
//

#import "UIFont+ZGUI.h"
#import "ZGUICore.h"

@implementation UIFont (ZGUI)

+ (UIFont *)zgui_lightSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont systemFontOfSize:fontSize weight:UIFontWeightLight];
}

+ (UIFont *)zgui_systemFontOfSize:(CGFloat)size weight:(ZGUIFontWeight)weight italic:(BOOL)italic {
    UIFont *font = nil;
    font = [UIFont systemFontOfSize:size weight:weight == ZGUIFontWeightLight ? UIFontWeightLight : (weight == ZGUIFontWeightBold ? UIFontWeightSemibold : UIFontWeightRegular)];
    if (!italic) {
        return font;
    }
    
    UIFontDescriptor *fontDescriptor = font.fontDescriptor;
    UIFontDescriptorSymbolicTraits trait = fontDescriptor.symbolicTraits;
    trait |= UIFontDescriptorTraitItalic;
    fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:trait];
    font = [UIFont fontWithDescriptor:fontDescriptor size:0];
    return font;
}

+ (UIFont *)zgui_dynamicSystemFontOfSize:(CGFloat)size weight:(ZGUIFontWeight)weight italic:(BOOL)italic {
    return [self zgui_dynamicSystemFontOfSize:size upperLimitSize:size + 5 lowerLimitSize:0 weight:weight italic:italic];
}

+ (UIFont *)zgui_dynamicSystemFontOfSize:(CGFloat)pointSize
                          upperLimitSize:(CGFloat)upperLimitSize
                          lowerLimitSize:(CGFloat)lowerLimitSize
                                  weight:(ZGUIFontWeight)weight
                                  italic:(BOOL)italic {
    
    // 计算出 body 类型比默认的大小要变化了多少，然后在 pointSize 的基础上叠加这个变化
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    CGFloat offsetPointSize = font.pointSize - 17;// default UIFontTextStyleBody fontSize is 17
    CGFloat finalPointSize = pointSize + offsetPointSize;
    finalPointSize = MAX(MIN(finalPointSize, upperLimitSize), lowerLimitSize);
    font = [UIFont zgui_systemFontOfSize:finalPointSize weight:weight italic:NO];
    
    return font;
}

@end
