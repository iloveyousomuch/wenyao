//
//  BaseTableViewController.h
//  wenyao
//
//  Created by Meng on 14-9-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"
#import "HTTPRequestManager.h"
@interface BaseTableViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong) UITableView * tableView;
- (void)addNetView;

@end
