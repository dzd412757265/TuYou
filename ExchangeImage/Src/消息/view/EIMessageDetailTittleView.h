//
//  EIMessageDetailTittleView.h
//  ExchangeImage
//
//  Created by 张博成 on 16/7/25.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EIMessageDetailTittleView : UIView

+(CGSize)caculateViewWidthWithName:(NSString *)nickName;

- (void)setTitleWithName:(NSString *)nickName andWithSex:(NSNumber *)sex andWithCity:(NSString *)city;

@end
