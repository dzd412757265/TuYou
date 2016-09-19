//
//  RCIMDataBaseManager.m
//  jiuwuliao
//
//  Created by 古元庆 on 16/3/17.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIDataBaseManager.h"
#import "EIDBHelper.h"
#import "EIMessageModel.h"
#import "EIMessageDateBase.h"
#import "EIPictureDateBase.h"
#import "EIUserDateBase.h"
#import "SDWebImageManager.h"
#import "NSObject+EasyJSON.h"

static NSString * const messageDB = @"USERTABLE_IMAGE";

@implementation EIDataBaseManager

DEF_SINGLETON(EIDataBaseManager)

//+ (EIDataBaseManager*)shareInstance
//{
//    static EIDataBaseManager* instance = nil;
//    static dispatch_once_t predicate;
//    dispatch_once(&predicate, ^{
//        instance = [[[self class] alloc] init];
//        [instance CreateUserTable];
//    });
//    return instance;
//}

//- (instancetype)init
//{
//    if (self = [super init]) {
//        
//        [self CreateUserTable];
//    }
//    return self;
//}
//创建用户存储表
//-(void)CreateUserTable
//{
//    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
//    if (queue==nil) {
//        return;
//    }
//    [queue inDatabase:^(FMDatabase *db) {
//        if (![EIDBHelper isTableOK: messageDB withDB:db]) {
//            NSString *createTableSQL = @"CREATE TABLE USERTABLE_JWL (id integer PRIMARY KEY autoincrement, user_id text,nickname text, avatar text,sex integer,identify_verification integer)";
//            [db executeUpdate:createTableSQL];
//            NSString *createIndexSQL=@"CREATE unique INDEX idx_userid ON USERTABLE_JWL(user_id);";
//            [db executeUpdate:createIndexSQL];
//        }
//    }];
//    
//}

//存储用户信息
//-(void)insertUserToDB:(GBUser*)user
//{
//    NSString *insertSql = @"REPLACE INTO USERTABLE_JWL (user_id, nickname, avatar,sex,identify_verification) VALUES (?, ?, ? ,? ,?)";
//    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
//    
//    [queue inDatabase:^(FMDatabase *db) {
//        [db executeUpdate:insertSql,user.user_id,user.nickname,user.avatar,user.sex,user.identify_verification];
//    }];
//}

//- (void)insertUsersToDB:(NSArray *)users
//{
//    if (users.count == 0) {
//        return ;
//    }
//    
//    [users enumerateObjectsUsingBlock:^(GBUser *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [self insertUserToDB:obj];
//    }];
//}

//从表中获取用户信息
//-(GBUser*) getUserByUserId:(NSString*)userId
//{
//    __block GBUser *model = nil;
//    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
//    if (queue==nil) {
//        return nil;
//    }
//    [queue inDatabase:^(FMDatabase *db) {
//        FMResultSet *rs = [db executeQuery:@"SELECT * FROM USERTABLE_JWL where user_id = ?",userId];
//        while ([rs next]) {
//            model = [GBUser new];
//            model.user_id = [rs stringForColumn:@"user_id"];
//            model.nickname = [rs stringForColumn:@"nickname"];
//            model.avatar = [rs stringForColumn:@"avatar"];
//            model.sex = [NSNumber numberWithInt:[rs intForColumn:@"sex"]];
//            model.identify_verification = [NSNumber numberWithInt:[rs intForColumn:@"identify_verification"]];
//        }
//        [rs close];
//    }];
//    return model;
//}

//从表中获取所有用户信息
//-(NSArray *) getAllUserInfo
//{
//    NSMutableArray *allUsers = [NSMutableArray new];
//    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
//    [queue inDatabase:^(FMDatabase *db) {
//        FMResultSet *rs = [db executeQuery:@"SELECT * FROM USERTABLE_JWL"];
//        while ([rs next]) {
//            GBUser *user = [GBUser new];
//            user.user_id = [rs stringForColumn:@"user_id"];
//            user.nickname = [rs stringForColumn:@"nickname"];
//            user.avatar = [rs stringForColumn:@"avatar"];
//            user.sex = [NSNumber numberWithInt:[rs intForColumn:@"sex"]];
//            user.identify_verification = [NSNumber numberWithInt:[rs intForColumn:@"identify_verification"]];
//            [allUsers addObject:user];
//        }
//        [rs close];
//    }];
//    return allUsers;
//}

//- (void)deleteUserFromDB:(NSString *)userId
//{
//    NSString *deleteSql =[NSString stringWithFormat: @"DELETE FROM USERTABLE_JWL WHERE user_id='%@'",userId];
//    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
//    if (queue==nil) {
//        return ;
//    }
//    [queue inDatabase:^(FMDatabase *db) {
//        [db executeUpdate:deleteSql];
//    }];
//}

//清空用户缓存数据
//- (void)clearUserData
//{
//    NSString *deleteSql = @"DELETE FROM USERTABLE_JWL";
//    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
//    if (queue==nil) {
//        return ;
//    }
//    [queue inDatabase:^(FMDatabase *db) {
//        [db executeUpdate:deleteSql];
//    }];
//}

- (void)insertMessageModel:(EIMessageModel *)model{
    [[EIMessageDateBase sharedInstance] insertMessageToDB:model];
}

- (NSArray *)getLastMessagesByCount:(int)count sinceMessage:(NSString *)msgId{
    //return [[EIMessageDateBase sharedInstance] getAllMessagesInfo];
    if (msgId.isNotEmpty) {
        return [[EIMessageDateBase sharedInstance] getMessagesByDesc:count messageId:msgId];
    }else{
        return [[EIMessageDateBase sharedInstance] getMessagesByDesc:count];
    }
}

- (NSArray *)getAllMessage{
    return [[EIMessageDateBase sharedInstance] getAllMessagesInfo];
}

- (NSString *)getLastMessageId{
    return [[EIMessageDateBase sharedInstance] getLastMessageIdWithCondition:1];
}

- (void)clearDB{
    [[EIMessageDateBase sharedInstance] clearMessageData];
    [[EIPictureDateBase sharedInstance] clearPictureData];
    [[EIUserDateBase sharedInstance] clearUserData];
}

- (void)createDBTable{
    [[EIMessageDateBase sharedInstance] CreateMessageTable];
    [[EIPictureDateBase sharedInstance] CreatePictureTable];
    [[EIUserDateBase sharedInstance] CreateUserTable];
}

- (void)deleteMessage:(NSString *)messageId{
    [[EIMessageDateBase sharedInstance] deleteMessageFromDB:messageId];
}

@end
