//
//  EIReportCell.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/21.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIReportCell.h"

@implementation EIReportCell

+ (instancetype)createcellWithTableView:(UITableView *)tableView
{
    NSString *strId = NSStringFromClass([self class]);
    UINib *nib =[UINib nibWithNibName:@"EIReportCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:strId];
    
    return [tableView dequeueReusableCellWithIdentifier:strId];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectButton.layer.cornerRadius = 20;
    
    [self.selectButton setImage:[UIImage imageNamed:@"selectButton"] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"selectedButton"] forState:UIControlStateSelected];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)setCellWith:(NSString *)string
{
    self.contentLabel.text =string;
}
- (IBAction)selectButtonClick:(id)sender {
    
    self.selectButton.selected = !self.selectButton.selected;
    
    if (self.selectClick) {
        self.selectClick(self.selectButton.selected);
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
