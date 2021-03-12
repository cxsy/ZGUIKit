/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIBarItem+ZGUI.m
//  ZGUIKit
//
//  Created by ZGUI Team on 2018/4/5.
//

#import "UIBarItem+ZGUI.h"
#import "ZGUICore.h"
#import "UIView+ZGUI.h"
#import "ZGUIWeakObjectContainer.h"

@interface UIBarItem ()

@property(nonatomic, copy) NSString *zguibaritem_viewDidSetBlockIdentifier;
@end

@implementation UIBarItem (ZGUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // UIBarButtonItem -setView:
        // @warning 如果作为 UIToolbar.items 使用，则 customView 的情况下，iOS 10 及以下的版本不会调用 setView:，所以那种情况改为在 setToolbarItems:animated: 时调用，代码见下方
        ExtendImplementationOfVoidMethodWithSingleArgument([UIBarButtonItem class], @selector(setView:), UIView *, ^(UIBarButtonItem *selfObject, UIView *firstArgv) {
            [UIBarItem setView:firstArgv inBarButtonItem:selfObject];
        });
        
        if (IOS_VERSION_NUMBER < 110000) {
            // iOS 11.0 及以上，通过 setView: 调用 zgui_viewDidSetBlock 即可，10.0 及以下只能在 setToolbarItems 的时机触发
            ExtendImplementationOfVoidMethodWithTwoArguments([UIViewController class], @selector(setToolbarItems:animated:), NSArray<__kindof UIBarButtonItem *> *, BOOL, ^(UIViewController *selfObject, NSArray<__kindof UIBarButtonItem *> *firstArgv, BOOL secondArgv) {
                for (UIBarButtonItem *item in firstArgv) {
                    [UIBarItem setView:item.customView inBarButtonItem:item];
                }
            });
        }
        
        
        // UITabBarItem -setView:
        ExtendImplementationOfVoidMethodWithSingleArgument([UITabBarItem class], @selector(setView:), UIView *, ^(UITabBarItem *selfObject, UIView *firstArgv) {
            [UIBarItem setView:firstArgv inBarItem:selfObject];
        });
    });
}

- (UIView *)zgui_view {
    // UIBarItem 本身没有 view 属性，只有子类 UIBarButtonItem 和 UITabBarItem 才有
    if ([self respondsToSelector:@selector(view)]) {
        return [self zgui_valueForKey:@"view"];
    }
    return nil;
}

ZGUISynthesizeIdCopyProperty(zguibaritem_viewDidSetBlockIdentifier, setZguibaritem_viewDidSetBlockIdentifier)
ZGUISynthesizeIdCopyProperty(zgui_viewDidSetBlock, setZgui_viewDidSetBlock)

static char kAssociatedObjectKey_viewDidLayoutSubviewsBlock;
- (void)setZgui_viewDidLayoutSubviewsBlock:(void (^)(__kindof UIBarItem * _Nonnull, UIView * _Nullable))zgui_viewDidLayoutSubviewsBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_viewDidLayoutSubviewsBlock, zgui_viewDidLayoutSubviewsBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (self.zgui_view) {
        __weak __typeof(self)weakSelf = self;
        self.zgui_view.zgui_layoutSubviewsBlock = ^(__kindof UIView * _Nonnull view) {
            if (weakSelf.zgui_viewDidLayoutSubviewsBlock) {
                weakSelf.zgui_viewDidLayoutSubviewsBlock(weakSelf, view);
            }
        };
    }
}

- (void (^)(__kindof UIBarItem * _Nonnull, UIView * _Nullable))zgui_viewDidLayoutSubviewsBlock {
    return (void (^)(__kindof UIBarItem * _Nonnull, UIView * _Nullable))objc_getAssociatedObject(self, &kAssociatedObjectKey_viewDidLayoutSubviewsBlock);
}

static char kAssociatedObjectKey_viewLayoutDidChangeBlock;
- (void)setZgui_viewLayoutDidChangeBlock:(void (^)(__kindof UIBarItem * _Nonnull, UIView * _Nullable))zgui_viewLayoutDidChangeBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_viewLayoutDidChangeBlock, zgui_viewLayoutDidChangeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    // 这里有个骚操作，对于 iOS 11 及以上，item.view 被放在一个 UIStackView 内，而当屏幕旋转时，通过 item.view.zgui_frameDidChangeBlock 得到的时机过早，布局尚未被更新，所以把 zgui_frameDidChangeBlock 放到 stackView 上以保证时机的准确性，但当调用 zgui_viewLayoutDidChangeBlock 时传进去的参数 view 依然要是 item.view
    UIView *view = self.zgui_view;
    if (IOS_VERSION_NUMBER >= 110000 && [view.superview isKindOfClass:[UIStackView class]]) {
        view = self.zgui_view.superview;
    }
    if (view) {
        __weak __typeof(self)weakSelf = self;
        view.zgui_frameDidChangeBlock = ^(__kindof UIView * _Nonnull view, CGRect precedingFrame) {
            if (weakSelf.zgui_viewLayoutDidChangeBlock){
                weakSelf.zgui_viewLayoutDidChangeBlock(weakSelf, weakSelf.zgui_view);
            }
        };
    }
}

- (void (^)(__kindof UIBarItem * _Nonnull, UIView * _Nullable))zgui_viewLayoutDidChangeBlock {
    return (void (^)(__kindof UIBarItem * _Nonnull, UIView * _Nullable))objc_getAssociatedObject(self, &kAssociatedObjectKey_viewLayoutDidChangeBlock);
}

#pragma mark - Tools

+ (NSString *)identifierWithView:(UIView *)view block:(id)block {
    return [NSString stringWithFormat:@"%p, %p", view, block];
}

+ (void)setView:(UIView *)view inBarItem:(__kindof UIBarItem *)item {
    if (item.zgui_viewDidSetBlock) {
        item.zgui_viewDidSetBlock(item, view);
    }
    
    if (item.zgui_viewDidLayoutSubviewsBlock) {
        item.zgui_viewDidLayoutSubviewsBlock = item.zgui_viewDidLayoutSubviewsBlock;// to call setter
    }
    
    if (item.zgui_viewLayoutDidChangeBlock) {
        item.zgui_viewLayoutDidChangeBlock = item.zgui_viewLayoutDidChangeBlock;// to call setter
    }
}

+ (void)setView:(UIView *)view inBarButtonItem:(UIBarButtonItem *)item {
    if (![[UIBarItem identifierWithView:view block:item.zgui_viewDidSetBlock] isEqualToString:item.zguibaritem_viewDidSetBlockIdentifier]) {
        item.zguibaritem_viewDidSetBlockIdentifier = [UIBarItem identifierWithView:view block:item.zgui_viewDidSetBlock];
        
        [self setView:view inBarItem:item];
    }
}

@end
