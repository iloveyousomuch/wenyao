//
//  ReportDrugStoreViewController.h
//  wenyao
//
//  Created by xiezhenghong on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ReportDrugStoreViewController : BaseViewController

@property (nonatomic, strong) NSMutableDictionary       *infoDict;

@property (nonatomic, strong) UITextView                *textView;
@property (nonatomic, strong) UITableView               *tableView;

@end
