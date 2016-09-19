//
//  EIDataCacheManager.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/7.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingletonHelper.h"

@class EIMessageModel;
@class EIPlazaDisplayModel;
/**
    图片的下载,缓存,数据的转化
    同时用来管理DB和SDWebImageCache
**/

@interface EIDataCacheManager : NSObject

AS_SINGLETON(EIDataCacheManager)

//接受到数据后进行转化
- (void)receiveImageData:(EIMessageModel *)model block:(void(^)(EIPlazaDisplayModel *))block;

//发送数据
- (void)sendImageData:(EIPlazaDisplayModel *)model block:(void(^)(EIPlazaDisplayModel *))block;

//下载高清图
- (void)downloadImage:(NSString *)url completed:(void(^)(UIImage *,NSError *)) completed;

//从数据库中取数据
- (void)descendingFetchPlazaCacheFromDB:(int) count messageId:(NSString *)msgId completeBlock:(void(^)(NSArray *))completeBlock;

//从数据库中删除
- (void)deleteCacheFromDB:(EIMessageModel *)model block:(void(^)())completed;

//从服务器获取数据后存数据库然后再返回显示
- (void)queryPushHistory;

- (NSString *)getLastMessgeIdFromDB;

- (NSString *)getCacheSize;

- (void)clearAllCache;

- (void)clearOriginImageCache;

- (NSString *)getOriginCacheSize;

@end
