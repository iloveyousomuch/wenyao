//
//  BaseViewController.h
//  quanzhi
//
//  Created by xiezhenghong on 14-6-4.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constant.h"
#import "HTTPRequestManager.h"
#import "Reachability.h"
#import <MapKit/MapKit.h>
typedef void (^NoNetWorkBlcok)();
@interface BaseViewController : UIViewController
@property (nonatomic, strong) NoNetWorkBlcok blockNoNetwork;
@property (nonatomic, assign) BOOL          continueRegeode;
@property (nonatomic, strong) CLLocationManager *locationManager;
- (void)viewDidCurrentView;
- (void)layoutSubViewsWithFontSize;
- (void)zoomInSubViews;
- (void)zoomOutSubViews;
- (void)zoomClick;
//特殊字符的替换
- (NSString *)replaceSpecialStringWith:(NSString *)string;
- (void)backToPreviousController:(id)sender;
- (void)getCurrentLocation;
- (void)stopGetLocation;
@end
