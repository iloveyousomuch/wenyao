//
//  BaseInfromationViewController.h
//  quanzhi
//
//  Created by Meng on 14-8-7.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"
#import "SymBaseInfroCell.h"
//#import "UIFolderTableView.h"
@interface BaseInfromationViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,SymBaseInfroCellDelegate>

@property (nonatomic, strong) UITableView   *myTableView;
@property (nonatomic ,weak) UINavigationController * navigationController;
@property (nonatomic ,strong) NSMutableDictionary * dataSource;
@property (nonatomic ,strong) NSString * spmCode;


- (void)viewDidCurrentView;

@end
