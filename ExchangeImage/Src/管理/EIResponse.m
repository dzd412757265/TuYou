//
//  EIResponseModel.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/13.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIResponse.h"
#import "EIDefines.h"
#import "NSObject+EasyJSON.h"
#import "EICommonHelper.h"

@interface EIResponse()

@end

@implementation EIResponse

+ (id)responseWithObject:(NSDictionary *)object
                 success:(void (^)(id))successBlock
                 failure:(void (^)(NSError *))failureBlock{
    return [[self alloc] initWithResponseObject:object success:successBlock failure:failureBlock];
}

- (id)initWithResponseObject:(NSDictionary *)object success:(void(^)(id))successBlock failure:(void(^)(NSError *))failureBlock{
    JSONModelError *error;
    self = [super initWithDictionary:object error:&error];
    if (error) {
        failureBlock(error);
    }else{
        if (self.code.integerValue == 0) {
            successBlock(self.data);
        }else{
            DLog(@"code error:%@",self.code);
            
            NSString *errorMsg = [EICommonHelper errorList][self.code.stringValue];
            if (errorMsg.isNotEmpty) {
                failureBlock([EICommonHelper createError:self.code.integerValue description:errorMsg]);
            }else{
                failureBlock([EICommonHelper createError:self.code.integerValue description:self.msg]);
            }
        }
    }
    return self;
}



@end
