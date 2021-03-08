//
//  ZGUIThemeManager.h
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define ZGUITM \
[ZGUIThemeManager sharedInstance]

extern NSNotificationName const ZGGUIThemeDidChangeNotification;

@interface ZGUIThemeManager : NSObject

@property (nonatomic, strong) __kindof NSString *currentThemeIdentifier;
@property (nonatomic, strong) __kindof NSObject *currentTheme;

/// 获取所有主题的 identifier
@property(nonatomic, copy, readonly, nullable) NSArray<__kindof NSObject<NSCopying> *> *themeIdentifiers;
/// 获取所有主题的对象
@property(nonatomic, copy, readonly, nullable) NSArray<__kindof NSObject *> *themes;

- (void)addTheme:(NSObject *)theme withIdentifier:(NSString *)identifier;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
