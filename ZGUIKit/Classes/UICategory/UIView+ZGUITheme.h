//
//  UIView+ZGUITheme.h
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ZGUITheme)

- (void)zgui_themeDidChangeShouldEnumeratorSubviews:(BOOL)shouldEnumeratorSubviews;

- (void)zgui_onThemeDidChange;

@end

NS_ASSUME_NONNULL_END
