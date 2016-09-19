//
//  GBAvatarView.m
//  jiuwuliao
//
//  Created by admin on 15/8/28.
//  Copyright (c) 2015年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIAvatarView.h"
#import "UIImageView+WebCache.h"
#import "NSObject+EasyJSON.h"
#import "EIUserCenter.h"
#import "EIDefines.h"

static const CGFloat kAvatarPadding = 2.0f;
static const CGFloat kBorderWidth = 2.f;

@interface EIAvatarView()

@end

@implementation EIAvatarView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}
- (void)setup
{
    [self addSubview:self.imageView];
    [self addSubview:self.backgroundView];
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(kAvatarPadding, kAvatarPadding, CGRectGetWidth(self.frame) - kAvatarPadding * 2, CGRectGetHeight(self.frame) - kAvatarPadding * 2)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [_imageView.layer setCornerRadius:(CGRectGetWidth(self.frame) - kAvatarPadding * 2)/2];
        [_imageView setClipsToBounds:YES];
        _imageView.userInteractionEnabled = NO;
        _imageView.image = [UIImage imageNamed:@"lOGO"];
    }
    return _imageView;
}

- (UIView *)backgroundView
{
    if (!_backgroundView) {
        CGFloat width = CGRectGetWidth(self.bounds) - kBorderWidth * 2;
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(kBorderWidth, kBorderWidth, width, width)];
        [_backgroundView.layer setCornerRadius:width/2];
        [_backgroundView.layer setBorderWidth:kBorderWidth];
        [_backgroundView.layer setBorderColor:[UIColor clearColor].CGColor];
        _backgroundView.userInteractionEnabled = NO;
    }
    return _backgroundView;
}


- (void)setImageUrl:(NSString *)url sex:(NSNumber *)sex
{
    if (url.isNotEmpty) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"DefaultAvatar"] options:SDWebImageRetryFailed];
    }else{
        self.imageView.image = [UIImage imageNamed:@"DefaultAvatar"];
    }
    
    [self setSex:sex];
}

- (void)setSex:(NSNumber *)sex{
    
    if ([sex integerValue] == SexTypeMale) {
        [self.backgroundView.layer setBorderColor:EIBlueColor.CGColor];
    }else if([sex integerValue] == SexTypeFemale){
        [self.backgroundView.layer setBorderColor:EIPinkColor.CGColor];
    }else{
        [self.backgroundView.layer setBorderColor:[UIColor clearColor].CGColor];
    }
}

- (void)setImage:(UIImage *)image sex:(NSNumber *)sex
{
    self.imageView.image = image;
    
    [self setSex:sex];
}

@end
