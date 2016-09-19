//
//  EIMessageListTC.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/8.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIMessageListTC.h"
#import "EIMessageListCell.h"
#import "UIViewController+MMDrawerController.h"
#import "EIMessageListViewModel.h"
#import "EIDefines.h"
#import "EIMessageDetailTC.h"
#import "EIUserCenter.h"
#import "EIServerManager.h"
#import "UIView+Extension.h"

@interface EIMessageListTC ()

@property (nonatomic, strong)EIMessageListViewModel *viewModel;

@property (nonatomic, strong)UILabel *emptyLabel;

@end

@implementation EIMessageListTC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.joinAnalytic = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self setupTitle];
    [self setupButtonItem];
    
    [self.view addSubview:self.emptyLabel];
    
    [EIServerManager sharedInstance].messageTarget = nil;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(recieveMessage:) name:EINotificationReceiveMessage object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [EIServerManager sharedInstance].messageTarget = nil;
    [self refreshData];
    
    
}
- (void)refreshData
{
    
      ESWeakSelf
    [self.viewModel getChartListSuccess:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [__weakSelf.tableView reloadData];
            
        });
    } failure:^{
        
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
                
    });
    self.emptyLabel.hidden  = self.viewModel.userList.count > 0 ? YES : NO;
   
}
- (void)setupTitle{
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MessageTitle"]];
    
    self.title = @"消息";
}

- (void)setupButtonItem{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
    [button setImage:[UIImage imageNamed:@"ArrowLeft"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -15;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, leftBarButtonItem, nil];
}

- (void)backButtonPressed:(id)sender{
    
    [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
}
#pragma mark --notificationDelegate
- (void)recieveMessage:(NSNotification *)noti
{
    [self refreshData];
}
#pragma mark --UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewModel.userList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EIMessageListCell *cell = [EIMessageListCell creatCellWith:tableView];
        
    EIMessageListModel *model = [self.viewModel.userList objectAtIndex:indexPath.row];
        
    [cell setCellWithModel:model];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
//        NSLog(@"nsindexpath is %ld,self.viewmodel.userlis.count is %lu",(long)indexPath.row,(unsigned long)self.viewModel.userList.count);
        EIMessageListModel *model = [self.viewModel.userList objectAtIndex:indexPath.row];

       [self.viewModel removeConversation:model.targetId];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 77.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
     EIMessageListModel *model = [self.viewModel.userList objectAtIndex:indexPath.row];
    
//    NSLog(@"model.messageId is %@",model.targetId);
    
    EIMessageDetailTC *messageDetailTC =[[EIMessageDetailTC alloc]initWithModel:model];

    [self.navigationController pushViewController:messageDetailTC animated:YES];
}


#pragma mark ----proparty

- (EIMessageListViewModel *)viewModel
{
    if (!_viewModel) {
        
        _viewModel =[[EIMessageListViewModel alloc]init];
    }
    
    return _viewModel;
}

- (UILabel *)emptyLabel
{
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, kScreen_Width - 40, 0)];
        
        _emptyLabel.center = self.view.center;
        
        _emptyLabel.y = _emptyLabel.y - 32;
        
        _emptyLabel.font = EIFont(24);
        
        _emptyLabel.textColor = EINavigationBarTitleColor;
        
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        
        _emptyLabel.numberOfLines = 0;
        
        NSString *text = @"👈点击用户头像或长按图片可以进行私聊";
        
       _emptyLabel.height =  [text boundingRectWithSize:CGSizeMake(kScreen_Width - 40, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:EIFont(24),NSForegroundColorAttributeName:EINavigationBarTitleColor} context:nil].size.height;
        
        _emptyLabel.text = text;
        
        _emptyLabel.hidden = YES;
    }
    return _emptyLabel;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EINotificationReceiveMessage object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
