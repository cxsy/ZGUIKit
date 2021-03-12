/**
* Tencent is pleased to support the open source community by making QMUI_iOS available.
* Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
* Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
* http://opensource.org/licenses/MIT
* Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

//
//  UITableViewHeaderFooterView+ZGUI.m
//  ZGUIKit
//
//  Created by MoLice on 2020/6/4.
//  Copyright © 2020 ZGUI Team. All rights reserved.
//

#import "UITableViewHeaderFooterView+ZGUI.h"
#import "ZGUICore.h"
#import "UITableView+ZGUI.h"
#import "UIView+ZGUI.h"

@implementation UITableViewHeaderFooterView (ZGUI)

- (UITableView *)zgui_tableView {
    return [self valueForKey:@"tableView"];
}

@end

@implementation UITableViewHeaderFooterView (ZGUI_InsetGrouped)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 决定 tableView 赋予 header/footer 的高度
        OverrideImplementation([UITableViewHeaderFooterView class], @selector(initWithReuseIdentifier:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UITableViewHeaderFooterView *(UITableViewHeaderFooterView *selfObject, NSString *firstArgv) {
                
                // call super
                UITableViewHeaderFooterView *(*originSelectorIMP)(id, SEL, NSString *);
                originSelectorIMP = (UITableViewHeaderFooterView * (*)(id, SEL, NSString *))originalIMPProvider();
                UITableViewHeaderFooterView *result = originSelectorIMP(selfObject, originCMD, firstArgv);
                
                // iOS 13 系统的 UITableViewHeaderFooterView sizeThatFits: 接收的宽度是整个 tableView 的宽度，内部再根据 layoutMargins 调整 contentView，而为了保证所有 iOS 版本在重写 UITableViewHeaderFooterView sizeThatFits: 时可以用相同的计算方式，这里为 iOS 13 下的子类也调整了 sizeThatFits: 宽度的值，这样子类重写时直接把参数 size.width 当成缩进后的宽度即可。
                BOOL shouldConsiderSystemClass = YES;
                if (@available(iOS 13.0, *)) {
                    shouldConsiderSystemClass = NO;
                }
                if (shouldConsiderSystemClass || selfObject.class != UITableViewHeaderFooterView.class) {
                    [ZGUIHelper executeBlock:^{
                        OverrideImplementation(selfObject.class, @selector(sizeThatFits:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                            return ^CGSize(UITableViewHeaderFooterView *view, CGSize size) {
                                
                                BOOL shouldChangeWidth = view.zgui_tableView && view.zgui_tableView.zgui_style == ZGUITableViewStyleInsetGrouped;
                                if (shouldChangeWidth) {
                                    size.width = size.width - UIEdgeInsetsGetHorizontalValue(view.zgui_tableView.zgui_safeAreaInsets) - view.zgui_tableView.zgui_insetGroupedHorizontalInset * 2;
                                }
                                
                                // call super
                                CGSize (*originSelectorIMP)(id, SEL, CGSize);
                                originSelectorIMP = (CGSize (*)(id, SEL, CGSize))originalIMPProvider();
                                CGSize result = originSelectorIMP(view, originCMD, size);
                                
                                return result;
                            };
                        });
                    } oncePerIdentifier:[NSString stringWithFormat:@"InsetGroupedHeader %@-%@", NSStringFromClass(selfObject.class), NSStringFromSelector(@selector(sizeThatFits:))]];
                }
                
                return result;
            };
        });
        
        // iOS 13 都交给系统处理，下面的逻辑不需要
        if (@available(iOS 13.0, *)) return;
        
        if (@available(iOS 11.0, *)) {
            // 系统通过这个方法返回值来决定 contentView 的布局
            OverrideImplementation([UITableViewHeaderFooterView class], NSSelectorFromString(@"_contentRectForWidth:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^CGRect(UITableViewHeaderFooterView *selfObject, CGFloat firstArgv) {
                    BOOL shouldChangeWidth = firstArgv > 0 && selfObject.zgui_tableView && selfObject.zgui_tableView.zgui_style == ZGUITableViewStyleInsetGrouped;
                    if (shouldChangeWidth) {
                        firstArgv -= UIEdgeInsetsGetHorizontalValue(selfObject.zgui_tableView.zgui_safeAreaInsets) + selfObject.zgui_tableView.zgui_insetGroupedHorizontalInset * 2;
                    }
                    
                    // call super
                    CGRect (*originSelectorIMP)(id, SEL, CGFloat);
                    originSelectorIMP = (CGRect (*)(id, SEL, CGFloat))originalIMPProvider();
                    CGRect result = originSelectorIMP(selfObject, originCMD, firstArgv);
                    
                    if (shouldChangeWidth) {
                        result = CGRectSetX(result, selfObject.zgui_tableView.zgui_safeAreaInsets.left + selfObject.zgui_tableView.zgui_insetGroupedHorizontalInset);
                    }
                    return result;
                };
            });
        } else {
            // TODO: molice iOS 10 及以下是另一套实现方式，暂时不知道怎么修改 textLabel 的布局
            OverrideImplementation([UITableViewHeaderFooterView class], @selector(layoutSubviews), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UITableViewHeaderFooterView *selfObject) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD);
                    
                    if (selfObject.zgui_tableView && selfObject.zgui_tableView.zgui_style == ZGUITableViewStyleInsetGrouped) {
                        selfObject.contentView.frame = CGRectMake(selfObject.zgui_tableView.zgui_safeAreaInsets.left + selfObject.zgui_tableView.zgui_insetGroupedHorizontalInset, CGRectGetMinY(selfObject.contentView.frame), selfObject.zgui_tableView.zgui_validContentWidth, CGRectGetHeight(selfObject.bounds));
                    }
                };
            });
        }
    });
}

@end
