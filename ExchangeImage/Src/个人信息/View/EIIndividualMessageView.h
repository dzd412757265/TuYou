//
//  EIIndividualMessageView.h
//  ExchangeImage
//
//  Created by 张博成 on 16/7/8.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EIAvatarView;

@interface EIIndividualMessageView : UIView

+ (instancetype)view;

@property (weak, nonatomic) IBOutlet EIAvatarView *userImageView;



@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIButton *userCity;

- (void)setView;
@end
