//
//  EIMessageDetailCell.h
//  ExchangeImage
//
//  Created by 张博成 on 16/7/18.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIBaseImageTableViewCell.h"
#import "EIMessageDetailModel.h"
@interface EIMessageDetailCell : EIBaseImageTableViewCell

@property (nonatomic , copy) void(^clickPhotoBlock)(EIMessageDetailModel *);

@property (nonatomic , copy) void(^clickResendBlock)(EIMessageDetailModel *);

@property (nonatomic, copy) void(^longClickPhotoBlock)(EIMessageDetailModel *);

+ (NSString *)identifer;

+ (CGFloat)cellHeightWithModel:(EIMessageDetailModel *)imageModel;

- (void)setImageWithModel:(EIPlazaDisplayModel *)imageModel;

- (void)updatePercent:(CGFloat)percent;

- (BOOL)isTheCellForModel:(EIMessageDetailModel *)detailModel;

@end
