//
//  EIPlazaOfficialCell.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/26.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIPlazaOfficialCell.h"
#import "EIBaseImageView.h"
#import "EIAvatarView.h"
#import "EIDefines.h"
#import "UIView+Extension.h"

static const CGFloat kAvatarSize = 44.f;
static const CGFloat kContentPadding = 10.f;
static const CGFloat kPadding = 12.f;

@interface EIPlazaOfficialCell()

@property (nonatomic , strong)EIAvatarView *avatar;
@property (nonatomic , strong)UILabel *nameLabel;
@property (nonatomic , strong)UIView *bgView;

@property (nonatomic , strong)UILabel *contentLabel;

@end

@implementation EIPlazaOfficialCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (id)create{
    return [[self alloc] init];
}

- (id)init{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    _avatar = [[EIAvatarView alloc] initWithFrame:CGRectMake(kPadding, kPadding, kAvatarSize, kAvatarSize)];
    [_avatar setImage:[UIImage imageNamed:@"logo"] sex:@(2)];
    [self addSubview:_avatar];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = EIFont(14);
    _nameLabel.textColor = EILabelTextColor;
    _nameLabel.text = @"图友小助手";
    [self addSubview:_nameLabel];
    
    [_nameLabel sizeToFit];
    [_nameLabel setY:kPadding];
    [_nameLabel setX:kPadding + kAvatarSize + kPadding];
    
    UIView *officialIcon = [self officialIcon];
    [officialIcon setCenterY:_nameLabel.centerY];
    [officialIcon setX:CGRectGetMaxX(_nameLabel.frame) + kPadding/2];
    [self addSubview:officialIcon];
    
    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor whiteColor];
    [_bgView.layer setShadowColor:[UIColor blackColor].CGColor];
    [_bgView.layer setShadowOffset:CGSizeMake(0, 0)];
    [_bgView.layer setShadowRadius:2.0f];
    [_bgView.layer setShadowOpacity:.24f];
    [self addSubview:_bgView];
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.numberOfLines = 0;
    _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_bgView addSubview:_contentLabel];
    
    NSString *titleText = @"欢迎你来到这里！\n";
    NSString *tipText = [titleText stringByAppendingString:@"1、随机发送一张你的图片，即可加入和其他人交换图片的活动。\n2、你每发一张图片，都会收到来自其他不同的人发的图片。\n3、点击对方头像或者长按图片即可单独回复Ta。"];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 6;
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:tipText attributes:@{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:EIFont(14),NSForegroundColorAttributeName:EILabelTextColor}];
    [attriStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18] range:[tipText rangeOfString:titleText]];
    _contentLabel.attributedText = attriStr;
    
    CGSize size = [_contentLabel sizeThatFits:CGSizeMake(kScreen_Width * .6f, CGFLOAT_MAX)];
    _contentLabel.frame = CGRectMake(kContentPadding, kContentPadding, size.width, size.height);
    
    _bgView.frame = CGRectMake(kPadding + kAvatarSize + kPadding ,CGRectGetMaxY(_nameLabel.frame) + kPadding , size.width + kContentPadding * 2, size.height + kContentPadding * 2);
    
    self.bounds = CGRectMake(0, 0, kScreen_Width, CGRectGetMaxY(_bgView.frame));
}

- (UIView *)officialIcon{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = RGBCOLOR(252, 52, 125);
    [view.layer setCornerRadius:7];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"官号";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = EIFont(10);
    [view addSubview:label];
    
    CGSize size = [label sizeThatFits:CGSizeMake(CGFLOAT_MAX, 14)];
    label.frame = CGRectMake(3, 0, size.width, 14);
    view.bounds = CGRectMake(0, 0, size.width + 6, 14);
    
    return view;
}

@end
