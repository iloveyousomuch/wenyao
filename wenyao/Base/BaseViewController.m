//
//  BaseViewController.m
//  quanzhi
//
//  Created by xiezhenghong on 14-6-4.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "CLLocation+YCLocation.h"

#import <AMapSearchKit/AMapSearchAPI.h>

@interface BaseViewController ()<CLLocationManagerDelegate,AMapSearchDelegate>
@property (nonatomic ,strong) AMapSearchAPI *mapSearchAPI;
@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = BG_COLOR;
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    [self setupBackBarButtonItem];
    // Do any additional setup after loading the view.
    }

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
//    if (self.blockNoNetwork) {
//        self.blockNoNetwork();
//    }
}

- (void)setupBackBarButtonItem
{
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_btn_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backToPreviousController:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}


//特殊字符的替换
- (NSString *)replaceSpecialStringWith:(NSString *)string{
    string = [string stringByReplacingOccurrencesOfString:@"    &nbsp;&nbsp;&nbsp;&nbsp;" withString:@"    "];
    string = [string stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@"<p/>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt:" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt:" withString:@">"];
    return string;
}


- (void)viewDidCurrentView
{
    
}

- (void)backToPreviousController:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Get Current Location
- (void)getCurrentLocation
{
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        if (iOSv8) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }

    self.locationManager.distanceFilter = 10;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [self.locationManager startUpdatingLocation];
}

- (void)stopGetLocation
{
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
}

#pragma mark - CLLocation manager
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    [self.locationManager stopUpdatingLocation];
    location = [location locationMarsFromEarth];
    [self getCurrentLocationSuccessWithLoc:location];
    if (self.continueRegeode) {
        [self reGoecodeSearchData:location DistanceRadius:500];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"定位失败"
                                                    message:@""
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [self getCurrentLocationFailWithMsg:[error localizedDescription]];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
//        NSLog(@"%s-----%@",__func__,manager.location);
        [self.locationManager startUpdatingLocation];
        
    } else if (status == kCLAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"定位服务未开启"
                                                        message:@"请前往设置页面开启定位服务。"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        NSLog(@"Wrong location status");
    }
    [self getCurrentLocationWithAuthorizationStatus:status];
}

- (void)reGoecodeSearchData:(CLLocation *)location DistanceRadius:(CGFloat)radius
{
    //逆地址解析
    self.mapSearchAPI = [[AMapSearchAPI alloc] initWithSearchKey:[MAMapServices sharedServices].apiKey Delegate:self];
    AMapReGeocodeSearchRequest * request = [[AMapReGeocodeSearchRequest alloc] init];
    request.searchType = AMapSearchType_ReGeocode;
    request.requireExtension = YES;
    
    AMapGeoPoint * point = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    request.radius = radius;
    request.location = point;
    [self.mapSearchAPI AMapReGoecodeSearch:request];
}

//逆地理编码成功
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    NSLog(@"Response is %@",response);
    [self ReGeocodeSuccess:response];
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    
}

// 等待实现的方法
- (void)getCurrentLocationSuccessWithLoc:(CLLocation *)location
{
    
}

- (void)getCurrentLocationFailWithMsg:(NSString *)msg
{
    
}

- (void)getCurrentLocationWithAuthorizationStatus:(CLAuthorizationStatus)status
{
    
}

- (void)ReGeocodeSuccess:(AMapReGeocodeSearchResponse *)response
{
    
}

@end
