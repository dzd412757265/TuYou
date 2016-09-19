//
//  EIUserLoginMessageManager.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/13.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIUserLoginMessageManager.h"

@implementation EIUserLoginMessageManager

+ (NSString *)device_id
{
 return [UIDevice currentDevice].identifierForVendor.UUIDString;
}

+ (int)device_os
{
    return 1;
}

+ (NSString *)client_ver
{
    NSBundle *bundle = [NSBundle mainBundle];
    
    NSString *clientVer = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    return clientVer;
}

+ (NSString *)um_device_token
{
    return @"577b52cd67e58e174c0003e8";
}
@end
