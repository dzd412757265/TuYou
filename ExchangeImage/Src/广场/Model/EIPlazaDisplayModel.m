//
//  EIPlazaDisplayModel.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/6.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIPlazaDisplayModel.h"
#import "NSObject+EasyJSON.h"

@implementation EIPlazaDisplayModel

- (id)initWithBaseModel:(EIMessageModel *)model{
    self = [super init];
    if (self) {
        self.baseModel = model;
        self.sendFailed = NO;
        self.uploadPercent = -1.f;
    }
    return self;
}

@end
