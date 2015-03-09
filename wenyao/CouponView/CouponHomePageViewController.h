//
//  CouponHomePageViewController.h
//  wenyao
//
//  Created by 李坚 on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"

@interface CouponHomePageViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *noCouponLabel;

@property (weak, nonatomic) IBOutlet UIView *noCouponView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *couponArray;

@property (nonatomic, copy) NSString *provinceName;
@property (nonatomic, copy) NSString *cityName;

@end
