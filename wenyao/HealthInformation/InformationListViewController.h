//
//  InformationListViewController.h
//  quanzhi
//
//  Created by xiezhenghong on 14-6-24.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InformationListViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView   *tableView;
@property (nonatomic, assign) UINavigationController    *navigationController;
@property (nonatomic, strong) NSDictionary              *infoDict;
@property (nonatomic, strong) NSMutableArray            *infoList;
@property (nonatomic, strong) NSMutableArray            *bannerList;



- (void)viewDidCurrentView;

@end
