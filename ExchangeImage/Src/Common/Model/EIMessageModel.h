//
//  EIPictureModel.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/7.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "EIUserModel.h"
#import "EIPictureModel.h"

/**
    数据库中存储的数据模型
**/

@protocol EIMessageModel
@end

@interface EIMessageModel:JSONModel

@property (nonatomic , strong)NSString<Optional> *msg_id;
@property (nonatomic , strong)EIPictureModel<Optional> *picture;
@property (nonatomic , strong)EIUserModel<Optional> *user;

/**
 是否是对方:1是对方,0是自己
 **/
@property (nonatomic , assign)NSNumber<Optional> *isLeft;

@end

@interface EIMsgListModel:JSONModel

@property (nonatomic , strong)NSMutableArray<EIMessageModel> *msg_list;

@end


