//
//  GBResizableButton.m
//  jiuwuliao
//
//  Created by admin on 15/7/15.
//  Copyright (c) 2015年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIResizableButton.h"

@implementation EIResizableButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setImage:[self imageForState:UIControlStateNormal] forState:UIControlStateNormal];
        [self setImage:[self imageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
        [self setImage:[self imageForState:UIControlStateSelected] forState:UIControlStateSelected];
        [self setImage:[self imageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
        
        [self setBackgroundImage:[self backgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
        [self setBackgroundImage:[self backgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
        [self setBackgroundImage:[self backgroundImageForState:UIControlStateSelected] forState:UIControlStateSelected];
        [self setBackgroundImage:[self backgroundImageForState:UIControlStateDisabled] forState:UIControlStateDisabled];
    }
    return self;
}

- (void)setImage:(UIImage *)inImage forState:(UIControlState)inState {
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(ceilf(inImage.size.height / 2), ceilf(inImage.size.width / 2), ceilf(inImage.size.height / 2), ceilf(inImage.size.width / 2));
    if ([inImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        // iOS 5
        inImage = [inImage resizableImageWithCapInsets:edgeInsets];
    }
    else
        inImage = [inImage stretchableImageWithLeftCapWidth:edgeInsets.left topCapHeight:edgeInsets.top];
    
    [super setImage:inImage forState:inState];
}

- (void)setBackgroundImage:(UIImage *)inImage forState:(UIControlState)inState {
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(ceilf(inImage.size.height / 2), ceilf(inImage.size.width / 2), ceilf(inImage.size.height / 2), ceilf(inImage.size.width / 2));
    if ([inImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        // iOS 5
        inImage = [inImage resizableImageWithCapInsets:edgeInsets];
    }
    else
        inImage = [inImage stretchableImageWithLeftCapWidth:edgeInsets.left topCapHeight:edgeInsets.top];
    
    [super setBackgroundImage:inImage forState:inState];
}

- (void)setTitle:(NSString *)title font:(UIFont *)font color:(UIColor *)color state:(UIControlState)state
{
    [self setAttributedTitle:[[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:color,NSFontAttributeName:font}] forState:state];
}

@end
