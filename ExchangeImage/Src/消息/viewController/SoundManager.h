//
//  CDSoundManager.h
//  LeanChatLib
//
//  Created by lzw on 15/7/2.
//  Copyright (c) 2015年 LeanCloud（Bug汇报：QQ1356701892）.  All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  声音设置、播放管理类。设置带有持久化功能。会把设置写入 NSUserDefaults，并在启动时加载
 */

@interface SoundManager : NSObject

/**
 *  单例
 *  @return
 */
+ (SoundManager *)manager;

/**
 *  消息到来了，但没有在聊天，是否需要振动
 */
//@property (nonatomic, assign) BOOL needVibrateWhenNotChatting;

/**
 * 消息到来了，但没有在聊天，是否需要播放音效
 */
//@property (nonatomic, assign) BOOL needPlaySoundWhenNotChatting;

/**
 *  聊着天时，发送和接收消息，是否需要音效
 */
//@property (nonatomic, assign) BOOL needPlaySoundWhenChatting;

/**
 * 用户设置打开还是关闭消息声音的状态
 */
@property (nonatomic, assign) BOOL soundOff;
/**
 *  根据需要播放发送消息音效
 */
- (void)playSendSoundIfNeed;

/**
 *  根据需要播放接收消息音效
 */
- (void)playReceiveSoundIfNeed;

/**
 *  根据需要播放较响亮的接收消息音效
 */
- (void)playLoudReceiveSoundIfNeed;


- (void)playSwipeSoundIfNeed;

/**
 *  根据需要来振动
 */
- (void)vibrateIfNeed;

@end
