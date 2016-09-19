//
//  EIUserLocalUpHelper.h
//  ExchangeImage
//
//  Created by 张博成 on 16/7/20.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingletonHelper.h"
#import <CoreLocation/CoreLocation.h>
@interface EIUserLocalUpHelper : NSObject <CLLocationManagerDelegate>

AS_SINGLETON(EIUserLocalUpHelper)

@property (nonatomic, strong)CLLocationManager *locationManager;

@property (nonatomic,strong)CLLocation *currentLocation;

- (void)CurrentLocationIdentifier;
@end
