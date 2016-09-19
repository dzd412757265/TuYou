
//
//  EIMessageDetailCell.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/18.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIMessageDetailCell.h"
#import "EIDefines.h"
#import "UIImageView+WebCache.h"
#import "UIView+Extension.h"
#import "EIBaseImageView.h"
#import "UIImage+Color.h"
#import "EISubRichTextView.h"
#import "EICommonHelper.h"
#import "EIAvatarView.h"

static const CGFloat kSendFailedBtnPadding = 40.f;

@interface EIMessageDetailCell()

@property (nonatomic , strong)EIMessageDetailModel *localModel;

@property (nonatomic , strong)UIButton *sendFailed;

@property (nonatomic, strong)UILabel *progressLabel;

@end

@implementation EIMessageDetailCell

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
    
    self.contentImg.y = 0;
    
    _sendFailed = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    _sendFailed.hidden = YES;
    [_sendFailed setImage:[UIImage imageNamed:@"message_send_fail"] forState:UIControlStateNormal];
    [_sendFailed addTarget:self action:@selector(openPhotoPicker:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_sendFailed];
    
#if DEBUG_MODE
    _progressLabel = [[UILabel alloc] initWithFrame:self.contentImg.contentImageView.bounds];
    _progressLabel.hidden = YES;
    _progressLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _progressLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:.4f];
    _progressLabel.numberOfLines = 0;
    _progressLabel.textColor = [UIColor whiteColor];
    _progressLabel.font = EIFont(13);
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentImg.contentImageView addSubview:_progressLabel];
#endif

    
    ESWeakSelf
    [self.contentImg addClickAction:^{
        if (__weakSelf.clickPhotoBlock) {
            __weakSelf.clickPhotoBlock(__weakSelf.localModel);
        }
    }];
    
    [self.contentImg addLongPressMenu:@[@"删除"] clickBlock:^(NSInteger index, NSString *title) {
        
        if(__weakSelf.longClickPhotoBlock){
            __weakSelf.longClickPhotoBlock(__weakSelf.localModel);
        }
    }];
}

- (void)setImageWithModel:(EIMessageDetailModel *)imageModel
{
    _localModel = imageModel;
    
    [self.avatar setImageUrl:imageModel.user.avatar sex:imageModel.user.sex];
    
    [self.contentImg setContentImage:[[self class] getDisplayImage:imageModel]];
    
    [self.sendFailed setHidden:(!imageModel.sendFailed || imageModel.isLeft.intValue == 1)];
    
    [self updatePercent:imageModel.progress];
    
    [self reFrame];
}

+ (UIImage *)getDisplayImage:(EIMessageDetailModel *)imageModel{
    if (imageModel.thumbnailImage) {
        return imageModel.thumbnailImage;
    }else if(imageModel.image){
        return imageModel.image;
    }else{
        return [UIImage imageFromContextWithColor:RGBCOLOR(243, 243, 243)];
    }
}

- (void)reFrame{
    if (self.localModel) {
        if (self.localModel.isLeft.intValue == 1) {
            [self.avatar setX:kPadding];
            [self.contentImg setX:kPadding + kAvatarSize + kPadding];
            [self.sendFailed setCenter:CGPointMake(CGRectGetMaxX(self.contentImg.frame) +  kSendFailedBtnPadding, self.contentImg.centerY)];
//            [self.nameLabel setX:kPadding + kAvatarSize + kPadding];
//            self.nameLabel.textAlignment = NSTextAlignmentLeft;
//            
//            self.locationRichView.x = kPadding + kAvatarSize + kPadding;
//            self.timeRichView.x = CGRectGetMaxX(self.locationRichView.frame) + (self.locationRichView.width > 0 ? kRichTextViewPadding : 0);
        }else{
            [self.avatar setX:kScreen_Width - kPadding - kAvatarSize];
            [self.contentImg setX:kScreen_Width - kPadding - kAvatarSize - kPadding - [EIBaseImageView calculateViewSize:self.contentImg.contentImageView.image].width];
            [self.sendFailed setCenter:CGPointMake(CGRectGetMinX(self.contentImg.frame) - kSendFailedBtnPadding, self.contentImg.centerY)];
//            [self.nameLabel setX:kScreen_Width - kPadding - kAvatarSize - kPadding - self.nameLabel.width];
//            self.nameLabel.textAlignment = NSTextAlignmentRight;
//            
//            self.timeRichView.x = kScreen_Width - kPadding - kAvatarSize - kPadding - self.timeRichView.width;
//            self.locationRichView.x = CGRectGetMinX(self.timeRichView.frame) - (self.timeRichView.width > 0 ? kRichTextViewPadding : 0) - self.locationRichView.width;
        }
    }
}

+ (CGFloat)cellHeightWithModel:(EIMessageDetailModel *)imageModel
{
    CGFloat totalHeight = 0;
//    totalHeight += kNameLabelHeight;
//    totalHeight += kTimeHeight;
    totalHeight += [EIBaseImageView calculateViewSize:[[self class] getDisplayImage:imageModel]].height;
    totalHeight += kPadding * 2;
    return totalHeight;
}

- (void)openPhotoPicker:(id)sender{
    self.sendFailed.hidden = YES;
    self.localModel.sendFailed = NO;
    if (self.clickResendBlock) {
        self.clickResendBlock(self.localModel);
    }
}

- (void)openPhotoBrower:(id)sender{
    if (self.clickPhotoBlock) {
        self.clickPhotoBlock(self.localModel);
    }
}

- (void)updatePercent:(CGFloat)percent{
   
    if (_progressLabel) {
        if (percent == -1) {
            _progressLabel.hidden = YES;
        }else{
            if (percent < 1) {
                _progressLabel.text = [NSString stringWithFormat:@"%.0f%%",percent * 100.f];
            }else{
                _progressLabel.text = @"99%";
            }
            _progressLabel.hidden = NO;
        }
    }
}

- (BOOL)isTheCellForModel:(EIMessageDetailModel *)detailModel
{
    if (self.localModel.receivedTime == detailModel.receivedTime) {
        
        return YES;
    }else{
        return NO;
    }
}
@end
