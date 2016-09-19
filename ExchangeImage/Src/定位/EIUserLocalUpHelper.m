//
//  EIUserLocalUpHelper.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/20.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIUserLocalUpHelper.h"
#import "EIDefines.h"
#import "EIRequest.h"
#import "EINetworkTool.h"
#import "SVProgressHUD.h"
#import "EIUserCenter.h"
@implementation EIUserLocalUpHelper

DEF_SINGLETON(EIUserLocalUpHelper)


- (instancetype)init
{
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    
    // kCLLocationAccuracyNearestTenMeters:精度10米
    // kCLLocationAccuracyHundredMeters:精度100 米
    // kCLLocationAccuracyKilometer:精度1000 米
    // kCLLocationAccuracyThreeKilometers:精度3000米
    // kCLLocationAccuracyBest:设备使用电池供电时候最高的精度
    // kCLLocationAccuracyBestForNavigation:导航情况下最高精度，一般要有外接电源时才能使用
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    CLLocationDistance distance=10000.0;//十公里定位一次
    _locationManager.distanceFilter=distance;
}

- (void)CurrentLocationIdentifier
{
    if ([CLLocationManager locationServicesEnabled]) {
        
        if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)) {
            // 取得定位权限，有两个方法，取决于你的定位使用情况
            // 一个是requestAlwaysAuthorization，一个是requestWhenInUseAuthorization
            // [self.locationManager requestAlwaysAuthorization];
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    }
    else {
        NSLog(@"请开启定位功能！");
    }
    //------
}

#pragma mark CClocationDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([error code] == kCLErrorDenied) {
        NSLog(@"访问被拒绝");
    }
    if ([error code] == kCLErrorLocationUnknown) {
        NSLog(@"无法获取位置信息");
        //如果无法获取用户的位置信息那么就给用户的一个默认的位置信息
        
    }
    NSLog(@"errorCode is %@",error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    
    _currentLocation = [locations lastObject];
    
//    NSLog(@"纬度:%f",_currentLocation.coordinate.latitude);
//    NSLog(@"经度:%f",_currentLocation.coordinate.longitude);
//    
//    NSString *userLatitude = [NSString stringWithFormat:@"%f",_currentLocation.coordinate.latitude];
//    
//    NSString *userLongitude = [NSString stringWithFormat:@"%f",_currentLocation.coordinate.longitude];
    

    //[self.locationManager stopUpdatingLocation];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:_currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!error)
         {
             CLPlacemark *placemark = [placemarks lastObject];
             
//             NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
//             NSString *Address = locatedAt;
//             NSString *Area = placemark.locality;
//             NSString *subArea = placemark.subLocality;
//             NSString *Country = placemark.country;
             
             
//             NSString *CountryArea = [NSString stringWithFormat:@"地区:%@, 国家:%@ , 地址:%@, 子地区：%@", Area,Country,Address,subArea];
//             NSLog(@"%@",CountryArea);
//             NSLog(@"%@",[placemark.addressDictionary valueForKey:@"FormattedAddressLines"]);
             
//             NSString * city =  placemark.locality == nil ? @"未知" : placemark.locality;
             NSString * subCity = placemark.subLocality == nil ? @"未知" : placemark.subLocality;
             
//             NSLog(@"city is %@ subCity is %@",city,subCity);
             
             [EIUserCenter sharedInstance].userCity = subCity;
             
         }
         else
         {
             NSLog(@"获取具体位置信息失败: %@", error);
             //return;
         }
     }];
    //更新一次地理位置之后停止更新
//    [self.locationManager stopUpdatingLocation];
}

@end
