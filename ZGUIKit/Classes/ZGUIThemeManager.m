//
//  ZGUIThemeManager.m
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/5.
//

NSNotificationName const ZGGUIThemeDidChangeNotification = @"ZGGUIThemeDidChangeNotification";

#import "ZGUIThemeManager.h"

@interface ZGUIThemeManager ()

@property (nonatomic, assign) ZGUITheme currentTheme;

@end

@implementation ZGUIThemeManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static ZGUIThemeManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentTheme = ZGUIThemeLight;
    }
    return self;
}

- (void)switchTheme:(ZGUITheme)theme {
    if (theme == _currentTheme) {
        return;
    }
    _currentTheme = theme;
    [[NSNotificationCenter defaultCenter] postNotificationName:ZGGUIThemeDidChangeNotification
                                                        object:nil];
}

@end
