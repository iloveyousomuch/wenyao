//
//  DiseaseDetailViewController.h
//  quanzhi
//
//  Created by Meng on 14-12-10.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface DiseaseDetailViewController : BaseViewController
@property (nonatomic,copy)NSString* diseaseId;
@property (nonatomic,copy)NSString* diseaseName;
@property (nonatomic ,copy) NSString * diseaseType;
@property (nonatomic, weak) UIViewController      *containerViewController;

@property (nonatomic,copy)NSString* controllerName;
@end
