//
//  UIImage+ZGUITheme.m
//  ZGUIKit
//
//  Created by Zhiguo Guo on 2021/3/10.
//

#import "UIImage+ZGUITheme.h"
#import "UIColor+ZGUITheme.h"
#import "NSObject+ZGUI.h"
#import "NSMethodSignature+ZGUI.h"
#import <objc/message.h>

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

@interface ZGUIThemeImage ()

@property (nonatomic, copy) ZGUIThemeImageProvider provider;

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
    _provider = nil;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if (self.zgui_rawImage) {
        // 这里不能加上 [self.zgui_rawImage respondsToSelector:aSelector] 的判断，否则 UIImage 没有机会做消息转发
        return self.zgui_rawImage;
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
// https://github.com/Tencent/ZGUI_iOS/issues/971
- (id)copyWithZone:(NSZone *)zone {
    ZGUIThemeImage *image = (ZGUIThemeImage *)[UIImage zgui_imageWithProvider:self.provider];
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
    return (NSUInteger)self.provider;
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

- (UIImage *)zgui_rawImage {
    if (!_provider) {
        return nil;
    }
    return self.provider(ZGUITM.currentTheme);
}

@end

@implementation UIImage (ZGUITheme)

+ (UIImage *)zgui_imageFromColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0.f, 0.f, size.width, size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext(); //创建图片上下文
    CGContextSetFillColorWithColor(context, color.CGColor); //设置当前填充颜色的图形上下文
    CGContextFillRect(context, rect); //填充颜色
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext(); //创建图片
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)zgui_imageFromColor:(UIColor *)color {
    return [self zgui_imageFromColor:color size:CGSizeMake(1.f, 1.f)];
}

+ (instancetype)zgui_imageWithProvider:(ZGUIThemeImageProvider)provider {
    ZGUIThemeImage *image = [[ZGUIThemeImage alloc] init];
    image.provider = provider;
    return image;
}

@end
