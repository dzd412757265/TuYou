//
//  EIMessageDetailViewModel.h
//  ExchangeImage
//
//  Created by 张博成 on 16/7/14.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIBaseViewModel.h"
#import "EIMessageDetailModel.h"
#import "EICommonHelper.h"
#import "EIUserCenter.h"

@interface EIMessageDetailViewModel : EIBaseViewModel

@property (nonatomic , strong)NSMutableArray *modelList;

- (void)downLoadHDPhoto:(EIMessageDetailModel *)model completed:(void(^)(EIMessageDetailModel *))completed;

- (EIMessageDetailModel *)insertWithModel:(EIUserModel *)model WithImage:(UIImage *)image withthumbnailImage:(UIImage *)thumbnailImage withImgOriginUrl:(NSString *)urlString withLeft:(NSNumber *)isleft withSendFaild:(BOOL)sendStatus withMessageId:(long)messageId withCreate:(long long)recieveCreateTime;

- (void)getInitMessageWithModel:(EIUserModel *)model;

- (void)getMoreListWithModel:(EIUserModel *)model;

- (void)sendMessageImage:(UIImage *)image targetId:(NSString *)targetId progress:(void(^)(int,long))progress success:(void(^)(long))success failure:(void(^)(NSString *,long))failure;

- (void)resendMessageWithModel:(EIMessageDetailModel *)model targetId:(NSString *)targetId progress:(void (^)(int, long))progressBlock success:(void(^)(long))success failure:(void(^)(NSString *,long))failure;


- (void)removeModel:(EIMessageDetailModel *)model;

@end
