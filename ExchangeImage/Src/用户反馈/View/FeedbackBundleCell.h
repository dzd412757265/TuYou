//
//  FeedbackBundleCell.h
//  Jianjian
//
//  Created by admin on 15/4/9.
//  Copyright (c) 2015年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 意见反馈聊天泡泡
 */

@interface FeedbackBundleCell : UITableViewCell

-(void)setData:(NSDictionary *)dict;
-(CGFloat)setMutiLineLabelText:(NSDictionary*)dict;

@end
