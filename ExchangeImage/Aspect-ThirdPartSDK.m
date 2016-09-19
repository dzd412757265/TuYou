//
//  Aspect-ThirdPartSDK.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/14.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
// In an aspect file you create (.m file).
#import <XAspect/XAspect.h>
#import "AppDelegate.h"
#import "WXApi.h"
#import "EIDefines.h"
#import "EIUserCenter.h"
#import "UMessage.h"
#import <QiniuSDK.h>
#import "SensorsAnalyticsSDK.h"
#import "UMFeedback.h"

#import "UMMobClick/MobClick.h"

// A aspect namespace for the aspect implementation field (mandatory).
#define AtAspect ThirdPartSDK

// Create an aspect patch field for the class you want to add the aspect patches to.
#define AtAspectOfClass AppDelegate
@classPatchField(AppDelegate)

// Intercept the target objc message.

AspectPatch(-, void,application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions) {

#pragma mark ------WeiXin
    [WXApi registerApp:@"wxee92fccc7d94d2bc"];
    
#pragma mark ---------Umen
    //设置 AppKey 及 LaunchOptions
    [UMessage startWithAppkey:@"577b52cd67e58e174c0003e8" launchOptions:launchOptions];
    
    //UM反馈
    [UMFeedback setAppkey:@"577b52cd67e58e174c0003e8"];
    
    //UM统计
    [MobClick setAppVersion:XcodeAppVersion];
    
    UMConfigInstance.appKey = @"577b52cd67e58e174c0003e8";
    [MobClick startWithConfigure:UMConfigInstance];
    
    //1.3.0版本开始简化初始化过程。如不需要交互式的通知，下面用下面一句话注册通知即可。
    [UMessage registerForRemoteNotifications];
    /**  如果你期望使用交互式(只有iOS 8.0及以上有)的通知，请参考下面注释部分的初始化代码 **/
     //register remoteNotification types （iOS 8.0及其以上版本）
//     UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
//     action1.identifier = @"action1_identifier";
//     action1.title=@"Accept";
//     action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
//     
//     UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
//     action2.identifier = @"action2_identifier";
//     action2.title=@"Reject";
//     action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
//     action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
//     action2.destructive = YES;
//     
//     UIMutableUserNotificationCategory *actionCategory = [[UIMutableUserNotificationCategory alloc] init];
//     actionCategory.identifier = @"category1";//这组动作的唯一标示
//     [actionCategory setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
//     
//     NSSet *categories = [NSSet setWithObject:actionCategory];
    
     //如果默认使用角标，文字和声音全部打开，请用下面的方法
     //[UMessage registerForRemoteNotifications:categories];
     
     //如果对角标，文字和声音的取舍，请用下面的方法
//     UIRemoteNotificationType types7 = UIRemoteNotificationTypeBadge;
//     UIUserNotificationType types8 = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
//    
//     [UMessage registerForRemoteNotifications:categories withTypesForIos7:types7 withTypesForIos8:types8];
    //for log
    [UMessage setLogEnabled:YES];
    
    // 初始化 SDK
    [SensorsAnalyticsSDK sharedInstanceWithServerURL:@"http://jianjian.cloud.sensorsdata.cn:8006/sa?project=picture&token=dd6d40595499a212"
                                     andConfigureURL:@"http://jianjian.cloud.sensorsdata.cn/api/vtrack/config?project=picture"
                                        andDebugMode:SensorsAnalyticsDebugOff];
    
    XAMessageForward(application:application didFinishLaunchingWithOptions:launchOptions);
}

@end
#undef AtAspectOfClass
#undef AtAspect