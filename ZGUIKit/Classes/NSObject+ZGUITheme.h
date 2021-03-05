//
//  NSObject+ZGUITheme.h
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/5.
//

#import <Foundation/Foundation.h>
#import "ZGUIColorPicker.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ZGUITheme)

- (NSMutableDictionary<NSString *, ZGUIColorPicker *> *)zgui_pickers;

@end

NS_ASSUME_NONNULL_END
