//
//  EIOpenCameraToolBar.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/8.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EIOpenCameraToolBar : UIToolbar

+ (id)cameraToolBar;

+ (CGFloat)barHeight;

@property (nonatomic ,copy) void(^clickBlock)();

@end
