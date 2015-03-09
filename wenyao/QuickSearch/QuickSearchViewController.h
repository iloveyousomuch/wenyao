//
//  QuickSearchViewController.h
//  wenyao
//
//  Created by Meng on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface QuickSearchViewController : BaseViewController
//0是不需要显示回退    1是需要显示回退
@property (assign) NSInteger    showBack;

@end



@interface MyTapGestureRecognizer : UITapGestureRecognizer
@property (nonatomic ,assign) NSInteger tag;
@end