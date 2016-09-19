//
//  BaseViewController.h
//  wenda
//
//  Created by 古元庆 on 16/6/20.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger {
    ViewControllerStyleNone = 0,
    ViewControllerStylePlain ,
    ViewControllerStylePresenting
}ViewControllerStyle;

@interface EIBaseViewController : UIViewController

@property (nonatomic, assign) ViewControllerStyle viewControllerStyle;

@property (nonatomic ,assign)BOOL joinAnalytic;

- (void)dismissSelf;

@end
