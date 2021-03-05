//
//  UIColor+ZGUITheme.h
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (ZGUITheme)

+ (instancetype)zgui_brandColor;

+ (instancetype)zgui_text1Color;

+ (instancetype)zgui_colorWithRGBAHexString:(NSString *)hexStr;

@end

NS_ASSUME_NONNULL_END
