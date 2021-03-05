//
//  ZGUIColorPicker.m
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/5.
//

#import "ZGUIColorPicker.h"
#import "ZGUIThemeManager.h"
#import "UIColor+ZGUITheme.h"

typedef UIColor *(^ZGUIColorPickerBlock)(ZGUITheme theme);

@interface ZGUIColorPicker ()

@property (nonatomic, copy) ZGUIColorPickerBlock pickerBlock;

@end

@implementation ZGUIColorPicker

- (instancetype)initWithPickerBlock:(ZGUIColorPickerBlock)pickerBlock {
    self = [super init];
    if (self) {
        _pickerBlock = pickerBlock;
    }
    return self;
}

- (UIColor *)themedColor {
    return self.pickerBlock(CurrentTheme);
}

+ (instancetype)text1ColorPicker {
    ZGUIColorPicker *picker = [[ZGUIColorPicker alloc] initWithPickerBlock:^UIColor *(ZGUITheme theme) {
        switch (theme) {
            case ZGUIThemeDark:
                return [UIColor zgui_colorWithRGBAHexString:@"#FFFFFF"];
            case ZGUIThemeRed:
                return [UIColor zgui_colorWithRGBAHexString:@"#FFEEDE"];
            case ZGUIThemeLight:
            default:
                return [UIColor zgui_colorWithRGBAHexString:@"#25292E"];
        }
    }];
    return picker;
}

+ (instancetype)brandColorPicker {
    ZGUIColorPicker *picker = [[ZGUIColorPicker alloc] initWithPickerBlock:^UIColor *(ZGUITheme theme) {
        switch (theme) {
            case ZGUIThemeDark:
                return [UIColor zgui_colorWithRGBAHexString:@"#A3C5FF"];
            case ZGUIThemeRed:
                return [UIColor zgui_colorWithRGBAHexString:@"#FF860D"];
            case ZGUIThemeLight:
            default:
                return [UIColor zgui_colorWithRGBAHexString:@"#1966FF"];
        }
    }];
    return picker;
}

@end
