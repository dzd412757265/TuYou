//
//  EIPlazaViewController.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/6.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIPlazaViewController.h"
#import "EIPlazaViewModel.h"
#import "EIDefines.h"
#import "EIPlazaCell.h"
#import "EIPlazaOfficialCell.h"
#import "EIServerManager.h"
#import "EIPlazaTipsView.h"
#import "EIOpenCameraToolBar.h"
#import "UIViewController+MMDrawerController.h"
#import "NYTPhotosViewController.h"
#import "EIBaseImageView.h"
#import "SVProgressHUD.h"
#import "UIActionSheet+BlocksKit.h"
#import "EICommonHelper.h"
#import "EIImagePickerController.h"
#import "EIPicturePreview.h"
#import "EIMessageDetailTC.h"
#import "EIUserCenter.h"
#import "EIDataCacheManager.h"
#import "EIReportTC.h"
#import "EIBaseNavigationController.h"

#import "EIUserLocalUpHelper.h"

#import "SensorsAnalyticsSDK.h"

#import "SoundManager.h"

#import "EIGuideHelper.h"
#import "EIAvatarView.h"
#import <RongIMLib/RongIMLib.h>

@interface EIPlazaViewController ()<NYTPhotosViewControllerDelegate>

@property (nonatomic , strong)EIPlazaViewModel *viewModel;

@property (nonatomic , strong)EIPlazaTipsView *tipsView;

@property (nonatomic , strong)NYTPhotosViewController *photoBrowerVC;

@property (nonatomic , assign)BOOL loadMore;

@property (nonatomic, assign) CGFloat preContentHeight;

@property (nonatomic, strong) UIView *redSpotView;

@property (nonatomic ,strong) EIPlazaOfficialCell *officialHeader;

@end

@implementation EIPlazaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
    self.loadMore = NO;
    self.joinAnalytic = YES;
        
    [self setupMenuItem];
    [self setupTitle];
    [self setupTipsLabel];
    [self testToolBar];
    
    //ARC
    
    ESWeakSelf
    [self.viewModel fetchCacheFromDB:^(){
        [__weakSelf.tableView reloadData];
        [__weakSelf scrollToBottomAnimated:NO];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivewMessageNotification:) name:EIReceiveMessageNotification object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(printModelList:) name:EISendMessageNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reciveUnreadMessageNotification:) name:EINotificationUnreadMessage object:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearPlazaData:)
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearMemory:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EIReceiveMessageNotification object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:EISendMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EINotificationUnreadMessage object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:EIClearMessageCacheNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
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
                                                          @"Source" : [NSNumber numberWithInt:0],
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
                                                                                 @"Source" : [NSNumber numberWithInt:0],
                                                                                 @"Gender" : [NSNumber numberWithInteger:[EIUserCenter sharedInstance].userSex]
                                                                                 }];
                }];
            }];
        }];
        [__weakSelf presentViewController:vc animated:YES completion:^{
            [__weakSelf scrollToBottomAnimated:NO];
        }];
    };
    [self.view addSubview:toolBar];
}

- (void)setupMenuItem{
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 39, 44)];
    [leftButton addTarget:self action:@selector(userInfoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setImage:[UIImage imageNamed:@"ItemUser"] forState:UIControlStateNormal];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -15;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, leftBarButtonItem, nil];
    
    _redSpotView = [[UIView alloc]initWithFrame:CGRectMake(25, 5, 10, 10)];
    _redSpotView.layer.cornerRadius = 5;
    _redSpotView.backgroundColor = [UIColor redColor];
    
    _redSpotView.hidden = YES;
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 39, 44)];
    [rightButton addTarget:self action:@selector(messageButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setImage:[UIImage imageNamed:@"ItemChat"] forState:UIControlStateNormal];
    
    [rightButton addSubview:_redSpotView];
    
    UIBarButtonItem * rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    UIBarButtonItem * rightNegativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    rightNegativeSpacer.width = -15;
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:rightNegativeSpacer,rightBarButtonItem,nil];
}

- (void)setupTitle{
    self.title = @"图片交换";
}

- (void)setupTipsLabel{
    _tipsView = [[EIPlazaTipsView alloc] initWithFrame:CGRectMake(0, 64 - 30, CGRectGetWidth(self.view.bounds), 30)];
    [self.view addSubview:_tipsView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (EIPlazaViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[EIPlazaViewModel alloc] init];
    }
    return _viewModel;
}

- (EIPlazaOfficialCell *)officialHeader{
    if (!_officialHeader) {
        _officialHeader = [EIPlazaOfficialCell create];
    }
    return _officialHeader;
}

- (void)userInfoButtonPressed:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)messageButtonPressed:(id)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

#pragma mark -- tableview delegate

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y < -64.f - 15.f && !self.loadMore && scrollView.contentSize.height >CGRectGetHeight(scrollView.bounds)) {
        CGFloat preOffset = scrollView.contentOffset.y;
        _preContentHeight = self.tableView.contentSize.height;
        self.loadMore = YES;
        ESWeakSelf
        [self.viewModel fetchCacheFromDB:^{
            __weakSelf.loadMore = NO;
            [__weakSelf.tableView reloadData];
            CGFloat curContentHeight = __weakSelf.tableView.contentSize.height;
            [__weakSelf.tableView setContentOffset:CGPointMake(0,(curContentHeight - _preContentHeight)+preOffset)];
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = self.viewModel.modelList.count;
    return count;
}

- (EIPlazaCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EIPlazaCell *cell = [tableView dequeueReusableCellWithIdentifier:[EIPlazaCell identifer]];
    if (!cell) {
        cell = [[EIPlazaCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[EIPlazaCell identifer]];
        
        ESWeakSelf
        cell.clickPhotoBlock = ^(EIPlazaDisplayModel *model){
            [__weakSelf openPhotoBrower:model];
        };
        
        cell.clickResendBlock = ^(EIPlazaDisplayModel *model){
            [__weakSelf reloadTableViewCellProgress:model];
        };
        
        cell.clickAvatarBlock = ^(EIUserModel *user){
            if ([user.user_id isEqualToString:[EIUserCenter sharedInstance].userId]) {
                return;
            }
            EIMessageDetailTC *vc = [[EIMessageDetailTC alloc] initWithModel:user];
            [__weakSelf.navigationController pushViewController:vc animated:YES];
        };
        
        cell.clickLongPressMenuBlock = ^(EIPlazaDisplayModel *model ,NSString *title){
            if ([title isEqualToString:@"举报"]) {
                [__weakSelf reportPhoto:model];
            }else if([title isEqualToString:@"删除"]){
                [__weakSelf deletePhoto:model];
            }else if([title isEqualToString:@"回复"]){
                [__weakSelf replyPhoto:model];
            }
        };
    }
    
    NSInteger curIndex = indexPath.row;
    
    EIPlazaDisplayModel *model = [self.viewModel.modelList objectAtIndex:curIndex];
    
    //容错
//    if (model.placeholderImage == nil) {
//        ESWeakSelf
//        [__weakSelf.viewModel downLoadPlaceHolderPhoto:model completed:nil];
//    }
    
    [cell setImageWithModel:model];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger curIndex = indexPath.row;
    return [EIPlazaCell cellHeightWithModel:[self.viewModel.modelList objectAtIndex:curIndex]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}
#pragma mark -- function
- (void)openPhotoBrower:(EIPlazaDisplayModel *)localModel{
//    _photoBrowerVC = [[NYTPhotosViewController alloc] initWithPhotos:self.viewModel.modelList
//                                                        initialPhoto:localModel
//                                                            delegate:self];
    _photoBrowerVC = [[NYTPhotosViewController alloc] initWithPhotos:@[localModel]
                                                        initialPhoto:localModel
                                                            delegate:self];
    [self presentViewController:_photoBrowerVC animated:YES completion:nil];
    [self checkHDImageExist:localModel update:_photoBrowerVC];
}

- (void)checkHDImageExist:(EIPlazaDisplayModel *)model update:(NYTPhotosViewController *)photosViewController{
    
    if (model.image == nil) {
        __block  NYTPhotosViewController *mPhotoVC = photosViewController;
        
        ESWeakSelf
        [self.viewModel downLoadHDPhoto:model completed:^(EIPlazaDisplayModel *completedModel) {
            [mPhotoVC updateImageForPhoto:completedModel];
            
            //这里更新用来容错
            if (model.placeholderImage == nil) {
                [self.viewModel downLoadPlaceHolderPhoto:model completed:^(EIPlazaDisplayModel *displayModel) {
                    [__weakSelf.tableView reloadData];
                }];
            }
        }];
    }
}

#pragma mark -- notification

- (void)receivewMessageNotification:(NSNotification *)noti{
    EIPlazaDisplayModel *model = [[noti userInfo] objectForKey:@"displayModel"];
    [self.viewModel insertModel:model];
    [self.tableView reloadData];
    
    if (model.baseModel.isLeft.intValue == 1) {
        if ([self scrollAtBottom]) {
            [self scrollToBottomAnimated:YES];
        }else{
            [self.tipsView show:@"有新图片哦!"];
        }
    }else{
        [self scrollToBottomAnimated:YES];
    }
    
    if ([[RCIMClient sharedRCIMClient] getUnreadCount:@[@(ConversationType_SYSTEM)]] == 0
        &&!self.tableView.isDragging
        &&! self.tableView.isDecelerating) {
        //第一次收到对方图片,显示引导
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5f*NSEC_PER_SEC),
                       dispatch_get_main_queue(),
                       ^{
                           NSArray *cellList = self.tableView.visibleCells;
                           [cellList enumerateObjectsUsingBlock:^(EIPlazaCell* cell, NSUInteger idx, BOOL * _Nonnull stop) {
                               if ([cell checkMsgId:model.baseModel.msg_id]) {
                                   //todo...
                                   [[EIGuideHelper sharedInstance] showGuide:cell.avatar.bounds fromView:cell.avatar toView:self.view.window];
                               }
                           }];
                       });
    }
}

- (void)reciveUnreadMessageNotification:(NSNotification *)noti{
    
    NSNumber *data = [noti.userInfo objectForKey:@"data"];
    if ([data boolValue]) {
        _redSpotView.hidden = NO;
    }else{
        _redSpotView.hidden = YES;
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
    
    if (rows == 0) {
        self.tableView.tableHeaderView = self.officialHeader;
    }else{
        self.tableView.tableHeaderView = nil;
    }
    
    if (self.tableView.isTracking || self.tableView.isDecelerating || self.tableView.isDragging) {
        return;
    }
    
    if(rows > 0 && self.tableView.contentSize.height > CGRectGetHeight(self.tableView.bounds)) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                                atScrollPosition:UITableViewScrollPositionBottom
                                        animated:animated];
    }
}

//打开相机拍照结束
- (void)mediaDidFinishWithImage:(UIImage *)image{
    ESWeakSelf
    [self.viewModel sendVirtualPicture:image completed:^(EIPlazaDisplayModel *virtualModel) {
        
        [__weakSelf.viewModel insertModel:virtualModel];
        [__weakSelf.tableView reloadData];
        [__weakSelf scrollToBottomAnimated:YES];
        
        [__weakSelf reloadTableViewCellProgress:virtualModel];
    }];
}

- (void)uploadVisibleTableViewCell:(float)percent imageKey:(NSString *)imagekey{
    NSArray *cellList = self.tableView.visibleCells;
    [cellList enumerateObjectsUsingBlock:^(EIPlazaCell* cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cell checkImageKey:imagekey]) {
            //todo...
            [cell updatePercent:percent];
        }
    }];
}

- (void)reloadTableViewCellProgress:(EIPlazaDisplayModel *)virtualModel{
    
    ESWeakSelf
    [self.viewModel sendActualPictures:virtualModel
                            startBlock:nil
                          processBlock:^(float percent,NSString *imageKey) {
#if DEBUG_MODE
                              [__weakSelf uploadVisibleTableViewCell:percent imageKey:imageKey];
#endif
                          }
                        completedBlock:^(NSError *error,NSString *imageKey) {
                            if (error) {
                                [__weakSelf.tipsView show:error.localizedDescription];
                                if (![[EICommonHelper errorList] objectForKey:NSStringFromInteger(error.code)]) {
                                    if ([__weakSelf.viewModel changeSendStatus:YES imageKey:imageKey]) {
                                        [__weakSelf.tableView reloadData];
                                    }
                                }
                            }
#if DEBUG_MODE
                            [__weakSelf uploadVisibleTableViewCell:-1 imageKey:imageKey];
#endif
                            if (!error) {
                                //播放声音
                                [[SoundManager manager] playSwipeSoundIfNeed];
                                
                                //统计
                                [[[SensorsAnalyticsSDK sharedInstance] people] setOnce:@"FirstSendTime" to:[EICommonHelper getCurrentTime]];
                                
                                [[[SensorsAnalyticsSDK sharedInstance] people] increment:@"SendCount" by:[NSNumber numberWithInt:1]];
                            }
                        }];
}

//test代码

- (void)bierenfa:(id)sender{
    
}

#pragma mark -- photo brower delegate

- (UIView *)photosViewController:(NYTPhotosViewController *)photosViewController loadingViewForPhoto:(id<NYTPhoto>)photo{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [view.layer setCornerRadius:5];
    [view setBackgroundColor:[UIColor colorWithWhite:0 alpha:.7f]];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(30, 30);
    [indicator startAnimating];
    [view addSubview:indicator];
    return view;
};

- (UIView *)photosViewController:(NYTPhotosViewController *)photosViewController referenceViewForPhoto:(id<NYTPhoto>)photo{
    NSUInteger row = [self.viewModel.modelList indexOfObject:photo];
    EIPlazaCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    if (cell) {
        return cell.contentImg.contentImageView;
    }
    return nil;
}

- (NSString *)photosViewController:(NYTPhotosViewController *)photosViewController titleForPhoto:(id<NYTPhoto>)photo atIndex:(NSUInteger)photoIndex totalPhotoCount:(NSUInteger)totalPhotoCount{
    return @"测试";
}
- (void)photosViewController:(NYTPhotosViewController *)photosViewController actionCompletedWithActivityType:(NSString * _Nullable)activityType{
    NSLog(@"这是什么%@",activityType);
}

- (void)photosViewController:(NYTPhotosViewController *)photosViewController didNavigateToPhoto:(id<NYTPhoto>)photo atIndex:(NSUInteger)photoIndex{
    //没有高清图的话需要下载,下载完成后需要刷新tableview
    
    EIPlazaDisplayModel *photoModel = (EIPlazaDisplayModel *)photo;
    [self checkHDImageExist:photoModel update:photosViewController];
}

- (void)photosViewControllerDidDismiss:(NYTPhotosViewController *)photosViewController{
    self.photoBrowerVC = nil;
}

- (BOOL)photosViewController:(NYTPhotosViewController *)photosViewController handleLongPressForPhoto:(id<NYTPhoto>)photo withGestureRecognizer:(UILongPressGestureRecognizer *)longPressGestureRecognizer{
    if (photo.image) {
        ESWeakSelf
        EIPlazaDisplayModel *model = (EIPlazaDisplayModel *)photo;
        BOOL isOther = ![model.baseModel.user.user_id isEqualToString:[EIUserCenter  sharedInstance].userId];
        UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:nil];
        [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
        if (isOther) {
            [actionSheet bk_addButtonWithTitle:@"回复" handler:^{
                [photosViewController dismissViewControllerAnimated:YES completion:^{
                    [__weakSelf replyPhoto:model];
                }];
            }];
        }
        if (isOther) {
            [actionSheet bk_addButtonWithTitle:@"举报" handler:^{
                [photosViewController dismissViewControllerAnimated:YES completion:^{
                    [__weakSelf reportPhoto:model];
                }];
            }];
        }
        [actionSheet bk_addButtonWithTitle:@"删除" handler:^{
            [photosViewController dismissViewControllerAnimated:YES completion:^{
                [__weakSelf deletePhoto:model];
                
            }];
        }];
        if (isOther) {
            [actionSheet bk_addButtonWithTitle:@"保存图片" handler:^{
                //判断一下是否有权限
                if ([EICommonHelper checkPhotoLibraryAuthorizationStatus]) {
                    UIImageWriteToSavedPhotosAlbum(photo.image, __weakSelf, @selector(saveImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), NULL);
                }
            }];
        }
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

- (void)clearMemory:(NSNotification *)noti{
    ESWeakSelf
    [self.viewModel clearMemory:^{
        [__weakSelf.tableView reloadData];
    }];
}

//photo operation
- (void)deletePhoto:(EIPlazaDisplayModel *)model{
    NSIndexPath * deleteIndexPath = [NSIndexPath indexPathForRow:[self.viewModel.modelList indexOfObject:model] inSection:0];
    
    [self.viewModel deleteDisplayModel:model completed:^{
        NSLog(@"删除成功");
    }];
    
    [self.tableView deleteRowsAtIndexPaths:@[deleteIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)replyPhoto:(EIPlazaDisplayModel *)model{
    if ([model.baseModel.user.user_id isEqualToString:[EIUserCenter sharedInstance].userId]) {
        return;
    }
    EIMessageDetailTC *vc = [[EIMessageDetailTC alloc] initWithModel:model.baseModel.user];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)reportPhoto:(EIPlazaDisplayModel *)model{
    EIReportTC *vc = [[EIReportTC alloc] initWithTargetId:model.baseModel.user.user_id WithhostId:model.baseModel.picture.picture_id];
    [self presentViewController:[[EIBaseNavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
}

@end
