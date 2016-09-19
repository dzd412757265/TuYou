//
//  EIPlazaGuideView.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/8/3.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIGuideHelper.h"
#import "EIDefines.h"
#import "UIView+Extension.h"

@implementation EIGuideHelper

DEF_SINGLETON(EIGuideHelper)

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)showGuide:(CGRect)frame fromView:(UIView *)srcView toView:(UIView *)desView{
    
    //要弹引导
    NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey:PLAZA_GUIDE_KEY];
    if (value) {
        return;
    }
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect windowRect = [srcView convertRect:frame toView:nil];
    if(!CGRectContainsRect(screenRect, windowRect)){
        return;
    }
    
    //仅此一次
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:PLAZA_GUIDE_KEY];
    
    if (desView == nil) {
        desView = [UIApplication sharedApplication].keyWindow;
    }
    
    UIControl *_guideLayer = [[UIControl alloc] initWithFrame:desView.bounds];
    [_guideLayer setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
    [_guideLayer addTarget:self action:@selector(clearView:) forControlEvents:UIControlEventTouchUpInside];
    [desView addSubview:_guideLayer];
    
    CGRect rect = [srcView convertRect:frame toView:desView];
    
    CGFloat clipViewSize = rect.size.width < rect.size.height ?rect.size.width:rect.size.height;
    
    CGRect bounds = _guideLayer.bounds;
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    
    CGFloat kRadius = clipViewSize/2;
    CGRect const circleRect = CGRectMake(CGRectGetMidX(rect) - kRadius,
                                         CGRectGetMidY(rect) - kRadius,
                                         2 * kRadius, 2 * kRadius);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    [path appendPath:[UIBezierPath bezierPathWithRect:bounds]];
    maskLayer.path = path.CGPath;
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    
    _guideLayer.layer.mask = maskLayer;
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.font = EIFont(18);
    label.text = @"👈点击头像可以和Ta单独发图片";
    
    CGSize size = [label sizeThatFits:CGSizeMake(kScreen_Width - CGRectGetMaxX(circleRect) - 12 - 12, CGFLOAT_MAX)];
    label.x = CGRectGetMaxX(circleRect) + 12;
    label.width = size.width;
    label.height = size.height;
    
    label.centerY = CGRectGetMidY(circleRect);
    
    [_guideLayer addSubview:label];
}

- (void)clearView:(UIView *)sender{
    [sender removeFromSuperview];
}

@end
