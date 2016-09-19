//
//  EIEXPUserModel.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/14.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface EIUserModel:JSONModel

@property (nonatomic , strong)NSString<Optional> *user_id;
@property (nonatomic , strong)NSString<Optional> *avatar;
@property (nonatomic , strong)NSString<Optional> *nickname;
@property (nonatomic , strong)NSNumber<Optional> *sex;
@property (nonatomic , strong)NSString<Optional> *city;

@end