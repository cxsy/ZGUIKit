/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UINavigationItem+ZGUI.m
//  zgui
//
//  Created by ZGUI Team on 2020/10/28.
//

#import "UINavigationItem+ZGUI.h"
#import "UIView+ZGUI.h"

@implementation UINavigationItem (ZGUI)

- (UINavigationBar *)zgui_navigationBar {
    // UINavigationItem 内部有个方法可以获取 navigationBar
    if ([self respondsToSelector:@selector(navigationBar)]) {
        return [self performSelector:@selector(navigationBar)];
    }
    return nil;
}

- (UINavigationController *)zgui_navigationController {
    UINavigationBar *navigationBar = self.zgui_navigationBar;
    UINavigationController *navigationController = (UINavigationController *)navigationBar.superview.zgui_viewController;
    if ([navigationController isKindOfClass:UINavigationController.class]) {
        return navigationController;
    }
    return nil;
}

- (UIViewController *)zgui_viewController {
    UINavigationBar *navigationBar = self.zgui_navigationBar;
    UINavigationController *navigationController = self.zgui_navigationController;
    
    if (!navigationBar || !navigationController) return nil;
    
    NSInteger index = [navigationBar.items indexOfObject:self];
    if (index != NSNotFound && index < navigationController.viewControllers.count) {
        UIViewController *viewController = navigationController.viewControllers[index];
        return viewController;
    }
    return nil;
}

- (UINavigationItem *)zgui_previousItem {
    NSArray<UINavigationItem *> *items = self.zgui_navigationBar.items;
    if (!items.count) return nil;
    NSInteger index = [items indexOfObject:self];
    if (index != NSNotFound && index > 0) return items[index - 1];
    return nil;
}

- (UINavigationItem *)zgui_nextItem {
    NSArray<UINavigationItem *> *items = self.zgui_navigationBar.items;
    if (!items.count) return nil;
    NSInteger index = [items indexOfObject:self];
    if (index != NSNotFound && index < items.count - 1) return items[index + 1];
    return nil;
}

@end
