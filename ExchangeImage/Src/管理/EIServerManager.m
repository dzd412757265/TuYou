//
//  EIDataReceiver.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/7.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIServerManager.h"
#import "EIDataCacheManager.h"
#import "EIDefines.h"

#import "EIMessageModel.h"
#import "EIPlazaDisplayModel.h"
#import "EIPlazaResponseModel.h"
#import "EIDefines.h"
#import "EIUserModel.h"
#import "NSObject+EasyJSON.h"


#import "SoundManager.h"
@implementation EIServerManager

DEF_SINGLETON(EIServerManager)
- (instancetype)init
{
    if (self = [super init]) {
        
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    // 设置消息接收监听
    [[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:self object:nil];
    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:self];
}

#pragma mark --- RCIMClientReceiveMessageDelegate

- (void)onReceived:(RCMessage *)message
              left:(int)nLeft
            object:(id)object
{
    if (nLeft > 20) {
        return;
    }
    
    if (message.conversationType == ConversationType_SYSTEM) {
        
        //系统下发的文本消息
        RCTextMessage *systemMessage = (RCTextMessage *)message.content;
        
        NSError *error;
        
        EIMessageModel *newMsg = [[EIMessageModel alloc] initWithString:systemMessage.content error:&error];
        
        [[RCIMClient sharedRCIMClient] removeConversation:ConversationType_SYSTEM targetId:message.targetId];
        
        if (!error) {
            [self receiveData:newMsg];
        }else{
            NSLog(@"解析错误%@",error);
        }
        
    }else{
        //私聊图片消息接受
        
        if (![message.targetId isEqualToString:self.messageTarget]) {
            // 有声音提示
            
            [[SoundManager manager] playLoudReceiveSoundIfNeed];
            
            dispatch_main_async_safe(^{
                [[NSNotificationCenter defaultCenter]postNotificationName:EINotificationUnreadMessage object:self userInfo:@{@"data" : @(YES)}];
            })
            
            
        }else{
            
        }
        dispatch_main_async_safe(^{
            [[NSNotificationCenter defaultCenter]postNotificationName:EINotificationReceiveMessage object:self userInfo:@{@"data":message}];
        })
        
        
        //如果程序在后台,发送本地推送
        if (!([UIApplication sharedApplication].applicationState == UIApplicationStateActive)) {
            //定义本地通知对象
            UILocalNotification *notification=[[UILocalNotification alloc]init];
            //设置调用时间
            notification.fireDate=[NSDate dateWithTimeIntervalSinceNow:1.0];//通知触发的时间，10s以后
            notification.repeatInterval=1;//通知重复次数
            //notification.repeatCalendar=[NSCalendar currentCalendar];//当前日历，使用前最好设置时区等信息以便能够自动同步时间
            
            //设置通知属性
            notification.alertBody=@"您有新的消息"; //通知主体
            notification.applicationIconBadgeNumber = [[RCIMClient sharedRCIMClient]getTotalUnreadCount];//应用程序图标右上角显示的消息数
            notification.alertAction=@"打开应用"; //待机界面的滑动动作提示
            notification.alertLaunchImage=@"Default";//通过点击通知打开应用时的启动图片,这里使用程序启动图片
            notification.soundName=UILocalNotificationDefaultSoundName;//收到通知时播放的声音，默认消息声音
            //notification.soundName=@"msg.caf";//通知声音（需要真机才能听到声音）
            
            //设置用户信息
            notification.userInfo=@{@"msg_type":@"tab_message"};//绑定到通知上的其他附加信息
            
            //调用通知
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }

        
    }
    
}

/** 连接状态的监听 **/
- (void)onConnectionStatusChanged:(RCConnectionStatus)status
{
    switch (status) {
        case ConnectionStatus_Unconnected:
            NSLog(@"===========>连接失败和未连接");
            break;
        case ConnectionStatus_UNKNOWN:
            NSLog(@"===========>未知状态");
            break;
        case ConnectionStatus_Connected:
            NSLog(@"===========>连接成功");
            break;
        case ConnectionStatus_NETWORK_UNAVAILABLE:
            NSLog(@"===========>网络不可用");
            break;
        case ConnectionStatus_DISCONN_EXCEPTION:
            NSLog(@"===========>服务器断开连接");
            break;
        default:
            break;
    }
}

- (void)receiveData:(EIMessageModel *)model{
    
    if (!model.msg_id.isNotEmpty) {
        return ;
    }
    //经过一系列下载,转化,再广播
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EIDataCacheManager sharedInstance] receiveImageData:model
                                                        block:^(EIPlazaDisplayModel *displayModel){
                                                            dispatch_main_sync_safe(^{
                                                                [[NSNotificationCenter defaultCenter] postNotificationName:EIReceiveMessageNotification object:nil userInfo:@{@"displayModel":displayModel}];
                                                            })
                                                        }];
    });
}

- (void)sendData:(EIPlazaDisplayModel *)virtualModel actualModel:(EIMessageModel *)receiveData{
    
    //一边存储 一边处理新数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EIDataCacheManager sharedInstance] sendImageData:virtualModel block:^(EIPlazaDisplayModel *actualModel) {
            
            [self receiveData:receiveData];
            
            dispatch_main_sync_safe(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:EISendMessageNotification object:nil userInfo:nil];
            })
        }];
    });
}

- (void)receiveDataWithRemoteNotification:(NSDictionary *)info{
    //弃用
    
//    EIMessageModel *model  = [[EIMessageModel alloc] init];
//    model.isLeft = @(1);
//    if ([info objectForKey:@"msg_id"]) {
//        model.msg_id = [info objectForKey:@"msg_id"];
//    }else{
//        return;
//    }
//    
//    model.user = [[EIUserModel alloc] init];
//    if ([info objectForKey:@"user_id"]) {
//        model.user.user_id = [info objectForKey:@"user_id"];
//    }else{
//        return;
//    }
//    
//    if ([info objectForKey:@"avatar"]) {
//        model.user.avatar = [info objectForKey:@"avatar"];
//    }else{
//        return;
//    }
//    
//    
//    if ([info objectForKey:@"nickname"]) {
//        model.user.nickname = [info objectForKey:@"nickname"];
//    }else{
//        return;
//    }
//    
//    if ([info objectForKey:@"sex"]) {
//        model.user.sex = [NSNumber numberWithInt:[[info objectForKey:@"sex"] intValue]];
//    }else{
//        return;
//    }
//    
//    if ([info objectForKey:@"city"]) {
//        model.user.city = [info objectForKey:@"city"];
//    }else{
//        return;
//    }
//    
//    model.picture = [[EIPictureModel alloc] init];
//    if ([info objectForKey:@"picture_id"]) {
//        model.picture.picture_id = [info objectForKey:@"picture_id"];
//    }else{
//        return;
//    }
//    if ([info objectForKey:@"pic_url"]) {
//        model.picture.thumbnail_url = [[info objectForKey:@"pic_url"] stringByAppendingString:@"?imageView2/0/h/200"];
//        model.picture.origin_url = [info objectForKey:@"pic_url"];
//    }else{
//        return;
//    }
//    
//    if ([info objectForKey:@"time"]) {
//        model.picture.created = [NSNumber numberWithInt:[[info objectForKey:@"time"] intValue]];
//    }else{
//        return ;
//    }
//    
//    
//    [self receiveData:model];
}

@end
