//
//  EINewLoginViewModel.h
//  ExchangeImage
//
//  Created by 张博成 on 16/8/2.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIBaseViewModel.h"

@interface EINewLoginViewModel : EIBaseViewModel

- (void)loginWithUserName:(NSString *)userName WithPassWord:(NSString *)passWord success:(void(^)(id))sucess failure:(void(^)(NSError *))failure;;

//微信登录
- (void)loginAppWithCode:(NSString *)codeString success:(void(^)(id))sucess failure:(void(^)(NSError *))failure;
@end
