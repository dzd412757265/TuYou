//
//  Helper.m
//  jiuwuliao
//
//  Created by TANHUAZHE on 3/22/16.
//  Copyright © 2016 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EICommonHelper.h"
#import <BlocksKit/BlocksKit+UIKit.h>
#import "NSDate+Estension.h"
#import "NSString+EasyExtend.h"
@import AssetsLibrary;

@import AVFoundation;

@implementation EICommonHelper

+ (BOOL)checkPhotoLibraryAuthorizationStatus
{
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if (ALAuthorizationStatusDenied == authStatus ||
        ALAuthorizationStatusRestricted == authStatus) {
        [self showSettingAlertStr:@"请在iPhone的“设置->隐私->照片”中打开本应用的访问权限"];
        return NO;
    }
    return YES;
}

+ (BOOL)checkPhotoLibraryAuthorizationStatusOnly
{
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if (ALAuthorizationStatusDenied == authStatus ||
        ALAuthorizationStatusRestricted == authStatus) {
        return NO;
    }
    
    return YES;
}
+ (BOOL)checkCameraAuthorizationStatus
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"提示" message:@"该设备不支持拍照"];
        [alertView show];
        return NO;
    }
    
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (AVAuthorizationStatusDenied == authStatus ||
            AVAuthorizationStatusRestricted == authStatus) {
            [self showSettingAlertStr:@"请在iPhone的“设置->隐私->相机”中打开本应用的访问权限"];
            return NO;
        }
    }
    
    return YES;
}

+ (void)showSettingAlertStr:(NSString *)tipStr{
    //iOS8+系统下可跳转到‘设置’页面，否则只弹出提示窗即可
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"提示" message:tipStr];
        [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [alertView bk_addButtonWithTitle:@"设置" handler:nil];
        [alertView bk_setDidDismissBlock:^(UIAlertView *alert, NSInteger index) {
            if (index == 1) {
                UIApplication *app = [UIApplication sharedApplication];
                NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([app canOpenURL:settingsURL]) {
                    [app openURL:settingsURL];
                }
            }
        }];
        [alertView show];
    }else{
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"提示" message:tipStr];
        [alertView show];
    }
}


+ (NSString *)calculateTimeLeft:(int)create
{
    NSDate *date=[NSDate dateWithTimeIntervalSinceNow:0];
    
    NSTimeInterval now=[date timeIntervalSince1970]*1;
    
    int twoDays = 86400 * 2;
    
    NSTimeInterval exprireTime = create + twoDays;
    
    if (exprireTime < now) {
        return @"已结束";
    }else{
        NSDate *expireDate = [NSDate dateWithTimeIntervalSince1970:create + twoDays];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth
        | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
        
        NSDateComponents *dateCom = [calendar components:unit fromDate:date toDate:expireDate options:0];
        
        NSMutableString *result = [NSMutableString stringWithString:@"剩余"];
        if (dateCom.day > 0) {
            [result appendFormat:@"%zd天",dateCom.day];
        }
        
        if (dateCom.hour > 0) {
            [result appendFormat:@"%zd小时",dateCom.hour];
        }
        
        if (dateCom.minute > 0) {
            [result appendFormat:@"%zd分钟",dateCom.minute];
        }
        // 对比时间差
        return result;
    }
}

+ (NSString *)createIMDate:(int)create
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:create];
    return [EICommonHelper createDateWith:date];
}

+ (NSString *)createMessageDate:(long long)create
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:create];
    return [EICommonHelper createDateWith:date];
    
}

+(NSString *)createDateWith:(NSDate *)date
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"EEE MMM dd HH24:mm:ss Z yyyy";
    if (date.isThisYear) {
        if (date.isToday) { // 今天
 //           NSDateComponents *cmps = [date deltaWithNow];
//            if (cmps.hour >= 1) { // 至少是1小时前发的
//                fmt.dateFormat = @"HH:mm";
//                return [fmt stringFromDate:date];
//            } else if (cmps.minute >= 3) { // 3~59分钟之前发的
//                return [NSString stringWithFormat:@"%ld分钟前", (long)cmps.minute];
//            } else { // 3分钟内发的
//                return @"刚刚";
            fmt.dateFormat = @"HH:mm";
            return [fmt stringFromDate:date];
        }
        else if (date.isYesterday) { // 昨天
            fmt.dateFormat = @"昨天 HH:mm";
            return [fmt stringFromDate:date];
        }
        else { // 至少是前天
            fmt.dateFormat = @"MM月dd HH:mm";
            return [fmt stringFromDate:date];
        }
    } else { // 非今年
        fmt.dateFormat = @"yy年MM月dd";
        return [fmt stringFromDate:date];
    }

}
+ (NSString *)systemNow
{
    return [NSString stringWithFormat:@"%d",[[self class] systemDate]];
}

+ (int)systemDate
{
    NSDate *dat=[NSDate dateWithTimeIntervalSinceNow:0];
    
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    
    return (int)now;
}

+ (NSNumber *)getCurrentTime {
    UInt64 time = [[NSDate date] timeIntervalSince1970] * 1000;
    return @(time);
}

+ (NSString *)convertDir {
    NSString *docDir = [NSTemporaryDirectory() stringByAppendingPathComponent:@"AudioRecord"];
    [[NSFileManager defaultManager] createDirectoryAtPath:docDir withIntermediateDirectories:NO attributes:nil error:nil];
    return docDir;
}

+ (NSString *)createRandomString:(NSUInteger)maxSize
{
    char data[maxSize];
    for (int x=0;x<maxSize;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:maxSize encoding:NSUTF8StringEncoding];
}

+ (NSString *)createPictureKey:(NSString *)picId
{
    return [picId stringByAppendingFormat:@"_%@_%@",[[self class] systemNow],[[self class] createRandomString:6]];
}

+ (NSURL *)createImageURL
{
    return [[NSURL alloc] initWithScheme:@"http" host:@"localImage.com" path:[NSString stringWithFormat:@"/%@%@",[[self class] systemNow],[[self class] createRandomString:6]]];
}

+ (NSURL *)createImageURLWithKey:(NSString *)key{
    return [[NSURL alloc] initWithScheme:@"http" host:@"localImage.com" path:key];
}

+ (NSDictionary *)errorList{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ErrorMsg" ofType:@"plist"];
    return [[NSDictionary alloc] initWithContentsOfFile:path];
}

+ (NSError *)createError:(NSInteger)code description:(NSString *)description{
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:description forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"COMMON" code:code userInfo:details];
}

+ (NSString *)splashImageNameForOrientation:(UIDeviceOrientation)orientation {
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    NSString* viewOrientation = @"Portrait";
    if (UIDeviceOrientationIsLandscape(orientation)){
        viewSize = CGSizeMake(viewSize.height, viewSize.width);
        viewOrientation = @"Landscape";
    }
    
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict) {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
            return dict[@"UILaunchImageName"];
    }
    return nil;
}

@end

