/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UITableViewCell+ZGUI.m
//  ZGUIKit
//
//  Created by ZGUI Team on 2018/7/5.
//

#import "UITableViewCell+ZGUI.h"
#import "ZGUICore.h"
#import "UIView+ZGUI.h"
#import "UITableView+ZGUI.h"
#import "CALayer+ZGUI.h"

const UIEdgeInsets ZGUITableViewCellSeparatorInsetsNone = {INFINITY, INFINITY, INFINITY, INFINITY};

@interface UITableViewCell ()

@property(nonatomic, strong) CALayer *zguiTbc_separatorLayer;
@property(nonatomic, strong) CALayer *zguiTbc_topSeparatorLayer;
@end

@implementation UITableViewCell (ZGUI)

ZGUISynthesizeNSIntegerProperty(zgui_style, setZgui_style)
ZGUISynthesizeIdStrongProperty(zguiTbc_separatorLayer, setZguiTbc_separatorLayer)
ZGUISynthesizeIdStrongProperty(zguiTbc_topSeparatorLayer, setZguiTbc_topSeparatorLayer)
ZGUISynthesizeIdCopyProperty(zgui_separatorInsetsBlock, setZgui_separatorInsetsBlock)
ZGUISynthesizeIdCopyProperty(zgui_topSeparatorInsetsBlock, setZgui_topSeparatorInsetsBlock)
ZGUISynthesizeIdCopyProperty(zgui_setHighlightedBlock, setZgui_setHighlightedBlock)
ZGUISynthesizeIdCopyProperty(zgui_setSelectedBlock, setZgui_setSelectedBlock)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UITableViewCell class], @selector(initWithStyle:reuseIdentifier:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UITableViewCell *(UITableViewCell *selfObject, UITableViewCellStyle firstArgv, NSString *secondArgv) {
                // call super
                UITableViewCell *(*originSelectorIMP)(id, SEL, UITableViewCellStyle, NSString *);
                originSelectorIMP = (UITableViewCell *(*)(id, SEL, UITableViewCellStyle, NSString *))originalIMPProvider();
                UITableViewCell *result = originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);
                
                // 系统虽然有私有 API - (UITableViewCellStyle)style; 可以用，但该方法在 init 内得到的永远是 0，只有 init 执行完成后才可以得到正确的值，所以这里只能自己记录
                result.zgui_style = firstArgv;
                return result;
            };
        });
        ExtendImplementationOfVoidMethodWithTwoArguments([UITableViewCell class], @selector(setHighlighted:animated:), BOOL, BOOL, ^(UITableViewCell *selfObject, BOOL highlighted, BOOL animated) {
            if (selfObject.zgui_setHighlightedBlock) {
                selfObject.zgui_setHighlightedBlock(highlighted, animated);
            }
        });
        
        ExtendImplementationOfVoidMethodWithTwoArguments([UITableViewCell class], @selector(setSelected:animated:), BOOL, BOOL, ^(UITableViewCell *selfObject, BOOL selected, BOOL animated) {
            if (selfObject.zgui_setSelectedBlock) {
                selfObject.zgui_setSelectedBlock(selected, animated);
            }
        });
        
        // 修复 iOS 13.0 UIButton 作为 cell.accessoryView 时布局错误的问题
        // https://github.com/Tencent/QMUI_iOS/issues/693
        if (@available(iOS 13.0, *)) {
            if (@available(iOS 13.1, *)) {
            } else {
                ExtendImplementationOfVoidMethodWithoutArguments([UITableViewCell class], @selector(layoutSubviews), ^(UITableViewCell *selfObject) {
                    if ([selfObject.accessoryView isKindOfClass:[UIButton class]]) {
                        CGFloat defaultRightMargin = 15 + SafeAreaInsetsConstantForDeviceWithNotch.right;
                        selfObject.accessoryView.zgui_left = selfObject.zgui_width - defaultRightMargin - selfObject.accessoryView.zgui_width;
                        selfObject.accessoryView.zgui_top = CGRectGetMinYVerticallyCenterInParentRect(selfObject.frame, selfObject.accessoryView.frame);;
                        selfObject.contentView.zgui_right = selfObject.accessoryView.zgui_left;
                    }
                });
            }
        }
    });
}

static char kAssociatedObjectKey_cellPosition;
- (void)setZgui_cellPosition:(ZGUITableViewCellPosition)zgui_cellPosition {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_cellPosition, @(zgui_cellPosition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    BOOL shouldShowSeparatorInTableView = self.zgui_tableView && self.zgui_tableView.separatorStyle != UITableViewCellSeparatorStyleNone;
    if (shouldShowSeparatorInTableView) {
        [self zguiTbc_createSeparatorLayerIfNeeded];
        [self zguiTbc_createTopSeparatorLayerIfNeeded];
    }
}

- (ZGUITableViewCellPosition)zgui_cellPosition {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_cellPosition)) integerValue];
}

- (void)zguiTbc_swizzleLayoutSubviews {
    [ZGUIHelper executeBlock:^{
        ExtendImplementationOfVoidMethodWithoutArguments(self.class, @selector(layoutSubviews), ^(UITableViewCell *cell) {
            if (cell.zguiTbc_separatorLayer && !cell.zguiTbc_separatorLayer.hidden) {
                UIEdgeInsets insets = cell.zgui_separatorInsetsBlock(cell.zgui_tableView, cell);
                CGRect frame = CGRectZero;
                if (!UIEdgeInsetsEqualToEdgeInsets(insets, ZGUITableViewCellSeparatorInsetsNone)) {
                    CGFloat height = PixelOne;
                    frame = CGRectMake(insets.left, CGRectGetHeight(cell.bounds) - height + insets.top - insets.bottom, MAX(0, CGRectGetWidth(cell.bounds) - UIEdgeInsetsGetHorizontalValue(insets)), height);
                }
                cell.zguiTbc_separatorLayer.frame = frame;
            }
            
            if (cell.zguiTbc_topSeparatorLayer && !cell.zguiTbc_topSeparatorLayer.hidden) {
                UIEdgeInsets insets = cell.zgui_topSeparatorInsetsBlock(cell.zgui_tableView, cell);
                CGRect frame = CGRectZero;
                if (!UIEdgeInsetsEqualToEdgeInsets(insets, ZGUITableViewCellSeparatorInsetsNone)) {
                    CGFloat height = PixelOne;
                    frame = CGRectMake(insets.left, insets.top - insets.bottom, MAX(0, CGRectGetWidth(cell.bounds) - UIEdgeInsetsGetHorizontalValue(insets)), height);
                }
                cell.zguiTbc_topSeparatorLayer.frame = frame;
            }
        });
    } oncePerIdentifier:[NSString stringWithFormat:@"UITableViewCell %@-%@", NSStringFromClass(self.class), NSStringFromSelector(@selector(layoutSubviews))]];
}

- (BOOL)zguiTbc_customizedSeparator {
    return !!self.zgui_separatorInsetsBlock;
}

- (BOOL)zguiTbc_customizedTopSeparator {
    return !!self.zgui_topSeparatorInsetsBlock;
}

- (void)zguiTbc_createSeparatorLayerIfNeeded {
    if (![self zguiTbc_customizedSeparator]) {
        self.zguiTbc_separatorLayer.hidden = YES;
        return;
    }
    
    BOOL shouldShowSeparator = !UIEdgeInsetsEqualToEdgeInsets(self.zgui_separatorInsetsBlock(self.zgui_tableView, self), ZGUITableViewCellSeparatorInsetsNone);
    if (shouldShowSeparator) {
        if (!self.zguiTbc_separatorLayer) {
            [self zguiTbc_swizzleLayoutSubviews];
            self.zguiTbc_separatorLayer = [CALayer layer];
            [self.zguiTbc_separatorLayer zgui_removeDefaultAnimations];
            [self.layer addSublayer:self.zguiTbc_separatorLayer];
        }
        self.zguiTbc_separatorLayer.backgroundColor = self.zgui_tableView.separatorColor.CGColor;
        self.zguiTbc_separatorLayer.hidden = NO;
    } else {
        if (self.zguiTbc_separatorLayer) {
            self.zguiTbc_separatorLayer.hidden = YES;
        }
    }
}

- (void)zguiTbc_createTopSeparatorLayerIfNeeded {
    if (![self zguiTbc_customizedTopSeparator]) {
        self.zguiTbc_topSeparatorLayer.hidden = YES;
        return;
    }
    
    BOOL shouldShowSeparator = !UIEdgeInsetsEqualToEdgeInsets(self.zgui_topSeparatorInsetsBlock(self.zgui_tableView, self), ZGUITableViewCellSeparatorInsetsNone);
    if (shouldShowSeparator) {
        if (!self.zguiTbc_topSeparatorLayer) {
            [self zguiTbc_swizzleLayoutSubviews];
            self.zguiTbc_topSeparatorLayer = [CALayer layer];
            [self.zguiTbc_topSeparatorLayer zgui_removeDefaultAnimations];
            [self.layer addSublayer:self.zguiTbc_topSeparatorLayer];
        }
        self.zguiTbc_topSeparatorLayer.backgroundColor = self.zgui_tableView.separatorColor.CGColor;
        self.zguiTbc_topSeparatorLayer.hidden = NO;
    } else {
        if (self.zguiTbc_topSeparatorLayer) {
            self.zguiTbc_topSeparatorLayer.hidden = YES;
        }
    }
}

- (UITableView *)zgui_tableView {
    return [self valueForKey:@"tableView"];
}

static char kAssociatedObjectKey_selectedBackgroundColor;
- (void)setZgui_selectedBackgroundColor:(UIColor *)zgui_selectedBackgroundColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_selectedBackgroundColor, zgui_selectedBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (zgui_selectedBackgroundColor) {
        // 系统默认的 selectedBackgroundView 是 UITableViewCellSelectedBackground，无法修改自定义背景色，所以改为用普通的 UIView
        if ([NSStringFromClass(self.selectedBackgroundView.class) hasPrefix:@"UITableViewCell"]) {
            self.selectedBackgroundView = [[UIView alloc] init];
        }
        self.selectedBackgroundView.backgroundColor = zgui_selectedBackgroundColor;
    }
}

- (UIColor *)zgui_selectedBackgroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_selectedBackgroundColor);
}

- (UIView *)zgui_accessoryView {
    if (self.editing) {
        if (self.editingAccessoryView) {
            return self.editingAccessoryView;
        }
        return [self zgui_valueForKey:@"_editingAccessoryView"];
    }
    if (self.accessoryView) {
        return self.accessoryView;
    }
    
    // UITableViewCellAccessoryDetailDisclosureButton 在 iOS 13 及以上是分开的两个 accessoryView，以 NSSet 的形式存在这个私有接口里。而 iOS 12 及以下是以一个 UITableViewCellDetailDisclosureView 的 UIControl 存在。
    if (@available(iOS 13.0, *)) {
        NSSet<UIView *> *accessoryViews = [self zgui_valueForKey:@"_existingSystemAccessoryViews"];
        if ([accessoryViews isKindOfClass:NSSet.class] && accessoryViews.count) {
            UIView *leftView = nil;
            for (UIView *accessoryView in accessoryViews) {
                if (!leftView) {
                    leftView = accessoryView;
                    continue;
                }
                if (CGRectGetMinX(accessoryView.frame) < CGRectGetMinX(leftView.frame)) {
                    leftView = accessoryView;
                }
            }
            return leftView;
        }
        return nil;
    }
    return [self zgui_valueForKey:@"_accessoryView"];
}

@end

@implementation UITableViewCell (ZGUI_Styled)

- (void)zgui_styledAsZGUITableViewCell {
    if (!ZGUICMIActivated) return;
    
    self.textLabel.font = UIFontMake(16);
    self.textLabel.backgroundColor = UIColorClear;
    UIColor *textLabelColor = self.zgui_styledTextLabelColor;
    if (textLabelColor) {
        self.textLabel.textColor = textLabelColor;
    }
    
    self.detailTextLabel.font = UIFontMake(15);
    self.detailTextLabel.backgroundColor = UIColorClear;
    UIColor *detailLabelColor = self.zgui_styledDetailTextLabelColor;
    if (detailLabelColor) {
        self.detailTextLabel.textColor = detailLabelColor;
    }
    
    UIColor *backgroundColor = self.zgui_styledBackgroundColor;
    if (backgroundColor) {
        self.backgroundColor = backgroundColor;
    }
    
    UIColor *selectedBackgroundColor = self.zgui_styledSelectedBackgroundColor;
    if (selectedBackgroundColor) {
        self.zgui_selectedBackgroundColor = selectedBackgroundColor;
    }
}

- (UIColor *)zgui_styledTextLabelColor {
    return PreferredValueForTableViewStyle(self.zgui_tableView.zgui_style, TableViewCellTitleLabelColor, TableViewGroupedCellTitleLabelColor, TableViewInsetGroupedCellTitleLabelColor);
}

- (UIColor *)zgui_styledDetailTextLabelColor {
    return PreferredValueForTableViewStyle(self.zgui_tableView.zgui_style, TableViewCellDetailLabelColor, TableViewGroupedCellDetailLabelColor, TableViewInsetGroupedCellDetailLabelColor);
}

- (UIColor *)zgui_styledBackgroundColor {
    return PreferredValueForTableViewStyle(self.zgui_tableView.zgui_style, TableViewCellBackgroundColor, TableViewGroupedCellBackgroundColor, TableViewInsetGroupedCellBackgroundColor);
}

- (UIColor *)zgui_styledSelectedBackgroundColor {
    return PreferredValueForTableViewStyle(self.zgui_tableView.zgui_style, TableViewCellSelectedBackgroundColor, TableViewGroupedCellSelectedBackgroundColor, TableViewInsetGroupedCellSelectedBackgroundColor);
}

- (UIColor *)zgui_styledWarningBackgroundColor {
    return PreferredValueForTableViewStyle(self.zgui_tableView.zgui_style, TableViewCellWarningBackgroundColor, TableViewGroupedCellWarningBackgroundColor, TableViewInsetGroupedCellWarningBackgroundColor);
}

@end

@implementation UITableViewCell (ZGUI_InsetGrouped)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        OverrideImplementation([UITableViewCell class], NSSelectorFromString(@"_separatorFrame"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGRect(UITableViewCell *selfObject) {
                
                if ([selfObject zguiTbc_customizedSeparator]) {
                    return CGRectZero;
                }
                
                // iOS 13 自己会控制好 InsetGrouped 时不同 cellPosition 的分隔线显隐，iOS 12 及以下要全部手动处理
                if (@available(iOS 13.0, *)) {
                } else {
                    if (selfObject.zgui_tableView && selfObject.zgui_tableView.zgui_style == ZGUITableViewStyleInsetGrouped && (selfObject.zgui_cellPosition & ZGUITableViewCellPositionLastInSection) == ZGUITableViewCellPositionLastInSection) {
                        return CGRectZero;
                    }
                }
                
                // call super
                CGRect (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (CGRect (*)(id, SEL))originalIMPProvider();
                CGRect result = originSelectorIMP(selfObject, originCMD);
                return result;
            };
        });
        
        OverrideImplementation([UITableViewCell class], NSSelectorFromString(@"_topSeparatorFrame"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGRect(UITableViewCell *selfObject) {
                
                if ([selfObject zguiTbc_customizedTopSeparator]) {
                    return CGRectZero;
                }
                
                if (@available(iOS 13.0, *)) {
                } else {
                    // iOS 13 系统在 InsetGrouped 时默认就会隐藏顶部分隔线，所以这里只对 iOS 12 及以下处理
                    if (selfObject.zgui_tableView && selfObject.zgui_tableView.zgui_style == ZGUITableViewStyleInsetGrouped) {
                        return CGRectZero;
                    }
                }
                
                
                // call super
                CGRect (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (CGRect (*)(id, SEL))originalIMPProvider();
                CGRect result = originSelectorIMP(selfObject, originCMD);
                return result;
            };
        });
        
        // 下方的功能，iOS 13 都交给系统的 InsetGrouped 处理
        if (@available(iOS 13.0, *)) return;
        
        OverrideImplementation([UITableViewCell class], @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITableViewCell *selfObject, CGRect firstArgv) {
                
                UITableView *tableView = selfObject.zgui_tableView;
                if (tableView && tableView.zgui_style == ZGUITableViewStyleInsetGrouped) {
                    firstArgv = CGRectMake(tableView.zgui_safeAreaInsets.left + tableView.zgui_insetGroupedHorizontalInset, CGRectGetMinY(firstArgv), CGRectGetWidth(firstArgv) - UIEdgeInsetsGetHorizontalValue(tableView.zgui_safeAreaInsets) - tableView.zgui_insetGroupedHorizontalInset * 2, CGRectGetHeight(firstArgv));
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
        
        // 将缩进后的宽度传给 cell 的 sizeThatFits:，注意 sizeThatFits: 只有在 tableView 开启 self-sizing 的情况下才会被调用（也即高度被指定为 UITableViewAutomaticDimension）
        // TODO: molice 系统的 UITableViewCell 第一次布局总是得到错误的高度，不知道为什么
        OverrideImplementation([UITableViewCell class], @selector(systemLayoutSizeFittingSize:withHorizontalFittingPriority:verticalFittingPriority:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGSize(UITableViewCell *selfObject, CGSize targetSize, UILayoutPriority horizontalFittingPriority, UILayoutPriority verticalFittingPriority) {
                
                UITableView *tableView = selfObject.zgui_tableView;
                if (tableView && tableView.zgui_style == ZGUITableViewStyleInsetGrouped) {
                    [ZGUIHelper executeBlock:^{
                        OverrideImplementation(selfObject.class, @selector(sizeThatFits:), ^id(__unsafe_unretained Class originClass, SEL cellOriginCMD, IMP (^cellOriginalIMPProvider)(void)) {
                            return ^CGSize(UITableViewCell *cell, CGSize firstArgv) {
                                
                                UITableView *tableView = cell.zgui_tableView;
                                if (tableView && tableView.zgui_style == ZGUITableViewStyleInsetGrouped) {
                                    firstArgv.width = firstArgv.width - UIEdgeInsetsGetHorizontalValue(tableView.zgui_safeAreaInsets) - tableView.zgui_insetGroupedHorizontalInset * 2;
                                }
                                
                                // call super
                                CGSize (*originSelectorIMP)(id, SEL, CGSize);
                                originSelectorIMP = (CGSize (*)(id, SEL, CGSize))cellOriginalIMPProvider();
                                CGSize result = originSelectorIMP(cell, cellOriginCMD, firstArgv);
                                return result;
                            };
                        });
                    } oncePerIdentifier:[NSString stringWithFormat:@"InsetGroupedCell %@-%@", NSStringFromClass(selfObject.class), NSStringFromSelector(@selector(sizeThatFits:))]];
                }
                
                // call super
                CGSize (*originSelectorIMP)(id, SEL, CGSize, UILayoutPriority, UILayoutPriority);
                originSelectorIMP = (CGSize (*)(id, SEL, CGSize, UILayoutPriority, UILayoutPriority))originalIMPProvider();
                CGSize result = originSelectorIMP(selfObject, originCMD, targetSize, horizontalFittingPriority, verticalFittingPriority);
                return result;
            };
        });
    });
}

@end
