//
//  EINewRegisterViewModel.h
//  ExchangeImage
//
//  Created by 张博成 on 16/8/2.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIBaseViewModel.h"

@interface EINewRegisterViewModel : EIBaseViewModel

- (void)registerWithUserName:(NSString *)userName andWithPassWord:(NSString *)passWord success:(void(^)(id))success failure:(void(^)(NSError *))failure;

@end
