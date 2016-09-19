//
//  EIReportTC.h
//  ExchangeImage
//
//  Created by 张博成 on 16/7/21.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIBaseTableViewController.h"

@interface EIReportTC : EIBaseTableViewController

@property (nonatomic, strong)NSString *targetId;

@property (nonatomic, strong)NSString *hostId;

- (instancetype)initWithTargetId:(NSString *)targetId;

- (instancetype)initWithTargetId:(NSString *)targetId WithhostId:(NSString *)hostId;

@end
