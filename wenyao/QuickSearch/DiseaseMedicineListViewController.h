//
//  MedicineListViewController.h
//  quanzhi
//
//  Created by ZhongYun on 14-6-20.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"

@interface DiseaseMedicineListViewController : BaseViewController
@property(nonatomic,retain)NSDictionary* params;
//0是普通展示  1在storyboard中展示
@property (nonatomic,assign) NSUInteger     showType;

@end
