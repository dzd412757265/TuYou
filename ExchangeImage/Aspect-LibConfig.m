//
//  Aspect-LibConfig.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/14.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
// In an aspect file you create (.m file).
#import <Foundation/Foundation.h>
#import <XAspect/XAspect.h>
#import "AppDelegate.h"
#import "SDWebImageManager.h"
#import "NSObject+EasyJSON.h"

// A aspect namespace for the aspect implementation field (mandatory).
#define AtAspect LibConfig

// Create an aspect patch field for the class you want to add the aspect patches to.
#define AtAspectOfClass AppDelegate
@classPatchField(AppDelegate)

// Intercept the target objc message.
AspectPatch(-, void,application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions) {
    
    SDWebImageManager.sharedManager.cacheKeyFilter = ^(NSURL *url) {
        
        if(url.scheme.isNotEmpty && url.host.isNotEmpty && url.path.isNotEmpty && url.query.isNotEmpty){
            NSArray *queryArr = [url.query componentsSeparatedByString:@"&"];
            //将缩略图的参数截取出来
            __block NSString *imageViewParams = @"";
            [queryArr enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                //imageView 缩略图
                if([obj rangeOfString:@"imageView"].length > 0){
                    imageViewParams = obj;
                }
            }];
            return [NSString stringWithFormat:@"%@%@%@%@",url.scheme,url.host,url.path,imageViewParams];
        }
        
        return [url absoluteString];
    };
    
    XAMessageForward(application:application didFinishLaunchingWithOptions:launchOptions);
}

@end
#undef AtAspectOfClass
#undef AtAspect