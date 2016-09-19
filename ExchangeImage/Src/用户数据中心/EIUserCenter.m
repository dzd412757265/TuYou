//
//  EIUserCenter.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/6.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIUserCenter.h"
#import "NSObject+EasyJSON.h"
#import "EIUserModel.h"
#import "EICommonHelper.h"

@interface EIUserCenter()
{
   SexType _userSex;
   NSString * _userAvatar ;
    NSString * _userNickname ;
    NSString * _userId;
    NSString * _userCity;
    NSString * _rongToken;
    NSString * _qnToken;
    NSString * _userToken;
    
    NSString * _userDeviceumtoken;
}
@end

@implementation EIUserCenter

DEF_SINGLETON(EIUserCenter)

-(instancetype)init{
    self = [super init];
    if(self){
        
        self.userSex = [[[NSUserDefaults standardUserDefaults] objectForKey:user_sex] intValue];
        self.userAvatar = [[NSUserDefaults standardUserDefaults] objectForKey:user_avatar];
        self.userNickname = [[NSUserDefaults standardUserDefaults] objectForKey:user_nickname];
        self.userId = [[NSUserDefaults standardUserDefaults] objectForKey:user_id];
        self.userCity = [[NSUserDefaults standardUserDefaults] objectForKey:user_city];
        self.rongToken = [[NSUserDefaults standardUserDefaults] objectForKey:rong_token];
        self.qnToken = [[NSUserDefaults standardUserDefaults]objectForKey:qn_token];
        self.userToken = [[NSUserDefaults standardUserDefaults]objectForKey:user_token];
        
        self.userDeviceumtoken = [[NSUserDefaults standardUserDefaults]objectForKey:user_Deviceumtoken];
    }
    return self;
}

- (BOOL)currentUser
{
    if (self.userToken.isNotEmpty && self.qnToken.isNotEmpty && self.rongToken.isNotEmpty && self.userId.isNotEmpty) {
        return YES;
    }else{
        return NO;
    }
}

- (void)clearUser
{
    self.userSex = SexTypeNone;
    
    self.userAvatar = nil;
    
    self.userNickname = nil;
    
    self.userId = nil;
    
    self.userCity = nil;
    
//    self.rongToken = nil;
    
    self.qnToken = nil;
    
    self.userToken = nil;
    
//    self.userDeviceumtoken = nil;
}

- (void)loginInWith:(EILoginModel *)model
{
    if (model) {
        
        self.userSex = [model.user.sex intValue];
        
        self.userAvatar = model.user.avatar;
        
        self.userNickname = model.user.nickname;
        
        self.userId = model.user.user_id;
        
        self.userCity = model.user.city;
        
        self.rongToken = model.rong_token;
        
        self.qnToken = model.qn_token;
        
        self.userToken = model.user_token;
    }
}
- (SexType)userSex
{
    if (!_userSex) {
        _userSex = [[[NSUserDefaults standardUserDefaults] objectForKey:user_sex] intValue];
    }
    
    return _userSex;
}

- (void)setUserSex:(SexType)userSex
{
    if (userSex == SexTypeNone) {
        _userSex = userSex;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:user_sex];
    }else if (_userSex != userSex) {
        
        [[NSUserDefaults standardUserDefaults] setObject:@(userSex) forKey:user_sex];
        
        _userSex = userSex;
    }
    
}

//- (NSString *)userAvatar
//{
//    
//    if (!_userAvatar.isNotEmpty) {
//        _userAvatar = [[NSUserDefaults standardUserDefaults] objectForKey:user_avatar];
//    }
//    return _userAvatar;
//}

- (void)setUserAvatar:(NSString *)userAvatar
{
    
    if (!userAvatar.isNotEmpty) {
        _userAvatar = @"";
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:user_avatar];
    }else if (![_userAvatar isEqualToString:userAvatar]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:userAvatar forKey:user_avatar];
        
        _userAvatar = userAvatar;
        
    }
}

//- (NSString *)userNickname
//{
//    if (!_userNickname.isNotEmpty) {
//        
//        _userNickname = [[NSUserDefaults standardUserDefaults] objectForKey:user_nickname];
//    }
//
//    return _userNickname;
//}

- (void)setUserNickname:(NSString *)userNickname
{
    if (!userNickname.isNotEmpty) {
        _userNickname = @"";
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:user_nickname];
    }else if (![_userNickname isEqualToString:userNickname]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:userNickname forKey:user_nickname];
        
        _userNickname = userNickname;
    }
    
}

//- (NSString *)userId
//{
//    if (!_userId.isNotEmpty) {
//        
//        _userId = [[NSUserDefaults standardUserDefaults] objectForKey:user_id];
//    }
//    
//    return _userId;
//}

- (void)setUserId:(NSString *)userId
{
    
    if (!userId.isNotEmpty) {
        _userId = @"";
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:user_id];
    }else if (![_userId isEqualToString:userId]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:user_id];
        _userId = userId;
    }
}

//- (NSString *)userCity
//{
//    if (!_userCity.isNotEmpty) {
//        
//        _userCity = [[NSUserDefaults standardUserDefaults] objectForKey:user_city];
//    }
//    
//    return _userCity;
//}

- (void)setUserCity:(NSString *)userCity
{
    if (!userCity.isNotEmpty) {
        _userCity = @"";
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:user_city];
        
    }else if (![_userCity isEqualToString:userCity]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:userCity forKey:user_city];
        
        _userCity = userCity;
    }
}

//- (NSString *)rongToken
//{
//    if (!_rongToken.isNotEmpty) {
//        
//        _rongToken = [[NSUserDefaults standardUserDefaults] objectForKey:rong_token];
//    }
//
//    return _rongToken;
//}

- (void)setRongToken:(NSString *)rongToken
{
    if (!rongToken.isNotEmpty) {
        _rongToken = @"";
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:rong_token];
    }else if (![_rongToken isEqualToString:rongToken]) {
        
        [[NSUserDefaults standardUserDefaults]setObject:rongToken forKey:rong_token];
        
        _rongToken = rongToken;
    }
}
//
//- (NSString *)qnToken
//{
//    if (!_qnToken.isNotEmpty) {
//        
//        _qnToken = [[NSUserDefaults standardUserDefaults]objectForKey:qn_token];
//
//    }
//    
//    return _qnToken;
//}

- (void)setQnToken:(NSString *)qnToken
{
    if (!qnToken.isNotEmpty) {
        _qnToken = @"";
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:qn_token];
    }else if (![_qnToken isEqualToString:qnToken]) {
        
        [[NSUserDefaults standardUserDefaults]setObject:qnToken forKey:qn_token];
        
        _qnToken = qnToken;
    }
}

//- (NSString *)userToken
//{
//    if (!_userToken.isNotEmpty) {
//        
//        _userToken = [[NSUserDefaults standardUserDefaults]objectForKey:user_token];
//    }
//    
//    return _userToken;
//}

- (void)setUserToken:(NSString *)userToken
{
    if (!userToken.isNotEmpty) {
        _userToken = @"";
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:user_token];
    }else if (![_userToken isEqualToString:userToken]) {
        
        [[NSUserDefaults standardUserDefaults]setObject:userToken forKey:user_token];
        _userToken = userToken;
    }
}

- (void)setUserDeviceumtoken:(NSString *)userDeviceumtoken
{
    if (!userDeviceumtoken.isNotEmpty) {
        _userDeviceumtoken = @"";
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:user_Deviceumtoken];
    }else if (![_userDeviceumtoken isEqualToString:userDeviceumtoken]) {
       
        [[NSUserDefaults standardUserDefaults]setObject:userDeviceumtoken forKey:user_Deviceumtoken];
        _userDeviceumtoken = userDeviceumtoken;
    }
}

- (EIUserModel *)getUser{
    EIUserModel *model = [[EIUserModel alloc] init];
    model.user_id = [NSString stringWithString:self.userId];
    model.avatar = [NSString stringWithString:self.userAvatar];
    model.nickname = [NSString stringWithString:self.userNickname];
    model.sex = [NSNumber numberWithInteger:self.userSex];
    model.city = [NSString stringWithString:self.userCity];
    return model;
}

- (BOOL)checkTokenStampExpired
{
    if (!self.currentUser) {
        return NO;
    }
    NSInteger lastTimeStamp = [[NSUserDefaults standardUserDefaults] integerForKey:token_stamp];
    NSInteger nowTimeStamp = [EICommonHelper systemDate];
    if (nowTimeStamp - lastTimeStamp > 86400 * 3) {
        //超过三天,uploadtoken需要刷新
        return YES;
    }
    
    return NO;
}

@end
