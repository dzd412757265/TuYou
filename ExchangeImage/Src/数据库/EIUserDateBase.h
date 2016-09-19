//
//  EIUserDateBase.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/18.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingletonHelper.h"

@class EIUserModel;

@interface EIUserDateBase : NSObject

AS_SINGLETON(EIUserDateBase)

- (void)CreateUserTable;

- (void)insertUserToDB:(EIUserModel *)user;

- (void)insertUsersToDB:(NSArray *)users;

- (NSArray *) getAllUsersInfo;

- (EIUserModel *) getUserById:(NSString*)userId;

- (void)deleteUserFromDB:(NSString *)userId;

- (void)clearUserData;

@end
