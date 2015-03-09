//
//  HomePageViewController.h
//  wenyao
//
//  Created by Meng on 14-9-10.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    RemindNone = 0,
    RemindLogin = 1,
    RemindUncompleten,
    RemindLostConnect
} RemindType;


@interface HomePageViewController : UIViewController

@property (nonatomic, strong) UITableView       *tableView;
@property (nonatomic, strong) IBOutlet UIView   *headerView;

- (IBAction)pushIntoMyPharmacy:(id)sender;

- (IBAction)pushIntoIMPharmacy:(id)sender;

- (IBAction)pushIntoAddMedicine:(id)sender;


@end
