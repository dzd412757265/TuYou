//
//  EIMessageDateBase.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/18.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIMessageDateBase.h"
#import "EIDBHelper.h"
#import "EIMessageModel.h"
#import "NSObject+EasyJSON.h"
#import "EIUserDateBase.h"
#import "EIPictureDateBase.h"

static NSString * const kMessageTable = @"MESSAGE_TABLE";

@implementation EIMessageDateBase

DEF_SINGLETON(EIMessageDateBase)

- (instancetype)init
{
    if (self = [super init]) {
        
        [self CreateMessageTable];
    }
    return self;
}
//创建用户存储表
-(void)CreateMessageTable
{
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    if (queue==nil) {
        return;
    }
    [queue inDatabase:^(FMDatabase *db) {
        if (![EIDBHelper isTableOK: kMessageTable withDB:db]) {
            NSString *createTableSQL = [NSString stringWithFormat:@"CREATE TABLE %@ (id integer PRIMARY KEY autoincrement, msg_id text,picture_id text, user_id text ,is_left integer)",kMessageTable];
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL = [NSString stringWithFormat:@"CREATE unique INDEX idx_messageId ON %@(msg_id);",kMessageTable];
            [db executeUpdate:createIndexSQL];
        }
    }];
    
}

- (void)insertMessageToDB:(EIMessageModel *)message{
    
    if (!message.msg_id.isNotEmpty || !message.picture.picture_id.isNotEmpty || !message.user.user_id.isNotEmpty) {
        return;
    }
    
    NSString *insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ (msg_id, picture_id, user_id,is_left) VALUES (?, ?, ? ,?)",kMessageTable];
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql,message.msg_id,message.picture.picture_id,message.user.user_id,message.isLeft];
    }];
    
    [[EIPictureDateBase sharedInstance] insertPictureToDB:message.picture];
    
    [[EIUserDateBase sharedInstance] insertUserToDB:message.user];
}

- (void)insertMessagesToDB:(NSArray *)messages{
    if (messages.count == 0) {
        return;
    }
    
    [messages enumerateObjectsUsingBlock:^(EIMessageModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self insertMessageToDB:obj];
    }];
}

- (EIMessageModel *)getMessageById:(NSString *)messageId{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    if (queue == nil || !messageId.isNotEmpty) {
        return nil;
    }
    
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ where msg_id = ?",kMessageTable];
        FMResultSet *rs = [db executeQuery:sqlStr,messageId];
        while ([rs next]) {
            dict[@"msg_id"] = [rs stringForColumn:@"msg_id"];
            dict[@"is_left"] = [NSNumber numberWithInt:[rs intForColumn:@"is_left"]];
            dict[@"picture_id"] = [rs stringForColumn:@"picture_id"];
            dict[@"user_id"] = [rs stringForColumn:@"user_id"];
        }
        [rs close];
        
    }];
    EIMessageModel * model = [EIMessageModel new];
    model.msg_id = dict[@"msg_id"];
    model.isLeft = dict[@"is_left"];
    model.picture = [[EIPictureDateBase sharedInstance] getPictureById:dict[@"picture_id"]];
    model.user = [[EIUserDateBase sharedInstance] getUserById:dict[@"user_id"]];

    
    return model;
}

- (NSArray *)getAllMessagesInfo{
    NSMutableArray *allMessages = [NSMutableArray new];
    
    NSMutableArray *messageInfos = [NSMutableArray new];
    
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@",kMessageTable];
        FMResultSet *rs = [db executeQuery:sqlStr];
        while ([rs next]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            dict[@"msg_id"] = [rs stringForColumn:@"msg_id"];
            dict[@"is_left"] = [NSNumber numberWithInt:[rs intForColumn:@"is_left"]];
            dict[@"picture_id"] = [rs stringForColumn:@"picture_id"];
            dict[@"user_id"] = [rs stringForColumn:@"user_id"];
            [messageInfos addObject:dict];
        }
        [rs close];
    }];
    
    [messageInfos enumerateObjectsUsingBlock:^(NSDictionary * dict, NSUInteger idx, BOOL * _Nonnull stop) {
        EIMessageModel *model = [EIMessageModel new];
        model.msg_id = dict[@"msg_id"];
        model.isLeft = dict[@"is_left"];
        model.picture = [[EIPictureDateBase sharedInstance] getPictureById:dict[@"picture_id"]];
        model.user = [[EIUserDateBase sharedInstance] getUserById:dict[@"user_id"]];
        [allMessages addObject:model];
    }];
    
    return allMessages;
}

- (NSArray *)getMessagesByDesc:(int)count{
    NSMutableArray *allMessages = [NSMutableArray new];
    
    NSMutableArray *descInfos = [NSMutableArray new];
    
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY id DESC LIMIT %d",kMessageTable,count];
        FMResultSet *rs = [db executeQuery:sqlStr];
        while ([rs next]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            dict[@"msg_id"] = [rs stringForColumn:@"msg_id"];
            dict[@"is_left"] = [NSNumber numberWithInt:[rs intForColumn:@"is_left"]];
            dict[@"picture_id"] = [rs stringForColumn:@"picture_id"];
            dict[@"user_id"] = [rs stringForColumn:@"user_id"];
            [descInfos addObject:dict];
        }
        [rs close];
    }];
    
    NSArray * ascInfos = [[descInfos reverseObjectEnumerator] allObjects];
    
    [ascInfos enumerateObjectsUsingBlock:^(NSDictionary * dict, NSUInteger idx, BOOL * _Nonnull stop) {
        EIMessageModel *model = [EIMessageModel new];
        model.msg_id = dict[@"msg_id"];
        model.isLeft = dict[@"is_left"];
        model.picture = [[EIPictureDateBase sharedInstance] getPictureById:dict[@"picture_id"]];
        model.user = [[EIUserDateBase sharedInstance] getUserById:dict[@"user_id"]];
        [allMessages addObject:model];
    }];
    
    return allMessages;
}

- (NSArray *)getMessagesByDesc:(int)count messageId:(NSString *)msgId{
    NSMutableArray *allMessages = [NSMutableArray new];
    
    NSMutableArray *descInfos = [NSMutableArray new];
    
    __block NSInteger id = 0;
    
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sqlStr = [NSString stringWithFormat:@"SELECT id FROM %@ where msg_id = ?",kMessageTable];
        FMResultSet *rs = [db executeQuery:sqlStr,msgId];
        while ([rs next]) {
            id = [rs intForColumn:@"id"];
        }
        [rs close];
    }];
    
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ where id < %zd ORDER BY id DESC LIMIT %d",kMessageTable,id,count];
        FMResultSet *rs = [db executeQuery:sqlStr];
        while ([rs next]) {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            dict[@"msg_id"] = [rs stringForColumn:@"msg_id"];
            dict[@"is_left"] = [NSNumber numberWithInt:[rs intForColumn:@"is_left"]];
            dict[@"picture_id"] = [rs stringForColumn:@"picture_id"];
            dict[@"user_id"] = [rs stringForColumn:@"user_id"];
            [descInfos addObject:dict];
        }
        [rs close];
    }];
    
    NSArray *ascInfos = [[descInfos reverseObjectEnumerator] allObjects];
    
    [ascInfos enumerateObjectsUsingBlock:^(NSDictionary * dict, NSUInteger idx, BOOL * _Nonnull stop) {
        EIMessageModel *model = [EIMessageModel new];
        model.msg_id = dict[@"msg_id"];
        model.isLeft = dict[@"is_left"];
        model.picture = [[EIPictureDateBase sharedInstance] getPictureById:dict[@"picture_id"]];
        model.user = [[EIUserDateBase sharedInstance] getUserById:dict[@"user_id"]];
        [allMessages addObject:model];
    }];
    
    return allMessages;
}

- (NSString *)getLastMessageIdWithCondition:(int)isLeft{
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    if (queue == nil) {
        return nil;
    }
    
    __block NSString *messageId = nil;
    
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sqlStr = [NSString stringWithFormat:@"SELECT msg_id FROM %@ where is_left = %d ORDER BY id DESC LIMIT 1",kMessageTable,isLeft];
        FMResultSet *rs = [db executeQuery:sqlStr];
        while ([rs next]) {
            messageId = [rs stringForColumn:@"msg_id"];
        }
        [rs close];
    }];
    return messageId;
}

- (void)deleteMessageFromDB:(NSString *)messageId{
    NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE msg_id='%@'",kMessageTable,messageId];
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    if (queue == nil) {
        return;
    }
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];
    }];
}

- (void)clearMessageData
{
    NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@",kMessageTable];
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    if (queue==nil) {
        return ;
    }
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];
    }];
}

@end