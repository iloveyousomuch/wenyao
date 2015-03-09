//
//  DetailSubscriptionListViewController.h
//  wenyao
//
//  Created by Pan@QW on 14-9-25.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UIFolderTableView.h"

@interface DetailSubscriptionListViewController : BaseViewController

@property (nonatomic, strong) UIFolderTableView         *tableView;
@property (nonatomic, strong) NSDictionary              *infoDict;

@end
