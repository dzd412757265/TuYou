//
//  EILoginViewModel.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/27.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EILoginViewModel.h"
#import "EINetworkTool.h"
#import "EIIndividualMessageVC.h"
#import "EIMessageListTC.h"
#import "EIUserLoginMessageManager.h"
#import "EIRequest.h"
#import "EILoginModel.h"
#import "EIUserCenter.h"
#import "EICommonHelper.h"
#import "EIDataBaseManager.h"
#import "EIViewControllerManager.h"

@implementation EILoginViewModel

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
        
        //如果更换了账号,需要重新建立数据库
        [[EIDataBaseManager sharedInstance] createDBTable];
        
        [[EIViewControllerManager sharedInstance] loginIn];
    } failure:^(NSError *error) {
        
        failure(error);
    }];

}
@end
