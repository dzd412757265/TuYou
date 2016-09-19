//
//  EIImagePickerFlashBar.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/18.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,CameraMode){
    CameraModeAuto = 1,
    CameraModeOn,
    CameraModeOff,
};

@interface EIImagePickerFlashBar : UIBarButtonItem

- (void)setMode:(CameraMode )mode;

@end
