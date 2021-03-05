//
//  UIView+ZGUITheme.m
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/5.
//

#import "UIView+ZGUITheme.h"
#import "NSObject+ZGUITheme.h"
#import <objc/runtime.h>

@implementation UIView (ZGUITheme)

- (ZGUIColorPicker *)zgui_backgroundColorPicker {
    return objc_getAssociatedObject(self, @selector(zgui_backgroundColorPicker));
}

- (void)zgui_setBackgroundColorPicker:(ZGUIColorPicker *)colorPicker {
    objc_setAssociatedObject(self, @selector(zgui_backgroundColorPicker), colorPicker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.backgroundColor = colorPicker.themedColor;
    [self.zgui_pickers setValue:colorPicker forKey:@"setBackgroundColor:"];
}

@end
