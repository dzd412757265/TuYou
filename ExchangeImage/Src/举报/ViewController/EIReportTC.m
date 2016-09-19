//
//  EIReportTC.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/21.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIReportTC.h"
#import "EIReportCell.h"
#import "EIDefines.h"
#import "UIImage+resizable.h"
#import "EIResizableButton.h"
#import "EIReportViewModel.h"
#import "SVProgressHUD.h"
#import "NSObject+EasyJSON.h"

@interface EIReportTC ()

@property (nonatomic , strong)NSArray *datasource;

@property (nonatomic, strong)EIResizableButton *confirmButton;

@property (nonatomic, strong)EIReportViewModel *reportViewModel;

@property (nonatomic, strong)NSMutableArray *responsArray;

@end

@implementation EIReportTC

- (instancetype)initWithTargetId:(NSString *)targetId
{
    if (self =[super init]) {
        
        self.targetId = targetId;
    }
    return self;
}

- (instancetype)initWithTargetId:(NSString *)targetId WithhostId:(NSString *)hostId
{
    if (self =[super init]) {
        
        self.hostId = hostId;
        
        self.targetId = targetId;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self setTittle];
    
    [self initData];
    
    [self setButton];
    
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
}

- (void)setTittle
{
    
    self.title = @"举报";
    
//    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 44)];
//    
//    [backButton setImage:[UIImage imageNamed:@"ArrowLeft"] forState:UIControlStateNormal];
//    
//    [backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithCustomView:backButton];

}

- (void)initData
{
    _datasource = @[
                        @"色情、骚扰",
                        @"垃圾广告",
                        @"血腥暴力",
                        @"违法（涉毒、涉恐）"
                    ];
}

- (void)setButton
{
    CGFloat x = 25;
    CGFloat width = kScreen_Width - 2 * x;
    CGFloat height = 48;
    CGFloat y = kScreen_Height - 120;
    
    
    self.confirmButton.frame = CGRectMake(x, y, width, height);
    
    UIImage *inImage =[UIImage imageNamed:@"confirmButtonBackground"];
    
    [self.confirmButton setBackgroundImage:inImage forState:UIControlStateNormal];
    
    [self.confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    
    self.confirmButton.titleLabel.font = [UIFont systemFontOfSize:15];
    
    self.confirmButton.titleLabel.textColor =[UIColor whiteColor];
    
    [self.confirmButton addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.confirmButton];
}
#pragma mark ---- 按钮的点击事件
- (void)backButtonClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirmButtonClick:(id)sender
{
    if (self.responsArray.count <= 0) {
        
        [SVProgressHUD showErrorWithStatus:@"您还未选择举报信息"];
        return;
    }
    
    [SVProgressHUD show];
    
    ESWeakSelf
    
    int hostType;
    if (self.targetId.isNotEmpty && self.hostId.isNotEmpty) {
        hostType = 2;
    }else{
        hostType = 1;
    }
    [self.reportViewModel reportUser:self.targetId hostId:self.hostId hostType:hostType reasons:self.responsArray completedBlock:^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }else{
            [SVProgressHUD showSuccessWithStatus:@"举报成功"];
            [__weakSelf performSelector:@selector(dismissSelf) withObject:nil afterDelay:.5];
        }
    }];
    
}
#pragma mark ------ UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EIReportCell *cell =[EIReportCell createcellWithTableView:tableView];
    
    NSString *text = [self.datasource objectAtIndex:indexPath.row];
    
    [cell setCellWith:text];
    
    __block NSMutableArray *reasonsArr = self.responsArray;
    cell.selectClick = ^(BOOL addReasoon){
        
        if (addReasoon) {
            
            [reasonsArr addObject:text];
            
        }else{
            
            [reasonsArr removeObject:text];
        }
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 53.0f;
}

#pragma mark ----- praporty

- (EIResizableButton *)confirmButton
{
    if (!_confirmButton) {
        
        _confirmButton = [[EIResizableButton alloc]init];
    }
    return _confirmButton;
}

- (EIReportViewModel *)reportViewModel
{
    if (!_reportViewModel) {
        
        _reportViewModel = [[EIReportViewModel alloc]init];
    }
    return _reportViewModel;
}

- (NSMutableArray *)responsArray
{
    if (!_responsArray) {
        
        _responsArray = [[NSMutableArray alloc]init];
    }
    return _responsArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
