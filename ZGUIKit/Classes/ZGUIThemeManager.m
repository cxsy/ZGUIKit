//
//  ZGUIThemeManager.m
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/5.
//

#import "ZGUIThemeManager.h"
#import "UIView+ZGUITheme.h"
#import "UIViewController+ZGUITheme.h"

NSNotificationName const ZGGUIThemeDidChangeNotification = @"ZGGUIThemeDidChangeNotification";

@interface ZGUIThemeManager ()

@property (nonatomic, strong) NSMutableArray *_themeIdentifiers;
@property (nonatomic, strong) NSMutableArray *_themes;

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

- (instancetype)init {
    self = [super init];
    if (self) {
        self._themeIdentifiers = [NSMutableArray array];
        self._themes = [NSMutableArray array];
    }
    return self;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (void)setCurrentTheme:(NSObject *)currentTheme {
    if (!currentTheme || ![self._themes containsObject:currentTheme]) {
        NSAssert([self._themes containsObject:currentTheme], @"%@ should be added to ZGUIThemeManager.themes before it becomes current theme.", currentTheme);
        return;
    }
    
    BOOL themeChanged = _currentTheme && ![_currentTheme isEqual:currentTheme];
    
    _currentTheme = currentTheme;
    _currentThemeIdentifier = [self identifierForTheme:currentTheme];
    
    if (themeChanged) {
        [self notifyThemeChanged];
    }
}

- (void)setCurrentThemeIdentifier:(NSString *)currentThemeIdentifier {
    if (currentThemeIdentifier.length <= 0 || ![self._themeIdentifiers containsObject:currentThemeIdentifier]) {
        NSAssert([self._themeIdentifiers containsObject:currentThemeIdentifier], @"%@ should be added to ZGUIThemeManager.themeIdentifiers before it becomes current theme.", currentThemeIdentifier);
        return;
    }
    
    BOOL themeChanged = ![_currentThemeIdentifier isEqualToString:currentThemeIdentifier];
    
    _currentTheme = [self themeForIdentifier:currentThemeIdentifier];
    _currentThemeIdentifier = currentThemeIdentifier;
    
    if (themeChanged) {
        [self notifyThemeChanged];
    }
}

- (void)addTheme:(NSObject *)theme withIdentifier:(NSString *)identifier {
    NSAssert(![self._themes containsObject:theme], @"unable to add duplicate theme");
    NSAssert(![self._themeIdentifiers containsObject:identifier], @"unable to add duplicate theme identifier");

    [self._themes addObject:theme];
    [self._themeIdentifiers addObject:identifier];
}

- (NSArray<NSObject<NSCopying> *> *)themeIdentifiers {
    return self._themeIdentifiers.count ? self._themeIdentifiers.copy : nil;
}

- (NSArray<NSObject *> *)themes {
    return self._themes.count ? self._themes.copy : nil;
}

- (NSString *)identifierForTheme:(NSObject *)theme {
    NSUInteger index = [self._themes indexOfObject:theme];
    if (index != NSNotFound) return self._themeIdentifiers[index];
    return nil;
}

-(NSObject *)themeForIdentifier:(NSString *)identifier {
    NSUInteger index = [self._themeIdentifiers indexOfObject:identifier];
    if (index != NSNotFound) return self._themes[index];
    return nil;
}

- (void)notifyThemeChanged {
    [[NSNotificationCenter defaultCenter] postNotificationName:ZGGUIThemeDidChangeNotification
                                                        object:nil];
    [UIApplication.sharedApplication.windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!window.hidden && window.alpha > 0.01 && window.rootViewController) {
            [window.rootViewController zgui_onThemeDidChange];
            [window zgui_themeDidChangeShouldEnumeratorSubviews:YES];
        }
    }];
}

@end
