//
//  EIPlazaTipsView.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/7.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIPlazaTipsView.h"
#import "EIDefines.h"

@interface EIPlazaTipsView()

@property (nonatomic , strong)UILabel *tipsLabel;

@end

@implementation EIPlazaTipsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
    
    _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(self.bounds) - 30, CGRectGetHeight(self.bounds))];
    _tipsLabel.textColor = [UIColor whiteColor];
    _tipsLabel.font = EIFont(14);
    _tipsLabel.textAlignment = NSTextAlignmentCenter;
    _tipsLabel.text = @"有新图片哦!";
    [self addSubview:_tipsLabel];
    
    self.hidden = YES;
}

- (void)show:(NSString *)tips{
    self.tipsLabel.text = tips;
    if (!self.isHidden) {
        return ;
    }
    self.hidden = NO;
    [UIView animateWithDuration:.5 animations:^{
        CGFloat offsetY = CGRectGetHeight(self.bounds);
        self.transform = CGAffineTransformMakeTranslation(0, offsetY);
        [UIView animateWithDuration:1.5f delay:2 options:0 animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.hidden = YES;
        }];
    }];
}

@end
