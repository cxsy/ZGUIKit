//
//  UIImage+ZGUITheme.h
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/10.
//

#import <UIKit/UIKit.h>
#import "ZGUIThemeManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef UIImage * _Nonnull (^ZGUIThemeImageProvider)(NSObject *theme);

@interface ZGUIThemeImage : UIImage

@end

@interface UIImage (ZGUITheme)

+ (UIImage *)zgui_imageFromColor:(UIColor *)color;

+ (UIImage *)zgui_imageFromColor:(UIColor *)color size:(CGSize)size;

+ (instancetype)zgui_imageWithProvider:(ZGUIThemeImageProvider)provider;

@end

NS_ASSUME_NONNULL_END
