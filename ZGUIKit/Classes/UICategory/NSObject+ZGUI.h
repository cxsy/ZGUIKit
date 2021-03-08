//
//  NSObject+ZGUI.h
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/10.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ZGUI)

+ (void)zgui_enumrateInstanceMethodsOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(Method, SEL))block;

@end

NS_ASSUME_NONNULL_END
