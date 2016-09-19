//
//  EIPlazaViewModel.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/6.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIBaseViewModel.h"
#import "EIPlazaDisplayModel.h"

@interface EIPlazaViewModel : EIBaseViewModel

@property (nonatomic , strong)NSMutableArray *modelList;

- (void)insertModel:(EIPlazaDisplayModel *)model;

- (void)downLoadHDPhoto:(EIPlazaDisplayModel *)model completed:(void(^)(EIPlazaDisplayModel *))completed;
- (void)downLoadPlaceHolderPhoto:(EIPlazaDisplayModel *)model completed:(void (^)(EIPlazaDisplayModel *))completed;

- (void)sendActualPictures:(EIPlazaDisplayModel *)virtualModel
          startBlock:(void(^)())startBlock
        processBlock:(void(^)(float , NSString*))processBlock
      completedBlock:(void(^)(NSError * , NSString *))completedBlock;

- (void)sendVirtualPicture:(UIImage *)image
                 completed:(void(^)(EIPlazaDisplayModel *))completeBlock;


- (void)deleteDisplayModel:(EIPlazaDisplayModel *)model completed:(void(^)()) block;

- (void)deleteAllModel:(void(^)())block;

- (void)clearMemory:(void(^)())block;

//自己发的时候先造假数据
- (EIPlazaDisplayModel *)createTempDisplayModel:(UIImage *)image;

//改变发送状态

- (BOOL)changeSendStatus:(BOOL)isFailed imageKey:(NSString *)imageKey;

//根据messageId从数据库中取值,首次取messageId为nil
//目前弃用
- (void)fetchCacheFromDB:(void(^)())completedBlock;

//重新打开应用时,从服务器拉取推送历史数据
- (void)queryPushHistory:(void(^)(BOOL))completedBlock;

@end
