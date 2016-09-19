//
//  EIReportViewModel.h
//  ExchangeImage
//
//  Created by 张博成 on 16/7/21.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIBaseViewModel.h"

@interface EIReportViewModel : EIBaseViewModel

- (void)reportUser:(NSString *)targetId hostId:(NSString *)hostId hostType:(int)hostType reasons:(NSMutableArray *)reasons completedBlock:(void(^)(NSError *))completedBlock;
@end
