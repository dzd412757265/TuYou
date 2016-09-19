//
//  EIImagePickerFocusView.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/31.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIImagePickerFocusView.h"
#import "UIView+Extension.h"

@implementation EIImagePickerFocusView

- (instancetype)init
{
    if (self = [super init]) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.backgroundColor = [UIColor clearColor];
    
    self.layer.borderWidth = 1.0f;
    
    self.layer.borderColor = [UIColor yellowColor].CGColor;
    
    self.frame = CGRectMake(0, 0, 80, 80);
    
    self.hidden = YES;
}

- (void)alertAnimateWithPoint:(CGPoint)centerPoint
{
    self.alpha = 1.f;
    self.hidden = NO;
    self.center = centerPoint;
    self.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [UIView animateWithDuration:.2 animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.1 delay:1 options:0 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            self.hidden = YES;
        }];
    }];
//    CGPoint point = centerPoint;
//    
//    point.x = point.x - 40;
//    point.y = point.y - 40;
//    
//    self.center = point;
//    
//    CGFloat bigWidth = 80;
//    CGFloat bigHeight = 80;
//    
//    CGFloat littleWidht = 60;
//    CGFloat littleHeight = 60;
//    
//    CGFloat animatTime = 0.2;
//    
//    self.width = bigWidth;
//    
//    self.height = bigHeight;
//    
//    self.hidden = NO;
//    
//    [UIView animateWithDuration:animatTime animations:^{
//        
//        self.width = littleWidht;
//        
//        self.height = littleHeight;
//        
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:animatTime animations:^{
//            
//            self.width = bigWidth;
//            
//            self.height  = bigHeight;
//            
//        } completion:^(BOOL finished) {
//            
//            [UIView animateWithDuration:animatTime animations:^{
//                
//                self.width = littleWidht;
//                
//                self.height = littleHeight;
//            } completion:^(BOOL finished) {
//                
//                [UIView animateWithDuration:animatTime animations:^{
//                    
//                    self.width = bigWidth;
//                    
//                    self.height = bigHeight;
//                    
//                    
//                } completion:^(BOOL finished) {
//                   
//                    self.hidden = YES;
//                    
//                    self.width = 0;
//                    
//                    self.height = 0;
//                }];
//            }];
//        }];
//    }];
}
@end
