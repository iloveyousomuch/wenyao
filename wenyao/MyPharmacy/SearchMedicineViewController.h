//
//  SearchMedicineViewController.h
//  wenyao
//
//  Created by xiezhenghong on 14-10-8.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "secondCustomAlertView.h"

@interface SearchMedicineViewController : UIViewController


@property (nonatomic,copy) void(^selectBlock)(NSMutableDictionary* dataRow);
@property (nonatomic ,strong) secondCustomAlertView *customAlertView;

@end
