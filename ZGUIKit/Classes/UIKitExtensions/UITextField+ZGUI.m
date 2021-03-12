/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UITextField+ZGUI.m
//  zgui
//
//  Created by ZGUI Team on 2017/3/29.
//

#import "UITextField+ZGUI.h"
#import "NSObject+ZGUI.h"
#import "ZGUICore.h"
#import "UIImage+ZGUI.h"

@implementation UITextField (ZGUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // iOS 12 及以下版本需要重写该方法才能替换
        if (@available(iOS 13.0, *)) {
        } else {
            OverrideImplementation([UITextField class], NSSelectorFromString(@"_clearButtonImageForState:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UIImage *(UITextField *selfObject, UIControlState firstArgv) {
                    
                    if (selfObject.zgui_clearButtonImage) {
                        if (firstArgv & UIControlStateHighlighted) {
                            return [selfObject.zgui_clearButtonImage zgui_imageWithAlpha:UIControlHighlightedAlpha];
                        }
                        return selfObject.zgui_clearButtonImage;
                    }
                    
                    // call super
                    UIImage *(*originSelectorIMP)(id, SEL, UIControlState);
                    originSelectorIMP = (UIImage *(*)(id, SEL, UIControlState))originalIMPProvider();
                    UIImage *result = originSelectorIMP(selfObject, originCMD, firstArgv);
                    return result;
                };
            });
        }
    });
}

- (NSRange)zgui_selectedRange {
    NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:self.selectedTextRange.start];
    NSInteger length = [self offsetFromPosition:self.selectedTextRange.start toPosition:self.selectedTextRange.end];
    return NSMakeRange(location, length);
}

- (UIButton *)zgui_clearButton {
    return [self zgui_valueForKey:@"clearButton"];
}

// - (id) _clearButtonImageForState:(unsigned long)arg1;
static char kAssociatedObjectKey_clearButtonImage;
- (void)setZgui_clearButtonImage:(UIImage *)zgui_clearButtonImage {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_clearButtonImage, zgui_clearButtonImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.zgui_clearButton setImage:zgui_clearButtonImage forState:UIControlStateNormal];
    // 如果当前 clearButton 正在显示的时候把自定义图片去掉，需要重新 layout 一次才能让系统默认图片显示出来
    if (!zgui_clearButtonImage) {
        [self setNeedsLayout];
    }
}

- (UIImage *)zgui_clearButtonImage {
    return (UIImage *)objc_getAssociatedObject(self, &kAssociatedObjectKey_clearButtonImage);
}

- (NSRange)zgui_convertNSRangeFromUITextRange:(UITextRange *)textRange {
    NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:textRange.start];
    NSInteger length = [self offsetFromPosition:textRange.start toPosition:textRange.end];
    return NSMakeRange(location, length);
}

- (UITextRange *)zgui_convertUITextRangeFromNSRange:(NSRange)range {
    if (range.location == NSNotFound || NSMaxRange(range) > self.text.length) {
        return nil;
    }
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:beginning offset:NSMaxRange(range)];
    return [self textRangeFromPosition:startPosition toPosition:endPosition];
}

@end
