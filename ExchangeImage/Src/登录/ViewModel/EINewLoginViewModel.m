//
//  EINewLoginViewModel.m
//  ExchangeImage
//
//  Created by 张博成 on 16/8/2.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EINewLoginViewModel.h"
#import "EIUserLoginMessageManager.h"
#import "EIUserCenter.h"
#import "EIRequest.h"
#import "EINetworkTool.h"
#import "AppDelegate.h"
#import "EICommonHelper.h"
#import "EIViewControllerManager.h"

@implementation EINewLoginViewModel

- (void)loginWithUserName:(NSString *)userName WithPassWord:(NSString *)passWord success:(void (^)(id))sucess failure:(void (^)(NSError *))failure
{
    NSDictionary *params = @{
                             @"usr":userName,
                             @"pwd":passWord,
                             @"device_id":[EIUserLoginMessageManager device_id],
                             @"device_os":@([EIUserLoginMessageManager device_os]),
                             @"client_ver":[EIUserLoginMessageManager client_ver],
                             @"um_device_token":[EIUserCenter sharedInstance].userDeviceumtoken
                             
                             };
    
    EIRequest *request = [EIRequest request];
    request.method = HttpMethod_POST;
    request.path = @"/v1.0/ios/login";
    [request.params addEntriesFromDictionary:params];
    
    [EINetworkTool networkTool:request success:^(id data) {
        
        if (sucess) {
            sucess(data);
        }
        
        [[NSUserDefaults standardUserDefaults] setInteger:[EICommonHelper systemDate] forKey:token_stamp];
        
        EILoginModel *model = [[EILoginModel alloc]initWithDictionary:data error:nil];
        
        [[EIUserCenter sharedInstance]loginInWith:model];
        
        [[EIViewControllerManager sharedInstance] loginIn];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
        
    }];

}

- (void)loginAppWithCode:(NSString *)code success:(void (^)(id))sucess failure:(void (^)(NSError *))failure
{
    NSDictionary *params = @{
                             @"code":code,
                             @"device_id":[EIUserLoginMessageManager device_id],
                             @"device_os":@([EIUserLoginMessageManager device_os]),
                             @"client_ver":[EIUserLoginMessageManager client_ver],
                             @"um_device_token":[EIUserCenter sharedInstance].userDeviceumtoken
                             
                             };
    
    EIRequest *request = [EIRequest request];
    request.method = HttpMethod_POST;
    request.path = @"/v1.0/wx_login";
    [request.params addEntriesFromDictionary:params];
    
    [EINetworkTool networkTool:request success:^(id data) {
        
        sucess(data);
        [[NSUserDefaults standardUserDefaults] setInteger:[EICommonHelper systemDate] forKey:token_stamp];
        
        EILoginModel *model = [[EILoginModel alloc]initWithDictionary:data error:nil];
        
        [[EIUserCenter sharedInstance]loginInWith:model];
        
        [[EIViewControllerManager sharedInstance] loginIn];
    } failure:^(NSError *error) {
        
        failure(error);
    }];
    
}

@end
