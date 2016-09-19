//
//  EIBaseTableViewCell.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/6.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIBaseImageTableViewCell.h"
#import "EIDefines.h"
#import "EIBaseImageView.h"
#import "EIAvatarView.h"

@interface EIBaseImageTableViewCell()

@end

@implementation EIBaseImageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    
    _avatar = [[EIAvatarView alloc] initWithFrame:CGRectMake(kPadding, 0, kAvatarSize, kAvatarSize)];
    [self addSubview:_avatar];
    
    _contentImg = [[EIBaseImageView alloc] initWithFrame:CGRectMake(kPadding + kAvatarSize + kPadding, kNameLabelHeight + kTimeHeight, 0, 0)];
    [self addSubview:_contentImg];
}

@end
