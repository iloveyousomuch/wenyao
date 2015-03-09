//
//  SearchViewController.h
//  wenyao
//
//  Created by Meng on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"

typedef enum : NSUInteger {
    medicineViewController,
    diseaseViewController,
    symptomViewController,
} CurrentSelectedViewController;

@interface SearchSliderViewController : BaseViewController<UITextFieldDelegate>

@property (nonatomic ,assign) CurrentSelectedViewController currentSelectedViewController;

@end
