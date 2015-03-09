//
//  HealthySliderViewController.h
//  wenyao
//
//  Created by 李坚 on 15/1/20.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"
#import "QCSlideSwitchView.h"
@interface HealthySliderViewController : BaseViewController
@property (nonatomic, strong) NSMutableArray *viewControllerArray;
@property (nonatomic ,strong) QCSlideSwitchView * slideSwitchView;
@property (nonatomic, strong) NSDictionary      *infoDict;
@end
