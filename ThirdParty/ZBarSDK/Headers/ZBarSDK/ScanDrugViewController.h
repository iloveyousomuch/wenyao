//
//  ScanDrugViewController.h
//  quanzhi
//
//  Created by xiezhenghong on 14-6-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanReaderViewController.h"
#import "BaseViewController.h"

@interface ScanDrugViewController : BaseViewController<
UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray  *drugList;
@property (nonatomic, strong) UITableView     *tableView;

//1代表普通扫码界面     2代表家庭药箱扫码界面
@property (nonatomic, assign) NSUInteger      userType;
@property (nonatomic, copy)   chooseMedicineBlock       completionBolck;


@end
