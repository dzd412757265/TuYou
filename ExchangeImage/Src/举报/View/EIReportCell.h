//
//  EIReportCell.h
//  ExchangeImage
//
//  Created by 张博成 on 16/7/21.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EIReportCell : UITableViewCell


+ (instancetype)createcellWithTableView:(UITableView *)tableView;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;


@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@property(nonatomic, copy) void (^selectClick)(BOOL);

- (void)setCellWith:(NSString *)string;

@end
