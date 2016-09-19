//
//  NetworkTool.h
//  wenda
//
//  Created by 古元庆 on 16/6/23.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EIRequest;

@interface EINetworkTool : NSObject

+ (void)saveCookies;
+ (void)loadCookies;
+ (void)clearCookies;
+ (BOOL)checkCookiesExist;

+ (void)networkTool:(EIRequest *)request
            success:(void(^)(id))success
            failure:(void(^)(NSError *))failure;

//微信登录获取access_token

+ (void)getWechatAccessToken:(NSString *)code successBlock:(void(^)(NSString *))success failureBlock:(void(^)(NSString *))failure;

@end
