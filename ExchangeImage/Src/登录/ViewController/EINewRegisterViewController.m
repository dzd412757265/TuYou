//
//  EINewRegisterViewController.m
//  ExchangeImage
//
//  Created by 张博成 on 16/8/1.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EINewRegisterViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "EILoginInputView.h"
#import "EIDefines.h"
#import "EIConfirmButton.h"
#import "UIView+Extension.h"
#import "EINewRegisterViewModel.h"
#import "SVProgressHUD.h"
#import "EICommonHelper.h"
#import <ReactiveCocoa.h>

@interface EINewRegisterViewController ()

@property (nonatomic, strong)TPKeyboardAvoidingScrollView *contentView;

@property (nonatomic, strong)EILoginInputView *loginInputView;

@property (nonatomic, strong)EIConfirmButton *confirmButton;

@property (nonatomic, strong)UIImageView *loginBgImageView;

@property (nonatomic, strong)EINewRegisterViewModel *viewModel;

@end

@implementation EINewRegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUI];
    
    [self addARC];
}
- (void)addARC
{
    @weakify(self)
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"?!,;/:@／：；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+'\""];
    
    
    RACSignal *usernameSignal =[self.loginInputView.userNameTextField.rac_textSignal
                                map:^id(NSString *text) {
                                    @strongify(self)
                                    NSString *newText = [text stringByTrimmingCharactersInSet:set];
                                    self.loginInputView.userNameTextField.text = newText;
                                    return @(newText.length);
                                }];
    RACSignal *passwordSignal =[self.loginInputView.passWordTextField.rac_textSignal
                                map:^id(NSString *text) {
                                    @strongify(self)
                                    NSString *newText = [text stringByTrimmingCharactersInSet:set];
                                    self.loginInputView.passWordTextField.text = newText;
                                    return @(newText.length);
                                }];
    
    RACSignal *signUpActiveSignal = [RACSignal combineLatest:@[usernameSignal,passwordSignal]
                                                      reduce:^id(NSNumber *usernameText,NSNumber *passwordSignal){
                                                          @strongify(self)
                                                          return @([self isSatisfyNumber:usernameText] && [self isSatisfyNumber:passwordSignal]);
                                                      }];
    [signUpActiveSignal subscribeNext:^(NSNumber*signupActive){
        @strongify(self)
        self.confirmButton.enabled =[signupActive boolValue];
    }];
    
}

-(BOOL)isSatisfyNumber:(NSNumber *)number
{
    if ([number integerValue] >=6 && [number integerValue] <= 20) {
        
        return YES;
    }else{
        return NO;
    }
}

- (void)setUI
{
    UILabel *titLable =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 72, 25)];
    
    titLable.font = EIFont(18);
    
    titLable.textColor = RGBCOLOR(55, 58, 64);
    
    titLable.text = @"注册帐号";
    
    self.navigationItem.titleView = titLable;
    
    _loginBgImageView =[[UIImageView alloc]initWithFrame:self.view.bounds];
    
    _loginBgImageView.image = [UIImage imageNamed:[EICommonHelper splashImageNameForOrientation:UIDeviceOrientationPortrait]];
    
    _loginBgImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:_loginBgImageView];
    
    
    [self.view addSubview:self.contentView];
    
    _loginInputView = [[EILoginInputView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 0)];
    
    _loginInputView.center = self.contentView.center;
    
    _loginInputView.userNameTextField.placeholder = @"帐号：8-20位英文数字、字母";
    
    _loginInputView.passWordTextField.placeholder = @"密码：8-20位英文数字、字母";
    
    [self.contentView addSubview:_loginInputView];
    
    _confirmButton = [EIConfirmButton confirmButtonWithName:@"确认注册"];
    
    _confirmButton.y = CGRectGetMaxY(_loginInputView.frame) + _loginInputView.height;
    
    [_confirmButton setTitle:@"确认注册" forState:UIControlStateNormal];
    
    [_confirmButton addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:_confirmButton];
    
}

- (TPKeyboardAvoidingScrollView *)contentView
{
    if (!_contentView){
        
        _contentView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.view.bounds];
        _contentView.showsVerticalScrollIndicator = NO;

    }
    return _contentView;
}

- (EINewRegisterViewModel *)viewModel
{
    if (!_viewModel) {
        
        _viewModel = [[EINewRegisterViewModel alloc]init];
    }
    return _viewModel;
}

- (void)confirmButtonClick:(id)sender
{
    
    [SVProgressHUD showWithStatus:@"正在注册"];
    
    [self.viewModel registerWithUserName:self.loginInputView.userNameTextField.text andWithPassWord:self.loginInputView.passWordTextField.text success:^(id data) {
        
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:error.debugDescription];
    }];
}
@end
