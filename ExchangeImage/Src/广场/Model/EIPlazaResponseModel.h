//
//  EIPlazaResponseModel.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/14.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "EIMessageModel.h"

@interface EIPlazaResponseModel : JSONModel

@property (nonatomic , strong)NSString<Optional> *picture_id;
@property (nonatomic , strong)NSString<Optional> *cur_msg_id;
@property (nonatomic , strong)EIMessageModel<Optional> *exp_msg;

@end
