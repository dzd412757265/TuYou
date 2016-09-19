//
//  EIResponseModel.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/13.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface EIResponse : JSONModel

@property (nonatomic , strong)NSNumber<Optional> *code;
@property (nonatomic , strong)NSString<Optional> *msg;
@property (nonatomic , strong)NSDictionary<Optional> *data;

+ (id)responseWithObject:(NSDictionary *)object
                 success:(void(^)(id))successBlock
                 failure:(void(^)(NSError *))failureBlock;

@end
