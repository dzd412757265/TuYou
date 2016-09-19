//
//  GBAvatarView.h
//  jiuwuliao
//
//  Created by admin on 15/8/28.
//  Copyright (c) 2015年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EIAvatarView : UIControl

@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)UIView *backgroundView;

- (void)setImageUrl:(NSString *)url sex:(NSNumber *)sex;

- (void)setImage:(UIImage *)image sex:(NSNumber *)sex;

- (void)setSex:(NSNumber *)sex;

@end
