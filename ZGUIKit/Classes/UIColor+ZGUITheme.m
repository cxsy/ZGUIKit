//
//  UIColor+ZGUITheme.m
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/5.
//

#import "UIColor+ZGUITheme.h"
#import "ZGUIThemeManager.h"

static inline NSUInteger hexStrToInt(NSString *str) {
    uint32_t result = 0;
    sscanf([str UTF8String], "%X", &result);
    return result;
}

static BOOL hexStrToRGBA(NSString *str,
                         CGFloat *r, CGFloat *g, CGFloat *b, CGFloat *a) {
    if ([str hasPrefix:@"#"]) {
        str = [str substringFromIndex:1];
    } else if ([str hasPrefix:@"0X"] || [str hasPrefix:@"0x"]) {
        str = [str substringFromIndex:2];
    }
    
    NSUInteger length = [str length];
    //         RGB            RGBA          RRGGBB        RRGGBBAA
    if (length != 3 && length != 4 && length != 6 && length != 8) {
        return NO;
    }
    
    //RGB,RGBA,RRGGBB,RRGGBBAA
    if (length < 5) {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 1)]) / 255.0f;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(1, 1)]) / 255.0f;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(2, 1)]) / 255.0f;
        if (length == 4)  *a = hexStrToInt([str substringWithRange:NSMakeRange(3, 1)]) / 255.0f;
        else *a = 1;
    } else {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 2)]) / 255.0f;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(2, 2)]) / 255.0f;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(4, 2)]) / 255.0f;
        if (length == 8) *a = hexStrToInt([str substringWithRange:NSMakeRange(6, 2)]) / 255.0f;
        else *a = 1;
    }
    return YES;
}

@implementation UIColor (ZGUITheme)

+ (instancetype)zgui_brandColor {
    ZGUITheme theme = ThemeManager.currentTheme;
    switch (theme) {
        case ZGUIThemeDark:
            return [UIColor zgui_colorWithRGBAHexString:@"#A3C5FF"];
        case ZGUIThemeRed:
            return [UIColor zgui_colorWithRGBAHexString:@"#FF860D"];
        case ZGUIThemeLight:
        default:
            return [UIColor zgui_colorWithRGBAHexString:@"#1966FF"];
    }
}

+ (instancetype)zgui_text1Color {
    ZGUITheme theme = ThemeManager.currentTheme;
    switch (theme) {
        case ZGUIThemeDark:
            return [UIColor zgui_colorWithRGBAHexString:@"#FFFFFF"];
        case ZGUIThemeRed:
            return [UIColor zgui_colorWithRGBAHexString:@"#FFEEDE"];
        case ZGUIThemeLight:
        default:
            return [UIColor zgui_colorWithRGBAHexString:@"#25292E"];
    }
}

+ (UIColor *)zgui_colorWithRGBAHexString:(NSString *)hexStr {
    CGFloat r, g, b, a;
    if (hexStrToRGBA(hexStr, &r, &g, &b, &a)) {
        return [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
    return nil;
}

@end
