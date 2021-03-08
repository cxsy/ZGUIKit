//
//  ZGUIAppDelegate.m
//  ZGUIKit
//
//  Created by cxsy on 02/05/2021.
//  Copyright (c) 2021 cxsy. All rights reserved.
//

#import "ZGUIAppDelegate.h"
#import "DemoThemeManager.h"
#import <ZGUIKit/ZGUIThemeManager.h>
#import <ZGUIKit/UIImage+ZGUITheme.h>
#import <ZGUIKit/UIColor+ZGUITheme.h>

@implementation ZGUIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSObject<DemoThemeProtocol> *darkTheme = [DemoThemeManager generateThemeWithDictionary:@{
        @"brandColor"   : @"#A3C5FF",
        @"text1Color"   : @"#FFFFFF",
        @"brandImage"   : [UIImage zgui_imageFromColor:[UIColor zgui_colorWithRGBAHexString:@"#DAE8FB"]],
    }];
    NSObject<DemoThemeProtocol> *lightTheme = [DemoThemeManager generateThemeWithDictionary:@{
        @"brandColor"   : @"#1966FF",
        @"text1Color"   : @"#25292E",
        @"brandImage"   : [UIImage zgui_imageFromColor:[UIColor zgui_colorWithRGBAHexString:@"#A3C5FF"]],
    }];
    NSObject<DemoThemeProtocol> *redTheme = [DemoThemeManager generateThemeWithDictionary:@{
        @"brandColor"   : @"#FF860D",
        @"text1Color"   : @"#FFEEDE",
        @"brandImage"   : [UIImage zgui_imageFromColor:[UIColor zgui_colorWithRGBAHexString:@"#FFEEDE"]],
    }];
    [ZGUITM addTheme:darkTheme withIdentifier:@"dark"];
    [ZGUITM addTheme:lightTheme withIdentifier:@"light"];
    [ZGUITM addTheme:redTheme withIdentifier:@"red"];
    
    [ZGUITM setCurrentTheme:darkTheme];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
