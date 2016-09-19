//
//  EIOpenCameraToolBar.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/8.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIOpenCameraToolBar.h"
#import "EIDefines.h"
#import "UIView+Extension.h"

@implementation EIOpenCameraToolBar

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
    
    self.clipsToBounds = YES;
    [self setBackgroundImage:[UIImage imageNamed:@"bar_background_img"] forToolbarPosition:0 barMetrics:0];
    //self.backgroundColor = kCommonBackgroundColor;
    
    UIButton *cameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    [cameraBtn setImage:[UIImage imageNamed:@"ShootPicture"] forState:UIControlStateNormal];
    [cameraBtn setTitle:@"拍摄" forState:UIControlStateNormal];
    [cameraBtn setTitleColor:EINavigationBarTitleColor forState:UIControlStateNormal];
    cameraBtn.titleLabel.font = EIFont(18);
    [cameraBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 12, 0, 0)];
    [cameraBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 12)];
    [cameraBtn addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *cameraItem = [[UIBarButtonItem alloc] initWithCustomView:cameraBtn];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self setItems:@[flexibleItem,cameraItem,flexibleItem]];
}

- (void)itemAction:(id)sender{
    if (self.clickBlock) {
        self.clickBlock();
    }
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    self.frame = CGRectMake(0, CGRectGetHeight(self.superview.bounds) - [[self class] barHeight], kScreen_Width, [[self class] barHeight]);
}

+ (id)cameraToolBar{
    return [[self alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, [[self class] barHeight])];
}

+ (CGFloat)barHeight{
    return 49.f;
}

@end
