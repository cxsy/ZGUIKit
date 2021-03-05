//
//  UIView+ZGUITheme.h
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/5.
//

#import <Foundation/Foundation.h>
#import "ZGUIColorPicker.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ZGUITheme)

@property (nonatomic, strong, setter = zgui_setBackgroundColorPicker:) ZGUIColorPicker *zgui_backgroundColorPicker;

@end

NS_ASSUME_NONNULL_END
