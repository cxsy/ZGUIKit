//
//  DemoThemeManager.h
//  ZGUIKit_Example
//
//  Created by Zhiguo Guo on 2021/3/10.
//  Copyright © 2021 cxsy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DemoThemeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DemoThemeManager : NSObject

@property (class, nonatomic, strong) NSObject<DemoThemeProtocol> *currentTheme;

+ (NSObject<DemoThemeProtocol> *)generateThemeWithDictionary:(NSDictionary *)dictionary;

@end

@interface UIColor (ThemeDemo)

+ (UIColor *)demo_brandColor;

+ (UIColor *)demo_text1Color;

@end

@interface UIImage (ThemeDemo)

+ (UIImage *)demo_brandImage;

@end

NS_ASSUME_NONNULL_END
