//
//  EIPlazaGuideView.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/8/3.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingletonHelper.h"

#define PLAZA_GUIDE_KEY @"kPlazaGuideKey"

@interface EIGuideHelper : NSObject

AS_SINGLETON(EIGuideHelper)

- (void)showGuide:(CGRect)frame fromView:(UIView *)srcView toView:(UIView *)desView;

@end
