//
//  UIViewController+ZGUITheme.m
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/8.
//

#import "UIViewController+ZGUITheme.h"

@implementation UIViewController (ZGUITheme)

- (void)zgui_onThemeDidChange {
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull childViewController, NSUInteger idx, BOOL * _Nonnull stop) {
        [childViewController zgui_onThemeDidChange];
    }];
    if (self.presentedViewController && self.presentedViewController.presentingViewController == self) {
        [self.presentedViewController zgui_onThemeDidChange];
    }
}

@end
