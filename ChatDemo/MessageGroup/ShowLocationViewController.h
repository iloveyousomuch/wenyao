//
//  ShowLocationViewController.h
//  wenyao
//
//  Created by garfield on 15/3/3.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <CoreLocation/CLLocation.h>

@interface ShowLocationViewController : BaseViewController

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString               *address;

@end
