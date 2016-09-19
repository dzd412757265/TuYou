//
//  Helper.h
//  jiuwuliao
//
//  Created by TANHUAZHE on 3/22/16.
//  Copyright © 2016 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface EICommonHelper : NSObject

/**
 * 检查系统"照片"授权状态, 如果权限被关闭, 提示用户去隐私设置中打开.
 */
+ (BOOL)checkPhotoLibraryAuthorizationStatus;

/**
 * 只检查系统"照片"授权状态.
 */

+ (BOOL)checkPhotoLibraryAuthorizationStatusOnly;

/**
 * 检查系统"相机"授权状态, 如果权限被关闭, 提示用户去隐私设置中打开.
 */
+ (BOOL)checkCameraAuthorizationStatus;

+ (void)showSettingAlertStr:(NSString *)tipStr;

+ (NSString *)calculateTimeLeft:(int)create;

+ (NSString *)systemNow;

+ (NSNumber *)getCurrentTime;

+ (int)systemDate;

+ (NSString *)createIMDate:(int)create;

+ (NSString *)convertDir;

+ (NSString *)createRandomString:(NSUInteger)maxSize;

+ (NSString *)createPictureKey:(NSString *)picId;

+ (NSURL *)createImageURL;

+ (NSURL *)createImageURLWithKey:(NSString *)key;

+ (NSString *)createMessageDate:(long long)create;

+ (NSDictionary *)errorList;

+ (NSError *)createError:(NSInteger)code description:(NSString *)description;

+ (NSString *)splashImageNameForOrientation:(UIDeviceOrientation)orientation;

@end

