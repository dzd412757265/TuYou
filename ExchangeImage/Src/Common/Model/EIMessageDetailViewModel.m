//
//  EIMessageDetailViewModel.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/14.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIMessageDetailViewModel.h"
#import <RongIMLib/RongIMLib.h>
#import "EIDataCacheManager.h"
#import "EIDefines.h"
#import "SoundManager.h"
#import "EIFileManager.h"
#import "SDWebImageManager.h"


@implementation EIMessageDetailViewModel

- (id)init{
    self = [super init];
    if (self) {
        
        self.modelList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)getInitMessageWithModel:(EIUserModel *)userModel
{
    NSArray *arrMessage = [[RCIMClient sharedRCIMClient] getLatestMessages:ConversationType_PRIVATE targetId:userModel.user_id count:10];
    
    for (RCMessage *message in arrMessage) {
        
        [self createModelWithMessage:message andWithUserModel:userModel];
    }

}

- (void)getMoreListWithModel:(EIUserModel *)userModel
{
    EIMessageDetailModel *detailModel = [self.modelList firstObject];
    NSArray *arrMessage = [[RCIMClient sharedRCIMClient] getHistoryMessages:ConversationType_PRIVATE
                                                                   targetId:userModel.user_id
                                                            oldestMessageId:detailModel.messageId
                                                                      count:5];
    
    for (RCMessage *message in arrMessage) {
       
        [self createModelWithMessage:message andWithUserModel:userModel];
    }
}
- (EIMessageDetailModel *)createModelWithMessage:(RCMessage *)message andWithUserModel:(EIUserModel *)userModel
{
    UIImage *thumbnailImage = nil;
    UIImage *originImage = nil;
    NSString *urlString = nil;
    BOOL isSendFaild = YES;
    NSLog(@"message.receivedTime is %lld",message.receivedTime);
    long long create = message.receivedTime;
    long messageIds = message.messageId;
    
    if([message.content isMemberOfClass:[RCImageMessage class]]){
        
        RCImageMessage *imageMessage =(RCImageMessage *)message.content;
        
        thumbnailImage= imageMessage.thumbnailImage;
        //            NSLog(@"ththunmbnai imag is%@",ththumbnailImage);
        urlString = imageMessage.imageUrl;
//        NSLog(@"imageMessage.imageurl is %@",urlString);
        if (message.sentStatus == SentStatus_FAILED) {
            isSendFaild = YES;
        }else if (message.sentStatus == SentStatus_SENDING){
            isSendFaild = YES;
        }else if (message.sentStatus == SentStatus_SENT){
            isSendFaild = NO;
        }else{
            isSendFaild = NO;
        }
    }
    
    EIUserModel *nuserModel = [[EIUserModel alloc] init];
    NSNumber *isLeft = nil;
    if (message.messageDirection  == MessageDirection_SEND) {
        
        nuserModel.user_id = [NSString stringWithString:[EIUserCenter sharedInstance].userId];
        nuserModel.avatar = [NSString stringWithString:[EIUserCenter sharedInstance].userAvatar];
        nuserModel.nickname = [NSString stringWithString:[EIUserCenter sharedInstance].userNickname];
        nuserModel.sex = [NSNumber numberWithInteger:[EIUserCenter sharedInstance].userSex];
        nuserModel.city = @"未知";
        originImage = [UIImage imageWithContentsOfFile:urlString];
        isLeft = @(0);
        
    }else{
        
        nuserModel.user_id = userModel.user_id;
        nuserModel.avatar = userModel.avatar;
        nuserModel.nickname = userModel.nickname;
        nuserModel.sex = userModel.sex;
        nuserModel.city = userModel.city;
        isLeft = @(1);
        
    }
    
    EIMessageDetailModel *messageDetailModle = [self createModelWithModel:nuserModel WithImage:originImage withthumbnailImage:thumbnailImage withImgOriginUrl:urlString withIsleft:isLeft withSendFaild:isSendFaild withMessageId:messageIds withCreate:create];
    //        NSLog(@"model urlString is %@",messageDetailModle.baseModel.picture.origin_url);
    
    
    [self.modelList insertObject:messageDetailModle atIndex:0];
    
    return messageDetailModle;
}
- (EIMessageDetailModel *)createModelWithModel:(EIUserModel *)userModel WithImage:(UIImage *)image withthumbnailImage:(UIImage *)thumbnailImage withImgOriginUrl:(NSString *)urlString withIsleft:(NSNumber *)isLeft withSendFaild:(BOOL)sendStatus withMessageId:(long)messageId withCreate:(long long)recieveCreateTime{
    
    EIMessageDetailModel *model = [[EIMessageDetailModel alloc]init];
    
    model.user = userModel;
    
    model.image = image;
    
    model.thumbnailImage = thumbnailImage;
    
    model.origin_url = urlString;
    
    model.isLeft = isLeft;
    
    model.sendFailed = sendStatus;
    
    model.messageId = messageId;
    
    model.receivedTime = recieveCreateTime;
    
    model.placeholderImage = thumbnailImage;
    
    model.progress  =-1;
    
    return model;
}

- (EIMessageDetailModel *)insertWithModel:(EIUserModel *)userModel WithImage:(UIImage *)image withthumbnailImage:(UIImage *)thumbnailImage withImgOriginUrl:(NSString *)urlString withLeft:(NSNumber *)isleft withSendFaild:(BOOL)sendStatus withMessageId:(long)messageId withCreate:(long long)recieveCreateTime
{
    
    EIMessageDetailModel *messageDetailModle = [self createModelWithModel:userModel WithImage:image withthumbnailImage:thumbnailImage withImgOriginUrl:urlString withIsleft:isleft withSendFaild:sendStatus withMessageId:messageId withCreate:recieveCreateTime];
    
    [self.modelList addObject:messageDetailModle];
    
    return messageDetailModle;

}

- (void)downLoadHDPhoto:(EIMessageDetailModel *)model completed:(void (^)(EIMessageDetailModel *))completed{
    
//    NSLog(@"url string is %@",model.baseModel.picture.origin_url);
    [[EIDataCacheManager sharedInstance] downloadImage:model.origin_url completed:^(UIImage *image, NSError *error) {
        if (!error) {
            model.image = image;
        }else{
            DLog(@"imageErro*************%@",error);
        }
        completed(model);
    }];
}

- (void)sendMessageImage:(UIImage *)image targetId:(NSString *)targetId progress:(void (^)(int, long))progressBlock success:(void (^)(long))success failure:(void (^)(NSString *, long))failure
{
//    NSLog(@"image is %@,tartId is %@",image,targetId);
    RCImageMessage *contentMessage = [RCImageMessage messageWithImage:image];
    [[RCIMClient sharedRCIMClient] sendImageMessage:ConversationType_PRIVATE
                                           targetId:targetId
                                            content:contentMessage
                                        pushContent:nil
                                           progress:^(int progress, long messageId){
                                               
//                                               NSLog(@"progress is %d",progress);
                                               
                                               progressBlock(progress,messageId);
                                           }
                                            success:^(long messageId) {
                                                NSLog(@"发送成功。当前消息ID：%ld", messageId);
                                                //播放声音
                                                [[SoundManager manager] playSwipeSoundIfNeed];

                                                success(messageId);
                                                
                                            }error:^(RCErrorCode nErrorCode, long messageId) {
                                                NSLog(@"发送失败。消息ID：%ld， 错误码：%ld", messageId, (long)nErrorCode);
                                                
                                                NSString *errorString = nil;
                                                if(nErrorCode == ERRORCODE_UNKNOWN){
                                                    errorString = @"未知错误";
                                                }else if(nErrorCode == REJECTED_BY_BLACKLIST){
                                                    errorString = @"已被对方加入黑名单";
                                                }else if (nErrorCode == ERRORCODE_TIMEOUT){
                                                    errorString = @"超时";
                                                }else if (nErrorCode == SEND_MSG_FREQUENCY_OVERRUN){
                                                    errorString = @"发送频率太快";
                                                }else if(nErrorCode == RC_CHANNEL_INVALID){
                                                    errorString = @"网络连接不可用";
                                                }else if(nErrorCode == RC_NETWORK_UNAVAILABLE){
                                                    errorString = @"当前连接不可用";
                                                }else if (nErrorCode == DATABASE_ERROR){
                                                    errorString = @"数据库错误";
                                                }else if (nErrorCode == INVALID_PARAMETER){
                                                    errorString = @"参数错误";
                                                }else if(nErrorCode == CLIENT_NOT_INIT){
                                                    errorString = @"sdk 未初始化，请重新登录";
                                                }else{
//                                                    errorString = [NSString stringWithFormat:@"错误%ld",nErrorCode];
                                                    errorString = @"网络链接错误，发送失败";
                                                }
//                                                NSString *error =[NSString stringWithFormat:@"发送消息失败,错误码：%@",errorString];
                                                failure(errorString,messageId);
                                            } ];
    

}
- (void)resendMessageWithModel:(EIMessageDetailModel *)model targetId:(NSString *)targetId progress:(void (^)(int, long))progressBlock success:(void (^)(long))success failure:(void (^)(NSString *, long))failure
{
    //删除本地消息
    BOOL isDelete = [[RCIMClient sharedRCIMClient] deleteMessages:@[@(model.messageId)]];
    
    if (isDelete) {
        
        //发送请求
//       NSLog(@"model.messageId is %ld",model.messageId);
//        
//        NSLog(@"model.image is %@",model.image);
        [self sendMessageImage:model.image
              targetId:targetId
              progress:^(int progress, long messageId){
                  
                  progressBlock(progress,messageId);
              }
              success:^(long messageId){
            
                  success(messageId);
            
             } failure:^(NSString *errocode,long messageId){
            
                 failure(errocode,messageId);
             }];
        }
    
}
- (void)deleteModelWith:(long)messageId
{
    for (EIMessageDetailModel *model in self.modelList) {
        
        if (model.messageId == messageId) {
            
            [self.modelList removeObject:model];
            
            break;
        }
    }
}

- (void)removeModel:(EIMessageDetailModel *)model
{
    for (EIMessageDetailModel *localModel in self.modelList ) {
        
        if (localModel.messageId == model.messageId) {
            
            [self.modelList removeObject:model];
            
            [[RCIMClient sharedRCIMClient] deleteMessages:@[@(model.messageId)]];
            
            NSString *urlString = model.origin_url;
            
            if ([model.isLeft integerValue] == 0) {
                
                [EIFileManager removeFileAtPath:urlString];
                
            }else if([model.isLeft integerValue] == 1){
                
                NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:urlString]];
                [[SDWebImageManager sharedManager].imageCache removeImageForKey:key];
            }
            
            break;
        }
    }
}
@end
