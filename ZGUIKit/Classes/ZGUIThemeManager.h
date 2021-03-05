//
//  ZGUIThemeManager.h
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define ThemeManager \
[ZGUIThemeManager sharedInstance]
#define CurrentTheme \
ThemeManager.currentTheme

extern NSNotificationName const ZGGUIThemeDidChangeNotification;

typedef NS_ENUM(NSInteger, ZGUITheme) {
    ZGUIThemeLight      = 1,
    ZGUIThemeDark       = 2,
    ZGUIThemeRed        = 3,
};

@interface ZGUIThemeManager : NSObject

@property (nonatomic, assign, readonly) ZGUITheme currentTheme;

+ (instancetype)sharedInstance;

- (void)switchTheme:(ZGUITheme)theme;

@end

NS_ASSUME_NONNULL_END
