//
//  EIRequest.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/13.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EIResponseModel;

typedef NS_ENUM(NSInteger,HttpMethod){
    HttpMethod_GET = 1,
    HttpMethod_POST,
    HttpMethod_PUT,
    HttpMethod_DELETE,
    HttpMethod_PATCH,
    HttpMethod_UNKNOW
};

@interface EIRequest : NSObject

@property (nonatomic , strong)NSMutableDictionary *params;
@property (nonatomic , strong)NSString *path;
@property (nonatomic , assign)HttpMethod method;

@property (nonatomic , assign)NSTimeInterval timeoutInterval;

@property (nonatomic , strong)NSString *SCHEME;
@property (nonatomic , strong)NSString *host;

@property(nonatomic,strong)NSDictionary *httpHeaderFields;
@property(nonatomic,strong)NSSet *acceptableContentTypes;

+ (EIRequest *)request;

@end
