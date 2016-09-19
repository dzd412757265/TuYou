//
//  EIPictureDateBase.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/18.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingletonHelper.h"

@class EIPictureModel;

@interface EIPictureDateBase : NSObject

AS_SINGLETON(EIPictureDateBase)

- (void)CreatePictureTable;

-(void)insertPictureToDB:(EIPictureModel*)picture;

- (void)insertPicturesToDB:(NSArray *)pictures;

-(NSArray *) getAllPictureInfo;

-(EIPictureModel *) getPictureById:(NSString*)pictureId;

-(void)deletePictureFromDB:(NSString *)pictureId;

- (void)clearPictureData;

@end
