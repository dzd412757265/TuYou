//
//  EIMessageListCell.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/8.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIMessageListCell.h"
#import "UIImageView+WebCache.h"
#import "EIDefines.h"
#import "UIView+Extension.h"
#import "EIUserCenter.h"
#import "NSObject+EasyJSON.h"

@interface EIMessageListCell()

@property (nonatomic, strong)CAGradientLayer *gradientLayer;

@end
@implementation EIMessageListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
//    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    
//    //初始化CAGradientlayer对象，使它的大小为UIView的大小
//    self.gradientLayer = [CAGradientLayer layer];
//    self.gradientLayer.frame = self.messageNumberButton.bounds;
//    
//    //将CAGradientlayer对象添加在我们要设置背景色的视图的layer层
//    [self.messageNumberButton.layer addSublayer:self.gradientLayer];
//    
//    //设置渐变区域的起始和终止位置（范围为0-1）
//    self.gradientLayer.startPoint = CGPointMake(0, 0);
//    self.gradientLayer.endPoint = CGPointMake(1, 1);
//    
//    //设置颜色数组
//    self.gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:255/255.0 green:157/255.0 blue:98/255.0 alpha:1].CGColor,
//                                  (__bridge id)[UIColor colorWithRed:255/255.0 green:71/255.0 blue:132/255.0 alpha:1].CGColor];
//    
//    //设置颜色分割点（范围：0-1）
//    self.gradientLayer.locations = @[@(0.f), @(1.0f)];
    
    self.messageNumberButton.layer.cornerRadius = 11;
    [self.messageNumberButton setBackgroundColor:UIColorFromHex(0xFE3824)];
//    self.messageNumberButton.layer.masksToBounds = YES;
}

+ (instancetype)creatCellWith:(UITableView *)tableView
{
    NSString *strId = NSStringFromClass([self class]);
    
    UINib *nib =[UINib nibWithNibName:@"EIMessageListCell" bundle:nil];
    
    [tableView registerNib:nib forCellReuseIdentifier:strId];
    
    EIMessageListCell *cell = [tableView dequeueReusableCellWithIdentifier:strId];
    
    return cell;

}

- (void)setCellWithModel:(EIMessageListModel *)listModel
{
        if ([listModel.messageNumber integerValue] > 0) {
            
            self.messageNumberButton.hidden = NO;
            
            [self.messageNumberButton setTitle:[NSString stringWithFormat:@"%@",listModel.messageNumber] forState:UIControlStateNormal];
        }else{
            
            self.messageNumberButton.hidden = YES;
            
        }

    
    self.nameLabel.text = listModel.nickname;
    
    CGFloat maxWidth = self.messageNumberButton.x - self.nameLabel.x- 12 - 7;
    
     self.nameLabelWidth.constant =[listModel.nickname boundingRectWithSize:CGSizeMake(maxWidth, 21) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:EIFont(15),NSForegroundColorAttributeName:EINickNameColor} context:nil].size.width + 1;
    
    if ([listModel.sex integerValue] == SexTypeMale) {
        
        [self.sexImage setImage:[UIImage imageNamed:@"IconMale"]];
        
    }else if([listModel.sex integerValue] == SexTypeFemale){
        
        [self.sexImage setImage:[UIImage imageNamed:@"IconFemale"]];
        
    }else{
        
        [self.sexImage setImage:nil];
    }
    
    [self.avatorImageView setImageUrl:listModel.avatar sex:listModel.sex];

    NSString *cityString = nil;
    if (listModel.city.length > 0) {
        cityString = listModel.city;
    }else{
        cityString = @"未知";
    }
    CGFloat cityWidth =  [cityString boundingRectWithSize:CGSizeMake(kScreen_Width, 14) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:EIFont(10),NSForegroundColorAttributeName:EIGreyColor} context:nil].size.width + 1 + 4 + 8;
    
    self.locationButtonWidth.constant = cityWidth;
    [self.locationButton setTitle:cityString forState:UIControlStateNormal];
    
    NSString *timeString = listModel.timeString.isNotEmpty ? listModel.timeString : @"未知";
    CGFloat timeWidth = [timeString boundingRectWithSize:CGSizeMake(kScreen_Width, 14) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:EIFont(10),NSForegroundColorAttributeName:EIGreyColor} context:nil].size.width + 1 + 4 + 8;
    self.timeButtonWidth.constant = timeWidth;
    [self.timeButton setTitle:listModel.timeString forState:UIControlStateNormal];
    

        
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
