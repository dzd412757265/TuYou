//
//  EISubRichTextView.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/7.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EISubRichTextView : UIView

@property (nonatomic , strong) UIImage *icon;
@property (nonatomic , strong) NSString *textStr;

- (void)setFont:(UIFont *)textFont;

- (id)initWithImage:(UIImage *)icon
               text:(NSString *)text
               rect:(CGRect)frame;

- (void)setImage:(UIImage *)icon text:(NSString *)text;

@end
