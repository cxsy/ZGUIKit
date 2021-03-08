//
//  DemoThemeProtocol.h
//  ZGUIKit_Example
//
//  Created by Zhiguo Guo on 2021/3/10.
//  Copyright © 2021 cxsy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DemoThemeProtocol <NSObject>

@property (nonatomic, strong) UIColor *brandColor;
@property (nonatomic, strong) UIColor *text1Color;

@property (nonatomic, strong) UIImage *brandImage;

@end

NS_ASSUME_NONNULL_END
