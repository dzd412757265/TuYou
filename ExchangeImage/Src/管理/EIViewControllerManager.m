//
//  EIMainSwitchViewController.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/8/2.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIViewControllerManager.h"
#import "EIUserCenter.h"
#import "EILoginViewController.h"
#import "EIMainDrawerController.h"
#import "EINewLoginViewController.h"
#import "EIBaseNavigationController.h"
#import "EINetworkTool.h"
#import "EIBaseViewController.h"
#import "EICommonHelper.h"
#import "EIRequest.h"
#import "WXApi.h"
#import "EIDefines.h"

#define IsLoginByWX_KEY  @"kIsLoginByWX"

@implementation EIViewControllerManager

DEF_SINGLETON(EIViewControllerManager)

- (void)loginIn{
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    if (![window.rootViewController isKindOfClass:[EIMainDrawerController class]]) {
        window.rootViewController = [EIMainDrawerController DrawerVC];
    }
}

- (void)loginOut{
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    [[EIUserCenter sharedInstance]clearUser];
    
    BOOL loginByWX = [[NSUserDefaults standardUserDefaults] boolForKey:IsLoginByWX_KEY];
    if (loginByWX) {
        if (![window.rootViewController isKindOfClass:[EILoginViewController class]]) {
            window.rootViewController = [[EILoginViewController alloc] init];
        }
    }else{
        window.rootViewController = [[EIBaseNavigationController alloc] initWithRootViewController:[[EINewLoginViewController alloc] init]];
    }
}

- (void)initViewController{
    
    if ([[EIUserCenter sharedInstance]currentUser] && ![[EIUserCenter sharedInstance] checkTokenStampExpired]) {
        //如果用户已经登录并且在token没有过期的情况下，直接进入主界面
        [self loginIn];
    }else{
        //如果用户没有登录，进入登录界面
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        
        EIBaseViewController *vcHub = [[EIBaseViewController alloc] init];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:vcHub.view.bounds];
        imageView.image = [UIImage imageNamed:[EICommonHelper splashImageNameForOrientation:UIDeviceOrientationPortrait]];
        [vcHub.view addSubview:imageView];
        
        window.rootViewController = vcHub;
        
        EIRequest *request = [EIRequest request];
        request.method = HttpMethod_GET;
        request.timeoutInterval = 5.f;
        request.path = @"/v1.0/ios/params";
        [request.params addEntriesFromDictionary:@{@"ver":XcodeAppVersion}];
        
        [EINetworkTool networkTool:request success:^(NSDictionary * response) {
            
            if ([response objectForKey:@"usr_pwd_pg"]) {
                int value = [[response objectForKey:@"usr_pwd_pg"] intValue];
                if (value == 0) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IsLoginByWX_KEY];
                }else{
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IsLoginByWX_KEY];
                }
            }else{
                NSLog(@"Key不存在");
                if ([WXApi isWXAppInstalled]) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IsLoginByWX_KEY];
                }else{
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IsLoginByWX_KEY];
                }
            }
            
            [self loginOut];
        } failure:^(NSError *error) {
            
            if ([WXApi isWXAppInstalled]) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IsLoginByWX_KEY];
            }else{
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IsLoginByWX_KEY];
            }
            
            [self loginOut];
        }];
    }
}

@end
