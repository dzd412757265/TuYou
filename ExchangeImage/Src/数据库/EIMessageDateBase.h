//
//  EIMessageDateBase.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/18.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingletonHelper.h"

@class EIMessageModel;

@interface EIMessageDateBase : NSObject

AS_SINGLETON(EIMessageDateBase)

- (void)CreateMessageTable;

- (void)insertMessageToDB:(EIMessageModel*)message;

- (void)insertMessagesToDB:(NSArray *)messages;

- (NSArray *) getAllMessagesInfo;

- (EIMessageModel *) getMessageById:(NSString*)messageId;

- (NSArray *)getMessagesByDesc:(int)count;

- (NSArray *)getMessagesByDesc:(int)count messageId:(NSString *)msgId;

- (void)deleteMessageFromDB:(NSString *)messageId;

- (NSString *)getLastMessageIdWithCondition:(int)isLeft;

- (void)clearMessageData;

@end
