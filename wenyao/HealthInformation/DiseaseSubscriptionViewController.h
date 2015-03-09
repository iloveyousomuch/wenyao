//
//  DiseaseSubscriptionViewController.h
//  wenyao
//
//  Created by Pan@QW on 14-9-24.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface DiseaseSubscriptionViewController : BaseViewController

@property (nonatomic, assign) UINavigationController    *navigationController;
@property (nonatomic, strong) UITableView               *tableView;
//no是健康资讯    yes是全维药师IM进入
@property (nonatomic, assign) BOOL                      subType;

- (void)queryDrugGuideList:(BOOL)forece;


@end
