//
//  ConsultPharmacyViewController.h
//  wenyao
//
//  Created by xiezhenghong on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "AppDelegate.h"

@interface ConsultPharmacyViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView    *tableView;

@end
