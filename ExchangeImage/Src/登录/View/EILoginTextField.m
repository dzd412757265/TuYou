//
//  EILoginTextField.m
//  ExchangeImage
//
//  Created by 张博成 on 16/8/1.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EILoginTextField.h"
#import "UIView+Extension.h"
#import "EIDefines.h"

@implementation EILoginTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setUI];
    }
    return self;
}

- (void)setUI
{
    self.backgroundColor =[UIColor clearColor];
    
    self.height = 34;
    
    self.font = EIFont(14);
    
    self.textColor = RGBCOLOR(158, 161, 169);
    
    self.keyboardType = UIKeyboardTypeASCIICapable;
    
    UIView *bottomView =[[UIView alloc]initWithFrame:CGRectMake(27.5, 33, self.width - 27.5, 1)];
    
    bottomView.backgroundColor = RGBACOLOR(0, 0, 0, 0.12);
    
    
    [self addSubview:bottomView];
}

- (void)setLeftViewWithImage:(UIImage *)image andPlacehold:(NSString *)placehold
{
    UIImageView *leftImageView =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    leftImageView.image = image;
    
    self.leftView = leftImageView;
    
    self.leftViewMode = UITextFieldViewModeAlways;
    
    self.placeholder = placehold;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 27.5, 7);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 27.5, 7);
}

//- (CGRect)leftViewRectForBounds:(CGRect)bounds
//{
//    CGRect iconRect = [super leftViewRectForBounds:bounds];
//    iconRect.origin.y +=5;
//    
//    return iconRect;
//}
@end
