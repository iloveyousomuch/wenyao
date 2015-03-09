//
//  RemindAlarmViewController.h
//  wenyao
//
//  Created by xiezhenghong on 14-10-18.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RemindAlarmViewController : UIViewController


@property (nonatomic, strong) NSMutableDictionary              *infoDict;

@property (nonatomic, strong) IBOutlet UIScrollView     *scrollView;
@property (nonatomic, strong) IBOutlet UILabel          *productNameLabel;
@property (nonatomic, strong) IBOutlet UIView           *container;
@property (nonatomic, strong) IBOutlet UIImageView      *containerBackImage;

@property (nonatomic, strong) IBOutlet UILabel          *useageLabel;
@property (nonatomic, strong) IBOutlet UILabel          *remarkLabel;
@property (nonatomic, strong) IBOutlet UILabel          *useNameLabel;

- (IBAction)deleteClock:(id)sender;
- (IBAction)finishClock:(id)sender;

@end
