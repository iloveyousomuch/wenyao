//
//  DiseaseSubViewController.h
//  wenyao
//
//  Created by Meng on 14-10-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseTableViewController.h"

@interface DiseaseSubViewController : BaseTableViewController

@property (nonatomic,strong) UINavigationController * navigationController;

@property (nonatomic ,copy) NSString * classId;

- (void)viewDidCurrentView;

@end
