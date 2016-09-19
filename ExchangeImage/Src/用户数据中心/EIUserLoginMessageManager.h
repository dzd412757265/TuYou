//
//  EIUserLoginMessageManager.h
//  ExchangeImage
//
//  Created by 张博成 on 16/7/13.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EIUserLoginMessageManager : NSObject

+(NSString *)device_id;

+ (int)device_os;

+ (NSString *)client_ver;

+ (NSString *)um_device_token;

@end
