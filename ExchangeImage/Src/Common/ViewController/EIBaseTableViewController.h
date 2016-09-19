//
//  BaseTableViewController.h
//  wenda
//
//  Created by 古元庆 on 16/6/20.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIBaseViewController.h"

@interface EIBaseTableViewController : EIBaseViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong)UITableView *tableView;
@property (nonatomic , assign)UITableViewStyle tableViewStyle;

@end
