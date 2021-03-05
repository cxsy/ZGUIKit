//
//  UILabel+ZGUITheme.m
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/5.
//

#import "UILabel+ZGUITheme.h"
#import "NSObject+ZGUITheme.h"
#import <objc/runtime.h>

@implementation UILabel (ZGUITheme)

- (ZGUIColorPicker *)zgui_textColorPicker {
    return objc_getAssociatedObject(self, @selector(zgui_textColorPicker));
}

- (void)zgui_setTextColorPicker:(ZGUIColorPicker *)colorPicker {
    objc_setAssociatedObject(self, @selector(zgui_textColorPicker), colorPicker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.textColor = colorPicker.themedColor;
    [self.zgui_pickers setValue:colorPicker forKey:@"setTextColor:"];
}

@end
