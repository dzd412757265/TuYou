//
//  EILoginModel.h
//  ExchangeImage
//
//  Created by 张博成 on 16/7/13.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIBaseModel.h"

@interface EILoginUserModel : EIBaseModel

@property (nonatomic, strong)NSString<Optional> *user_id;
@property (nonatomic, strong)NSString<Optional> *nickname;
@property (nonatomic, strong)NSNumber<Optional>*sex;
@property (nonatomic, strong)NSString<Optional>*city;
@property (nonatomic, strong)NSString <Optional>*avatar;


@end

@interface EILoginModel : EIBaseModel

@property (nonatomic, strong)NSString<Optional> *user_token;
@property (nonatomic, strong)NSString <Optional>*qn_token;
@property (nonatomic, strong)NSString <Optional>*rong_token;
@property (nonatomic, strong)EILoginUserModel <Optional>*user;

@end
