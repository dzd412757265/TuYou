//
//  UIMessagePhotoImageView.h
//  jiuwuliao
//
//  Created by 古元庆 on 16/3/24.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIMessagePhotoTriangleMargin  8.f


@interface UIMessagePhotoImageView : UIView

@property (nonatomic, strong) UIImage *messagePhoto;
@property (nonatomic, assign) BOOL isSend;

- (void)configureMessagePhoto:(UIImage *)messagePhoto onMessageType:(BOOL)isSend;

@end
