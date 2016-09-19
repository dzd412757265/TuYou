//
//  EIUserDateBase.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/18.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIUserDateBase.h"
#import "EIDBHelper.h"
#import "EIUserModel.h"
#import "NSObject+EasyJSON.h"

static NSString * const kUserTable = @"USER_TABLE";

@implementation EIUserDateBase

DEF_SINGLETON(EIUserDateBase)

- (instancetype)init
{
    if (self = [super init]) {
        
        [self CreateUserTable];
    }
    return self;
}

-(void)CreateUserTable
{
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    if (queue == nil) {
        return;
    }
    [queue inDatabase:^(FMDatabase *db) {
        if (![EIDBHelper isTableOK: kUserTable withDB:db]) {
            NSString *createTableSQL = [NSString stringWithFormat:@"CREATE TABLE %@ (id integer PRIMARY KEY autoincrement, user_id text,avatar text, nickname text,sex integer,city text)",kUserTable];
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL = [NSString stringWithFormat:@"CREATE unique INDEX idx_userId ON %@(user_id);",kUserTable];
            [db executeUpdate:createIndexSQL];
        }
    }];
    
}

- (void)insertUserToDB:(EIUserModel *)user{
    
    if (!user.user_id.isNotEmpty) {
        return;
    }
    
    NSString *insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ (user_id, avatar,nickname,sex,city) VALUES (?, ?, ? ,?, ?)",kUserTable];
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql,user.user_id,user.avatar,user.nickname,user.sex,user.city];
    }];
}

- (void)insertUsersToDB:(NSArray *)users{
    if (users.count == 0) {
        return;
    }
    
    [users enumerateObjectsUsingBlock:^(EIUserModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self insertUserToDB:obj];
    }];
}

- (EIUserModel *)getUserById:(NSString *)userId{
    __block EIUserModel *model = nil;
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    if (queue == nil || !userId.isNotEmpty) {
        return nil;
    }
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ where user_id = ?",kUserTable];
        FMResultSet *rs = [db executeQuery:sqlStr,userId];
        while ([rs next]) {
            model = [EIUserModel new];
            model.user_id = [rs stringForColumn:@"user_id"];
            model.avatar = [rs stringForColumn:@"avatar"];
            model.nickname = [rs stringForColumn:@"nickname"];
            model.sex = [NSNumber numberWithInt:[rs intForColumn:@"sex"]];
            model.city = [rs stringForColumn:@"city"];
        }
        [rs close];
        
    }];
    
    return model;
}

- (NSArray *)getAllUsersInfo{
    NSMutableArray *allUsers = [NSMutableArray new];
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@",kUserTable];
        FMResultSet *rs = [db executeQuery:sqlStr];
        while ([rs next]) {
            EIUserModel *model = [EIUserModel new];
            model.user_id = [rs stringForColumn:@"user_id"];
            model.avatar = [rs stringForColumn:@"avatar"];
            model.nickname = [rs stringForColumn:@"nickname"];
            model.sex = [NSNumber numberWithInt:[rs intForColumn:@"sex"]];
            model.city = [rs stringForColumn:@"city"];
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}

- (void)deleteUserFromDB:(NSString *)userId{
    NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE user_id='%@'",kUserTable,userId];
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    if (queue == nil) {
        return;
    }
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];
    }];
}

- (void)clearUserData
{
    NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@",kUserTable];
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    if (queue == nil) {
        return ;
    }
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];
    }];
}

@end
