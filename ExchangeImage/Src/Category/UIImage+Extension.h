//
//  UIImage+Extension.h
//  新浪微博
//
//  Created by xc on 15/3/5.
//  Copyright (c) 2015年 xc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)
+ (UIImage *) resizableImageWithName:(NSString *)imageName;
- (UIImage*) scaleImageWithSize:(CGSize)size;

- (UIImage *)compressImage;
- (NSData *) compressData;

- (UIImage *)resetSizeOfImage;

- (UIImage*)scaledToMaxSize:(CGSize )size;

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
+ (UIImage *)gaussianBlurImage:(UIImage *)image andInputRadius:(CGFloat)radius;
+ (UIImage *)gaussianBlurImageWithColor:(UIColor *)color andSize:(CGSize)size andInputRadius:(CGFloat)radius;

@end
