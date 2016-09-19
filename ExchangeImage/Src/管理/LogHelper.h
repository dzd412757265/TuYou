//
//  LogHelper.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/27.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingletonHelper.h"

@interface LogHelper : NSObject

AS_SINGLETON(LogHelper)

- (void)setLog:(NSString *)object;

- (void)setLogs:(NSString *)object,...;

- (void)setLogArr:(NSArray *)objects;

- (NSString *)getLogs;

- (void)clearLogs;

@end
