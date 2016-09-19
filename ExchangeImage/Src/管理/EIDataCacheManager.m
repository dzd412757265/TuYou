//
//  EIDataCacheManager.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/7.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIDataCacheManager.h"
#import "UIImageView+WebCache.h"
#import "EIMessageModel.h"
#import "EIPlazaDisplayModel.h"
#import "NSObject+EasyJSON.h"
#import "EIDataBaseManager.h"
#import "SDWebImageManager.h"
#import "EIDefines.h"
#import "NSObject+EasyJSON.h"

#import "LogHelper.h"

@implementation EIDataCacheManager

DEF_SINGLETON(EIDataCacheManager)

- (void)receiveImageData:(EIMessageModel *)model block:(void(^)(EIPlazaDisplayModel *))block{
    
     model.isLeft = [NSNumber numberWithInt:1];
    
    //接受消息后,先将原数据模型存数据库
    [[EIDataBaseManager sharedInstance] insertMessageModel:model];
    
    //这里第一时间是不下载高清图的,只下载缩略图
    [self downloadImage:model.picture.thumbnail_url.isNotEmpty ? model.picture.thumbnail_url : model.picture.origin_url
              completed:^(UIImage *image, NSError *error) {
                  EIPlazaDisplayModel *displayModel = [[EIPlazaDisplayModel alloc] initWithBaseModel:model];
                  if (error) {
                      displayModel.placeholderImage = nil;
                      DLog(@"收到图片:%@",error);
                  }else{
                      displayModel.placeholderImage = image;
                  }
                  block(displayModel);
              }];
}

- (void)sendImageData:(EIPlazaDisplayModel *)model block:(void (^)(EIPlazaDisplayModel *))block{
    //数据存数据库,图片存imageCache
    
    [[EIDataBaseManager sharedInstance] insertMessageModel:model.baseModel];
    
    [[SDWebImageManager sharedManager] saveImageToCache:model.image forURL:[NSURL URLWithString:model.baseModel.picture.origin_url]];
    
    [[SDWebImageManager sharedManager] saveImageToCache:model.placeholderImage forURL:[NSURL URLWithString:model.baseModel.picture.thumbnail_url]];
    
    block(model);
}

- (void)downloadImage:(NSString *)url completed:(void (^)(UIImage *, NSError *))completed{
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:url]
                                                    options:SDWebImageRetryFailed
                                                   progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      
#ifdef DEBUG
                                                      if (error) {
                                                          [[LogHelper sharedInstance] setLogArr:@[error.localizedDescription,imageURL.absoluteString]];
                                                      }
#endif
                                                      completed(image,error);
    }];
}

- (void)descendingFetchPlazaCacheFromDB:(int)count messageId:(NSString *)msgId completeBlock:(void (^)(NSArray *))completeBlock{
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    NSArray *plazaList = [[EIDataBaseManager sharedInstance] getLastMessagesByCount:count sinceMessage:msgId];
    
    if (plazaList.count == 0) {
        if (completeBlock) {
            completeBlock(nil);
        }
        return;
    }
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    [plazaList enumerateObjectsUsingBlock:^(EIMessageModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EIPlazaDisplayModel *displayModel = [[EIPlazaDisplayModel alloc] initWithBaseModel:obj];
        
        NSString *key ;
        BOOL isThumbnail = NO;
        if ([manager cachedImageExistsForURL:[NSURL URLWithString:displayModel.baseModel.picture.thumbnail_url]]) {
            key = [manager cacheKeyForURL:[NSURL URLWithString:displayModel.baseModel.picture.thumbnail_url]];
            isThumbnail = YES;
        }else{
            key = [manager cacheKeyForURL:[NSURL URLWithString:displayModel.baseModel.picture.origin_url]];
            isThumbnail = NO;
        }
        NSOperation *operation = [manager.imageCache queryDiskCacheForKey:key done:^(UIImage *image, SDImageCacheType cacheType) {
            dispatch_main_sync_safe(^{
                
                if (isThumbnail) {
                    displayModel.placeholderImage = image;
                }else{
                    displayModel.image = image;
                }
                [array addObject:displayModel];
                if (array.count == plazaList.count) {
                    completeBlock(array);
                }
            });
        }];
        
        [queue addOperation:operation];
    }];
}

//- (void)xianzhangekeng{
//    NSLog(@"最后一条消息的ID:%@",[[EIDataBaseManager sharedInstance] getLastMessageId]);
//}

- (NSString *)getLastMessgeIdFromDB{
    NSString *messgeId = [[EIDataBaseManager sharedInstance] getLastMessageId];
    return messgeId ? messgeId : @"0";
}

- (void)queryPushHistory{
    
}

- (NSString *)getCacheSize{
    NSUInteger size = [[SDImageCache sharedImageCache] getSize];
    if (size < 1000) {
        return @"0 M";
    }
    return [NSString stringWithFormat:@"%.2f M", size/(1024.0 *1024.0)];
}

- (NSString *)getOriginCacheSize{
    
    NSArray *baseModelList = [[EIDataBaseManager sharedInstance] getAllMessage];
    
    NSMutableArray *originFiles = [[NSMutableArray alloc] init];
    
    [baseModelList enumerateObjectsUsingBlock:^(EIMessageModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.isLeft.integerValue == 1) {
            NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:obj.picture.origin_url]];
            
            NSString *filePath = [[SDWebImageManager sharedManager].imageCache defaultCachePathForKey:key];
            
            [originFiles addObject:filePath];
        }
        
    }];
    
    __block NSUInteger size = 0;
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSString *filePath in originFiles) {
            
            NSError *error;
            
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
            if (!error) {
                size += [attrs fileSize];
            }
        }
    });
    
    if (size < 1000) {
        return @"0 M";
    }
    
    return [NSString stringWithFormat:@"%.2f M",size/(1024 * 1024.f)];
}

- (void)clearAllCache{
    [[SDWebImageManager sharedManager].imageCache clearMemory];
    [[SDWebImageManager sharedManager].imageCache clearDisk];
    
    //[[EIDataBaseManager sharedInstance] clearDB];
}

- (void)clearOriginImageCache{
    NSArray *baseModelList = [[EIDataBaseManager sharedInstance] getAllMessage];
    [baseModelList enumerateObjectsUsingBlock:^(EIMessageModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isLeft.integerValue == 1) {
            NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:obj.picture.origin_url]];
            [[SDWebImageManager sharedManager].imageCache removeImageForKey:key];
        }
    }];
}

- (void)deleteCacheFromDB:(EIMessageModel *)model block:(void (^)())completed{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[EIDataBaseManager sharedInstance] deleteMessage:model.msg_id];
        
        NSString *imageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:model.picture.origin_url]];
        [[SDWebImageManager sharedManager].imageCache removeImageForKey:imageKey withCompletion:^{
            NSString *imageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:model.picture.thumbnail_url]];
            [[SDWebImageManager sharedManager].imageCache removeImageForKey:imageKey withCompletion:^{
                if (completed) {
                    completed();
                }
            }];
        }];
    });
}

@end
