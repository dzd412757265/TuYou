//
//  EIMessageDetailTC.h
//  ExchangeImage
//
//  Created by 张博成 on 16/7/14.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIBaseTableViewController.h"
#import "EIMessageDetailViewModel.h"
@interface EIMessageDetailTC : EIBaseTableViewController

@property (nonatomic, strong)NSString *targetId;
@property (nonatomic, strong)NSString *avatar;
@property (nonatomic, strong)NSString *nickname;

- (instancetype)initWithModel:(EIUserModel *)model;

@property (nonatomic, assign)int count;

@end
