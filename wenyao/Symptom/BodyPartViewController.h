//
//  BodyPartViewController.h
//  quanzhi
//
//  Created by xiezhenghong on 14-8-7.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Constant.h"


@interface BodyPartViewController : BaseViewController

- (void)viewDidCurrentView;
- (IBAction)showBodyHighLight:(id)sender;
- (IBAction)didSelectDifferentBodyPart:(id)sender;
- (IBAction)transformSex:(id)sender;
- (IBAction)turnAround:(id)sender;
@property (nonatomic, weak) UIViewController      *containerViewController;


@property (nonatomic, strong) IBOutlet  UIView   *manPositive;
@property (nonatomic, strong) IBOutlet  UIView   *manNegative;
@property (nonatomic, strong) IBOutlet  UIView   *womanPositive;
@property (nonatomic, strong) IBOutlet  UIView   *womanNegative;
@property (nonatomic, strong) IBOutlet  UIView   *childPositive;
@property (nonatomic, strong) IBOutlet  UIView   *childNegative;

@end
