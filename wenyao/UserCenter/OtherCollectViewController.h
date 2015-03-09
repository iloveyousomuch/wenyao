//
//  OtherCollectViewController.h
//  wenyao
//
//  Created by Meng on 14-10-2.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseTableViewController.h"

typedef enum : NSUInteger {
    medicineCollect,
    symptomCollect,
    diseaseCollect,
    messageCollect,
} OtherCollectType;

@interface OtherCollectViewController : BaseTableViewController

@property (nonatomic ,strong) UINavigationController * navigationController;

@property (nonatomic ,assign) OtherCollectType collectType;

@property (nonatomic, strong) UIViewController  *containerViewController;

- (void)viewDidCurrentView;

@end
