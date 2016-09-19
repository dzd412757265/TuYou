//
//  EIMessageListModel.h
//  ExchangeImage
//
//  Created by 张博成 on 16/7/14.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//
#import "EIUserModel.h"

@interface EIMessageListModel : EIUserModel

@property (nonatomic, strong)NSNumber <Optional>*messageNumber;

@property (nonatomic, strong)NSString <Optional>*targetId;

@property (nonatomic, strong)NSString <Optional>*timeString;

- (void)setUserModel:(EIUserModel *)userModel;

@end
