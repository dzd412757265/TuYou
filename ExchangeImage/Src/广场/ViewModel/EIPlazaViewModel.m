//
//  EIPlazaViewModel.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/6.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIPlazaViewModel.h"
#import "EIDataCacheManager.h"
#import "EIDefines.h"
#import <QiniuSDK.h>
#import "QNEtag.h"
#import "EIDefines.h"
#import "EINetworkTool.h"
#import "EIRequest.h"
#import "EIUserCenter.h"
#import "EICommonHelper.h"
#import "UIImage+Extension.h"
#import "EIServerManager.h"
#import "EIPlazaResponseModel.h"
#import "NSObject+EasyJSON.h"

#define LimitCount 10

@interface EIPlazaViewModel()

@property (nonatomic , strong)QNUploadManager *uploadManager;

@end

@implementation EIPlazaViewModel

- (id)init{
    self = [super init];
    if (self) {
        //初始化去数据里fetch
        self.modelList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (QNUploadManager *)uploadManager{
    if (!_uploadManager) {
//        _uploadManager = [[QNUploadManager alloc] initWithConfiguration:[QNConfiguration build:^(QNConfigurationBuilder *builder) {
//            builder.zone = [QNZone zone1];
//        }]];
        _uploadManager = [[QNUploadManager alloc] init];
    }
    return _uploadManager;
}

- (void)fetchCacheFromDB:(void (^)())completedBlock{
    
    NSString *messageId ;
    
    if (self.modelList.count == 0) {
        messageId = nil;
    }else{
        messageId = ((EIPlazaDisplayModel *)self.modelList.firstObject).baseModel.msg_id;
    }
    
    [[EIDataCacheManager sharedInstance] descendingFetchPlazaCacheFromDB:LimitCount messageId:messageId completeBlock:^(NSArray *cacheList) {
        if (cacheList && cacheList.count != 0) {
            [self.modelList insertObjects:cacheList atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, cacheList.count)]];
        }
        
        if (completedBlock) {
            completedBlock();
        }
    }];
}

- (void)insertModel:(EIPlazaDisplayModel *)model{
    [self.modelList addObject:model];
}

- (void)downLoadHDPhoto:(EIPlazaDisplayModel *)model completed:(void (^)(EIPlazaDisplayModel *))completed{
    
    if (!model.baseModel.picture.isNotEmpty) {
        return;
    }
    
    [[EIDataCacheManager sharedInstance] downloadImage:model.baseModel.picture.origin_url completed:^(UIImage *image, NSError *error) {
        if (!error) {
            model.image = image;
            if(completed) completed(model);
        }else{
            DLog(@"%@",error);
        }
    }];
}

- (void)downLoadPlaceHolderPhoto:(EIPlazaDisplayModel *)model completed:(void (^)(EIPlazaDisplayModel *))completed{
    [[EIDataCacheManager sharedInstance] downloadImage:model.baseModel.picture.thumbnail_url completed:^(UIImage *image, NSError *error) {
        if (!error) {
            model.placeholderImage = image;
        }else{
            DLog(@"%@",error);
        }
        if(completed) completed(model);
    }];
}

- (void)sendVirtualPicture:(UIImage *)image completed:(void (^)(EIPlazaDisplayModel *model))completeBlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EIPlazaDisplayModel *model = [self createTempDisplayModel:image];
        dispatch_sync(dispatch_get_main_queue(), ^{
            completeBlock(model);
        });
    });
}

- (void)sendActualPictures:(EIPlazaDisplayModel *)virtualModel
          startBlock:(void (^)())startBlock
        processBlock:(void (^)(float percent , NSString *imageKey))processBlock
      completedBlock:(void (^)(NSError *error , NSString *imageKey))completedBlock{
    
    dispatch_main_sync_safe(^{
        if(startBlock) startBlock();
    })
    
    DLog(@"本地计算的hash值:%@",[QNEtag data:[virtualModel.image compressData]]);
    
    ESWeakSelf
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        QNUpCompletionHandler completionHandler = ^(QNResponseInfo *info, NSString *key, NSDictionary *resp){
            
            if (info.error) {
                dispatch_main_sync_safe(^{
                    DLog(@"上传七牛失败%@:%d",info.error,info.statusCode);
#if DEBUG_MODE
                    virtualModel.uploadPercent = -1.f;
#endif
                    NSString *errorMsg;
                    if (info.statusCode == -1009) {
                        errorMsg = @"连接异常,请检查您的网络";
                    }else{
                        errorMsg = @"发送失败,请重试";
                    }
                    NSError *error = [NSError errorWithDomain:@"COMMON" code:info.error.code userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
                    if(completedBlock) completedBlock(error,key);
                })
                return;
            }
//#if DEBUG_MODE
//            if (processBlock) {
//                virtualModel.uploadPercent = 1;
//                processBlock(1,key);
//            }
//#endif
            EIRequest *request = [EIRequest request];
            request.method = HttpMethod_POST;
            request.path = @"/v1.0/pictures";
            request.httpHeaderFields = @{@"EXP-User-Token":[EIUserCenter sharedInstance].userToken};
            
            NSString *picHash = [resp objectForKey:@"hash"];
            
            DLog(@"上传七牛返回的hash:%@",picHash);
            
            [request.params addEntriesFromDictionary:@{@"picture_key":key,@"picture_hash":picHash ? picHash :@"",@"city":[EIUserCenter sharedInstance].userCity,@"longitude":@"",@"latitude":@""}];
            
            [EINetworkTool networkTool:request success:^(id obj) {
                
                NSError *error;
                
                EIPlazaResponseModel *actualModel = [[EIPlazaResponseModel alloc] initWithDictionary:obj error:&error];
                if (!error) {
                    //这里返回的cur_msg_id和exp_msg里的一样
                    //virtualModel.baseModel.msg_id = actualModel.cur_msg_id;
                    virtualModel.baseModel.picture.picture_id = actualModel.picture_id;
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (long)(arc4random()%3 + 1)*NSEC_PER_SEC),
                                   dispatch_get_main_queue(),
                                   ^{
                                       [[EIServerManager sharedInstance] sendData:virtualModel actualModel:actualModel.exp_msg];
                                   });
                }else{
                    DLog(@"EIPlazaResponseModel解析error:\n%@",error);
                }
                dispatch_main_sync_safe(^{
#if DEBUG_MODE
                    virtualModel.uploadPercent = -1.f;
#endif
                    if(completedBlock) completedBlock(nil,key);
                })
            } failure:^(NSError *error) {
                dispatch_main_sync_safe(^{
#if DEBUG_MODE
                    virtualModel.uploadPercent = -1.f;
#endif
                    if(completedBlock) completedBlock(error,key);
                })
            }];
        };
        
        QNUploadOption *opt = [[QNUploadOption alloc] initWithProgressHandler:^(NSString *key, float percent) {
            dispatch_async(dispatch_get_main_queue(), ^{
#if DEBUG_MODE
                CGFloat value = percent >= .95f ? -1 : percent;
                virtualModel.uploadPercent = value;

                if(processBlock) processBlock(value,key);
#endif
            });
        }];

        [__weakSelf.uploadManager putData:[virtualModel.image compressData]
                                      key:virtualModel.imageKey
                                    token:[EIUserCenter sharedInstance].qnToken
                                 complete:completionHandler
                                   option:opt];
    });
}

- (EIPlazaDisplayModel *)createTempDisplayModel:(UIImage *)image{
    EIPlazaDisplayModel *model = [EIPlazaDisplayModel new];
    model.image = [image resetSizeOfImage];
    model.placeholderImage = [image scaledToMaxSize:CGSizeMake(200, 200)];
    model.imageKey = [EICommonHelper createPictureKey:[EIUserCenter sharedInstance].userId];
    
    model.baseModel  = [[EIMessageModel alloc] init];
    model.baseModel.isLeft = @(0);
    model.baseModel.msg_id = [EICommonHelper systemNow];    //假的
    model.baseModel.user =[ [EIUserCenter sharedInstance] getUser];
    
    model.baseModel.picture = [[EIPictureModel alloc] init];
    model.baseModel.picture.picture_id = [EICommonHelper systemNow]; //假的
    model.baseModel.picture.origin_url = [[EICommonHelper createImageURL] absoluteString];
    model.baseModel.picture.thumbnail_url = [model.baseModel.picture.origin_url stringByAppendingString:@"?imageView2/0/h/200"];
    
    model.baseModel.picture.created = [NSNumber numberWithInt:[EICommonHelper systemDate]];
    return model;
}

- (BOOL)changeSendStatus:(BOOL)isFailed imageKey:(NSString *)imageKey{
    
    if (self.modelList.count == 0) {
        return NO;
    }
    __block BOOL isChanged = NO;
    [self.modelList enumerateObjectsUsingBlock:^(EIPlazaDisplayModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.imageKey isEqualToString:imageKey]) {
            if (obj.sendFailed != isFailed) {
                obj.sendFailed = isFailed;
                isChanged = YES;
            }
            *stop = YES;
        }
    }];
    
    return isChanged;
}

- (void)queryPushHistory:(void (^)(BOOL))completedBlock{
    
    EIRequest *request = [EIRequest request];
    request.method = HttpMethod_GET;
    request.path = @"/v1.0/messages";
    request.httpHeaderFields = @{@"EXP-User-Token":[EIUserCenter sharedInstance].userToken};
    [request.params addEntriesFromDictionary:@{@"since":[[EIDataCacheManager sharedInstance] getLastMessgeIdFromDB],@"num":@"10"}];
    
    [EINetworkTool networkTool:request success:^(id data) {
        JSONModelError * error;
        EIMsgListModel *list = [[EIMsgListModel alloc] initWithDictionary:data error:&error];
        if (!error) {
            if (list.msg_list.count > 0) {
                [self downLoadHistory:list.msg_list downloadSuccessBlock:completedBlock];
            }else{
                if (completedBlock) {
                    completedBlock(NO);
                }
            }
        }else{
            if (completedBlock) {
                completedBlock(NO);
            }
            DLog(@"%@",error);
        }
        
    } failure:^(NSError *error) {
        completedBlock(NO);
        DLog(@"获取推送历史失败:%@",error);
    }];
}

- (void)downLoadHistory:(NSArray *)modelList
          downloadSuccessBlock:(void(^)(BOOL))completedBlock{
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    [modelList enumerateObjectsUsingBlock:^(EIMessageModel *  obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [[EIDataCacheManager sharedInstance] receiveImageData:obj block:^(EIPlazaDisplayModel *displayModel) {
                [self.modelList addObject:displayModel];
                dispatch_main_sync_safe(^{
                    if (completedBlock) {
                        completedBlock(YES);
                    }
                })
            }];
        }];
        [queue addOperation:operation];
    }];
}

- (void)deleteDisplayModel:(EIPlazaDisplayModel *)model completed:(void (^)())block{
    
    [self.modelList removeObject:model];
    
    [[EIDataCacheManager sharedInstance] deleteCacheFromDB:model.baseModel block:block];
}

- (void)deleteAllModel:(void (^)())block{
    
    [self.modelList removeAllObjects];
    
    if (block) {
        block();
    }
}

- (void)clearMemory:(void (^)())block{
    
    if (self.modelList.count <= 10) {
        return;
    }
    
    [self.modelList removeObjectsInRange:NSMakeRange(self.modelList.count - 10, 10)];
    
    if (block) {
        block();
    }
}

@end
