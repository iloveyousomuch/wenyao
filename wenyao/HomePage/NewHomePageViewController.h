//
//  NewHomePageViewController.h
//  wenyao
//
//  Created by garfield on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLCycleScrollView.h"
#import "MKNumberBadgeView.h"

@interface NewHomePageViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, weak) IBOutlet UIScrollView  *scrollerView;
@property (weak, nonatomic) IBOutlet UITableView *consultTableView;
@property (weak, nonatomic) IBOutlet UITableView *recommendedTableView;

@property (weak, nonatomic) IBOutlet UIView *recommededView;
@property (weak, nonatomic) IBOutlet UIView *consultView;
@property (strong, nonatomic) NSLayoutConstraint  *bottomLayoutConstraint;
@property (nonatomic, strong) MKNumberBadgeView *badgeView;

- (IBAction)pushIntoFreeConsult:(id)sender;

- (IBAction)pushIntoNearByStore:(id)sender;
- (void)pushIntoMessageBox:(id)sender;

@end
