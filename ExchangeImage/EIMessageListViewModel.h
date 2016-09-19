//
//  EIMessageListViewModel.h
//  ExchangeImage
//
//  Created by 张博成 on 16/7/14.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIBaseViewModel.h"
#import "EIMessageListModel.h"
#import <RongIMLib/RongIMLib.h>
@interface EIMessageListViewModel : EIBaseViewModel


@property(nonatomic, strong)NSArray *dataSource;

@property(nonatomic, strong)NSMutableArray *userList;

- (void)getChartListSuccess:(void(^)(void))success failure:(void(^)(void))failure;

- (void)removeConversation:(NSString *)targetId;

@end
