//
//  EIMessageListModel.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/14.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIMessageListModel.h"

@implementation EIMessageListModel

- (void)setUserModel:(EIUserModel *)userModel
{
    self.user_id = userModel.user_id;
    self.avatar = userModel.avatar;
    self.nickname = userModel.nickname;
    self.sex = userModel.sex;
    self.city = userModel.city;
}
@end
