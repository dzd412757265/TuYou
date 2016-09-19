//
//  CustomProgressHUD.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/26.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "CustomProgressHUD.h"
#define CLScreenWidth [UIScreen mainScreen].bounds.size.width
#define CLScreenHeight [UIScreen mainScreen].bounds.size.height
#define CLScreenBounds [UIScreen mainScreen].bounds

@interface CustomProgressHUD()
{
    NSTimer *_timer;
    float _start;
}
@property (weak,nonatomic)CAShapeLayer *shapLayer;

@end

@implementation CustomProgressHUD

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (id)createProgress{
    return [[self alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    self.backgroundColor = [[UIColor colorWithWhite:0.292 alpha:1.000] colorWithAlphaComponent:0.5];
    self.layer.cornerRadius = 10;
    self.clipsToBounds = YES;
    [self addBGview];
    
    //开启一个定时器
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target: self selector: @selector(draw) userInfo: nil repeats: YES];
    
    //[self creatShplayer];
    [self.layer addSublayer:self.shapLayer];
}

- (void)addBGview{
    UIBlurEffect * blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView * effe = [[UIVisualEffectView alloc]initWithEffect:blur];
    effe.frame = CGRectMake(50, 90, self.frame.size.width, 400);
    // 添加毛玻璃
    [self addSubview:effe];
    
}

- (void)draw{
    self.transform = CGAffineTransformMakeRotation(_start);
    _start = _start + .2f;
}

//- (void)creatShplayer{
//    
//    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
//    anim.keyPath = @"transform.rotation";
//    anim.values = @[@(M_PI/4.0), @(M_PI * 2/4.0), @( M_PI * 3/4.0), @(4 * M_PI /4.0),@(5 *M_PI/4.0), @(6 *M_PI/4.0), @(7 *M_PI/4.0), @(8 * M_PI /4.0),@(8 * M_PI /4.0 + M_PI/4.0)];
//    anim.repeatCount = MAXFLOAT;
//    anim.duration = 1;
//    anim.removedOnCompletion = NO;
//    anim.fillMode = kCAFillModeForwards;
//    [self.shapLayer addAnimation:anim forKey:@"CLAnimation"];
//}

- (CAShapeLayer *)shapLayer{
    if (_shapLayer == nil) {
        CGFloat width = CGRectGetWidth(self.bounds);
        CAShapeLayer *shapLayer = [CAShapeLayer layer];
        shapLayer.frame = CGRectMake(0, 0, width, width);
        shapLayer.fillColor = [UIColor clearColor].CGColor;
        
        shapLayer.lineWidth = 3.0f;
        shapLayer.strokeColor = [UIColor blackColor].CGColor;//线条颜色
        
        UIBezierPath *bezier = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, width, width)];//画个圆
        shapLayer.path = bezier.CGPath;
        [self.layer addSublayer:shapLayer];
        shapLayer.strokeStart = 0;
        shapLayer.strokeEnd = 0.85;
        _shapLayer = shapLayer;
    }
    return _shapLayer;
}

@end
