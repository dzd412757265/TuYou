//
//  Aspect-Window.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/14.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

// In an aspect file you create (.m file).
#import <Foundation/Foundation.h>
#import <XAspect/XAspect.h>
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import <RongIMLib/RongIMLib.h>
#import "EIViewControllerManager.h"

#import "EIUserLocalUpHelper.h"
// A aspect namespace for the aspect implementation field (mandatory).
#define AtAspect Window

// Create an aspect patch field for the class you want to add the aspect patches to.
#define AtAspectOfClass AppDelegate
@classPatchField(AppDelegate)

// Intercept the target objc message.
AspectPatch(-, void, application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions)
{
    [SVProgressHUD setMinimumDismissTimeInterval:1.f];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
#pragma mark ----- Rongyun
    [[RCIMClient sharedRCIMClient] initWithAppKey:@"x4vkb1qpvp9qk"];
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyWindow];
    //    [self loginIn];
    
    
    [[EIViewControllerManager sharedInstance] initViewController];
//    if ([[EIUserCenter sharedInstance]currentUser] && ![[EIUserCenter sharedInstance] checkTokenStampExpired]) {
//        //如果用户已经登录并且在token没有过期的情况下，直接进入主界面
//        [self loginIn];
//    }else{
//        //如果用户没有登录，进入登陆界面
//        [self loginOut];
//    }

    
    // Forward the message to the source implementation.
    
     XAMessageForward(application:application didFinishLaunchingWithOptions:launchOptions);}

@end
#undef AtAspectOfClass
#undef AtAspect