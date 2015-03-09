//
//  CouponConsuletViewController.h
//  wenyao
//
//  Created by 李坚 on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "BaseTableViewController.h"

@interface CouponConsuletViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) id promotionId;
@property (strong, nonatomic) NSMutableArray *array;

@end
