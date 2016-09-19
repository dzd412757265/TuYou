//
//  EILoginInputView.m
//  ExchangeImage
//
//  Created by 张博成 on 16/8/1.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EILoginInputView.h"
#import "EIDefines.h"
#import "UIView+Extension.h"

@implementation EILoginInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setUI];
        
    }
    return self;
}

- (void)setUI
{
    self.height = 76;
    
    self.backgroundColor = [UIColor clearColor];
    
    _userNameTextField =[[EILoginTextField alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width - 108, 0)];
    
    _userNameTextField.centerX = self.centerX;
    
    [_userNameTextField setLeftViewWithImage:[UIImage imageNamed:@"PhoneIcon"] andPlacehold:@"请输入帐号"];
    
    [self addSubview:_userNameTextField];
    
    _passWordTextField = [[EILoginTextField alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width - 108, 0)];
    
    _passWordTextField.centerX = self.centerX;
    
    [_passWordTextField setLeftViewWithImage:[UIImage imageNamed:@"LockIcon"] andPlacehold:@"请输入密码"];
    
    _passWordTextField.y = 48;
    
    _passWordTextField.secureTextEntry = YES;
    
    [self addSubview:_passWordTextField];
    
}
@end
