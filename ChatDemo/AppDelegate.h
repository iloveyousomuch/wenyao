//
//  AppDelegate.h
//  wenyao
//
//  Created by xiezhenghong on 14-9-1.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import "DataBase.h"
#import "customAlertView.h"
#import "ReachabilityMonitor.h"

enum  Enum_TabBar_Items {
    Enum_TabBar_Items_HomePage   = 0,
    Enum_TabBar_Items_QuickSearch = 1,
    Enum_TabBar_Items_HealthInformation = 2,
    Enum_TabBar_Items_UserCenter  = 3,
};

@interface AppDelegate : UIResponder <UIApplicationDelegate,
UIAlertViewDelegate,ReachabilityDelegate,UITabBarControllerDelegate>
{
    CLLocationManager * locationManager;
    __block  UIBackgroundTaskIdentifier  backgroundTask;
}

@property (nonatomic, copy)   dispatch_source_t     pullMessageTimer;

@property (nonatomic, assign) NetworkStatus           currentNetWork;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (nonatomic, assign) BOOL logStatus;
@property (nonatomic, strong) DataBase      *dataBase;
@property (nonatomic, strong) DataBase      *cacheBase;
@property (nonatomic, strong) NSMutableDictionary   *configureList;
@property (nonatomic ,strong) NSString * deviceToken;
@property (nonatomic ,strong) NSString * token;

@property (nonatomic, strong) ReachabilityMonitor       *reachabilityMonitor;

@property (nonatomic ,strong) MAMapView * mapView;

// 版本更新
@property (nonatomic, strong) customAlertView *myAlertView;
@property (nonatomic, strong) NSDictionary *dicNewVersionInfo;
@property (nonatomic, assign) NSTimeInterval lastTimeStamp;
@property (nonatomic, assign) BOOL boolLoadFromFirstIn;

@property (nonatomic, strong) UIImageView *imageViewBudge;
@property (nonatomic, strong) UIImageView *myCenterBudge;

@property (nonatomic, assign) BOOL needShowBadge;

@property (nonatomic, assign) BOOL hasNewDisease;

@property (nonatomic, assign) BOOL isForceUpdating;
@property (nonatomic, strong) NSDictionary *dicForceUpdated;

- (void)updateUnreadCountBadge;
- (NSString *)updateDisplayTime:(NSDate *)date;
- (NSString *)updateFirstPageTimeDisplayer:(NSDate *)date;
- (void)initDataSource:(NSString *)username;
- (void)saveAppConfigure;
- (void)clearAccountInformation;
-(void)initsocailShare:(NSString *)urlString;
- (void)showDiseaseBudge:(BOOL)show;
- (void)cacheLastLocationInformation:(NSString *)city
                            location:(CLLocation *)location;
- (NSString *)replaceSpecialStringWith:(NSString *)string;
- (void)cacheLastLocationInformation:(NSString *)city
                            province:(NSString *)province
                    formatterAddress:(NSString *)address
                            location:(CLLocation *)location;

@end

extern AppDelegate  *app;
void setHistoryConfig(NSString * key , id value);
id getHistoryConfig(NSString *key);
