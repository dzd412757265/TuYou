//
//  EIUserCenter.h
//  ExchangeImage
//
//  Created by 张博成 on 16/7/6.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingletonHelper.h"
#import "NSObject+RACPropertySubscribing.h"
#import "EILoginModel.h"

static NSString *user_token = @"EIUserToken"; //用户API请求凭证
static NSString *qn_token = @"EIQNToken" ; //用户七牛上传凭证
static NSString *rong_token = @"EIRongToken"; //融云登录凭证

static NSString *user_id =@"EIUserId";
static NSString *user_sex = @"EIUserSex";
static NSString *user_avatar = @"EIUserAvatar";
static NSString *user_nickname = @"EIUserNickname";
static NSString *user_city = @"EIUserCity";

static NSString *user_Deviceumtoken = @"EIUserUMDeviceToken";

static NSString *token_stamp = @"EITokenStamp";

typedef NS_ENUM(int, SexType){
    SexTypeNone     =  0 ,
    SexTypeMale     =  1 ,
    SexTypeFemale   =  2 ,
};

@class EIUserModel;

@interface EIUserCenter : NSObject

AS_SINGLETON(EIUserCenter)

@property (nonatomic,assign)SexType userSex;                 //用户性别
@property (nonatomic,strong)NSString *userAvatar;            //用户头像
@property (nonatomic,strong)NSString *userNickname;          //用户昵称
@property (nonatomic,strong)NSString *userId;
@property (nonatomic,strong)NSString *userCity;

@property (nonatomic,strong)NSString *rongToken;
@property (nonatomic,strong)NSString *qnToken;
@property (nonatomic,strong)NSString *userToken;

@property (nonatomic,strong)NSString *userDeviceumtoken;

- (BOOL)currentUser;

- (void)clearUser;

- (void)loginInWith:(EILoginModel *)model;

- (EIUserModel *)getUser;

- (BOOL)checkTokenStampExpired;

@end
