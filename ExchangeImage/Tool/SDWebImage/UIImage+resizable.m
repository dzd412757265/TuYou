//
//  UIImage+resizable.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/21.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "UIImage+resizable.h"

@implementation UIImage (resizable)

+ (UIImage *)getResizableImageWithOriginImage:(UIImage *)inImage
{
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(ceilf(inImage.size.height / 2), ceilf(inImage.size.width / 2), ceilf(inImage.size.height / 2), ceilf(inImage.size.width / 2));
    
    if ([inImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
        // 
        inImage = [inImage resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
    }
    else{
        
        inImage = [inImage stretchableImageWithLeftCapWidth:edgeInsets.left topCapHeight:edgeInsets.top];
    }
    
    return inImage;
}
@end
