//
//  DDProgressHUD.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/11.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "DDProgressHUD.h"
#import "EIDefines.h"

static DDProgressHUD *hud = nil;

//内半径
const CGFloat INRADIUS     =  20.0f;
//外半径
const CGFloat OUTRADIUS  =    28.0f;
//线宽
const CGFloat LINEWIDTH  =    3.0f;


@interface DDProgressHUD () {
    uint _start;
    NSTimer *_timer;
    uint _max;
    CGFloat *_capacity;
}
@end

@implementation DDProgressHUD


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        self.frame = CGRectMake(0, 0, 80, 80);
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
        _max = 24;
        self.alpha= 0.7;
        
        CGFloat average = 1.0f / _max;
        //分配内存
        _capacity = (CGFloat *)malloc(sizeof(CGFloat) * _max);
        //计算出每一个白条的透明度
        for (int i = 0; i < _max ; ++i) {
            _capacity[i] = 1 - average * i;
        }
        //开启一个定时器
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target: self selector: @selector(draw) userInfo: nil repeats: YES];
        
    }
    
    return self;
}
- (void)draw {
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //横坐标用半径乘cosa,纵坐标用半径乘sina.
    CGFloat x = self.layer.bounds.size.width / 2;
    CGFloat y = self.layer.bounds.size.height / 2;
    
    const CGFloat PI2 = M_PI * 2;
    
    for (int i = 0; i < _max; i++) {
        
        CGFloat cosa = cos(PI2 / _max * i);
        CGFloat sina = sin(PI2 / _max * i);
        
        CGFloat minx = x + INRADIUS *  cosa;
        CGFloat miny = y + INRADIUS *  sina;
        
        CGFloat maxx = x + OUTRADIUS * cosa;
        CGFloat maxy = y + OUTRADIUS * sina;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        
        [path moveToPoint:CGPointMake(minx, miny)];
        [path addLineToPoint:CGPointMake(maxx, maxy)];
        
        path.lineWidth = LINEWIDTH;
        
        path.lineCapStyle = kCGLineCapRound;
        UIColor *strokeColor = RGBACOLOR(0xff, 0xff, 0xff, _capacity[(i + _start) % _max]);
        
        [strokeColor set];
        
        [path stroke];
    }
    _start = ++_start % _max;
}

+ (void)showHUDAddedTo:(UIView *)view {
    
    if (hud) {
        [hud removeFromSuperview];
        hud = nil;
    }
    hud = [[DDProgressHUD alloc] init];
    
    hud.center = view.center;
    
    [view addSubview:hud];
}
+ (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        hud.alpha = 0;
    } completion:^(BOOL finished) {
        [hud removeFromSuperview];
        hud = nil;
    }];
}
- (void)dealloc {
    free(_capacity);
}
@end
