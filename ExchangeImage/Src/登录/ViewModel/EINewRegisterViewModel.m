//
//  EINewRegisterViewModel.m
//  ExchangeImage
//
//  Created by 张博成 on 16/8/2.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EINewRegisterViewModel.h"
#import "EIRequest.h"
#import "EINetworkTool.h"
#import "EINewLoginViewModel.h"
#import "EIDefines.h"

@interface EINewRegisterViewModel()

@property (nonatomic, strong)EINewLoginViewModel *loginviewModel;

@end

@implementation EINewRegisterViewModel

- (void)registerWithUserName:(NSString *)userName andWithPassWord:(NSString *)passWord success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    ESWeakSelf
    NSDictionary *params = @{
                             @"usr":userName,
                             @"pwd":passWord
                             
                             };
    
    EIRequest *request = [EIRequest request];
    request.method = HttpMethod_POST;
    request.path = @"/v1.0/ios/users";
    [request.params addEntriesFromDictionary:params];
    
    [EINetworkTool networkTool:request success:^(id data) {
        
        success(data);
        
        [__weakSelf.loginviewModel loginWithUserName:userName WithPassWord:passWord success:nil failure:nil];
        
    } failure:^(NSError *error) {
        
        failure(error);
    }];

}

- (EINewLoginViewModel *)loginviewModel
{
    if (!_loginviewModel) {
        _loginviewModel = [[EINewLoginViewModel alloc]init];
    }
    return _loginviewModel;
}
@end
