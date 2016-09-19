//
//  EILoginViewController.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/5.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EILoginViewController.h"
#import "EIResizableButton.h"
#import "UIView+Extension.h"
#import "EIDefines.h"
#import "SVProgressHUD.h"
#import "EILoginViewModel.h"
#import "WXApi.h"
#import "EICommonHelper.h"

@interface EILoginViewController()<WXApiDelegate>

@property (nonatomic, strong)EIResizableButton *loginButton;

@property (nonatomic, strong)UIImageView *loginBgImageView;

//@property (nonatomic, strong)UIImageView *loginPicture;

@property (nonatomic, assign)BOOL isHiddenLoginButton;

@property (nonatomic, strong)EILoginViewModel *viewModel;

@end

@implementation EILoginViewController

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isHiddenLoginButton = ![[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"weixin://"]];
    
    [self setUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weiXinLoginNotifi:) name:WeiXinLogin object:nil];
}

- (void)setUI
{
    self.loginBgImageView =[[UIImageView alloc]initWithFrame:self.view.bounds];
    
    self.loginBgImageView.image = [UIImage imageNamed:[EICommonHelper splashImageNameForOrientation:UIDeviceOrientationPortrait]];
    
    self.loginBgImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:self.loginBgImageView];
    
//    self.loginPicture = [[UIImageView alloc]initWithFrame:CGRectMake(0, 81.5, 138, 138)];
//    
//    self.loginPicture.centerX = kScreen_Width /2;
//    
//    self.loginPicture.contentMode = UIViewContentModeScaleToFill;
//    
//    [self.loginPicture setImage:[UIImage imageNamed:@"LoginForheadImage"]];
//    
//    [self.view addSubview:self.loginPicture];
    
    CGFloat x = 36;
    CGFloat width = kScreen_Width - 2 * x;
    CGFloat height = 56;
    CGFloat y = kScreen_Height - 48.5 - height;
    self.loginButton.frame = CGRectMake(x, y, width, height);
    
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"confirmButtonBackground"] forState:UIControlStateNormal];
    
    [self.loginButton setTitle:@"微信登录" font:[UIFont systemFontOfSize:17] color:[UIColor whiteColor] state:UIControlStateNormal];
    
    [self.loginButton setImage:[UIImage imageNamed:@"WechatIcon"] forState:UIControlStateNormal];
    
    [self.loginButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 4,-10 )];
    
    [self.loginButton setImageEdgeInsets:UIEdgeInsetsMake(0,10, 4,10)];
    
    
    [self.loginButton addTarget:self action:@selector(loginButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.loginButton];
    
    self.loginButton.hidden = self.isHiddenLoginButton;
    
}
//- (void)buttonClick:(id)sender
//{
//    
//    EIIndividualMessageVC *vc =[[EIIndividualMessageVC alloc]init];
//    
//    [self.navigationController pushViewController:vc animated:YES];
//}
//
//- (void)buttonOneClick:(id)sender
//{
//    EIMessageListTC *tc = [[EIMessageListTC alloc]init];
//    
//     [self.navigationController pushViewController:tc animated:YES];
//}
- (void)loginButtonClick:(id)sender
{
    //微信登录    
    [self loginWeiXin];
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

- (EIResizableButton *)loginButton
{
    if (!_loginButton) {
        
        _loginButton =[EIResizableButton buttonWithType:UIButtonTypeCustom];
    }
    
    return _loginButton;
}

- (EILoginViewModel *)viewModel
{
    if(!_viewModel){
        
        _viewModel = [[EILoginViewModel alloc]init];
    }
    return _viewModel;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
