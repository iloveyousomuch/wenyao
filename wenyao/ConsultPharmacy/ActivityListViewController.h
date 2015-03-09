//
//  ActivityListViewController.h
//  wenyao
//
//  Created by xiezhenghong on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ActivityListViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic) id groupId;
@property (nonatomic, strong) NSMutableArray        *infoList;
@property (nonatomic, strong) UITableView           *tableView;

@end
