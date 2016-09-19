//
//  EIPlazaCell.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/6.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIPlazaCell.h"
#import "EIDefines.h"
#import "UIImageView+WebCache.h"
#import "EIPlazaDisplayModel.h"
#import "UIView+Extension.h"
#import "EIBaseImageView.h"
#import "UIImage+Color.h"
#import "EISubRichTextView.h"
#import "EICommonHelper.h"
#import "EIAvatarView.h"
#import "EIUserCenter.h"
#import "NSObject+EasyJSON.h"

#define PROGRESS_LABEL_TAG  999

static const CGFloat kSendFailedBtnPadding = 40.f;
static const CGFloat kSexIconSize = 12.f;
static const CGFloat kSexIconPadding = 6.f;

@interface EIPlazaCell()

@property (nonatomic , strong)UILabel *nameLabel;

@property (nonatomic , strong)EISubRichTextView *timeRichView;
@property (nonatomic , strong)EISubRichTextView *locationRichView;

@property (nonatomic , strong)EIPlazaDisplayModel *localModel;

@property (nonatomic , strong)UIButton *sendFailed;

@property (nonatomic , strong)UIImageView *sexIcon;

@end

@implementation EIPlazaCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)identifer
{
    return NSStringFromClass([self class]);
}

- (void)setupUI{
    [super setupUI];
    
    [self.avatar addTarget:self action:@selector(clickAvatarAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPadding + kAvatarSize + kPadding, 0,kScreen_Width - kPadding * 3 - kAvatarSize , kNameLabelHeight)];
    _nameLabel.font = EIFont(14);
    _nameLabel.textColor = EILabelTextColor;
    
    _sexIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSexIconSize, kSexIconSize)];
    _sexIcon.centerY = _nameLabel.centerY;
    
    _locationRichView = [[EISubRichTextView alloc] initWithImage:[UIImage imageNamed:@"IconLocation"]
                                                            text:@"未知"
                                                            rect:CGRectMake(0, kNameLabelHeight, 0, kTimeHeight)];
    
    _timeRichView = [[EISubRichTextView alloc] initWithFrame:CGRectMake(0, kNameLabelHeight, 0, kTimeHeight)];
    
    _sendFailed = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    _sendFailed.hidden = YES;
    [_sendFailed setImage:[UIImage imageNamed:@"message_send_fail"] forState:UIControlStateNormal];
    [_sendFailed addTarget:self action:@selector(reSendPicture:) forControlEvents:UIControlEventTouchUpInside];
    
    
    ESWeakSelf
    [self.contentImg addClickAction:^{
        if (__weakSelf.clickPhotoBlock) {
            __weakSelf.clickPhotoBlock(__weakSelf.localModel);
        }
    }];
    
#if DEBUG_MODE
    UILabel *progressLabel = [[UILabel alloc] initWithFrame:self.contentImg.contentImageView.bounds];
    progressLabel.hidden = YES;
    progressLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    progressLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:.4f];
    progressLabel.numberOfLines = 0;
    progressLabel.textColor = [UIColor whiteColor];
    progressLabel.font = EIFont(13);
    progressLabel.tag = PROGRESS_LABEL_TAG;
    progressLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentImg.contentImageView addSubview:progressLabel];
#endif
    
    [self addSubview:_nameLabel];
    [self addSubview:_sexIcon];
    [self addSubview:_locationRichView];
    [self addSubview:_timeRichView];
    [self addSubview:_sendFailed];
}

- (void)setImageWithModel:(EIPlazaDisplayModel *)imageModel
{
    _localModel = imageModel;
    
    [self.avatar setImageUrl:imageModel.baseModel.user.avatar sex:imageModel.baseModel.user.sex];
    
    self.nameLabel.text = imageModel.baseModel.user.nickname;
    
    if (imageModel.baseModel.user.sex.integerValue == SexTypeMale) {
        self.sexIcon.image = [UIImage imageNamed:@"IconMale"];
    }else if(imageModel.baseModel.user.sex.integerValue == SexTypeFemale){
        self.sexIcon.image = [UIImage imageNamed:@"IconFemale"];
    }else{
        self.sexIcon.image = nil;
    }
    
    [self.locationRichView setTextStr:(imageModel.baseModel.user.city.isNotEmpty ? imageModel.baseModel.user.city:@"未知")];
    [self.timeRichView setImage:[UIImage imageNamed:@"IconTime"]
                           text:[EICommonHelper createIMDate:imageModel.baseModel.picture.created.intValue]];
    [self.contentImg setContentImage:[[self class] getDisplayImage:imageModel]];
    
    [self.sendFailed setHidden:(!imageModel.sendFailed || imageModel.baseModel.isLeft.intValue == 1)];
    
    [self updatePercent:imageModel.uploadPercent];
    
    ESWeakSelf
    
    NSArray *titles;
    
    if ([[EIUserCenter sharedInstance].userId isEqualToString:imageModel.baseModel.user.user_id]) {
        titles = @[@"删除"];
    }else{
        titles = @[@"回复",@"举报",@"删除"];
    }
    
    [self.contentImg addLongPressMenu:titles clickBlock:^(NSInteger index, NSString *title) {
        if (__weakSelf.clickLongPressMenuBlock) {
            __weakSelf.clickLongPressMenuBlock(__weakSelf.localModel,title);
        }
    }];
    
    [self reFrame];
}

+ (UIImage *)getDisplayImage:(EIPlazaDisplayModel *)imageModel{
    if(imageModel.placeholderImage){
        return imageModel.placeholderImage;
    }else if(imageModel.image){
        return imageModel.image;
    }else{
        return [UIImage imageFromContextWithColor:RGBCOLOR(243, 243, 243)];
    }
}

- (void)reFrame{
    if (self.localModel) {
        if (self.localModel.baseModel.isLeft.intValue == 1) {
            [self.avatar setX:kPadding];
            [self.contentImg setX:kPadding + kAvatarSize + kPadding];
            [self.sendFailed setCenter:CGPointMake(CGRectGetMaxX(self.contentImg.frame) +  kSendFailedBtnPadding, self.contentImg.centerY)];
            [self.nameLabel setX:kPadding + kAvatarSize + kPadding];
            self.nameLabel.textAlignment = NSTextAlignmentLeft;
            
            CGSize nameSize = [self.nameLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, kNameLabelHeight)];
            self.sexIcon.x = CGRectGetMinX(self.nameLabel.frame) + nameSize.width + kSexIconPadding;
            
            self.locationRichView.x = kPadding + kAvatarSize + kPadding;
            self.timeRichView.x = CGRectGetMaxX(self.locationRichView.frame) + (self.locationRichView.width > 0 ? kRichTextViewPadding : 0);
        }else{
            [self.avatar setX:kScreen_Width - kPadding - kAvatarSize];
            [self.contentImg setX:kScreen_Width - kPadding - kAvatarSize - kPadding - [EIBaseImageView calculateViewSize:self.contentImg.contentImageView.image].width];
            [self.sendFailed setCenter:CGPointMake(CGRectGetMinX(self.contentImg.frame) - kSendFailedBtnPadding, self.contentImg.centerY)];
            [self.nameLabel setX:kScreen_Width - kPadding - kAvatarSize - kPadding - self.nameLabel.width];
            self.nameLabel.textAlignment = NSTextAlignmentRight;
            
            CGSize nameSize = [self.nameLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, kNameLabelHeight)];
            self.sexIcon.x = CGRectGetMaxX(self.nameLabel.frame) - nameSize.width - kSexIconPadding - kSexIconSize;
            
            self.timeRichView.x = kScreen_Width - kPadding - kAvatarSize - kPadding - self.timeRichView.width;
            self.locationRichView.x = CGRectGetMinX(self.timeRichView.frame) - (self.timeRichView.width > 0 ? kRichTextViewPadding : 0) - self.locationRichView.width;
        }
    }
}

+ (CGFloat)cellHeightWithModel:(EIPlazaDisplayModel *)imageModel
{
    CGFloat totalHeight = 0;
    totalHeight += kNameLabelHeight;
    totalHeight += kTimeHeight;
    totalHeight += [EIBaseImageView calculateViewSize:[[self class] getDisplayImage:imageModel]].height;
    totalHeight += kPadding * 2;
    return totalHeight;
}

//- (void)openPhotoBrower:(id)sender{
//    if (self.clickPhotoBlock) {
//        self.clickPhotoBlock(self.localModel);
//    }
//}

- (void)clickAvatarAction:(id)sender{
    if (self.clickAvatarBlock) {
        self.clickAvatarBlock(self.localModel.baseModel.user);
    }
}

- (BOOL)checkImageKey:(NSString *)imageKey{
    return [self.localModel.imageKey isEqualToString:imageKey];
}

- (BOOL)checkMsgId:(NSString *)msgId{
    return [self.localModel.baseModel.msg_id isEqualToString:msgId];
}
- (void)reSendPicture:(id)sender{
    self.sendFailed.hidden = YES;
    self.localModel.sendFailed = NO;
    if (self.clickResendBlock) {
        self.clickResendBlock(self.localModel);
    }
}

- (void)checkSendFailed:(NSString *)imageKey{
    if ([imageKey isEqualToString:self.localModel.imageKey]) {
        self.sendFailed.hidden = NO;
    }
}

- (void)updatePercent:(CGFloat)percent{
    UILabel *progressLabel = [self.contentImg.contentImageView viewWithTag:PROGRESS_LABEL_TAG];
    if (progressLabel) {
        if (percent == -1) {
            progressLabel.hidden = YES;
        }else{
            if (percent < 1) {
                progressLabel.text = [NSString stringWithFormat:@"%.0f%%",percent * 100.f];
            }else{
                progressLabel.text = @"完成..";
            }
            progressLabel.hidden = NO;
        }
    }
}


@end
