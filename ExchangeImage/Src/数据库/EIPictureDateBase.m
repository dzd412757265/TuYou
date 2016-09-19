//
//  EIPictureDateBase.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/18.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIPictureDateBase.h"
#import "EIDBHelper.h"
#import "EIPictureModel.h"
#import "NSObject+EasyJSON.h"

static NSString * const kPictureTable = @"PICTURE_TABLE";

@implementation EIPictureDateBase

DEF_SINGLETON(EIPictureDateBase)

- (instancetype)init
{
    if (self = [super init]) {
        
        [self CreatePictureTable];
    }
    return self;
}
//创建用户存储表
-(void)CreatePictureTable
{
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    if (queue == nil) {
        return;
    }
    [queue inDatabase:^(FMDatabase *db) {
        if (![EIDBHelper isTableOK: kPictureTable withDB:db]) {
            NSString *createTableSQL = [NSString stringWithFormat:@"CREATE TABLE %@ (id integer PRIMARY KEY autoincrement, picture_id text,thumbnail_url text, origin_url text,created integer)",kPictureTable];
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL = [NSString stringWithFormat:@"CREATE unique INDEX idx_pictureId ON %@(picture_id);",kPictureTable];
            [db executeUpdate:createIndexSQL];
        }
    }];
    
}

- (void)insertPictureToDB:(EIPictureModel *)picture{
    
    if (!picture.picture_id.isNotEmpty) {
        return;
    }
    
    NSString *insertSql = [NSString stringWithFormat:@"REPLACE INTO %@ (picture_id, thumbnail_url, origin_url,created) VALUES (?, ?, ? ,?)",kPictureTable];
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql,picture.picture_id,picture.thumbnail_url,picture.origin_url,picture.created];
    }];
}

- (void)insertPicturesToDB:(NSArray *)pictures{
    if (pictures.count == 0) {
        return;
    }
    
    [pictures enumerateObjectsUsingBlock:^(EIPictureModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self insertPictureToDB:obj];
    }];
}

- (EIPictureModel *)getPictureById:(NSString *)pictureId{
    __block EIPictureModel *model = nil;
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    if (queue == nil || !pictureId.isNotEmpty) {
        return nil;
    }
    
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ where picture_id = ?",kPictureTable];
        FMResultSet *rs = [db executeQuery:sqlStr,pictureId];
        while ([rs next]) {
            model = [EIPictureModel new];
            model.picture_id = [rs stringForColumn:@"picture_id"];
            model.thumbnail_url = [rs stringForColumn:@"thumbnail_url"];
            model.origin_url = [rs stringForColumn:@"origin_url"];
            model.created = [NSNumber numberWithInt:[rs intForColumn:@"created"]];
        }
        [rs close];

    }];
    
    return model;
}

- (NSArray *)getAllPictureInfo{
    NSMutableArray *allPictures = [NSMutableArray new];
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        NSString *sqlStr = [NSString stringWithFormat:@"SELECT * FROM %@",kPictureTable];
        FMResultSet *rs = [db executeQuery:sqlStr];
        while ([rs next]) {
            EIPictureModel *model = [EIPictureModel new];
            model.picture_id = [rs stringForColumn:@"picture_id"];
            model.thumbnail_url = [rs stringForColumn:@"thumbnail_url"];
            model.origin_url = [rs stringForColumn:@"origin_url"];
            model.created = [NSNumber numberWithInt:[rs intForColumn:@"created"]];
            [allPictures addObject:model];
        }
        [rs close];
    }];
    return allPictures;
}

- (void)deletePictureFromDB:(NSString *)pictureId{
    NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE picture_id='%@'",kPictureTable,pictureId];
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    if (queue == nil) {
        return;
    }
    
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];
    }];
}

- (void)clearPictureData
{
    NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM %@",kPictureTable];
    FMDatabaseQueue *queue = [EIDBHelper getDatabaseQueue];
    if (queue == nil) {
        return ;
    }
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];
    }];
}

@end
