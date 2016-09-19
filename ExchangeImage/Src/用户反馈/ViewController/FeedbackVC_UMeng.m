//
//  FeedbackVC_UMeng.m
//  Jianjian
//
//  Created by admin on 15/4/9.
//  Copyright (c) 2015年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "FeedbackVC_UMeng.h"
#import "FeedbackBundleCell.h"
#import "EIUserCenter.h"
#import "EIDefines.h"
#import "SVProgressHUD.h"

@interface FeedbackVC_UMeng ()
@property(nonatomic,strong)UITextView *textView;
@property(nonatomic,strong)UIView *textFieldView;
@property(nonatomic,strong)UIButton *confirmBtn;
@property(nonatomic,strong)UIControl *maskLayer;

@property (strong, nonatomic) UMFeedback *feedback;
@property(strong,nonatomic)NSMutableDictionary *offscreenCells;
@end

@implementation FeedbackVC_UMeng

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"意见反馈";
    
    self.offscreenCells=[[NSMutableDictionary alloc] init];
    self.feedback = [UMFeedback sharedInstance];
    self.feedback.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);

    //给键盘加个遮罩层
    self.maskLayer = [[UIControl alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    [self.maskLayer addTarget:self action:@selector(resignFirstResponsder4Mask) forControlEvents:UIControlEventTouchDown];
    self.maskLayer.hidden = YES;
    [self.view addSubview:self.maskLayer];
    
    _textFieldView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-49, kScreen_Width, 49)];
    _textFieldView.backgroundColor = [UIColor whiteColor];
    [_textFieldView.layer setBorderWidth:.5f];
    [_textFieldView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.view addSubview:_textFieldView];
    
    CGFloat sendButtonRightGap = 16;
    CGFloat sendButtonLeftGap = sendButtonRightGap;
    
    UIView *textFieldBg = [[UIView alloc]initWithFrame:CGRectMake(6, 6, CGRectGetWidth(_textFieldView.bounds) - CGRectGetHeight(_textFieldView.bounds) - sendButtonRightGap -sendButtonLeftGap, CGRectGetHeight(_textFieldView.bounds)-12)];
    textFieldBg.backgroundColor = [UIColor whiteColor];
    [textFieldBg.layer setCornerRadius:2.f];
    [textFieldBg.layer setBorderWidth:.5f];
    [textFieldBg.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    textFieldBg.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [_textFieldView addSubview:textFieldBg];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(4, 0, CGRectGetWidth(textFieldBg.bounds)-8, CGRectGetHeight(textFieldBg.bounds))];
    self.textView.font = [UIFont systemFontOfSize:17];
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleHeight;
    self.textView.delegate = self;
    self.textView.scrollEnabled = YES;
    self.textView.returnKeyType=UIReturnKeySend;
    [textFieldBg addSubview:self.textView];
    
    self.confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(sendButtonLeftGap + CGRectGetWidth(textFieldBg.bounds), 0, CGRectGetHeight(self.textFieldView.bounds), CGRectGetHeight(self.textFieldView.bounds))];
    self.confirmBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
//    [self.confirmBtn setImage:[UIImage imageNamed:@"chat_send"] forState:UIControlStateNormal];
    [self.confirmBtn setTitle:@"发送" forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:EINavigationBarTitleColor forState:UIControlStateNormal];
    self.confirmBtn.titleLabel.font = EIFont(18);
    [self.confirmBtn addTarget:self action:@selector(feedbackSubmit) forControlEvents:UIControlEventTouchUpInside];

    [_textFieldView addSubview:self.confirmBtn];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ESWeakSelf
    [self.feedback get:^(NSError *error) {
        if (!error) {
            [__weakSelf.tableView reloadData];
            [__weakSelf scrollToBottomAnimated:YES];
        }
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [self.textView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.textView resignFirstResponder];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [self.textView removeObserver:self forKeyPath:@"contentSize" context:nil];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)keyboardWillChangeFrame:(NSNotification*) notif
{
    NSDictionary *info = [notif userInfo];
    
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];

    CGRect endKeyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    UIView *windowView=[UIApplication sharedApplication].keyWindow.rootViewController.view;
    CGRect beginTextViewRect=[self.view convertRect:self.textFieldView.frame toView:windowView];
    beginTextViewRect.origin.y=endKeyboardRect.origin.y-self.textFieldView.frame.size.height;
    CGRect endTextViewRect=[windowView convertRect:beginTextViewRect toView:self.view];
    
    [UIView animateWithDuration:duration animations:^{
        self.textFieldView.frame=endTextViewRect;
    }];
    
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        
        CGPoint contentSizeNew=[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];

        if (contentSizeNew.y>118) {
            return;
        }
        
        CGFloat offsetY=contentSizeNew.y-self.textView.frame.size.height;
        
        [self.textFieldView setFrame:CGRectMake(self.textFieldView.frame.origin.x, self.textFieldView.frame.origin.y-offsetY, self.textFieldView.frame.size.width, self.textFieldView.frame.size.height+offsetY)];
        }

}
#pragma mark - Table view data source
-(void)feedbackSubmit
{
    if (self.textView.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"内容不能为空"];
        return ;
    }
    NSDictionary *postContent = @{@"content":self.textView.text,
                                  @"type": @"user_reply",
                                  @"gender":NSStringFromInteger([EIUserCenter sharedInstance].userSex),
                                  };
    ESWeakSelf
    [self.feedback post:postContent completion:^(NSError *error) {
        if (!error) {
            __weakSelf.textView.text = @"";
            [__weakSelf.tableView reloadData];
            [__weakSelf scrollToBottomAnimated:YES];
        }else{
            [SVProgressHUD showErrorWithStatus:@"提交失败,内容格式错误"];
        }
    }];
    
    [self resignFirstResponsder4Mask];
}
-(void)resignFirstResponsder4Mask
{
    self.maskLayer.hidden=YES;
    [self.textView resignFirstResponder];
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.maskLayer setHidden:NO];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [self feedbackSubmit];
        return NO;
    }
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.feedback.topicAndReplies count];
}
//- (void)getFinishedWithError:(NSError *)error {
//    if (error != nil) {
//        
//    } else {
//        [self.tableView reloadData];
//        [self showTableViewFooter];
//    }
//}

//- (void)postFinishedWithError:(NSError *)error {
//    if (error != nil) {
//        self.alertView.message=@"提交失败,内容格式错误";
//        [self.alertView show];
//    } else {
//        
//        [self.tableView reloadData];
//        [self showTableViewFooter];
//    }
//}

//-(void)showTableViewFooter
//{
//    if (self.tableView.contentSize.height>self.tableView.frame.size.height) {
//        [UIView animateWithDuration:.2f animations:^{
//            self.tableView.contentOffset=CGPointMake(self.tableView.contentOffset.x, self.tableView.contentSize.height-self.tableView.frame.size.height+49);
//        }];
//    }
//    
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedbackBundleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"feedbackCell"];
    if (!cell) {
        cell=[[FeedbackBundleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"feedbackCell"];
    }
    [cell setData:[self.feedback.topicAndReplies objectAtIndex:indexPath.row]];
     //Configure the cell...
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier=@"feedbackCell";
    
    FeedbackBundleCell *cell=[self.offscreenCells objectForKey:reuseIdentifier];
    
    if (!cell) {
        
        cell=[[FeedbackBundleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        
        [self.offscreenCells setObject:cell forKey:reuseIdentifier];
        
    }
    
    return [cell setMutiLineLabelText:[self.feedback.topicAndReplies objectAtIndex:indexPath.row]] + 12;
}


@end
