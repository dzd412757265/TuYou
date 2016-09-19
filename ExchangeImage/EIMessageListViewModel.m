//
//  EIMessageListViewModel.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/14.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIMessageListViewModel.h"
#import "EIRequest.h"
#import "EINetworkTool.h"
#import "EIDefines.h"
#import "EIUserCenter.h"
#import "EICommonHelper.h"
#import "EIUserDateBase.h"
#import "NSObject+EasyJSON.h"
#import "SDWebImageManager.h"
#import "EIFileManager.h"


@implementation EIMessageListViewModel

- (instancetype)init
{
    if (self =[super init]) {
        
        _userList =[[NSMutableArray alloc]init];
    }
    return self;
}
- (void)getChartListSuccess:(void (^)(void))success failure:(void (^)(void))failure
{
    
    int totalUnreadCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[@(ConversationType_PRIVATE)]];
//    NSLog(@"totalUnreadCount is %d",totalUnreadCount);
    if (totalUnreadCount >= 1) {
        dispatch_main_async_safe(^{
            [[NSNotificationCenter defaultCenter]postNotificationName:EINotificationUnreadMessage object:self userInfo:@{@"data" : @(YES)}];
        })
    }else{
        dispatch_main_async_safe(^{
            [[NSNotificationCenter defaultCenter]postNotificationName:EINotificationUnreadMessage object:self userInfo:@{@"data" : @(NO)}];
        })
    }
   
    
    NSArray *conversationList = [[RCIMClient sharedRCIMClient]
                                 getConversationList:@[@(ConversationType_PRIVATE)]];
    
    _dataSource = conversationList;
    
    
    if (_dataSource.count < self.userList.count) {
        
        [self.userList removeAllObjects];
    }
    
    ESWeakSelf
    for (RCConversation *conversation in _dataSource) {
//                NSLog(@"会话类型：%lu，目标会话ID：%@ , conversation.unreadMessageCount is %d", (unsigned long)conversation.conversationType, conversation.targetId,conversation.unreadMessageCount);
        
        BOOL isExist = NO;
        for (EIMessageListModel *model in self.userList) {
            
            if ([model.targetId isEqualToString:conversation.targetId]) {
                
//                NSLog(@"list unreadMessageCount is %@",@(conversation.unreadMessageCount));
                model.messageNumber = @(conversation.unreadMessageCount);
                model.timeString = [EICommonHelper createMessageDate:conversation.receivedTime /1000];
                isExist = YES;
                break;
            }
        }
        
        if (isExist) {
            
            continue;
        }
        
        EIUserModel *userModel  = [[EIUserDateBase sharedInstance]getUserById:conversation.targetId];
        
        if (userModel.isNotEmpty) {
            
            EIMessageListModel *model = [[EIMessageListModel alloc]init];
            
            [model setUserModel:userModel];
            
            model.targetId = conversation.targetId;
            model.messageNumber = @(conversation.unreadMessageCount);
            model.timeString = [EICommonHelper createMessageDate:conversation.receivedTime/1000];
            
            [self.userList addObject:model];
        }else{
        
            EIRequest *requst  = [EIRequest request];
            
            requst.method = HttpMethod_GET;
            
            requst.httpHeaderFields = @{@"EXP-User-Token":[EIUserCenter sharedInstance].userToken};
            
            requst.path = [NSString stringWithFormat:@"/v1.0/users/%@/baseinfo",conversation.targetId];
            
            [ EINetworkTool networkTool:requst success:^(NSDictionary * object) {
                
                EIUserModel *userModel = [[EIUserModel alloc]initWithDictionary:object error:nil];
                [[EIUserDateBase sharedInstance]insertUserToDB:userModel];
                EIMessageListModel *model = [[EIMessageListModel alloc]init];
                [model setUserModel:userModel];
                model.messageNumber = @(conversation.unreadMessageCount);
                model.targetId = conversation.targetId;
                model.timeString = [EICommonHelper createMessageDate:conversation.receivedTime/1000];
                [__weakSelf.userList addObject:model];
                
                //            NSLog(@"self.viewModel.userList is %lu",(unsigned long)self.viewModel.userList.count);
                success();
                
                //            NSLog(@"avatar is %@,city is %@ ,nickname is%@,sex is %@,user_id is %@",model.avatar,model.city,model.nickname,model.sex,model.user_id);
                
            } failure:^(NSError * error) {
                NSLog(@"用户列表的请求错误信息是 %@",error);
                
            }];

        }
    }
}

- (void)removeConversation:(NSString *)targetId
{
    for (RCConversation *conversation in self.dataSource) {
        
        if ([targetId isEqualToString:conversation.targetId]) {
            
            //删除会话里的所有图片
            NSArray *array = [[RCIMClient sharedRCIMClient] getLatestMessages:ConversationType_PRIVATE targetId:targetId count:10000];
            
            [array enumerateObjectsUsingBlock:^(RCMessage *message, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if([message.content isMemberOfClass:[RCImageMessage class]]){
                    
                    RCImageMessage *imageMessage =(RCImageMessage *)message.content;
                    
                    NSString * urlString = imageMessage.imageUrl;
                    
//                    NSLog(@"urlString is %@",imageMessage.imageUrl);
                    
                    if (message.messageDirection == MessageDirection_SEND) {
                        
                        [EIFileManager removeFileAtPath:urlString];
                        
                    }else if(message.messageDirection == MessageDirection_RECEIVE){
                        
                        NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:urlString]];
                        [[SDWebImageManager sharedManager].imageCache removeImageForKey:key];
                    }
                    
                }

            }];
            
            //删除会话列表
            [[RCIMClient sharedRCIMClient] removeConversation:conversation.conversationType targetId:conversation.targetId];
            //删除会话中所有消息
            [[RCIMClient sharedRCIMClient] clearMessages:conversation.conversationType targetId:conversation.targetId];
            
        }
    }
    
    for (EIMessageListModel *model in self.userList) {
        
        if ([model.targetId isEqualToString:targetId]) {
            
            [self.userList removeObject:model];
            return;
        }
    }
}
@end
