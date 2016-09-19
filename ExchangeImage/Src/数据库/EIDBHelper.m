//
//  DBHelper.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/5/22.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "EIDBHelper.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "EIUserCenter.h"
#import "NSObject+EasyJSON.h"

@implementation EIDBHelper

static FMDatabaseQueue *databaseQueue = nil;
//
//+(FMDatabase *) getDataBase:(NSString *)dbname
//{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDirectory = [paths objectAtIndex:0];
//    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:dbname];
//    FMDatabase *db = [FMDatabase databaseWithPath:dbPath] ;
//    if (![db open]) {
//        NSLog(@"Could not open %@",dbname);
//    }
//    
//    return db;
//}

+(FMDatabaseQueue *) getDatabaseQueue
{
    if (![EIUserCenter sharedInstance].userId.isNotEmpty) {
        return nil;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"ExchangeImage%@",[EIUserCenter sharedInstance].userId]];
    
    if (!databaseQueue) {
        databaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }else{
        if (![dbPath isEqualToString:databaseQueue.path]) {
            databaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        }
    }
    
    return databaseQueue;
}

+ (BOOL) isTableOK:(NSString *)tableName withDB:(FMDatabase *)db
{
    BOOL isOK = NO;
    
    FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    while ([rs next])
    {
        NSInteger count = [rs intForColumn:@"count"];
        
        if (0 == count)
        {
            isOK =  NO;
        }
        else
        {
            isOK = YES;
        }
    }
    [rs close];
    
    return isOK;
}

@end
