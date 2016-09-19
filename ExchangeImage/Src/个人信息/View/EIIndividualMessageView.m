//
//  EIIndividualMessageView.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/8.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIIndividualMessageView.h"
#import "EIUserCenter.h"
#import "UIImageView+WebCache.h"
#import "EIDefines.h"
#import "EIAvatarView.h"

@implementation EIIndividualMessageView

+ (instancetype)view
{
    
    EIIndividualMessageView *view = [[NSBundle mainBundle]loadNibNamed:@"EIIndividualMessageView" owner:nil options:nil].firstObject;
    return view;
}

- (void)awakeFromNib
{
    self.userImageView.backgroundColor = [UIColor clearColor];
//    self.userImageView.layer.cornerRadius = 30;
//    
//    self.userImageView.layer.masksToBounds = YES;
//    
//    self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
    
//    self.userName.text = [EIUserCenter sharedInstance].userNickname;
    
//    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:[EIUserCenter sharedInstance].userAvatar] placeholderImage:kDefaultAvatar];
}

- (void)setView
{
    self.userName.text = [EIUserCenter sharedInstance].userNickname;
    
    //[self.userImageView sd_setImageWithURL:[NSURL URLWithString:[EIUserCenter sharedInstance].userAvatar] placeholderImage:kDefaultAvatar];
    [self.userImageView setImageUrl:[EIUserCenter sharedInstance].userAvatar sex:@([EIUserCenter sharedInstance].userSex)];
    
    if ([EIUserCenter sharedInstance].userCity.length >0) {
        
        [self.userCity setTitle:[EIUserCenter sharedInstance].userCity forState:UIControlStateNormal];
        
    }else{
        
        [self.userCity setTitle:@"未知" forState:UIControlStateNormal];
    }
}
@end
