//
//  CityListViewController.h
//  wenyao
//
//  Created by xiezhenghong on 14-10-7.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface CityListViewController : BaseViewController

@property (nonatomic, copy) void(^selectBlock)(NSString *cityName);
@property (nonatomic, strong) NSString                  *currentCity;
@property (nonatomic, strong) NSMutableDictionary    *cityList;

@end
