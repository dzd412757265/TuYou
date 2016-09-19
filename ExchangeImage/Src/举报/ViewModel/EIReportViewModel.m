//
//  EIReportViewModel.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/21.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIReportViewModel.h"
#import "EIRequest.h"
#import "EINetworkTool.h"
#import "EIUserCenter.h"
@implementation EIReportViewModel

-(void)reportUser:(NSString *)targetId hostId:(NSString *)hostId hostType:(int)hostType reasons:(NSMutableArray *)reasons completedBlock:(void (^)(NSError *))completedBlock
{
    
    NSString *reasonString = [reasons componentsJoinedByString:@";"];
    
    NSLog(@"reasonString is %@",reasonString);
    EIRequest *request =[EIRequest request];
    
    request.method = HttpMethod_POST;
    
    request.path = @"/v1.0/reports";
    
    NSDictionary *dict = @{
                           @"target_id" : targetId,
                           @"host_id" :hostId,
                           @"host_type":@(hostType),
                           @"reasons":reasonString
                           };
    
    request.httpHeaderFields = @{@"EXP-User-Token":[EIUserCenter sharedInstance].userToken};
    
    [request.params addEntriesFromDictionary:dict];
    
    [ EINetworkTool networkTool:request success:^(NSDictionary * object) {
        
        completedBlock(nil);
        
    } failure:^(NSError * error) {
        
        completedBlock(error);
        
    }];

}
@end
