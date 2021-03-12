/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UIImage+ZGUITheme.m
//  ZGUIKit
//
//  Created by MoLice on 2019/J/16.
//

#import "UIImage+ZGUITheme.h"
#import "ZGUIThemeManager.h"
#import "ZGUIThemeManagerCenter.h"
#import "ZGUIThemePrivate.h"
#import "NSMethodSignature+ZGUI.h"
#import "ZGUICore.h"
#import <objc/message.h>

@interface ZGUIThemeImageCache : NSCache

@end

@implementation ZGUIThemeImageCache

- (instancetype)init {
    if (self = [super init]) {
        // NSCache 在 app 进入后台时会删除所有缓存，它的实现方式是在 init 的时候去监听 UIApplicationDidEnterBackgroundNotification ，一旦进入后台则调用 removeAllObjects，通过 removeObserver 可以禁用掉这个策略
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

@end

@interface ZGUIAvoidExceptionProxy : NSProxy
@end

@implementation ZGUIAvoidExceptionProxy

+ (instancetype)proxy {
    static dispatch_once_t onceToken;
    static ZGUIAvoidExceptionProxy *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [super alloc];
    });
    return instance;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSMethodSignature zgui_avoidExceptionSignature];
}

@end

@interface ZGUIThemeImage()

@property(nonatomic, strong) ZGUIThemeImageCache *cachedRawImages;

@end

@implementation ZGUIThemeImage

static IMP zgui_getMsgForwardIMP(NSObject *self, SEL selector) {
    
    IMP msgForwardIMP = _objc_msgForward;
#if !defined(__arm64__)
    // As an ugly internal runtime implementation detail in the 32bit runtime, we need to determine of the method we hook returns a struct or anything larger than id.
    // https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/LowLevelABI/000-Introduction/introduction.html
    // https://github.com/ReactiveCocoa/ReactiveCocoa/issues/783
    // http://infocenter.arm.com/help/topic/com.arm.doc.ihi0042e/IHI0042E_aapcs.pdf (Section 5.4)
    Method method = class_getInstanceMethod(self.class, selector);
    const char *encoding = method_getTypeEncoding(method);
    BOOL methodReturnsStructValue = encoding[0] == _C_STRUCT_B;
    if (methodReturnsStructValue) {
        @try {
            // 以下代码参考 JSPatch 的实现，但在 OpenCV 时会抛异常
            NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:encoding];
            if ([methodSignature.debugDescription rangeOfString:@"is special struct return? YES"].location == NSNotFound) {
                methodReturnsStructValue = NO;
            }
        } @catch (__unused NSException *e) {
            // 以下代码参考 Aspect 的实现，可以兼容 OpenCV
            @try {
                NSUInteger valueSize = 0;
                NSGetSizeAndAlignment(encoding, &valueSize, NULL);

                if (valueSize == 1 || valueSize == 2 || valueSize == 4 || valueSize == 8) {
                    methodReturnsStructValue = NO;
                }
            } @catch (NSException *exception) {}
        }
    }
    if (methodReturnsStructValue) {
        msgForwardIMP = (IMP)_objc_msgForward_stret;
    }
#endif
    return msgForwardIMP;
}

- (void)dealloc {
    _themeProvider = nil;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if (self.zgui_rawImage) {
        // 这里不能加上 [self.zgui_rawImage respondsToSelector:aSelector] 的判断，否则 UIImage 没有机会做消息转发
        return self.zgui_rawImage;
    }
    // 在 dealloc 的时候 UIImage 会调用 _isNamed 是用于判断 image 对象是否由 [UIImage imageNamed:] 创建的，并根据这个结果决定是否缓存 image，但是 ZGUIThemeImage 仅仅是一个容器，真正的缓存工作会在 zgui_rawImage 的 dealloc 执行，所以可以忽略这个方法的调用
    NSArray *ignoreSelectorNames = @[@"_isNamed"];
    if (![ignoreSelectorNames containsObject:NSStringFromSelector(aSelector)]) {
//        ZGUILogWarn(@"UIImage+ZGUITheme", @"ZGUIThemeImage 试图执行 %@ 方法，但是 zgui_rawImage 为 nil", NSStringFromSelector(aSelector));
    }
    return [ZGUIAvoidExceptionProxy proxy];
}

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class selfClass = [ZGUIThemeImage class];
        UIImage *instance =  UIImage.new;
        // ZGUIThemeImage 覆盖重写了大部分 UIImage 的方法，在这些方法调用时，会交给 zgui_rawImage 处理
        // 除此之外 UIImage 内部还有很多私有方法，无法全部在 ZGUIThemeImage 重写一遍，这些方法将通过消息转发的形式交给 zgui_rawImage 调用。
        [NSObject zgui_enumrateInstanceMethodsOfClass:instance.class includingInherited:NO usingBlock:^(Method  _Nonnull method, SEL  _Nonnull selector) {
            // 如果 ZGUIThemeImage 已经实现了该方法，则不需要消息转发
            if (class_getInstanceMethod(selfClass, selector) != method) return;
            const char * typeDescription = (char *)method_getTypeEncoding(method);
            class_addMethod(selfClass, selector, zgui_getMsgForwardIMP(instance, selector), typeDescription);
        }];
    });
}

// 让 ZGUIThemeImage 支持 NSCopying 是为了修复 iOS 12 及以下版本，ZGUIThemeImage 在搭配 resizable 使用的情况下可能无法跟随主题刷新的 bug，使用的地方在 UIView+ZGUITheme zgui_themeDidChangeByManager:identifier:theme 内。
// https://github.com/Tencent/QMUI_iOS/issues/971
- (id)copyWithZone:(NSZone *)zone {
    ZGUIThemeImage *image = (ZGUIThemeImage *)[UIImage zgui_imageWithThemeManagerName:self.managerName provider:self.themeProvider];
    image.cachedRawImages = self.cachedRawImages;
    return image;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p>, rawImage is %@", NSStringFromClass(self.class), self, self.zgui_rawImage.description];
}

- (instancetype)init {
    return ((id (*)(id, SEL))[NSObject instanceMethodForSelector:_cmd])(self, _cmd);
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    return [self.zgui_rawImage respondsToSelector:aSelector];
}

- (BOOL)isKindOfClass:(Class)aClass {
    if (aClass == ZGUIThemeImage.class) return YES;
    return [self.zgui_rawImage isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    if (aClass == ZGUIThemeImage.class) return YES;
    return [self.zgui_rawImage isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [self.zgui_rawImage conformsToProtocol:aProtocol];
}

- (NSUInteger)hash {
    return (NSUInteger)self.themeProvider;
}

- (BOOL)isEqual:(id)object {
    return NO;
}

- (CGSize)size {
    return self.zgui_rawImage.size;
}

- (CGImageRef)CGImage {
    return self.zgui_rawImage.CGImage;
}

- (CIImage *)CIImage {
    return self.zgui_rawImage.CIImage;
}

- (UIImageOrientation)imageOrientation {
    return self.zgui_rawImage.imageOrientation;
}

- (CGFloat)scale {
    return self.zgui_rawImage.scale;
}

- (NSArray<UIImage *> *)images {
    return self.zgui_rawImage.images;
}

- (NSTimeInterval)duration {
    return self.zgui_rawImage.duration;
}

- (UIEdgeInsets)alignmentRectInsets {
    return self.zgui_rawImage.alignmentRectInsets;
}

- (void)drawAtPoint:(CGPoint)point {
    [self.zgui_rawImage drawAtPoint:point];
}

- (void)drawAtPoint:(CGPoint)point blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha {
    [self.zgui_rawImage drawAtPoint:point blendMode:blendMode alpha:alpha];
}

- (void)drawInRect:(CGRect)rect {
    [self.zgui_rawImage drawInRect:rect];
}

- (void)drawInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha {
    [self.zgui_rawImage drawInRect:rect blendMode:blendMode alpha:alpha];
}

- (void)drawAsPatternInRect:(CGRect)rect {
    [self.zgui_rawImage drawAsPatternInRect:rect];
}

- (UIImage *)resizableImageWithCapInsets:(UIEdgeInsets)capInsets {
    return [self.zgui_rawImage resizableImageWithCapInsets:capInsets];
}

- (UIImage *)resizableImageWithCapInsets:(UIEdgeInsets)capInsets resizingMode:(UIImageResizingMode)resizingMode {
    return [self.zgui_rawImage resizableImageWithCapInsets:capInsets resizingMode:resizingMode];
}

- (UIEdgeInsets)capInsets {
    return [self.zgui_rawImage capInsets];
}

- (UIImageResizingMode)resizingMode {
    return [self.zgui_rawImage resizingMode];
}

- (UIImage *)imageWithAlignmentRectInsets:(UIEdgeInsets)alignmentInsets {
    return [self.zgui_rawImage imageWithAlignmentRectInsets:alignmentInsets];
}

- (UIImage *)imageWithRenderingMode:(UIImageRenderingMode)renderingMode {
    return [self.zgui_rawImage imageWithRenderingMode:renderingMode];
}

- (UIImageRenderingMode)renderingMode {
    return self.zgui_rawImage.renderingMode;
}

- (UIGraphicsImageRendererFormat *)imageRendererFormat {
    return self.zgui_rawImage.imageRendererFormat;
}

- (UITraitCollection *)traitCollection {
    return self.zgui_rawImage.traitCollection;
}

- (UIImageAsset *)imageAsset {
    return self.zgui_rawImage.imageAsset;
}

- (UIImage *)imageFlippedForRightToLeftLayoutDirection {
    return self.zgui_rawImage.imageFlippedForRightToLeftLayoutDirection;
}

- (BOOL)flipsForRightToLeftLayoutDirection {
    return self.zgui_rawImage.flipsForRightToLeftLayoutDirection;
}

- (UIImage *)imageWithHorizontallyFlippedOrientation {
    return self.zgui_rawImage.imageWithHorizontallyFlippedOrientation;
}

- (BOOL)isSymbolImage {
    return self.zgui_rawImage.isSymbolImage;
}

- (CGFloat)baselineOffsetFromBottom {
    return self.zgui_rawImage.baselineOffsetFromBottom;
}

- (BOOL)hasBaseline {
    return self.zgui_rawImage.hasBaseline;
}

- (UIImage *)imageWithBaselineOffsetFromBottom:(CGFloat)baselineOffset {
    return [self.zgui_rawImage imageWithBaselineOffsetFromBottom:baselineOffset];
}

- (UIImage *)imageWithoutBaseline {
    return self.zgui_rawImage.imageWithoutBaseline;
}

- (UIImageConfiguration *)configuration {
    return self.zgui_rawImage.configuration;
}

- (UIImage *)imageWithConfiguration:(UIImageConfiguration *)configuration {
    return [self.zgui_rawImage imageWithConfiguration:configuration];
}

- (UIImageSymbolConfiguration *)symbolConfiguration {
    return self.zgui_rawImage.symbolConfiguration;
}

- (UIImage *)imageByApplyingSymbolConfiguration:(UIImageSymbolConfiguration *)configuration {
    return [self.zgui_rawImage imageByApplyingSymbolConfiguration:configuration];
}

- (UIImage *)imageWithTintColor:(UIColor *)color {
    return [self.zgui_rawImage imageWithTintColor:color];
}

- (UIImage *)imageWithTintColor:(UIColor *)color renderingMode:(UIImageRenderingMode)renderingMode {
    return [self.zgui_rawImage imageWithTintColor:color renderingMode:renderingMode];
}

#pragma mark - <ZGUIDynamicImageProtocol>

- (UIImage *)zgui_rawImage {
    if (!_themeProvider) return nil;
    ZGUIThemeManager *manager = [ZGUIThemeManagerCenter themeManagerWithName:self.managerName];
    NSString *cacheKey = [NSString stringWithFormat:@"%@_%@",manager.name, manager.currentThemeIdentifier];
    UIImage *rawImage = [self.cachedRawImages objectForKey:cacheKey];
    if (!rawImage) {
        rawImage = self.themeProvider(manager, manager.currentThemeIdentifier, manager.currentTheme).zgui_rawImage;
        if (rawImage) [self.cachedRawImages setObject:rawImage forKey:cacheKey];
    }
    return rawImage;
}

- (BOOL)zgui_isDynamicImage {
    return YES;
}

@end

@implementation UIImage (ZGUITheme)

+ (UIImage *)zgui_imageWithThemeProvider:(UIImage * _Nonnull (^)(__kindof ZGUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    return [UIImage zgui_imageWithThemeManagerName:ZGUIThemeManagerNameDefault provider:provider];
}

+ (UIImage *)zgui_imageWithThemeManagerName:(__kindof NSObject<NSCopying> *)name provider:(UIImage * _Nonnull (^)(__kindof ZGUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    ZGUIThemeImage *image = [[ZGUIThemeImage alloc] init];
    image.cachedRawImages = [[ZGUIThemeImageCache alloc] init];
    image.managerName = name;
    image.themeProvider = provider;
    return (UIImage *)image;
}

#pragma mark - <ZGUIDynamicImageProtocol>

- (UIImage *)zgui_rawImage {
    return self;
}

- (BOOL)zgui_isDynamicImage {
    return NO;
}

@end
