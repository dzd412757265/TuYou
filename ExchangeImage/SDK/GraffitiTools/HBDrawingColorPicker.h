//
//  HBDrawingColorPicker.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/8/5.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBDrawingColorMenu:UIButton

@property (nonatomic , strong)UIColor *colorProperty;

@end

@interface HBDrawingColorPicker : UIScrollView

@property (nonatomic ,copy)void(^clickColorMenu)(UIColor *);

- (id)initWithFrame:(CGRect)frame colors:(NSArray *)colors;

- (void)chooseMenuAtIndex:(NSInteger)index;

@end
