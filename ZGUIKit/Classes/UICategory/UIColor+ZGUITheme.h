//
//  UIColor+ZGUITheme.h
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/5.
//

#import <UIKit/UIKit.h>
#import "ZGUIThemeManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef UIColor * _Nonnull (^ZGUIThemeColorProvider)(NSObject *theme);

@interface ZGUIThemeColor : UIColor

@end

@interface UIColor (ZGUITheme)

+ (instancetype)zgui_colorWithProvider:(ZGUIThemeColorProvider)provider;

+ (instancetype)zgui_colorWithRGBAHexString:(NSString *)hexStr;

- (CGFloat)zgui_alpha;

@end

NS_ASSUME_NONNULL_END
