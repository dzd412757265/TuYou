//
//  EILoginViewModel.h
//  ExchangeImage
//
//  Created by 张博成 on 16/7/27.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIBaseViewModel.h"

@interface EILoginViewModel : EIBaseViewModel
- (void)loginAppWithCode:(NSString *)codeString success:(void(^)(id))sucess failure:(void(^)(NSError *))failure;
@end
