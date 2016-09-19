//
//  NetworkTool.m
//  wenda
//
//  Created by 古元庆 on 16/6/23.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EINetworkTool.h"
#import <AFNetworking.h>
#import <JSONModel/JSONModel.h>
#import "EIDefines.h"
#import "EIRequest.h"
#import "NSObject+EasyJSON.h"
#import "EIResponse.h"
#import "EICommonHelper.h"

#define COOKIES_KEY @"kCookiesKey"

@implementation EINetworkTool

+ (void)saveCookies
{
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: COOKIES_KEY];
}

+ (void)loadCookies
{
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: COOKIES_KEY]];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in cookies){
        [cookieStorage setCookie: cookie];
    }
}

+ (void)clearCookies
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:COOKIES_KEY];
}

+ (BOOL)checkCookiesExist
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:COOKIES_KEY] boolValue];
}

+ (void)getWechatAccessToken:(NSString *)code
                successBlock:(void (^)(NSString *))success
                failureBlock:(void (^)(NSString *))failure
{
    NSString *url = @"https://api.weixin.qq.com/sns/oauth2/access_token";
    //?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"code"] = code;
    params[@"grant_type"] = @"authorization_code";
    
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSDictionary *result=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"result is %@",result);
        
        NSString *accessToken = [result objectForKey:@"access_token"];
        success(accessToken);
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        failure([ NSString stringWithFormat:@"操作错误:%@",error.localizedDescription]);
    }];
}

+ (void)networkTool:(EIRequest *)request
            success:(void (^)(id))success
            failure:(void (^)(NSError *))failure{
    
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];

    NSString *URL;
    if (request.SCHEME.isNotEmpty && request.host.isNotEmpty && request.path.isNotEmpty) {
        URL = [NSString stringWithFormat:@"%@://%@%@",request.SCHEME,request.host,request.path];
    }else{
        failure([EICommonHelper createError:999 description:@"请求参数缺失"]);
        return;
    }
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    if(request.httpHeaderFields.isNotEmpty){
        [request.httpHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
            [manager.requestSerializer setValue:value forHTTPHeaderField:key];
        }];
    }
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    if (request.acceptableContentTypes.isNotEmpty) {
        manager.responseSerializer.acceptableContentTypes = request.acceptableContentTypes;
    }
    
    if (request.timeoutInterval != 0) {
        manager.requestSerializer.timeoutInterval = request.timeoutInterval;
    }
    
    if (request.method == HttpMethod_GET) {
        [manager GET:URL parameters:request.params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            [EIResponse responseWithObject:responseObject success:success failure:failure];
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"URL:%@\nServerError:\n%@",URL,operation.response);
            failure(error);
        }];
    }else if (request.method == HttpMethod_POST){
        [manager POST:URL parameters:request.params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
            [EIResponse responseWithObject:responseObject success:success failure:failure];
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"URL:%@\nServerError:\n%@",URL,operation.response);
            failure(error);
        }];
    }else if(request.method == HttpMethod_PUT){
        [manager PUT:URL parameters:request.params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            [EIResponse responseWithObject:responseObject success:success failure:failure];
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"URL:%@\nServerError:\n%@",URL,operation.response);
            failure(error);
        }];
    }else if(request.method == HttpMethod_DELETE){
        [manager DELETE:URL parameters:request.params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            [EIResponse responseWithObject:responseObject success:success failure:failure];
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"URL:%@\nServerError:\n%@",URL,operation.response);
            failure(error);
        }];
    }else if(request.method == HttpMethod_PATCH){
        [manager PATCH:URL parameters:request.params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            [EIResponse responseWithObject:responseObject success:success failure:failure];
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"URL:%@\nServerError:\n%@",URL,operation.response);
            failure(error);
        }];
    }
}

@end
