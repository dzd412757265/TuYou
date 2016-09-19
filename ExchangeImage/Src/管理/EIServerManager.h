//
//  EIDataReceiver.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/7.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

/**
    图片的收发管理
**/

#import <Foundation/Foundation.h>
#import "SingletonHelper.h"
#import <RongIMLib/RongIMLib.h>

@class EIMessageModel;
@class EIPlazaDisplayModel;
@class EIPlazaResponseModel;

@interface EIServerManager : NSObject<RCIMClientReceiveMessageDelegate,RCConnectionStatusChangeDelegate>

AS_SINGLETON(EIServerManager)

- (void)sendData:(EIPlazaDisplayModel *)virtualModel actualModel:(EIMessageModel *)receiveData;

- (void)receiveData:(EIMessageModel *)model;

- (void)receiveDataWithRemoteNotification:(NSDictionary *)info;

@property (nonatomic, strong)NSString *messageTarget;

@end
