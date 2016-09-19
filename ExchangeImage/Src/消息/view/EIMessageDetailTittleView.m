//
//  EIMessageDetailTittleView.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/25.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIMessageDetailTittleView.h"
#import "EIDefines.h"
#import "UIView+Extension.h"
#import "EIUserCenter.h"
#import "NSObject+EasyJSON.h"

@interface EIMessageDetailTittleView()

@property (nonatomic, strong)UILabel *nickNameLabel;

@property (nonatomic, strong)UIImageView *sexIcon;

@property (nonatomic, strong)UIButton *userLocation;

@end

@implementation EIMessageDetailTittleView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setUI];
        
    }
    return self;
}

- (void)setUI
{
    _nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.width - 12 - 7, 25)];
    _nickNameLabel.font = EIFont(18);
    _nickNameLabel.textColor = EINavigationBarTitleColor;
    
    _nickNameLabel.centerX = self.centerX;
    
    [self addSubview:_nickNameLabel];
    
    _sexIcon = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_nickNameLabel.frame) + 7, 0, 12, 12)];
    _sexIcon.contentMode = UIViewContentModeScaleAspectFit;
    _sexIcon.y = self.width - _sexIcon.width;
    _sexIcon.centerY = _nickNameLabel.centerY;
    [self addSubview:_sexIcon];
    
    _userLocation = [[UIButton alloc]initWithFrame:CGRectMake(0, _nickNameLabel.height + 1.5, self.width, 14)];
    _userLocation.titleLabel.font = EIFont(10);
    [_userLocation setTitleColor:EIGreyColor forState:UIControlStateNormal];
    [_userLocation setImage:[UIImage imageNamed:@"IconLocation"] forState:UIControlStateNormal];
    [_userLocation setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 4)];
    [_userLocation setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 0)];
    [self addSubview:_userLocation];
    
}

- (void)setTitleWithName:(NSString *)nickName andWithSex:(NSNumber *)sex andWithCity:(NSString *)city
{
    self.nickNameLabel.text = nickName;
    
    if ([sex intValue] == SexTypeMale) {
        
        [self.sexIcon setImage:[UIImage imageNamed:@"IconMale"]];
        
    }else if([sex intValue] == SexTypeFemale){
        
        [self.sexIcon setImage:[UIImage imageNamed:@"IconFemale"]];
    }else{
        
        [self.sexIcon setImage:nil];
    }
    NSString *cityString = city.isNotEmpty?city:@"未知";
    [self.userLocation setTitle:cityString forState:UIControlStateNormal];
}
+ (CGSize)caculateViewWidthWithName:(NSString *)nickName
{
    CGFloat height = 25 + 1.5 + 14; //名称高度 ＋ 间距 ＋ 位置按钮的高度
    
    CGFloat width = 0;
    
    width =   [nickName boundingRectWithSize:CGSizeMake(kScreen_Width, 25) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSForegroundColorAttributeName:EINavigationBarTitleColor, NSFontAttributeName:EIFont(18)} context:nil].size.width;
    width += 7;
    width += 12;
    CGSize size = CGSizeMake(width, height);
    return size;
}
@end
