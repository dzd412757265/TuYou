//
//  EIEXPImageModel.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/14.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface EIPictureModel:JSONModel

@property (nonatomic , strong)NSString<Optional> *picture_id;
@property (nonatomic , strong)NSString<Optional> *thumbnail_url;
@property (nonatomic , strong)NSString<Optional> *origin_url;
@property (nonatomic , strong)NSNumber<Optional> *created;

@end