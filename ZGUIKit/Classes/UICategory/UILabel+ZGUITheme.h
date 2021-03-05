//
//  UILabel+ZGUITheme.h
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/5.
//

#import <Foundation/Foundation.h>
#import "ZGUIColorPicker.h"

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (ZGUITheme)

@property (nonatomic, strong, setter = zgui_setTextColorPicker:) ZGUIColorPicker *zgui_textColorPicker;

@end

NS_ASSUME_NONNULL_END
