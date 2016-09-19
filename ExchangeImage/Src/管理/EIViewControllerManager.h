//
//  EIMainSwitchViewController.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/8/2.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingletonHelper.h"

@interface EIViewControllerManager : NSObject

AS_SINGLETON(EIViewControllerManager)

- (void)loginIn;
- (void)loginOut;

- (void)initViewController;

@end
