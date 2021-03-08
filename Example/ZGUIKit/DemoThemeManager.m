//
//  DemoThemeManager.m
//  ZGUIKit_Example
//
//  Created by Zhiguo Guo on 2021/3/10.
//  Copyright © 2021 cxsy. All rights reserved.
//

#import "DemoThemeManager.h"
#import <ZGUIKit/ZGUIThemeManager.h>
#import <ZGUIKit/UIColor+ZGUITheme.h>
#import <ZGUIKit/UIImage+ZGUITheme.h>

@interface DemoTheme : NSObject <DemoThemeProtocol>

@end

@implementation DemoTheme

@synthesize brandColor;
@synthesize text1Color;
@synthesize brandImage;

@end

@interface DemoThemeManager ()

@property (nonatomic, strong) UIColor *demo_brandColor;
@property (nonatomic, strong) UIColor *demo_text1Color;

@property (nonatomic, strong) UIImage *demo_brandImage;

@end

@implementation DemoThemeManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static DemoThemeManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

+ (NSObject<DemoThemeProtocol> *)currentTheme {
    return ZGUITM.currentTheme;
}

+ (NSObject<DemoThemeProtocol> *)generateThemeWithDictionary:(NSDictionary *)dictionary {
    DemoTheme *theme = [[DemoTheme alloc] init];
    theme.brandColor = [UIColor zgui_colorWithRGBAHexString:dictionary[@"brandColor"]];
    theme.text1Color = [UIColor zgui_colorWithRGBAHexString:dictionary[@"text1Color"]];
    theme.brandImage = dictionary[@"brandImage"];
    return theme;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.demo_brandColor = [UIColor zgui_colorWithProvider:^UIColor * _Nonnull(NSObject<DemoThemeProtocol> *theme) {
            return theme.brandColor;
        }];
        self.demo_text1Color = [UIColor zgui_colorWithProvider:^UIColor * _Nonnull(NSObject<DemoThemeProtocol> *theme) {
            return theme.text1Color;
        }];
        self.demo_brandImage = [UIImage zgui_imageWithProvider:^UIImage * _Nonnull(NSObject<DemoThemeProtocol> *theme) {
            return theme.brandImage;
        }];
    }
    return self;
}

@end

@implementation UIColor (ThemeDemo)

+ (UIColor *)demo_brandColor {
    return DemoThemeManager.sharedInstance.demo_brandColor;
}

+ (UIColor *)demo_text1Color {
    return DemoThemeManager.sharedInstance.demo_text1Color;
}

@end

@implementation UIImage (ThemeDemo)

+ (UIImage *)demo_brandImage {
    return DemoThemeManager.sharedInstance.demo_brandImage;
}

@end
