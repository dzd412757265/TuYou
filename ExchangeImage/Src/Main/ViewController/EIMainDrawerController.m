//
//  EIMainDrawerController.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/8.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIMainDrawerController.h"
#import "EIBaseViewController.h"
#import "EIPlazaViewController.h"
#import "EIBaseNavigationController.h"
#import "EIDefines.h"
#import "MMDrawerVisualState.h"
#import "EIMessageListTC.h"
#import "EIIndividualMessageVC.h"
#import "EIUserCenter.h"
#import <RongIMLib/RongIMLib.h>

#import "SensorsAnalyticsSDK.h"
#import "EIUserCenter.h"
#import "EIUserLocalUpHelper.h"

@interface EIMainDrawerController ()

@end

@implementation EIMainDrawerController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    
    [[SensorsAnalyticsSDK sharedInstance] identify:[EIUserCenter sharedInstance].userId];
    
    [[[SensorsAnalyticsSDK sharedInstance] people] set:@"Gender" to:[NSNumber numberWithInteger:[EIUserCenter sharedInstance].userSex]];
    
    [[SensorsAnalyticsSDK sharedInstance] track:@"AppLoaded"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initDrawer{
    
    EIPlazaViewController *plazaVC = [[EIPlazaViewController alloc] init];
    
    EIIndividualMessageVC *leftVC = [[EIIndividualMessageVC alloc] init];
    EIMessageListTC *rightVC = [[EIMessageListTC alloc] init];
    
    EIBaseNavigationController *plazaNav = [[EIBaseNavigationController alloc] initWithRootViewController:plazaVC];
    EIBaseNavigationController *leftNav = [[EIBaseNavigationController alloc] initWithRootViewController:leftVC];
    EIBaseNavigationController *rightNav = [[EIBaseNavigationController alloc] initWithRootViewController:rightVC];
    
    self = [super initWithCenterViewController:plazaNav
                      leftDrawerViewController:leftNav
                     rightDrawerViewController:rightNav];
    [self setShowsShadow:NO];
    [self setRestorationIdentifier:@"EIMainDrawerController"];
    [self setMaximumRightDrawerWidth:kScreen_Width];
    [self setMaximumLeftDrawerWidth:kScreen_Width];
    [self setShowsShadow:NO];
    [self setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [self setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
        MMDrawerControllerDrawerVisualStateBlock block = [MMDrawerVisualState parallaxVisualStateBlockWithParallaxFactor:4.0];
        block(drawerController,drawerSide,percentVisible);
    }];
    
    return self;
}

+ (id)DrawerVC{
    return [[self alloc] initDrawer];
}

- (void)getUserLocation
{
    //获取用户的地理信息
    [[EIUserLocalUpHelper sharedInstance] CurrentLocationIdentifier];
}
- (void)openRongClound
{
    [[RCIMClient sharedRCIMClient] connectWithToken:[EIUserCenter sharedInstance].rongToken
                                            success:^(NSString *userId) {
                                                //NSLog(@"登录成功。当前登录的用户ID：%@", userId);
                                            } error:^(RCConnectErrorCode status) {
                                                NSLog(@"登录的错误码为:%ld", (long)status);
                                            } tokenIncorrect:^{
                                                //token过期或者不正确。
                                                //如果设置了token有效期并且token过期，请重新请求您的服务器获取新的token
                                                //如果没有设置token有效期却提示token错误，请检查您客户端和服务器的appkey是否匹配，还有检查您获取token的流程。
                                                NSLog(@"token错误");
                                            }];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self openRongClound];
    [self getUserLocation];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[RCIMClient sharedRCIMClient] logout];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
