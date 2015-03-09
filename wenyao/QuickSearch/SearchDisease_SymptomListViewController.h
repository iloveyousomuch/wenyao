//
//  SearchDisease+SymptomListViewController.h
//  wenyao
//
//  Created by Meng on 14/12/2.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseTableViewController.h"

typedef enum {
    RequsetTypeDisease, //来自人体图
    RequsetTypeSymptom //来自搜索
}RequsetType;


@interface SearchDisease_SymptomListViewController : BaseTableViewController

@property (nonatomic ,strong) NSString * kwId;
@property (nonatomic ,assign) RequsetType requsetType;
@property (nonatomic ,assign) UIViewController  *containerViewController;

@end
