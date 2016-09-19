//
//  EIIndividualInfoCell.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/23.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIIndividualInfoCell.h"
#import "EIDefines.h"

static const CGFloat kCellHeight = 48.f;

@interface EIIndividualInfoCell()

@property (nonatomic , strong)UIView *separatorLine;

@end

@implementation EIIndividualInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setup];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, kScreen_Width - 24 * 2, kCellHeight)];
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.font = EIFont(16);
    [self addSubview:_nameLabel];
    
    _separatorLine = [[UIView alloc] initWithFrame:CGRectMake(12, kCellHeight - .5, kScreen_Width - 12 * 2 , 1)];
    _separatorLine.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dottedLine"]];
    [self addSubview:_separatorLine];
}

+ (CGFloat)cellHeight{
    return kCellHeight;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
