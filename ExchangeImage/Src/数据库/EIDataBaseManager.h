//
//  RCIMDataBaseManager.h
//  jiuwuliao
//
//  Created by 古元庆 on 16/3/17.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingletonHelper.h"
#import "EIUserModel.h"

/**
    数据库操作类
**/

@class EIMessageModel;

@interface EIDataBaseManager : NSObject

AS_SINGLETON(EIDataBaseManager)

- (void)insertMessageModel:(EIMessageModel *)model;

- (NSArray *)getLastMessagesByCount:(int)count sinceMessage:(NSString *) msgId;

- (NSArray *)getAllMessage;

- (void)clearDB;

- (void)deleteMessage:(NSString *)messageId;

- (void)createDBTable;

//获取数据库中最后一个其他用户发送的消息ID
- (NSString *)getLastMessageId;

@end
