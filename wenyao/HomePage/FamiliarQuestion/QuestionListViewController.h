//
//  QuestionListViewController.h
//  wenyao
//
//  Created by qwyf0006 on 15/1/15.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionListViewController : UIViewController

@property (strong, nonatomic) UINavigationController *currNavigationController;
@property (strong, nonatomic) NSString *classId;
@property (strong, nonatomic) NSString *moduleId;

- (void)viewDidCurrentView;

@end
