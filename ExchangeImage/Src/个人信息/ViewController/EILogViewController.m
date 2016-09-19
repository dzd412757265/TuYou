//
//  EILogViewController.m
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/27.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EILogViewController.h"
#import "EIDefines.h"
#import "LogHelper.h"

@interface EILogViewController ()

@property (nonatomic , strong)UITextView *textView;

@end

@implementation EILogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(self.view.bounds) - 20, CGRectGetHeight(self.view.bounds) - 20)];
    _textView.font = EIFont(14);
    _textView.textColor = [UIColor blackColor];
    _textView.scrollEnabled = YES;
    _textView.backgroundColor = [UIColor clearColor];
    _textView.editable = NO;
    
    [self.view addSubview:_textView];
    
    // Do any additional setup after loading the view.
    self.title = @"Debug Log";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(clearAction:)];
}

- (void)clearAction:(id)sender{
    [[LogHelper sharedInstance] clearLogs];
    _textView.text = [[LogHelper sharedInstance] getLogs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.textView.text = [[LogHelper sharedInstance] getLogs];
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
