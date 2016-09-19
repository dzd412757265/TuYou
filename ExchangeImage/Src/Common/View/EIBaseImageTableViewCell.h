//
//  EIBaseTableViewCell.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/6.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat kPadding = 12.f;
static const CGFloat kAvatarSize = 44.f;
static const CGFloat kNameLabelHeight = 20.f;
static const CGFloat kTimeHeight = 25.f;
static const CGFloat kRichTextViewPadding = 20.f;

@class EIPlazaDisplayModel;
@class EIBaseImageView;
@class EIAvatarView;

@interface EIBaseImageTableViewCell : UITableViewCell

@property (nonatomic , strong)EIBaseImageView *contentImg;
@property (nonatomic , strong)EIAvatarView *avatar;

- (void)setupUI;

@end
