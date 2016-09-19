//
//  EINewLoginViewController.m
//  ExchangeImage
//
//  Created by 张博成 on 16/8/1.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EINewLoginViewController.h"
#import "EILoginInputView.h"
#import "EIDefines.h"
#import "UIView+Extension.h"
#import "EIConfirmButton.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "EINewRegisterViewController.h"
#import "EINewLoginViewModel.h"
#import "SVProgressHUD.h"
#import "WXApi.h"
#import "EICommonHelper.h"
#import <ReactiveCocoa.h>

@interface EINewLoginViewController()<WXApiDelegate>

@property (nonatomic, strong)UIImageView *loginBgImageView;

@property (nonatomic, strong)EILoginInputView *loginInputView;

@property (nonatomic, strong)UIView *displayView;

//@property (nonatomic, strong)UIImageView *sloganImageView;

@property (nonatomic, strong)UIButton *registerButton;

@property (nonatomic, strong)UIButton *weiXinButton;

@property (nonatomic, strong)EIConfirmButton *confirmButton;

@property (nonatomic, strong)TPKeyboardAvoidingScrollView *contentView;

@property (nonatomic, strong)EINewLoginViewModel *viewModel;

@end
@implementation EINewLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUI];

    [self addARC];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weiXinLoginNotifi:) name:WeiXinLogin object:nil];
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
    _loginBgImageView =[[UIImageView alloc]initWithFrame:self.view.bounds];
    
    _loginBgImageView.image = [UIImage imageNamed:[EICommonHelper splashImageNameForOrientation:UIDeviceOrientationPortrait]];;
    
    _loginBgImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:_loginBgImageView];
    
    [self.view addSubview:self.contentView];
    
    _displayView = [[UIView alloc]initWithFrame:self.view.bounds];
    
    _displayView.backgroundColor =[UIColor clearColor];
    
    [self.contentView addSubview:_displayView];
    
    _loginInputView = [[EILoginInputView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 0)];
    
    _loginInputView.center = self.view.center;
    
    [_displayView addSubview:_loginInputView];
    
    
//    UIImage *image = [UIImage imageNamed:@"Slogan"];
//    _sloganImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 71.5, image.size.width, image.size.height)];
//    
//    _sloganImageView.image =image;
//    
//    _sloganImageView.centerX = _displayView.centerX;
//    
//    [_displayView addSubview:_sloganImageView];
    
    
    _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _registerButton.frame = CGRectMake(kScreen_Width - 54 - 48, CGRectGetMaxY(_loginInputView.frame) + 20, 48, 17);
    
    _registerButton.titleLabel.font = EIFont(12);
    
    [_registerButton setTitleColor:RGBCOLOR(66, 69, 77) forState:UIControlStateNormal];
    
    [_registerButton setTitle:@"注册帐号" forState:UIControlStateNormal];
    
    [_registerButton addTarget:self action:@selector(registerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [_displayView addSubview:_registerButton];
    
    _weiXinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _weiXinButton.frame = CGRectMake(0, kScreen_Height - 24 -21, 60, 21);
    
    _weiXinButton.titleLabel.font = EIFont(15);
    
    [_weiXinButton setTitleColor:RGBCOLOR(66, 69, 77) forState:UIControlStateNormal];
    
    _weiXinButton.centerX = _displayView.centerX;
    
    [_weiXinButton setTitle:@"微信登录" forState:UIControlStateNormal];
    
    [_weiXinButton addTarget:self action:@selector(weiXinButtonClick:) forControlEvents:UIControlEventTouchUpInside];

    [_displayView addSubview:_weiXinButton];
    
    
    
    _confirmButton =[EIConfirmButton confirmButtonWithName:@"确认登录"];
    
    _confirmButton.enabled = NO;
    
    _confirmButton.y = CGRectGetMaxY(_registerButton.frame) + 46 + _registerButton.height;
    
    [_confirmButton addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [_displayView addSubview:_confirmButton];

    
    
    
}

- (void)setViewControllerStyle:(ViewControllerStyle)viewControllerStyle
{
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}
- (void)loginWeiXin
{
    //构造SendAuthReq结构体
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"weixin_login" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
    
}

- (TPKeyboardAvoidingScrollView *)contentView
{
    if (!_contentView) {
        _contentView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.view.bounds];
        _contentView.showsVerticalScrollIndicator = NO;
    }
    return _contentView;
}

- (EINewLoginViewModel *)viewModel
{
    if (!_viewModel) {
        
        _viewModel = [[EINewLoginViewModel alloc]init];
        
    }
    return _viewModel;
}
#pragma mark -----buttonClick

- (void)registerButtonClick:(id)sender
{
    
    EINewRegisterViewController *registerVC = [[EINewRegisterViewController alloc]init];
    
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (void)weiXinButtonClick:(id)sender
{
    if(![WXApi isWXAppInstalled]){
        
        [SVProgressHUD showInfoWithStatus:@"未安装微信客户端"];
        return;
    }
    [self loginWeiXin];
}

- (void)weiXinLoginNotifi:(NSNotification *)notifi
{
    NSString * code = [notifi.userInfo objectForKey:@"code"];
    
    [SVProgressHUD showWithStatus:@"正在登录"];
    [self.viewModel loginAppWithCode:code success:^(id data) {
        
        [SVProgressHUD dismiss];
        
    } failure:^(NSError * error) {
        
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (void)confirmButtonClick:(id)sender
{
    [SVProgressHUD showWithStatus:@"正在登录"];
    [self.viewModel loginWithUserName:self.loginInputView.userNameTextField.text
                         WithPassWord:self.loginInputView.passWordTextField.text
                              success:^(id data) {
                              
                                  [SVProgressHUD dismiss];
                              }
                              failure:^(NSError * error) {
                                  
                                  [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                              }
     ];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
