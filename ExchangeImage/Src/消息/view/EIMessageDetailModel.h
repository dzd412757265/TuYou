//
//  EIMessageDetailModel.h
//  ExchangeImage
//
//  Created by 张博成 on 16/7/18.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NYTPhoto.h"
#import "EIMessageModel.h"

@interface EIMessageDetailModel : NSObject<NYTPhoto>

@property (nonatomic , strong) UIImage *image;
@property (nonatomic , strong) NSData *imageData;
@property (nonatomic , strong) UIImage *placeholderImage;
@property (nonatomic , strong) UIImage *thumbnailImage;
@property (nonatomic , strong) NSString *origin_url;

@property (nonatomic , strong)NSAttributedString *attributedCaptionTitle;
@property (nonatomic , strong)NSAttributedString *attributedCaptionSummary;
@property (nonatomic , strong)NSAttributedString *attributedCaptionCredit;

@property (nonatomic , strong)EIUserModel<Optional> *user;

@property (nonatomic , assign)BOOL sendFailed;
@property(nonatomic, assign) long long receivedTime;
@property(nonatomic, assign) long messageId;
@property (nonatomic , assign)NSNumber<Optional> *isLeft;
@property (nonatomic, assign)CGFloat progress;

@end
