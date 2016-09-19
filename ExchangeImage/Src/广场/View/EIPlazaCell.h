//
//  EIPlazaCell.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/6.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EIBaseImageTableViewCell.h"

@class EIUserModel;

@interface EIPlazaCell : EIBaseImageTableViewCell

@property (nonatomic , copy) void(^clickPhotoBlock)(EIPlazaDisplayModel *);

@property (nonatomic , copy) void(^clickLongPressMenuBlock)(EIPlazaDisplayModel *,NSString *);

@property (nonatomic , copy) void(^clickResendBlock)(EIPlazaDisplayModel *);

@property (nonatomic , copy) void(^clickAvatarBlock)(EIUserModel *);

+ (NSString *)identifer;

+ (CGFloat)cellHeightWithModel:(EIPlazaDisplayModel *)imageModel;

- (void)setImageWithModel:(EIPlazaDisplayModel *)imageModel;

- (void)checkSendFailed:(NSString *)imageKey;

- (BOOL)checkImageKey:(NSString *)imageKey;

- (BOOL)checkMsgId:(NSString *)msgId;

- (void)updatePercent:(CGFloat)percent;

@end
