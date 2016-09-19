//
//  dottedImageView.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/12.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "dottedImageView.h"

@implementation dottedImageView

- (void)awakeFromNib
{
    [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"dottedLine"]]];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
