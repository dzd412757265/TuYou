//
//  EIConfirmButton.m
//  ExchangeImage
//
//  Created by 张博成 on 16/8/1.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIConfirmButton.h"
#import "EIDefines.h"

@implementation EIConfirmButton

+ (instancetype)confirmButtonWithName:(NSString *)buttonName
{
    EIConfirmButton *button = [EIConfirmButton buttonWithType:UIButtonTypeCustom];
    
    CGFloat width = kScreen_Width - 2 * 36;
    CGFloat height = 56;
    button.frame = CGRectMake(36, 0, width, height);
    
    [button setBackgroundImage:[UIImage imageNamed:@"confirmButtonBackground"] forState:UIControlStateNormal];
    
    [button setTitle:buttonName font:[UIFont systemFontOfSize:17] color:[UIColor whiteColor] state:UIControlStateNormal];
    
     [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 4,0)];
    
    return button;
}
@end
