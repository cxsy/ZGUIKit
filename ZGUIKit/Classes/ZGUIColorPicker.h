//
//  ZGUIColorPicker.h
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define BrandColorPicker \
[ZGUIColorPicker brandColorPicker]

#define Text1ColorPicker \
[ZGUIColorPicker text1ColorPicker]

@interface ZGUIColorPicker : NSObject

- (UIColor *)themedColor;

+ (instancetype)brandColorPicker;

+ (instancetype)text1ColorPicker;

@end

NS_ASSUME_NONNULL_END
