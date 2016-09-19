//
//  EIImagePickerFlashBar.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/18.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIImagePickerFlashBar.h"


@implementation EIImagePickerFlashBar

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setImage:[UIImage imageNamed:@"CameraFlashAuto"]];
}

- (void)setMode:(CameraMode)mode{
    switch (mode) {
        case CameraModeAuto:
            [self setImage:[[UIImage imageNamed:@"CameraFlashAuto"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            break;
        case CameraModeOn:
            [self setImage:[[UIImage imageNamed:@"CameraFlashOn"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            break;
        case CameraModeOff:
            [self setImage:[[UIImage imageNamed:@"CameraFlashOff"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        default:
            break;
    }
}

@end
