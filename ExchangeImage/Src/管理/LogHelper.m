//
//  LogHelper.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/27.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "LogHelper.h"
#import "NSObject+EasyJSON.h"

@interface LogHelper()

@property (nonatomic , strong)NSMutableArray *datas;

@end

@implementation LogHelper

DEF_SINGLETON(LogHelper)

- (NSMutableArray *)datas{
    if (!_datas) {
        _datas = [[NSMutableArray alloc] init];
    }
    return _datas;
}

- (void)setLog:(NSString *)object{
    [self.datas addObject:[NSString stringWithFormat:@"%@",object]];
}

- (NSString *)getLogs{
    return [self.datas componentsJoinedByString:@"\n\n"];
}

- (void)setLogArr:(NSArray *)objects{
    if (objects.count == 0) {
        return ;
    }
    //获取系统当前时间
    NSDate *currentDate = [NSDate date];
    //用于格式化NSDate对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置格式：zzz表示时区
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSDate转NSString
    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    
    [self.datas addObject:[NSString stringWithFormat:@"*****%@*****",currentDateString]];
    
    [objects enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isNotEmpty) {
            [self.datas addObject:obj];
        }
    }];
}

- (void)setLogs:(NSString *)object, ...{
    
    //获取系统当前时间
    NSDate *currentDate = [NSDate date];
    //用于格式化NSDate对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置格式：zzz表示时区
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSDate转NSString
    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    
    [self.datas addObject:[NSString stringWithFormat:@"*****%@*****",currentDateString]];
    
    va_list args;
    
    va_start(args,object);
    if(object){
        
        [self.datas addObject:[NSString stringWithString:object]];
        
        NSObject *otherObject;
        while((otherObject = va_arg(args,NSString *))){
            //依次取得所有参数
            [self.datas addObject:otherObject];
        }
    }
    
    va_end(args);
}

- (void)clearLogs
{
    [self.datas removeAllObjects];
}

@end
