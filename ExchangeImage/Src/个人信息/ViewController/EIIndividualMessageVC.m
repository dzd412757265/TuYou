//
//  EIIndividualMessageVC.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/8.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIIndividualMessageVC.h"
#import "EIIndividualMessageView.h"
#import "UIView+Extension.h"
#import "UIViewController+MMDrawerController.h"
#import "EIDefines.h"
#import "EIViewControllerManager.h"
#import "UIImage+Extension.h"
#import "EIIndividualInfoCell.h"
#import "EIDataCacheManager.h"
#import "SVProgressHUD.h"
#import "EICommonHelper.h"
#import "FeedbackVC_UMeng.h"
#import "SoundManager.h"
#import "EIAvatarView.h"

#import "EILogViewController.h"

static const NSInteger kCellDetailTag = 999;

typedef NS_ENUM(NSUInteger,IndividualTag) {
    IndividualTagFeed = 1,
    IndividualTagClearCache,
    IndividualTagNotificationSetting,
    IndividualTagMessageSoundControl
};

@interface EIIndividualMessageVC()

@property (nonatomic, strong)EIIndividualMessageView *contentView;
@property (nonatomic, strong)NSArray *dataSource;
@end

@implementation EIIndividualMessageVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.joinAnalytic = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = self.contentView;
    
    [self setupTitle];
    
    [self setupButtonItem];
    
    [self installOutButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundAction:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (NSArray *)dataSource{
    if (!_dataSource) {
        _dataSource = @[
                        @[@{@"title":@"推送消息",@"tag":@(IndividualTagNotificationSetting)},
                          @{@"title":@"消息声音",@"tag":@(IndividualTagMessageSoundControl)},
                          @{@"title":@"意见反馈",@"tag":@(IndividualTagFeed)},
                          @{@"title":@"清除缓存",@"tag":@(IndividualTagClearCache)}]
                        ];
    }
    return _dataSource;
}

- (void)setupTitle{
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UserInfoTitle"]];
    self.title = @"个人信息";
}

- (void)setupButtonItem{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 39, 44)];
    [button addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"ArrowRight"] forState:UIControlStateNormal];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -15;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, rightBarButtonItem, nil];
    
    self.navigationItem.leftBarButtonItems = nil;
}

- (void)backButtonPressed:(id)sender{
    [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
}

- (void)installOutButton
{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, self.view.height -  49, CGRectGetWidth(self.view.bounds), 49)];
    
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:0 alpha:0.05f]] forState:UIControlStateNormal];
    
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:0 alpha:0.1f]] forState:UIControlStateHighlighted];
    
    [button.titleLabel setFont:EIFont(17)];
    [button setTitle:@"退出登录" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(loginOut:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
    [self.contentView setView];
}

- (void)loginOut:(id)sender
{
    [[EIViewControllerManager sharedInstance] loginOut];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.tableView reloadData];
}
#pragma mark --- UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSArray *)(self.dataSource[section])).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EIIndividualInfoCell *cell;
    NSString *identifier;
    NSInteger tag = [self.dataSource[indexPath.section][indexPath.row][@"tag"] integerValue];
    if (tag == IndividualTagNotificationSetting) {
        identifier = @"NotificationCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[EIIndividualInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width/2, 0, kScreen_Width/2 - 24, [EIIndividualInfoCell cellHeight])];
            detailLabel.textColor = [UIColor lightGrayColor];
            detailLabel.textAlignment = NSTextAlignmentRight;
            detailLabel.font = EIFont(14);
            detailLabel.tag = kCellDetailTag;
            [cell addSubview:detailLabel];
        }
        
        UILabel *detailLabel = [cell viewWithTag:kCellDetailTag];
        if (detailLabel) {
            detailLabel.text = [self isAllowedNotification] ? @"已开启" : @"已关闭";
        }
        
    }else if (tag == IndividualTagMessageSoundControl){
        
        identifier = @"MessageSoundControlCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[EIIndividualInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width/2, 0, kScreen_Width/2 - 24, [EIIndividualInfoCell cellHeight])];
            detailLabel.textColor = [UIColor lightGrayColor];
            detailLabel.textAlignment = NSTextAlignmentRight;
            detailLabel.font = EIFont(14);
            detailLabel.tag = kCellDetailTag;
            [cell addSubview:detailLabel];
        }
        
        UILabel *detailLabel = [cell viewWithTag:kCellDetailTag];
        if (detailLabel) {
            detailLabel.text = [SoundManager manager].soundOff ? @"已关闭" : @"已开启";
        }

    }else if(tag == IndividualTagClearCache){
        identifier = @"ClearCacheCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[EIIndividualInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            
            UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width/2, 0, kScreen_Width/2 - 24, [EIIndividualInfoCell cellHeight])];
            detailLabel.textColor = [UIColor lightGrayColor];
            detailLabel.textAlignment = NSTextAlignmentRight;
            detailLabel.font = EIFont(14);
            detailLabel.tag = kCellDetailTag;
            [cell addSubview:detailLabel];
        }
        
        UILabel *detailLabel = [cell viewWithTag:kCellDetailTag];
        if (detailLabel) {
            detailLabel.text = [[EIDataCacheManager sharedInstance] getOriginCacheSize];
        }
        
    }else if(tag == IndividualTagFeed){
        identifier = @"FeedCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[EIIndividualInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            
            UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AccessoryArrowRight"]];
            accessoryView.center = CGPointMake(kScreen_Width - 25, [EIIndividualInfoCell cellHeight]/2);
            [cell addSubview:accessoryView];
        }
    }else{
        identifier = NSStringFromClass([EIIndividualInfoCell class]);
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[EIIndividualInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
    }
    cell.nameLabel.text = self.dataSource[indexPath.section][indexPath.row][@"title"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return [EIIndividualInfoCell cellHeight]/2;
    }else{
        return CGFLOAT_MIN;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger tag = [self.dataSource[indexPath.section][indexPath.row][@"tag"] integerValue];
    if (tag == IndividualTagFeed) {
        [self feedback];
    }else if(tag == IndividualTagClearCache){
        [self clearCache];
    }else if(tag == IndividualTagNotificationSetting){
        [EICommonHelper showSettingAlertStr:@"请在iPhone的“设置->通知”中打开本应用的访问权限"];
    }else if(tag == IndividualTagMessageSoundControl){
        [self changeMessageSound];
    }
}

- (void)changeMessageSound{
    
    [SoundManager manager].soundOff = ![SoundManager manager].soundOff;
    [self.tableView reloadData];
}
- (void)clearCache{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[EIDataCacheManager sharedInstance] clearOriginImageCache];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
            
            [SVProgressHUD dismiss];
            
            //[[NSNotificationCenter defaultCenter] postNotificationName:EIClearMessageCacheNotification object:nil];
        });
    });
}


- (void)feedback
{
    FeedbackVC_UMeng *viewC = [[FeedbackVC_UMeng alloc] init];
    [self.navigationController pushViewController:viewC animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [EIIndividualInfoCell cellHeight];
}

- (EIIndividualMessageView *)contentView
{
    if (!_contentView) {
        
        _contentView = [EIIndividualMessageView view];
        _contentView.backgroundColor = [UIColor clearColor];
#ifdef DEBUG
        _contentView.userImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        tap.numberOfTapsRequired = 4;
        
        [_contentView.userImageView addGestureRecognizer:tap];
#endif
    }
    return _contentView;
}

- (void)tapAction:(id)sender{
    [self.navigationController pushViewController:[[EILogViewController alloc] init] animated:YES];
}

- (void)applicationWillEnterForegroundAction:(NSNotification *)noti{
    [self.tableView reloadData];
}

- (BOOL)isAllowedNotification {
    //iOS8 check if user allow notification
    if (IOS_8_OR_LATER) {
        // system is iOS8
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (UIUserNotificationTypeNone != setting.types) {
            return YES;
        }
    } else {
        //iOS7
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if(UIRemoteNotificationTypeNone != type)
            return YES;
    }
    
    return NO;
}

@end
