/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  ZGUIConfigurationMacros.h
//  zgui
//
//  Created by ZGUI Team on 14-7-2.
//

#import "ZGUIConfiguration.h"


/**
 *  提供一系列方便书写的宏，以便在代码里读取配置表的各种属性。
 *  @warning 请不要在 + load 方法里调用 BDECUIConfigurationTemplate 或 ZGUIConfigurationMacros 提供的宏，那个时机太早，可能导致 crash
 *  @waining 维护时，如果需要增加一个宏，则需要定义一个新的 ZGUIConfiguration 属性。
 */


// 单例的宏

#define ZGUICMI ({[[ZGUIConfiguration sharedInstance] applyInitialTemplate];[ZGUIConfiguration sharedInstance];})

/// 标志当前项目是否正使用配置表功能
#define ZGUICMIActivated            [ZGUICMI active]

#pragma mark - Global Color

// 基础颜色
#define UIColorClear                [ZGUICMI clearColor]
#define UIColorWhite                [ZGUICMI whiteColor]
#define UIColorBlack                [ZGUICMI blackColor]
#define UIColorGray                 [ZGUICMI grayColor]
#define UIColorGrayDarken           [ZGUICMI grayDarkenColor]
#define UIColorGrayLighten          [ZGUICMI grayLightenColor]
#define UIColorRed                  [ZGUICMI redColor]
#define UIColorGreen                [ZGUICMI greenColor]
#define UIColorBlue                 [ZGUICMI blueColor]
#define UIColorYellow               [ZGUICMI yellowColor]

// 功能颜色
#define UIColorLink                 [ZGUICMI linkColor]                       // 全局统一文字链接颜色
#define UIColorDisabled             [ZGUICMI disabledColor]                   // 全局统一文字disabled颜色
#define UIColorForBackground        [ZGUICMI backgroundColor]                 // 全局统一的背景色
#define UIColorMask                 [ZGUICMI maskDarkColor]                   // 全局统一的mask背景色
#define UIColorMaskWhite            [ZGUICMI maskLightColor]                  // 全局统一的mask背景色，白色
#define UIColorSeparator            [ZGUICMI separatorColor]                  // 全局分隔线颜色
#define UIColorSeparatorDashed      [ZGUICMI separatorDashedColor]            // 全局分隔线颜色（虚线）
#define UIColorPlaceholder          [ZGUICMI placeholderColor]                // 全局的输入框的placeholder颜色

// 测试用的颜色
#define UIColorTestRed              [ZGUICMI testColorRed]
#define UIColorTestGreen            [ZGUICMI testColorGreen]
#define UIColorTestBlue             [ZGUICMI testColorBlue]

// 可操作的控件
#pragma mark - UIControl

#define UIControlHighlightedAlpha       [ZGUICMI controlHighlightedAlpha]          // 一般control的Highlighted透明值
#define UIControlDisabledAlpha          [ZGUICMI controlDisabledAlpha]             // 一般control的Disable透明值

// 按钮
#pragma mark - UIButton
#define ButtonHighlightedAlpha          [ZGUICMI buttonHighlightedAlpha]           // 按钮Highlighted状态的透明度
#define ButtonDisabledAlpha             [ZGUICMI buttonDisabledAlpha]              // 按钮Disabled状态的透明度
#define ButtonTintColor                 [ZGUICMI buttonTintColor]                  // 普通按钮的颜色

#define GhostButtonColorBlue            [ZGUICMI ghostButtonColorBlue]              // ZGUIGhostButtonColorBlue的颜色
#define GhostButtonColorRed             [ZGUICMI ghostButtonColorRed]               // ZGUIGhostButtonColorRed的颜色
#define GhostButtonColorGreen           [ZGUICMI ghostButtonColorGreen]             // ZGUIGhostButtonColorGreen的颜色
#define GhostButtonColorGray            [ZGUICMI ghostButtonColorGray]              // ZGUIGhostButtonColorGray的颜色
#define GhostButtonColorWhite           [ZGUICMI ghostButtonColorWhite]             // ZGUIGhostButtonColorWhite的颜色

#define FillButtonColorBlue             [ZGUICMI fillButtonColorBlue]              // ZGUIFillButtonColorBlue的颜色
#define FillButtonColorRed              [ZGUICMI fillButtonColorRed]               // ZGUIFillButtonColorRed的颜色
#define FillButtonColorGreen            [ZGUICMI fillButtonColorGreen]             // ZGUIFillButtonColorGreen的颜色
#define FillButtonColorGray             [ZGUICMI fillButtonColorGray]              // ZGUIFillButtonColorGray的颜色
#define FillButtonColorWhite            [ZGUICMI fillButtonColorWhite]             // ZGUIFillButtonColorWhite的颜色

#pragma mark - TextInput
#define TextFieldTextColor              [ZGUICMI textFieldTextColor]               // ZGUITextField、ZGUITextView 的文字颜色
#define TextFieldTintColor              [ZGUICMI textFieldTintColor]               // ZGUITextField、ZGUITextView 的tintColor
#define TextFieldTextInsets             [ZGUICMI textFieldTextInsets]              // ZGUITextField 的内边距
#define KeyboardAppearance              [ZGUICMI keyboardAppearance]

#pragma mark - UISwitch
#define SwitchOnTintColor               [ZGUICMI switchOnTintColor]                 // UISwitch 打开时的背景色（除了圆点外的其他颜色）
#define SwitchOffTintColor              [ZGUICMI switchOffTintColor]                // UISwitch 关闭时的背景色（除了圆点外的其他颜色）
#define SwitchTintColor                 [ZGUICMI switchTintColor]                   // UISwitch 关闭时的周围边框颜色
#define SwitchThumbTintColor            [ZGUICMI switchThumbTintColor]              // UISwitch 中间的操控圆点的颜色

#pragma mark - NavigationBar

#define NavBarContainerClasses                          [ZGUICMI navBarContainerClasses]
#define NavBarHighlightedAlpha                          [ZGUICMI navBarHighlightedAlpha]
#define NavBarDisabledAlpha                             [ZGUICMI navBarDisabledAlpha]
#define NavBarButtonFont                                [ZGUICMI navBarButtonFont]
#define NavBarButtonFontBold                            [ZGUICMI navBarButtonFontBold]
#define NavBarBackgroundImage                           [ZGUICMI navBarBackgroundImage]
#define NavBarShadowImage                               [ZGUICMI navBarShadowImage]
#define NavBarShadowImageColor                          [ZGUICMI navBarShadowImageColor]
#define NavBarBarTintColor                              [ZGUICMI navBarBarTintColor]
#define NavBarStyle                                     [ZGUICMI navBarStyle]
#define NavBarTintColor                                 [ZGUICMI navBarTintColor]
#define NavBarTitleColor                                [ZGUICMI navBarTitleColor]
#define NavBarTitleFont                                 [ZGUICMI navBarTitleFont]
#define NavBarLargeTitleColor                           [ZGUICMI navBarLargeTitleColor]
#define NavBarLargeTitleFont                            [ZGUICMI navBarLargeTitleFont]
#define NavBarBarBackButtonTitlePositionAdjustment      [ZGUICMI navBarBackButtonTitlePositionAdjustment]
#define NavBarBackIndicatorImage                        [ZGUICMI navBarBackIndicatorImage]
#define SizeNavBarBackIndicatorImageAutomatically       [ZGUICMI sizeNavBarBackIndicatorImageAutomatically]
#define NavBarCloseButtonImage                          [ZGUICMI navBarCloseButtonImage]

#define NavBarLoadingMarginRight                        [ZGUICMI navBarLoadingMarginRight]                          // titleView里左边的loading的右边距
#define NavBarAccessoryViewMarginLeft                   [ZGUICMI navBarAccessoryViewMarginLeft]                     // titleView里的accessoryView的左边距
#define NavBarActivityIndicatorViewStyle                [ZGUICMI navBarActivityIndicatorViewStyle]                  // titleView loading 的style
#define NavBarAccessoryViewTypeDisclosureIndicatorImage [ZGUICMI navBarAccessoryViewTypeDisclosureIndicatorImage]   // titleView上倒三角的默认图片


#pragma mark - TabBar

#define TabBarContainerClasses                          [ZGUICMI tabBarContainerClasses]
#define TabBarBackgroundImage                           [ZGUICMI tabBarBackgroundImage]
#define TabBarBarTintColor                              [ZGUICMI tabBarBarTintColor]
#define TabBarShadowImageColor                          [ZGUICMI tabBarShadowImageColor]
#define TabBarStyle                                     [ZGUICMI tabBarStyle]
#define TabBarItemTitleFont                             [ZGUICMI tabBarItemTitleFont]
#define TabBarItemTitleFontSelected                     [ZGUICMI tabBarItemTitleFontSelected]
#define TabBarItemTitleColor                            [ZGUICMI tabBarItemTitleColor]
#define TabBarItemTitleColorSelected                    [ZGUICMI tabBarItemTitleColorSelected]
#define TabBarItemImageColor                            [ZGUICMI tabBarItemImageColor]
#define TabBarItemImageColorSelected                    [ZGUICMI tabBarItemImageColorSelected]

#pragma mark - Toolbar

#define ToolBarContainerClasses                         [ZGUICMI toolBarContainerClasses]
#define ToolBarHighlightedAlpha                         [ZGUICMI toolBarHighlightedAlpha]
#define ToolBarDisabledAlpha                            [ZGUICMI toolBarDisabledAlpha]
#define ToolBarTintColor                                [ZGUICMI toolBarTintColor]
#define ToolBarTintColorHighlighted                     [ZGUICMI toolBarTintColorHighlighted]
#define ToolBarTintColorDisabled                        [ZGUICMI toolBarTintColorDisabled]
#define ToolBarBackgroundImage                          [ZGUICMI toolBarBackgroundImage]
#define ToolBarBarTintColor                             [ZGUICMI toolBarBarTintColor]
#define ToolBarShadowImageColor                         [ZGUICMI toolBarShadowImageColor]
#define ToolBarStyle                                    [ZGUICMI toolBarStyle]
#define ToolBarButtonFont                               [ZGUICMI toolBarButtonFont]


#pragma mark - SearchBar

#define SearchBarTextFieldBorderColor                   [ZGUICMI searchBarTextFieldBorderColor]
#define SearchBarTextFieldBackgroundImage               [ZGUICMI searchBarTextFieldBackgroundImage]
#define SearchBarBackgroundImage                        [ZGUICMI searchBarBackgroundImage]
#define SearchBarTintColor                              [ZGUICMI searchBarTintColor]
#define SearchBarTextColor                              [ZGUICMI searchBarTextColor]
#define SearchBarPlaceholderColor                       [ZGUICMI searchBarPlaceholderColor]
#define SearchBarFont                                   [ZGUICMI searchBarFont]
#define SearchBarSearchIconImage                        [ZGUICMI searchBarSearchIconImage]
#define SearchBarClearIconImage                         [ZGUICMI searchBarClearIconImage]
#define SearchBarTextFieldCornerRadius                  [ZGUICMI searchBarTextFieldCornerRadius]


#pragma mark - TableView / TableViewCell

#define TableViewEstimatedHeightEnabled                 [ZGUICMI tableViewEstimatedHeightEnabled]            // 是否要开启全局 UITableView 的 estimatedRow(Section/Footer)Height

#define TableViewBackgroundColor                        [ZGUICMI tableViewBackgroundColor]                   // 普通列表的背景色
#define TableSectionIndexColor                          [ZGUICMI tableSectionIndexColor]                     // 列表右边索引条的文字颜色
#define TableSectionIndexBackgroundColor                [ZGUICMI tableSectionIndexBackgroundColor]           // 列表右边索引条的背景色
#define TableSectionIndexTrackingBackgroundColor        [ZGUICMI tableSectionIndexTrackingBackgroundColor]   // 列表右边索引条按下时的背景色
#define TableViewSeparatorColor                         [ZGUICMI tableViewSeparatorColor]                    // 列表分隔线颜色

#define TableViewCellNormalHeight                       [ZGUICMI tableViewCellNormalHeight]                  // ZGUITableView 的默认 cell 高度
#define TableViewCellTitleLabelColor                    [ZGUICMI tableViewCellTitleLabelColor]               // cell的title颜色
#define TableViewCellDetailLabelColor                   [ZGUICMI tableViewCellDetailLabelColor]              // cell的detailTitle颜色
#define TableViewCellBackgroundColor                    [ZGUICMI tableViewCellBackgroundColor]               // 列表 cell 的背景色
#define TableViewCellSelectedBackgroundColor            [ZGUICMI tableViewCellSelectedBackgroundColor]       // 列表 cell 按下时的背景色
#define TableViewCellWarningBackgroundColor             [ZGUICMI tableViewCellWarningBackgroundColor]        // 列表 cell 在提醒状态下的背景色

#define TableViewCellDisclosureIndicatorImage           [ZGUICMI tableViewCellDisclosureIndicatorImage]      // 列表 cell 右边的箭头图片
#define TableViewCellCheckmarkImage                     [ZGUICMI tableViewCellCheckmarkImage]                // 列表 cell 右边的打钩checkmark
#define TableViewCellDetailButtonImage                  [ZGUICMI tableViewCellDetailButtonImage]             // 列表 cell 右边的 i 按钮
#define TableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator [ZGUICMI tableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator]   // 列表 cell 右边的 i 按钮和向右箭头之间的间距（仅当两者都使用了自定义图片并且同时显示时才生效）

#define TableViewSectionHeaderBackgroundColor           [ZGUICMI tableViewSectionHeaderBackgroundColor]
#define TableViewSectionFooterBackgroundColor           [ZGUICMI tableViewSectionFooterBackgroundColor]
#define TableViewSectionHeaderFont                      [ZGUICMI tableViewSectionHeaderFont]
#define TableViewSectionFooterFont                      [ZGUICMI tableViewSectionFooterFont]
#define TableViewSectionHeaderTextColor                 [ZGUICMI tableViewSectionHeaderTextColor]
#define TableViewSectionFooterTextColor                 [ZGUICMI tableViewSectionFooterTextColor]
#define TableViewSectionHeaderAccessoryMargins          [ZGUICMI tableViewSectionHeaderAccessoryMargins]
#define TableViewSectionFooterAccessoryMargins          [ZGUICMI tableViewSectionFooterAccessoryMargins]
#define TableViewSectionHeaderContentInset              [ZGUICMI tableViewSectionHeaderContentInset]
#define TableViewSectionFooterContentInset              [ZGUICMI tableViewSectionFooterContentInset]

#define TableViewGroupedBackgroundColor                 [ZGUICMI tableViewGroupedBackgroundColor]               // Grouped 类型的 ZGUITableView 的背景色
#define TableViewGroupedSeparatorColor                  [ZGUICMI tableViewGroupedSeparatorColor]                // Grouped 类型的 ZGUITableView 分隔线颜色
#define TableViewGroupedCellTitleLabelColor             [ZGUICMI tableViewGroupedCellTitleLabelColor]           // Grouped 类型的列表的 ZGUITableViewCell 的标题颜色
#define TableViewGroupedCellDetailLabelColor            [ZGUICMI tableViewGroupedCellDetailLabelColor]          // Grouped 类型的列表的 ZGUITableViewCell 的副标题颜色
#define TableViewGroupedCellBackgroundColor             [ZGUICMI tableViewGroupedCellBackgroundColor]           // Grouped 类型的列表的 ZGUITableViewCell 的背景色
#define TableViewGroupedCellSelectedBackgroundColor     [ZGUICMI tableViewGroupedCellSelectedBackgroundColor]   // Grouped 类型的列表的 ZGUITableViewCell 点击时的背景色
#define TableViewGroupedCellWarningBackgroundColor      [ZGUICMI tableViewGroupedCellWarningBackgroundColor]    // Grouped 类型的列表的 ZGUITableViewCell 在提醒状态下的背景色
#define TableViewGroupedSectionHeaderFont               [ZGUICMI tableViewGroupedSectionHeaderFont]
#define TableViewGroupedSectionFooterFont               [ZGUICMI tableViewGroupedSectionFooterFont]
#define TableViewGroupedSectionHeaderTextColor          [ZGUICMI tableViewGroupedSectionHeaderTextColor]
#define TableViewGroupedSectionFooterTextColor          [ZGUICMI tableViewGroupedSectionFooterTextColor]
#define TableViewGroupedSectionHeaderAccessoryMargins   [ZGUICMI tableViewGroupedSectionHeaderAccessoryMargins]
#define TableViewGroupedSectionFooterAccessoryMargins   [ZGUICMI tableViewGroupedSectionFooterAccessoryMargins]
#define TableViewGroupedSectionHeaderDefaultHeight      [ZGUICMI tableViewGroupedSectionHeaderDefaultHeight]
#define TableViewGroupedSectionFooterDefaultHeight      [ZGUICMI tableViewGroupedSectionFooterDefaultHeight]
#define TableViewGroupedSectionHeaderContentInset       [ZGUICMI tableViewGroupedSectionHeaderContentInset]
#define TableViewGroupedSectionFooterContentInset       [ZGUICMI tableViewGroupedSectionFooterContentInset]

#define TableViewInsetGroupedCornerRadius               [ZGUICMI tableViewInsetGroupedCornerRadius] // InsetGrouped 类型的 UITableView 内 cell 的圆角值
#define TableViewInsetGroupedHorizontalInset            [ZGUICMI tableViewInsetGroupedHorizontalInset] // InsetGrouped 类型的 UITableView 内的左右缩进值
#define TableViewInsetGroupedBackgroundColor            [ZGUICMI tableViewInsetGroupedBackgroundColor] // InsetGrouped 类型的 UITableView 的背景色
#define TableViewInsetGroupedSeparatorColor                  [ZGUICMI tableViewInsetGroupedSeparatorColor]                // InsetGrouped 类型的 ZGUITableView 分隔线颜色
#define TableViewInsetGroupedCellTitleLabelColor             [ZGUICMI tableViewInsetGroupedCellTitleLabelColor]           // InsetGrouped 类型的列表的 ZGUITableViewCell 的标题颜色
#define TableViewInsetGroupedCellDetailLabelColor            [ZGUICMI tableViewInsetGroupedCellDetailLabelColor]          // InsetGrouped 类型的列表的 ZGUITableViewCell 的副标题颜色
#define TableViewInsetGroupedCellBackgroundColor             [ZGUICMI tableViewInsetGroupedCellBackgroundColor]           // InsetGrouped 类型的列表的 ZGUITableViewCell 的背景色
#define TableViewInsetGroupedCellSelectedBackgroundColor     [ZGUICMI tableViewInsetGroupedCellSelectedBackgroundColor]   // InsetGrouped 类型的列表的 ZGUITableViewCell 点击时的背景色
#define TableViewInsetGroupedCellWarningBackgroundColor      [ZGUICMI tableViewInsetGroupedCellWarningBackgroundColor]    // InsetGrouped 类型的列表的 ZGUITableViewCell 在提醒状态下的背景色
#define TableViewInsetGroupedSectionHeaderFont               [ZGUICMI tableViewInsetGroupedSectionHeaderFont]
#define TableViewInsetGroupedSectionFooterFont               [ZGUICMI tableViewInsetGroupedSectionFooterFont]
#define TableViewInsetGroupedSectionHeaderTextColor          [ZGUICMI tableViewInsetGroupedSectionHeaderTextColor]
#define TableViewInsetGroupedSectionFooterTextColor          [ZGUICMI tableViewInsetGroupedSectionFooterTextColor]
#define TableViewInsetGroupedSectionHeaderAccessoryMargins   [ZGUICMI tableViewInsetGroupedSectionHeaderAccessoryMargins]
#define TableViewInsetGroupedSectionFooterAccessoryMargins   [ZGUICMI tableViewInsetGroupedSectionFooterAccessoryMargins]
#define TableViewInsetGroupedSectionHeaderDefaultHeight      [ZGUICMI tableViewInsetGroupedSectionHeaderDefaultHeight]
#define TableViewInsetGroupedSectionFooterDefaultHeight      [ZGUICMI tableViewInsetGroupedSectionFooterDefaultHeight]
#define TableViewInsetGroupedSectionHeaderContentInset       [ZGUICMI tableViewInsetGroupedSectionHeaderContentInset]
#define TableViewInsetGroupedSectionFooterContentInset       [ZGUICMI tableViewInsetGroupedSectionFooterContentInset]

#pragma mark - UIWindowLevel
#define UIWindowLevelZGUIAlertView                      [ZGUICMI windowLevelZGUIAlertView]
#define UIWindowLevelZGUIConsole                        [ZGUICMI windowLevelZGUIConsole]

#pragma mark - ZGUILog
#define ShouldPrintDefaultLog                           [ZGUICMI shouldPrintDefaultLog]
#define ShouldPrintInfoLog                              [ZGUICMI shouldPrintInfoLog]
#define ShouldPrintWarnLog                              [ZGUICMI shouldPrintWarnLog]
#define ShouldPrintZGUIWarnLogToConsole                 [ZGUICMI shouldPrintZGUIWarnLogToConsole] // 是否在出现 ZGUILogWarn 时自动把这些 log 以 ZGUIConsole 的方式显示到设备屏幕上

#pragma mark - ZGUIBadge
#define BadgeBackgroundColor                            [ZGUICMI badgeBackgroundColor]
#define BadgeTextColor                                  [ZGUICMI badgeTextColor]
#define BadgeFont                                       [ZGUICMI badgeFont]
#define BadgeContentEdgeInsets                          [ZGUICMI badgeContentEdgeInsets]
#define BadgeOffset                                     [ZGUICMI badgeOffset]
#define BadgeOffsetLandscape                            [ZGUICMI badgeOffsetLandscape]
#define BadgeCenterOffset                               [ZGUICMI badgeCenterOffset]
#define BadgeCenterOffsetLandscape                      [ZGUICMI badgeCenterOffsetLandscape]

#define UpdatesIndicatorColor                           [ZGUICMI updatesIndicatorColor]
#define UpdatesIndicatorSize                            [ZGUICMI updatesIndicatorSize]
#define UpdatesIndicatorOffset                          [ZGUICMI updatesIndicatorOffset]
#define UpdatesIndicatorOffsetLandscape                 [ZGUICMI updatesIndicatorOffsetLandscape]
#define UpdatesIndicatorCenterOffset                    [ZGUICMI updatesIndicatorCenterOffset]
#define UpdatesIndicatorCenterOffsetLandscape           [ZGUICMI updatesIndicatorCenterOffsetLandscape]

#pragma mark - Others

#define AutomaticCustomNavigationBarTransitionStyle [ZGUICMI automaticCustomNavigationBarTransitionStyle] // 界面 push/pop 时是否要自动根据两个界面的 barTintColor/backgroundImage/shadowImage 的样式差异来决定是否使用自定义的导航栏效果
#define SupportedOrientationMask                        [ZGUICMI supportedOrientationMask]          // 默认支持的横竖屏方向
#define AutomaticallyRotateDeviceOrientation            [ZGUICMI automaticallyRotateDeviceOrientation]  // 是否在界面切换或 viewController.supportedOrientationMask 发生变化时自动旋转屏幕，默认为 NO
#define StatusbarStyleLightInitially                    [ZGUICMI statusbarStyleLightInitially]      // 默认的状态栏内容是否使用白色，默认为 NO，在 iOS 13 下会自动根据是否 Dark Mode 而切换样式，iOS 12 及以前则为黑色
#define NeedsBackBarButtonItemTitle                     [ZGUICMI needsBackBarButtonItemTitle]       // 全局是否需要返回按钮的title，不需要则只显示一个返回image
#define HidesBottomBarWhenPushedInitially               [ZGUICMI hidesBottomBarWhenPushedInitially] // ZGUICommonViewController.hidesBottomBarWhenPushed 的初始值，默认为 NO，以保持与系统默认值一致，但通常建议改为 YES，因为一般只有 tabBar 首页那几个界面要求为 NO
#define PreventConcurrentNavigationControllerTransitions [ZGUICMI preventConcurrentNavigationControllerTransitions] // PreventConcurrentNavigationControllerTransitions : 自动保护 ZGUINavigationController 在上一次 push/pop 尚未结束的时候就进行下一次 push/pop 的行为，避免产生 crash
#define NavigationBarHiddenInitially                    [ZGUICMI navigationBarHiddenInitially]      // preferredNavigationBarHidden 的初始值，默认为NO
#define ShouldFixTabBarTransitionBugInIPhoneX           [ZGUICMI shouldFixTabBarTransitionBugInIPhoneX] // 是否需要自动修复 iOS 11 下，iPhone X 的设备在 push 界面时，tabBar 会瞬间往上跳的 bug
#define ShouldFixTabBarSafeAreaInsetsBug [ZGUICMI shouldFixTabBarSafeAreaInsetsBug] // 是否要对 iOS 11 及以后的版本修复当存在 UITabBar 时，UIScrollView 的 inset.bottom 可能错误的 bug（issue #218 #934），默认为 YES
#define ShouldFixSearchBarMaskViewLayoutBug             [ZGUICMI shouldFixSearchBarMaskViewLayoutBug] // 是否自动修复 UISearchController.searchBar 被当作 tableHeaderView 使用时可能出现的布局 bug(issue #950)
#define SendAnalyticsToZGUITeam                         [ZGUICMI sendAnalyticsToZGUITeam] // 是否允许在 DEBUG 模式下上报 Bundle Identifier 和 Display Name 给 ZGUI 统计用
#define DynamicPreferredValueForIPad                    [ZGUICMI dynamicPreferredValueForIPad] // 当 iPad 处于 Slide Over 或 Split View 分屏模式下，宏 `PreferredValueForXXX` 是否把 iPad 视为某种屏幕宽度近似的 iPhone 来取值。
#define IgnoreKVCAccessProhibited                       [ZGUICMI ignoreKVCAccessProhibited] // 是否全局忽略 iOS 13 对 KVC 访问 UIKit 私有属性的限制
#define AdjustScrollIndicatorInsetsByContentInsetAdjustment [ZGUICMI adjustScrollIndicatorInsetsByContentInsetAdjustment] // 当将 UIScrollView.contentInsetAdjustmentBehavior 设为 UIScrollViewContentInsetAdjustmentNever 时，是否自动将 UIScrollView.automaticallyAdjustsScrollIndicatorInsets 设为 NO，以保证原本在 iOS 12 下的代码不用修改就能在 iOS 13 下正常控制滚动条的位置。

