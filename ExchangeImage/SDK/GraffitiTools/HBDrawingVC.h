//
//  HBDrawingVC.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/8/5.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIBaseViewController.h"

@interface HBDrawingVC : EIBaseViewController

@property (nonatomic , strong)UIImage *backgroundImg;

@property (nonatomic , copy)void(^drawFinishBlock)(UIImage *);

- (id)initWithBackgroundImg:(UIImage *)image;

@end
