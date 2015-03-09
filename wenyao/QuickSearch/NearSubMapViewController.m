//
//  NearSubMapViewController.m
//  wenyao
//
//  Created by Meng on 14-10-10.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "NearSubMapViewController.h"
#import "NearMapViewController.h"

#define SPAN            MACoordinateSpanMake(0.025, 0.025)
#define FACTORYMENU_X   60
#define kCalloutViewMargin          -8
#define kWidth  21.f
#define kHeight 32.f

@interface NearSubMapViewController ()<MAMapViewDelegate, CLLocationManagerDelegate,AMapSearchDelegate>
{
    
    BOOL isSet;//是否设置定位到蓝色标注位置
    CLLocationDegrees latitudDelta;
    CLLocationDegrees longituDelta;
}
//地图相关
@property (nonatomic ,strong) MAMapView * mapView;
@property (nonatomic ,strong) MAUserLocation * userLocation;
@property (nonatomic, strong) MAPointAnnotation *poiAnnotation;
@end

@implementation NearSubMapViewController

- (id)init{
    if (self = [super init]) {
        self.title = @"药店地址";
        isSet = NO;
        latitudDelta = 0.025;
        longituDelta = 0.025;
        //设置地图
        self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
        self.mapView.delegate = self;
        self.mapView.mapType = MAMapTypeStandard;
        self.mapView.touchPOIEnabled = YES;
        self.mapView.userTrackingMode = MAUserTrackingModeFollow;
        self.mapView.distanceFilter = 100;
        [self.view addSubview:self.mapView];
        
        
        UIImage * zoomImage = [UIImage imageNamed:@"放大缩小.png"];
        
        UIImageView * zoomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(APP_W -zoomImage.size.width-10, self.mapView.frame.size.height - 122 - zoomImage.size.height-8, zoomImage.size.width, zoomImage.size.height)];
        zoomImageView.image = zoomImage;
        zoomImageView.userInteractionEnabled = YES;
        [self.mapView addSubview:zoomImageView];
        
        UIButton * zoomOutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [zoomOutButton setFrame:CGRectMake(0, 0, zoomImage.size.width, zoomImage.size.height/2)];
        [zoomOutButton addTarget:self action:@selector(zoomOutButtonClick) forControlEvents:UIControlEventTouchUpInside];
        zoomOutButton.backgroundColor = [UIColor clearColor];
        [zoomImageView addSubview:zoomOutButton];
        
        UIButton * zoomInButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [zoomInButton setFrame:CGRectMake(0, zoomImage.size.height/2, zoomImage.size.width, zoomImage.size.height/2)];
        [zoomInButton addTarget:self action:@selector(zoomInButtonClick) forControlEvents:UIControlEventTouchUpInside];
        zoomInButton.backgroundColor = [UIColor clearColor];
        [zoomImageView addSubview:zoomInButton];
        
        
        //设置显示当前按钮
        UIImage * localMeImage = [UIImage imageNamed:@"定位.png"];
        UIButton * localMeButton= [[UIButton alloc] initWithFrame:RECT(APP_W-10-localMeImage.size.width, self.mapView.frame.size.height - 122, localMeImage.size.width, localMeImage.size.height)];
        //localMeButton.alpha = 0.5;
        //localMeButton.layer.cornerRadius = 4;
        [localMeButton setBackgroundImage:localMeImage forState:0];
        [localMeButton addTarget:self action:@selector(onLocalMeBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.mapView addSubview:localMeButton];
    }
    return self;
}
- (void)onLocalMeBtnTouched:(UIButton *)btn{
    [self.mapView setRegion:MACoordinateRegionMake(self.userLocation.coordinate, SPAN) animated:YES];
}

- (void)zoomOutButtonClick{
    latitudDelta /= 2;
    longituDelta /= 2;
    [self setMapRegion];
}

- (void)zoomInButtonClick{
    latitudDelta *= 2;
    longituDelta *= 2;
    [self setMapRegion];
}

- (void)setMapRegion{
    CLLocationCoordinate2D centerLocation = [self.mapView convertPoint:CGPointMake(self.mapView.frame.size.width / 2, self.mapView.frame.size.height / 2) toCoordinateFromView:self.mapView];//0.025
    
    MACoordinateRegion region = MACoordinateRegionMake(centerLocation, MACoordinateSpanMake(latitudDelta, longituDelta));
    [self.mapView setRegion:region animated:YES];
}

-(void)mapView:(MAMapView*)mapView didUpdateUserLocation:(MAUserLocation*)userLocation updatingLocation:(BOOL)updatingLocation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    if(![CLLocationManager locationServicesEnabled]){
//        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"定位失败" message:@"请在手机设置中开启定位功能\n开启步骤:设置 > 隐私 > 位置 > 定位服务" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
//        self.mapView = nil;
//        self.mapView.delegate = nil;
//        return;
//    }else{
//        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
//            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"定位失败" message:@"请在手机设置中开启定位功能\n开启步骤:设置 > 隐私 > 位置 > 定位服务下《问药》应用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alertView show];
//            self.mapView = nil;
//            self.mapView.delegate = nil;
//            return;
//        }
//    }
    
    
    
    
    if (self.annotationDict != nil) {
        if (isSet == NO) {
            CLLocationDegrees latitude = [self.annotationDict[@"latitude"] doubleValue];
            CLLocationDegrees longitude = [self.annotationDict[@"longitude"] doubleValue];
            //m_coordinate =
            CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(latitude, longitude);
            self.userLocation = userLocation;
            [self.mapView setRegion:MACoordinateRegionMake(coor, SPAN) animated:YES];
            [self addMapAnnotations];
            isSet = YES;
            return;
        }
        return;
    }
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    

}

- (void)addMapAnnotations{
    
    if (self.annotationDict != nil) {
        CLLocationDegrees latitude = [self.annotationDict[@"latitude"] doubleValue];
        CLLocationDegrees longitude = [self.annotationDict[@"longitude"] doubleValue];
        //m_coordinate =
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(latitude, longitude);
        MAPointAnnotation * ann = [[MAPointAnnotation alloc] init];
        ann.coordinate = coor;
        ann.title = self.annotationDict[@"name"];
        
        [self.mapView addAnnotation:ann];
        
        [self.mapView selectAnnotation:ann animated:YES];
        return;
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        
        
        //NSMutableDictionary * storeDic = ((MyAnnotation *)annotation).store;
        
        
        
        static NSString *customReuseIndetifier = @"customReuseIndetifier";
        MyAnnotationView * annotationView = (MyAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
        if (annotationView == nil) {
            //MAAnnotationView
            annotationView = [[MyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:customReuseIndetifier];
            annotationView.canShowCallout = YES;
            

            annotationView.iconView.image = [UIImage imageNamed:@"point_blue.png"];
            annotationView.tagLabel.hidden = YES;
        }
        return annotationView;
    }
    return nil;
}

- (MyAnnotation *)annotationForTouchPoi:(MATouchPoi *)touchPoi{
    if (touchPoi == nil) {
        return nil;
    }
    MyAnnotation * ann = [[MyAnnotation alloc] init];
    ann.coordinate = touchPoi.coordinate;
    ann.title = touchPoi.name;
    return ann;
}

- (void)mapView:(MAMapView *)mapView didTouchPois:(NSArray *)pois{
    if (pois.count == 0) {
        return;
    }
    MyAnnotation * ann = [self annotationForTouchPoi:pois[0]];
    if (self.poiAnnotation) {
        [self.mapView removeAnnotation:self.poiAnnotation];
    }
    [self.mapView addAnnotation:ann];
    [self.mapView selectAnnotation:ann animated:YES];
    self.poiAnnotation = ann;
}

- (void)clearMapView
{
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    self.mapView.delegate = nil;
}

- (void)clearSearch
{
    
}

#pragma mark - Handle Action

- (void)returnAction
{
    
    [self clearMapView];
    
    [self clearSearch];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self returnAction];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(![CLLocationManager locationServicesEnabled]){
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"定位失败" message:@"请在手机设置中开启定位功能\n开启步骤:设置 > 隐私 > 位置 > 定位服务" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        self.mapView = nil;
        self.mapView.delegate = nil;
        return;
    }else{
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"定位失败" message:@"请在手机设置中开启定位功能\n开启步骤:设置 > 隐私 > 位置 > 定位服务下《问药》应用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            self.mapView = nil;
            self.mapView.delegate = nil;
            return;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
