//
//  EIPlazaDisplayModel.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/6.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NYTPhoto.h"
#import "EIMessageModel.h"

/**
    在view中显示用到的数据模型
**/

@protocol EIPlazaDisplayModel

@end;

@interface EIPlazaDisplayModel : NSObject<NYTPhoto>

@property (nonatomic , strong)UIImage *image;
@property (nonatomic , strong)NSData *imageData;
@property (nonatomic , strong)UIImage *placeholderImage;
@property (nonatomic , strong)NSAttributedString *attributedCaptionTitle;
@property (nonatomic , strong)NSAttributedString *attributedCaptionSummary;
@property (nonatomic , strong)NSAttributedString *attributedCaptionCredit;

@property (nonatomic , strong)NSString *imageKey;

//是否发送失败
@property (nonatomic , assign)BOOL sendFailed;

//上传进度
@property (nonatomic , assign)CGFloat uploadPercent;

//基础数据
@property (nonatomic , strong)EIMessageModel *baseModel;

- (id)initWithBaseModel:(EIMessageModel *)model;

@end
