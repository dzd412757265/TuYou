//
//  EIMessageManager.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/16.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIMessageManager.h"
#import "EIDefines.h"
#import "SoundManager.h"

@implementation EIMessageManager
DEF_SINGLETON(EIMessageManager)

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
}

#pragma mark --- RCIMClientReceiveMessageDelegate

- (void)onReceived:(RCMessage *)message
              left:(int)nLeft
            object:(id)object
{
    NSLog(@"message.targetId is %@",[EIMessageManager sharedInstance].messageTarget);
    if (![message.targetId isEqualToString:[EIMessageManager sharedInstance].messageTarget]) {
        // 有声音提示
       
        [[SoundManager manager] playLoudReceiveSoundIfNeed];
        
        dispatch_main_async_safe(^{
            [[NSNotificationCenter defaultCenter]postNotificationName:EINotificationUnreadMessage object:self userInfo:@{@"data" : @(YES)}];
        });
        
    }else{
        
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:EINotificationReceiveMessage object:self userInfo:@{@"data":message}];
}
@end
