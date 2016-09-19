//
//  EIMessageDetailTC.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/14.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIMessageDetailTC.h"
#import "EIDefines.h"
#import "EIMessageDetailCell.h"
#import "EIServerManager.h"
#import "EIPlazaTipsView.h"
#import "EIOpenCameraToolBar.h"
#import "UIViewController+MMDrawerController.h"
#import "NYTPhotosViewController.h"
#import "EIBaseImageView.h"
#import "SVProgressHUD.h"
#import "UIActionSheet+BlocksKit.h"
#import <RongIMLib/RongIMLib.h>
#import "EIUserCenter.h"
#import "EIImagePickerController.h"
#import "EIServerManager.h"
#import "MJRefresh.h"
#import "EIReportTC.h"
#import "SVProgressHUD.h"
#import "DDProgressHUD.h"
#import "EIMessageDetailTittleView.h"
#import "UIImage+Extension.h"

#import "SensorsAnalyticsSDK.h"
#import "EIBaseNavigationController.h"
#import "HBDrawingVC.h"


@interface EIMessageDetailTC()<NYTPhotosViewControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate>

@property (nonatomic , strong)EIMessageDetailViewModel *viewModel;

@property (nonatomic , strong)EIPlazaTipsView *tipsView;

@property (nonatomic , strong)NYTPhotosViewController *photoBrowerVC;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)EIUserModel *targetUserModel;

@end

@implementation EIMessageDetailTC
- (instancetype)initWithModel:(EIUserModel *)model
{
    if (self =[super init]) {
        
        self.targetUserModel = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.joinAnalytic = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
    
    ESWeakSelf
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        //加载数据
        
        [__weakSelf.viewModel getMoreListWithModel:__weakSelf.targetUserModel];
        
        [__weakSelf.tableView reloadData];
        
        [__weakSelf.tableView.mj_header endRefreshing];
        
    }];
    
    [self setupTitle];
    [self getMessage];
    [self testToolBar];
    [self setupTipsLabel];
    
    //清空未读消息
    [self clearUnReadCount];

    
//    int totalUnreadCount = [[RCIMClient sharedRCIMClient] getTotalUnreadCount];
//    NSLog(@"当前所有会话的未读消息数为：%d", totalUnreadCount);
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getmessagess:) name:EINotificationReceiveMessage object:nil];
    [EIServerManager sharedInstance].messageTarget = self.targetUserModel.user_id;

    //统计
    [[[SensorsAnalyticsSDK sharedInstance] people] setOnce:@"FirstPrivateTime" to:[EICommonHelper getCurrentTime]];
    
    [[[SensorsAnalyticsSDK sharedInstance] people] increment:@"PrivateCount" by:[NSNumber numberWithInt:1]];
    
    [[SensorsAnalyticsSDK sharedInstance] track:@"PrivateChat"
                                 withProperties:@{
                                                  @"ReceiveId" : self.targetUserModel.user_id,
                                                  @"ReceiveGender" : self.targetUserModel.sex,
                                                  @"SenderGender" : [NSNumber numberWithInteger:[EIUserCenter sharedInstance].userSex]
                                                  }];
}

#pragma mark ---初始化UI
- (void)setupTitle{
    CGSize titleSize = [EIMessageDetailTittleView caculateViewWidthWithName:self.targetUserModel.nickname];
    EIMessageDetailTittleView *titleView =[[EIMessageDetailTittleView alloc]initWithFrame:CGRectMake(0, 0, titleSize.width, titleSize.height)];
    
    [titleView setTitleWithName:self.targetUserModel.nickname andWithSex:self.targetUserModel.sex andWithCity:self.targetUserModel.city];
    
    self.navigationItem.titleView = titleView;
//    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 44)];
//    
//    [backButton setImage:[UIImage imageNamed:@"ArrowLeft"] forState:UIControlStateNormal];
//    
//    [backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    UIButton *otherButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 44)];
    
    [otherButton setImage:[UIImage imageNamed:@"moreFunction"] forState:UIControlStateNormal];
    
    [otherButton addTarget:self action:@selector(otherButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -15;
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:otherButton];
    
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightBarButtonItem];
}

- (void)testToolBar{
    
    ESWeakSelf
    EIOpenCameraToolBar *toolBar = [EIOpenCameraToolBar cameraToolBar];
    toolBar.clickBlock = ^(){
        
        //统计
        [[SensorsAnalyticsSDK sharedInstance] trackTimer:@"SendPicture"];
        
        EIImagePickerController *vc = [EIImagePickerController createImagePickerController:^(UIImage *originImage) {
            
            [__weakSelf mediaDidFinishWithImage:originImage];
            
            //统计
            [[SensorsAnalyticsSDK sharedInstance] track:@"SendPicture"
                                         withProperties:@{
                                                          @"Method" : [NSNumber numberWithInt:1],
                                                          @"Channel" : @"app",
                                                          @"Source" : [NSNumber numberWithInt:1],
                                                          @"Gender" : [NSNumber numberWithInteger:[EIUserCenter sharedInstance].userSex]
                                                          }];
            
        } openAlbum:^(UIViewController *dismissVC) {
            [dismissVC dismissViewControllerAnimated:YES completion:^{
                [EIImagePickerController openAlbum:__weakSelf
                               didFinishPhotoBlock:^(UIImage *originImage) {
                                   
                                   [__weakSelf mediaDidFinishWithImage:originImage];
                                   
                                   //统计
                                   [[SensorsAnalyticsSDK sharedInstance] track:@"SendPicture"
                                                                withProperties:@{
                                                                                 @"Method" : [NSNumber numberWithInt:0],
                                                                                 @"Channel" : @"app",
                                                                                 @"Source" : [NSNumber numberWithInt:1],
                                                                                 @"Gender" : [NSNumber numberWithInteger:[EIUserCenter sharedInstance].userSex]
                                                                                 }];
                               }];
            }];
            
        }];
        [__weakSelf presentViewController:vc animated:YES completion:nil];
    };
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(barHandleLongPress:)];
    [toolBar addGestureRecognizer:longPress];
    
    [self.view addSubview:toolBar];
}

- (void)setupTipsLabel{
    _tipsView = [[EIPlazaTipsView alloc] initWithFrame:CGRectMake(0, 64 - 30, CGRectGetWidth(self.view.bounds), 30)];
    [self.view addSubview:_tipsView];
}
#pragma mark ---按钮点击事件
- (void)backButtonClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)otherButtonClick:(id)sender
{
   UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拉黑",nil];
    
    [actionSheet showInView:self.view];
    
}
#pragma mark ---初始化数据
- (void)getMessage
{
    [self.viewModel getInitMessageWithModel:self.targetUserModel];
    
    [self.tableView reloadData];
        
    [self scrollToBottomAnimated:YES];
}
/** 清空一下此会话下的未读消息 **/
- (void)clearUnReadCount
{
    //清空未读消息
    [[RCIMClient sharedRCIMClient] clearMessagesUnreadStatus:ConversationType_PRIVATE targetId:self.targetUserModel.user_id];
    
}

#pragma mark ----收发消息
//打开相机拍照结束
- (void)mediaDidFinishWithImage:(UIImage *)image{
    
    NSDate *dat=[NSDate dateWithTimeIntervalSinceNow:0];
    
    NSTimeInterval now=[dat timeIntervalSince1970]*1000;
    
    long defaultMessageId = -1;
    
    UIImage *originImage = [image compressImage];
    
   EIMessageDetailModel *messageModel = [self.viewModel insertWithModel:[[EIUserCenter sharedInstance]getUser] WithImage:originImage withthumbnailImage:nil withImgOriginUrl:nil withLeft:@(0) withSendFaild:NO withMessageId:defaultMessageId withCreate:(long long)now];
    
    NSLog(@"now is %f",now);
    __block EIMessageDetailModel* message = messageModel;
    
    ESWeakSelf
    
    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];

//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        [__weakSelf.tableView reloadData];
//        [__weakSelf scrollToBottomAnimated:YES];
//        
//    });
    
//
//    NSLog(@"messageCell is %@",detailCell);
    [self.viewModel sendMessageImage:originImage
                    targetId:self.targetUserModel.user_id
                    progress:^(int progress,long messageId){
                        
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        message.progress = progress;
                                        [__weakSelf uploadVisibleTableViewCell:progress messagDetailModel:message];
                                    });

                            }
                    success:^(long messageId){
        
                        
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                message.messageId = messageId;
                                message.sendFailed = NO;
                                message.progress = -1;
                            [__weakSelf uploadVisibleTableViewCell:-1 messagDetailModel:message];
                            
//                            [__weakSelf.tableView reloadData];
//                            
//                            [__weakSelf scrollToBottomAnimated:YES];
                            
                            [[SensorsAnalyticsSDK sharedInstance] track:@"SendPrivatePicture"
                                                         withProperties:@{
                                                                              @"ReceiveId" : self.targetUserModel.user_id,
                                                                              @"ReceiveGender" : self.targetUserModel.sex,
                                                                              @"SenderGender" : [NSNumber numberWithInteger:[EIUserCenter sharedInstance].userSex]
                                                          }];
            
                        });

                    }
                    failure:^(NSString * error, long messageId) {
                        
//                           [detailCell updatePercent:-1];
                        
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
//                                NSLog(@"erro message is %ld",messageId);
                                message.messageId = messageId;
                                message.progress = -1;
//                                NSLog(@"erro message is %ld",message.messageId);
                                message.sendFailed = YES;
                                
                                    [__weakSelf uploadVisibleTableViewCell:-1 messagDetailModel:message];
                                    [__weakSelf.tableView reloadData];
            
                                    [__weakSelf scrollToBottomAnimated:YES];
            
                                    [__weakSelf.tipsView show:error];
            
                            });

                    }];
    

}

- (void)getmessagess:(NSNotification *)noti
{
    RCMessage * message = [noti.userInfo objectForKey:@"data"];
    
    if (![message.targetId isEqualToString:self.targetUserModel.user_id]) {
        return;
    }
    if ([message.content isMemberOfClass:[RCTextMessage class]]) {
        //        RCTextMessage *testMessage = (RCTextMessage *)message.content;
        //        NSLog(@"消息内容：%@", testMessage.content);
    }else if([message.content isMemberOfClass:[RCImageMessage class]]){
        
        //         NSLog(@"消息内容：%@", message.content);
        RCImageMessage *imageMessage =(RCImageMessage *)message.content;
        
        //        NSLog(@"RCMessage .receiveCreate is %lld",message.receivedTime);
        UIImage *image = imageMessage.thumbnailImage;
        
        
        [self.viewModel insertWithModel:self.targetUserModel WithImage:nil withthumbnailImage:image withImgOriginUrl:imageMessage.imageUrl withLeft:@(1) withSendFaild:NO withMessageId:message.messageId withCreate:message.receivedTime];
        //        [self.viewModel insertModel:model];
        
        [[RCIMClient sharedRCIMClient] setMessageReceivedStatus:message.messageId receivedStatus:ReceivedStatus_READ];
        
        [self.tableView reloadData];
        
        [self scrollToBottomAnimated:YES];
        
    }
    
    //    NSLog(@"还剩余的未接收的消息数：%d", nLeft);
}

- (NSInteger)indexformodel:(EIMessageDetailModel *)messageModel
{
    NSInteger integer = 0;
    
    for (EIMessageDetailModel *model in self.viewModel.modelList) {
        
        if (model.messageId == messageModel.messageId) {
            
            return integer;
        }
        integer ++;
    }
    return -1;
}
- (void)reSendFailureMessage:(EIMessageDetailModel *)messageModel
{
    ESWeakSelf
    
    __block EIMessageDetailModel *messageDetailModel = messageModel;
    
//    __block EIMessageDetailCell *detailCell = nil;
//    if ([self indexformodel:messageModel] != -1) {
//       detailCell  = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self indexformodel:messageModel] inSection:0]];
//        [detailCell updatePercent:0];
//    }
//
//    NSLog(@"resendMessageModel longmessageIdis %ld",messageModel.messageId);
    
    [self.viewModel resendMessageWithModel:messageModel
                                 targetId:self.targetUserModel.user_id
                                 progress:^(int intimeProgress, long messageId) {
                                     
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         
//                                         if (detailCell) {
                                         
                                             messageDetailModel.progress = intimeProgress;
                                             [__weakSelf uploadVisibleTableViewCell:intimeProgress messagDetailModel:messageDetailModel];
//                                         }
                                         
                                     });
                                 }
                                  success:^(long messageId) {
                                   
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         
                                         messageDetailModel.messageId = messageId;
                                         messageDetailModel.sendFailed = NO;
                                         messageDetailModel.progress = -1;
//                                         if (detailCell) {
                                            [__weakSelf uploadVisibleTableViewCell:-1 messagDetailModel:messageDetailModel];
//                                         }

                                         [__weakSelf.tableView reloadData];
                                         
                                     });

                                 } failure:^(NSString *errorCode, long messageId) {
                                     
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         messageDetailModel.messageId = messageId;
                                         messageDetailModel.sendFailed = YES;
                                         messageDetailModel.progress = -1;
                                         [__weakSelf.tipsView show:errorCode];
                                         
//                                         if (detailCell) {
                                            [__weakSelf uploadVisibleTableViewCell:-1 messagDetailModel:messageDetailModel];
//                                         }
                                         [__weakSelf.tableView reloadData];
                                     });

                                 }];
    
}

- (void)uploadVisibleTableViewCell:(float)percent messagDetailModel:(EIMessageDetailModel *)detailModel{
    NSArray *cellList = self.tableView.visibleCells;
    [cellList enumerateObjectsUsingBlock:^(EIMessageDetailCell* cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cell isTheCellForModel:detailModel]) {
            //todo...
            [cell updatePercent:percent];
        }
    }];
}

- (void)dealloc{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:EINotificationReceiveMessage object:nil];
    [EIServerManager sharedInstance].messageTarget = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ---property
- (EIMessageDetailViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [EIMessageDetailViewModel new];
    }
    return _viewModel;
}

- (NSMutableArray *)dataList
{
    if (!_dataList) {
        
        _dataList = [[NSMutableArray alloc]init];
    }
    return _dataList;
}

#pragma mark -- tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewModel.modelList.count;
}

- (EIMessageDetailCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EIMessageDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:[EIMessageDetailCell identifer]];
    if (!cell) {
        cell = [[EIMessageDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[EIMessageDetailCell identifer]];
    }
    
     NSInteger curIndex = indexPath.row;
    [cell setImageWithModel:[self.viewModel.modelList objectAtIndex:curIndex]];
    
    ESWeakSelf
    cell.clickPhotoBlock = ^(EIMessageDetailModel *model){

        [__weakSelf openPhotoBrower:model];
    };
    
    cell.clickResendBlock = ^(EIMessageDetailModel *model){
        
        [__weakSelf reSendFailureMessage:model];
    };
    
    cell.longClickPhotoBlock = ^(EIMessageDetailModel *model){
    
        [__weakSelf.viewModel removeModel:model];
        
        [__weakSelf.tableView reloadData];
    };

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger curIndex = indexPath.row;
    
    return [EIMessageDetailCell cellHeightWithModel:[self.viewModel.modelList objectAtIndex:curIndex]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}


#pragma mark -- 图片放大
- (void)openPhotoBrower:(EIMessageDetailModel *)localModel{
    
    _photoBrowerVC = [[NYTPhotosViewController alloc] initWithPhotos:@[localModel]
                                                        initialPhoto:localModel
                                                            delegate:self];
    [self presentViewController:_photoBrowerVC animated:YES completion:nil];
    [self checkHDImageExist:localModel update:_photoBrowerVC];
}

- (void)checkHDImageExist:(EIMessageDetailModel *)model update:(NYTPhotosViewController *)photosViewController{
    if (model.image == nil) {
        if([model.isLeft intValue] == 0){
            
            NYTPhotosViewController *mPhotoVC = photosViewController;
            model.image = [UIImage imageWithContentsOfFile:model.origin_url];
            [mPhotoVC updateImageForPhoto:model];
            
            [self.tableView reloadData];
        
        }else{
            
            ESWeakSelf
            __block  NYTPhotosViewController *mPhotoVC = photosViewController;
            [self.viewModel downLoadHDPhoto:model completed:^(EIMessageDetailModel *completedModel) {
                [mPhotoVC updateImageForPhoto:completedModel];
                
                [__weakSelf.tableView reloadData];
            }];
        }
        
    }
}

#pragma mark -- scrollView action

//tableview的最后一个cell一定要位于可视化的cell至少3个
- (BOOL)scrollAtBottom{
    UITableViewCell *cell = self.tableView.visibleCells.lastObject;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if ([self.tableView numberOfRowsInSection:0] - indexPath.row <= 3) {
        return YES;
    }
    return NO;
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger rows = [self.tableView numberOfRowsInSection:0];

    if(rows > 0 && self.tableView.contentSize.height > CGRectGetHeight(self.tableView.bounds)) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
    }
}

#pragma mark -- photobrower delegate

- (UIView *)photosViewController:(NYTPhotosViewController *)photosViewController loadingViewForPhoto:(id<NYTPhoto>)photo{
    DDProgressHUD *view = [[DDProgressHUD alloc] init];
    return view;
};

- (UIView *)photosViewController:(NYTPhotosViewController *)photosViewController referenceViewForPhoto:(id<NYTPhoto>)photo{
    NSUInteger row = [self.viewModel.modelList indexOfObject:photo];
    EIMessageDetailCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    if (cell) {
        return cell.contentImg.contentImageView;
    }
   
    return nil;
}

//- (NSString *)photosViewController:(NYTPhotosViewController *)photosViewController titleForPhoto:(id<NYTPhoto>)photo atIndex:(NSUInteger)photoIndex totalPhotoCount:(NSUInteger)totalPhotoCount{
//    return @"测试";
//}
//- (void)photosViewController:(NYTPhotosViewController *)photosViewController actionCompletedWithActivityType:(NSString * _Nullable)activityType{
//    NSLog(@"这是什么%@",activityType);
//}
- (void)photosViewController:(NYTPhotosViewController *)photosViewController didNavigateToPhoto:(id<NYTPhoto>)photo atIndex:(NSUInteger)photoIndex{
    //没有高清图的话需要下载,下载完成后需要刷新tableview
    
    EIMessageDetailModel *photoModel = (EIMessageDetailModel *)photo;
    [self checkHDImageExist:photoModel update:photosViewController];
}

- (void)photosViewControllerDidDismiss:(NYTPhotosViewController *)photosViewController{
    self.photoBrowerVC = nil;
}

- (BOOL)photosViewController:(NYTPhotosViewController *)photosViewController handleLongPressForPhoto:(id<NYTPhoto>)photo withGestureRecognizer:(UILongPressGestureRecognizer *)longPressGestureRecognizer{
    if (photo.image) {
        
        ESWeakSelf
        
        EIMessageDetailModel *detailModel = (EIMessageDetailModel *)photo;
        
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:nil];
        [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [actionSheet bk_addButtonWithTitle:@"删除" handler:^{
           
            [photosViewController dismissViewControllerAnimated:YES completion:^{
               
                [__weakSelf.viewModel removeModel:detailModel];
                [__weakSelf.tableView reloadData];
            }];
        }];
        [actionSheet bk_addButtonWithTitle:@"涂鸦" handler:^{
            if (!detailModel.image) {
                return;
            }
            [photosViewController dismissViewControllerAnimated:NO completion:^{
                HBDrawingVC *drawingVC = [[HBDrawingVC alloc] initWithBackgroundImg:detailModel.image];
                drawingVC.drawFinishBlock = ^(UIImage *image){
                    [__weakSelf mediaDidFinishWithImage:image];
                    
                    //统计
                    [[SensorsAnalyticsSDK sharedInstance] track:@"SendPicture"
                                                 withProperties:@{
                                                                  @"Method" : [NSNumber numberWithInt:2],
                                                                  @"Channel" : @"app",
                                                                  @"Source" : [NSNumber numberWithInt:1],
                                                                  @"Gender" : [NSNumber numberWithInteger:[EIUserCenter sharedInstance].userSex]
                                                                  }];
                };
                [__weakSelf presentViewController:[[EIBaseNavigationController alloc] initWithRootViewController:drawingVC] animated:YES completion:^{
                    
                }];
            }];
        }];
        [actionSheet bk_addButtonWithTitle:@"保存图片" handler:^{
            //判断一下是否有权限
            if ([EICommonHelper checkPhotoLibraryAuthorizationStatus]) {
                UIImageWriteToSavedPhotosAlbum(photo.image, __weakSelf, @selector(saveImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), NULL);
            }
        }];
        [actionSheet showInView:self.view];
    }
    return YES;
}


//save photo select

- (void)saveImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    if (error) {
        [SVProgressHUD showErrorWithStatus:@"保存失败"];
    }else {
        [SVProgressHUD showSuccessWithStatus:@"保存成功"];
    }
}

#pragma mark ---ActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"拉黑后将不会收到对方的消息，是否拉黑？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        
        [alertView show];
        
//        EIReportTC *reportTC =[[EIReportTC alloc]initWithTargetId:self.targetUserModel.user_id];
//        
//        [self.navigationController pushViewController:reportTC animated:YES];
        
    }else if (buttonIndex == 1){
        
      
        
        
        
//        [[RCIMClient sharedRCIMClient]removeFromBlacklist:self.targetUserModel.user_id success:^{
//            
//            NSLog(@"解除拉黑");
//        } error:^(RCErrorCode status) {
//            
//            NSLog(@"没有解除拉黑");
//        }];
    }else{
        NSLog(@"取消");
    }
}
#pragma mark ---- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        NSLog(@"取消");
        
    }else{
        
        NSLog(@"确认拉黑");
        
        [[RCIMClient sharedRCIMClient]addToBlacklist:self.targetUserModel.user_id  success:^{
            
            [SVProgressHUD showSuccessWithStatus:@"拉黑成功"];
        } error:^(RCErrorCode status) {
            
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"拉黑失败,错误码 %ld",(long)status]];
            
        }];
    }
}

#pragma mark -- delegate
- (void)barHandleLongPress:(UILongPressGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateBegan) {
        ESWeakSelf
        HBDrawingVC *drawingVC = [[HBDrawingVC alloc] init];
        drawingVC.drawFinishBlock = ^(UIImage *image){
            [__weakSelf mediaDidFinishWithImage:image];
            
            //统计
            [[SensorsAnalyticsSDK sharedInstance] track:@"SendPicture"
                                         withProperties:@{
                                                          @"Method" : [NSNumber numberWithInt:2],
                                                          @"Channel" : @"app",
                                                          @"Source" : [NSNumber numberWithInt:1],
                                                          @"Gender" : [NSNumber numberWithInteger:[EIUserCenter sharedInstance].userSex]
                                                          }];
        };
        [self presentViewController:[[EIBaseNavigationController alloc] initWithRootViewController:drawingVC] animated:YES completion:nil];
    }
}
@end
