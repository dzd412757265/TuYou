//
//  EIRequest.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/13.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIRequest.h"

@implementation EIRequest

+ (EIRequest *)request{
    return [[self alloc] initWithRequest];
}

- (id)initWithRequest{
    self = [super init];
    if (self) {
        [self loadRequest];
    }
    return self;
}

- (void)loadRequest{
//    self.SCHEME = @"http";
//    self.host = @"exp-staging.jianjian.tv";
    
//    self.SCHEME = @"http";
//    self.host = @"101.200.219.127";
    
    self.SCHEME = @"https";
    self.host = @"exp.jianjian.tv";
    
    self.path = @"";
    self.method = HttpMethod_UNKNOW;
    self.params = [[NSMutableDictionary alloc] init];
    
    self.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];
}

@end
