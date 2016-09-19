//
//  EIMessageListCell.h
//  ExchangeImage
//
//  Created by 张博成 on 16/7/8.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EIMessageListModel.h"
#import "EIAvatarView.h"

@interface EIMessageListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIButton *messageNumberButton;

@property (weak, nonatomic) IBOutlet EIAvatarView *avatorImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLabelWidth;
@property (weak, nonatomic) IBOutlet UIImageView *sexImage;

@property (weak, nonatomic) IBOutlet UIButton *locationButton;

@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationButtonWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeButtonWidth;

+ (instancetype)creatCellWith:(UITableView *)tableView;

- (void)setCellWithModel:(EIMessageListModel *)listModel;

@end

