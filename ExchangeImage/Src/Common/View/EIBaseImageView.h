//
//  EIBaseImageView.h
//  ExchangeImage
//
//  Created by 古元庆 on 16/7/7.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^longPressMenuBlock)(NSInteger index, NSString *title);
typedef void(^singleClickBlock)();

static CGFloat kPhotoFramePadding = 5.f;

@interface EIBaseImageView : UIImageView

@property (nonatomic , strong) UIImageView *contentImageView;
@property (nonatomic , copy)longPressMenuBlock longpressBlock;
@property (nonatomic , copy)singleClickBlock singleClickBlock;
@property (strong, nonatomic) NSArray *longPressTitles;

+ (CGSize)calulateImageSize:(UIImage *)image;

+ (CGSize)calculateViewSize:(UIImage *)image;

+ (CGSize)calculateTotalSize:(CGSize)size;

- (void)setContentImage:(UIImage *)image;

- (void)setContentSize:(CGSize )size;

- (void)addLongPressMenu:(NSArray *)titles clickBlock:(longPressMenuBlock) block;

- (void)addClickAction:(singleClickBlock) block;

@end
