//
//  NearStoreViewController.m
//  wenyao
//
//  Created by yang_wei on 14-10-2.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "NearMapViewController.h"
#import "MenuViewCell.h"
#import "FactoryMenuViewCell.h"
#import "Categorys.h"
#import "ZhPMethod.h"
#import "SVProgressHUD.h"
#import "NearStoreDetailViewController.h"
#import "NearStoreDetail1ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MJRefresh.h"
#import "AppDelegate.h"
#import "CusAnnotationView.h"

#define kSpanMake(x)         MACoordinateSpanMake(x, x)

#define K_500             0.03
#define K_1000            0.05
#define K_3000            0.07
#define K_5000            0.09


#define kDistance         0.5
#define FACTORYMENU_X   60
#define kCalloutViewMargin          -8
#define kWidth  21.f
#define kHeight 32.f

@interface NearMapViewController ()<MAMapViewDelegate, CLLocationManagerDelegate,AMapSearchDelegate,UITableViewDataSource,UITableViewDelegate,CusAnnotationViewDelegate,UIAlertViewDelegate>
{
    NSArray * distanceArr;
    NSArray * tagArr;
    BOOL disMenuIsShow;//距离选择菜单是否显示
    BOOL factoryMenuIsShow;//右侧药店列表是否显示
    NSMutableArray* annotationArray;
    NSInteger historyRow;
    NSInteger currentRow;
    UIButton *zoomOutButton;
    UIButton *zoomInButton;
    CGFloat mapViewZoomLevel;
    
//    NSInteger currentPage;
    //int i;
    NSTimer *time;
    double rangeSpan;
    double currentLatitudeDelta;
    
    NSArray * myDistacnce;
}
//地图相关
@property (nonatomic ,strong) MAMapView *mapView;

@property (nonatomic ,strong) UIImageView *zoomImageView;
@property (nonatomic ,strong) UIButton *localMeButton;
@property (nonatomic ,strong) NSTimer *time;

@property (nonatomic ,strong) AMapSearchAPI *mapSearchAPI;

@property (nonatomic ,strong) MAUserLocation *userLocation;
//按钮
@property (nonatomic ,strong) UIButton *distanceButton;
@property (nonatomic ,strong) UIButton *bgButton;
//tableView
@property (nonatomic ,strong) UITableView *disMenuView;
@property (nonatomic ,strong) UITableView *factoryMenu;

@property (nonatomic ,strong) NSMutableArray *storeDataSource;

@property (nonatomic, strong) MAPointAnnotation *poiAnnotation;

@property (nonatomic ,strong) AMapReGeocodeSearchResponse *response;

@property (nonatomic ,strong) NSMutableDictionary *dic;
@end

@implementation NearMapViewController
- (id)init{
    if (self = [super init]) {
        
        
    }
    return self;
}

- (void)footerRereshing
{
    [self loadDataWithDistance:kDistance];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)restartNetWork
{
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    i = 12;
    mapViewZoomLevel = 0;
    time = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getTime) userInfo:nil repeats:YES];
    historyRow = 1999;
    self.title = @"附近药房";
    self.storeDataSource = [NSMutableArray array];
    distanceArr = @[@"500米",@"1千米",@"3千米",@"5千米"];
    myDistacnce = @[@5000000,@2000000,@1000000,@500000,@300000,@200000,@100000,@50000,@30000,@10000,@5000,@2000,@1000,@500,@200,@100,@50,@25];
    tagArr = @[@500,@1000,@3000,@5000];
    rangeSpan = K_500;
    currentRow = 999;
//    currentPage = 1;
    //设置地图
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartNetWork) name:NETWORK_RESTART object:nil];
    if(app.currentNetWork != kNotReachable)
    {
        self.mapView = [[MAMapView alloc] init];
        self.view.frame = CGRectMake(0, 0, APP_W, APP_H - 64);
        //[self.mapView removeOverlays:self.mapView.overlays];
        //[self.mapView removeAnnotations:self.mapView.overlays];
        self.mapView.showsUserLocation = YES;
        
        self.mapView.frame = self.view.frame ;
        self.mapView.delegate = self;
        
        self.mapView.mapType = MAMapTypeStandard;
        self.mapView.touchPOIEnabled = NO;
        self.mapView.showsScale = YES;
        self.mapView.scaleOrigin = CGPointMake(10, 10);
        //self.mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
        self.mapView.distanceFilter = 100;
        [self.view addSubview:self.mapView];
        
    }else{
        [SVProgressHUD showErrorWithStatus:@"网络异常,无法加载地图信息" duration:DURATION_SHORT];
    }
    //设置地址反编码
    self.mapSearchAPI = [[AMapSearchAPI alloc] initWithSearchKey:[MAMapServices sharedServices].apiKey Delegate:self];
    
    //设置显示距离按钮
    self.distanceButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.distanceButton.backgroundColor = [UIColor blackColor];
    self.distanceButton.tag = 500;
    self.distanceButton.layer.masksToBounds = YES;
    self.distanceButton.layer.cornerRadius = 3;
    self.distanceButton.enabled = NO;
    self.distanceButton.titleLabel.font = FontB(14);
    [self.distanceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.distanceButton setFrame:CGRectMake(10, self.mapView.frame.size.height - 40, 75, 35)];
    [self.distanceButton addTarget:self action:@selector(distanceButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.distanceButton setTitle:@"500米" forState:UIControlStateNormal];
    //[self.mapView addSubview:self.distanceButton];
    
    //设置距离菜单
//    self.disMenuView = [[UITableView alloc] initWithFrame:CGRectMake(10, self.distanceButton.frame.origin.y, 75, 0) style:UITableViewStylePlain];
//    self.disMenuView.rowHeight = 35;
//    self.disMenuView.tag = 887;
//    self.disMenuView.delegate = self;
//    self.disMenuView.dataSource = self;
//    [self.mapView addSubview:self.disMenuView];
    disMenuIsShow = NO;
    factoryMenuIsShow = NO;
//    UIImage *zoomImage = [UIImage imageNamed:@"放大缩小.png"];
    UIImage *bigBgImage = [UIImage imageNamed:@"zoomOut.png"];
    UIImage *smallBgImage = [UIImage imageNamed:@"zoomIn.png"];
    
    self.zoomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(APP_W -bigBgImage.size.width*2-10, self.mapView.frame.size.height - 30, bigBgImage.size.width*2, bigBgImage.size.height)];
    self.zoomImageView.userInteractionEnabled = YES;
    [self.view addSubview:self.zoomImageView];
    
    
    zoomInButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [zoomInButton setFrame:CGRectMake(0, 0, smallBgImage.size.width, smallBgImage.size.height)];
    [zoomInButton addTarget:self action:@selector(zoomInButtonClick) forControlEvents:UIControlEventTouchUpInside];
    zoomInButton.backgroundColor = [UIColor clearColor];
    [zoomInButton setImage:[smallBgImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.zoomImageView addSubview:zoomInButton];
    
    zoomOutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [zoomOutButton setFrame:CGRectMake(zoomInButton.frame.origin.x + zoomInButton.frame.size.width, 0, bigBgImage.size.width, bigBgImage.size.height)];
    [zoomOutButton addTarget:self action:@selector(zoomOutButtonClick) forControlEvents:UIControlEventTouchUpInside];
    zoomOutButton.backgroundColor = [UIColor clearColor];
    [zoomOutButton setImage:[bigBgImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.zoomImageView addSubview:zoomOutButton];
    
    
    
    
    //设置显示当前按钮
    
    UIImage * localMeImage = [UIImage imageNamed:@"定位"];
    self.localMeButton= [[UIButton alloc] initWithFrame:RECT(10, self.mapView.frame.size.height - 50, localMeImage.size.width, localMeImage.size.height)];
    //localMeButton.alpha = 0.5;
    //localMeButton.layer.cornerRadius = 4;
    self.localMeButton.userInteractionEnabled = NO;
    [self.localMeButton setBackgroundImage:localMeImage forState:0];
    [self.localMeButton addTarget:self action:@selector(onLocalMeBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:self.localMeButton];
    
    self.bgButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.bgButton setFrame:self.mapView.bounds];
    self.bgButton.hidden = YES;
    self.bgButton.alpha = 0.3;
    [self.bgButton setBackgroundColor:[UIColor colorWithWhite:0.425 alpha:1.000]];
    [self.bgButton addTarget:self action:@selector(factoryMenuHidenAndShow) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:self.bgButton];
    
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"列表.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(factoryMenuHidenAndShow)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    self.factoryMenu = [[UITableView alloc] initWithFrame:CGRectMake(APP_W, 0, APP_W-FACTORYMENU_X, APP_H-NAV_H) style:UITableViewStylePlain];
    self.factoryMenu.tag = 888;
    self.factoryMenu.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.factoryMenu.rowHeight = 70;
    self.factoryMenu.delegate = self;
    self.factoryMenu.dataSource = self;
    [self.mapView addSubview:self.factoryMenu];
    
//    [self.factoryMenu addFooterWithTarget:self action:@selector(footerRereshing)];
//    self.factoryMenu.footerPullToRefreshText = @"上拉可以加载更多数据了";
//    self.factoryMenu.footerReleaseToRefreshText = @"松开加载更多数据了";
//    self.factoryMenu.footerRefreshingText = @"正在帮你加载中";
    
    
    UISwipeGestureRecognizer * swipeGestuer = [[UISwipeGestureRecognizer alloc]init];
    swipeGestuer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.factoryMenu addGestureRecognizer:swipeGestuer];
    [swipeGestuer addTarget:self action:@selector(factoryMenuHidenAndShow)];
    
    [self buttonDisEnabled];
    
}

- (void)buttonEnabled
{
    if (self.time) {
        [self.time invalidate];
    }
    self.localMeButton.userInteractionEnabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.zoomImageView.userInteractionEnabled = YES;
    self.mapView.userInteractionEnabled = YES;
}

- (void)buttonDisEnabled
{
    if (self.time) {
        [self.time invalidate];
    }
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.zoomImageView.userInteractionEnabled = NO;
    self.mapView.userInteractionEnabled = NO;
    
    self.time = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(buttonEnabled) userInfo:nil repeats:NO];
}

- (void)getTime{
//    
//    if (app.currentNetWork == kNotReachable)
//    {
//        i -= 1;
//    }
//    if(i == 0){
//        [time invalidate];
//        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
//        return;
//    }
}
#pragma mark ------定位距离按钮点击-----
- (void)distanceButtonClick{
    
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        return;
    }
    if (disMenuIsShow) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.1];
        self.disMenuView.frame = CGRectMake(10, self.distanceButton.frame.origin.y, 75, 0);
        [UIView commitAnimations];
        disMenuIsShow = NO;
    }else{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.1];
        self.disMenuView.frame = CGRectMake(10, self.distanceButton.frame.origin.y-2-35*4, 75, 35*4);
        [UIView commitAnimations];
        disMenuIsShow = YES;
    }
}

- (void)onLocalMeBtnTouched:(UIButton *)btn{
    [self buttonDisEnabled];
    if (self.userLocation) {
        [self.mapView setRegion:MACoordinateRegionMake(self.userLocation.coordinate, kSpanMake(rangeSpan)) animated:YES];
    }else{
        NSString * latitude = getHistoryConfig(@"latitude");
        NSString * longitude = getHistoryConfig(@"longitude");
        
        if (latitude != nil && [latitude doubleValue] > 0) {
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([latitude doubleValue],[longitude doubleValue]);
            [self.mapView setRegion:MACoordinateRegionMake(coordinate, kSpanMake(rangeSpan)) animated:YES];
        }
    }
}

- (void)zoomOutButtonClick{
    rangeSpan /= 1.2;
    rangeSpan /= 1.2;
    [self setMapRegion];
}

- (void)zoomInButtonClick{
    rangeSpan *= 1.2;
    rangeSpan *= 1.2;
    [self setMapRegion];
}

- (void)setMapRegion{
    CLLocationCoordinate2D centerLocation = [self.mapView convertPoint:CGPointMake(self.mapView.frame.size.width / 2, self.mapView.frame.size.height / 2) toCoordinateFromView:self.mapView];
    
    MACoordinateRegion region = MACoordinateRegionMake(centerLocation, MACoordinateSpanMake(rangeSpan, rangeSpan));
    [self.mapView setRegion:region animated:YES];
}

- (void)factoryMenuHidenAndShow{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    if (factoryMenuIsShow) {
        zoomInButton.hidden = NO;
        zoomOutButton.hidden = NO;
        self.bgButton.hidden = YES;
        [self.factoryMenu setFrame:CGRectMake(APP_W, 0, APP_W-FACTORYMENU_X, APP_H-NAV_H)];
        factoryMenuIsShow = NO;
        self.mapView.scrollEnabled       = YES;
        self.mapView.zoomEnabled         = YES;
        self.mapView.rotateEnabled       = YES;
        self.mapView.rotateCameraEnabled = YES;
    }else{
        zoomInButton.hidden = YES;
        zoomOutButton.hidden = YES;
        self.bgButton.hidden = NO;
        [self.factoryMenu setFrame:CGRectMake(FACTORYMENU_X, 0, APP_W-FACTORYMENU_X, APP_H-NAV_H)];
        factoryMenuIsShow = YES;
        self.mapView.scrollEnabled       = NO;
        self.mapView.zoomEnabled         = NO;
        self.mapView.rotateEnabled       = NO;
        self.mapView.rotateCameraEnabled = NO;
    }
    [UIView commitAnimations];
}

#pragma mark ------tableViewDelegate------
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView isEqual:self.disMenuView]){
        return 35.0f;
    }else {
        return 81.0f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:self.disMenuView]) {
        return distanceArr.count;
    }else if ([tableView isEqual:self.factoryMenu]){
        return self.storeDataSource.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:self.disMenuView]) {
//        static NSString * cellIdentifier = @"cellIdentifier";
//        MenuViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//        if (cell == nil) {
//            cell = [[NSBundle mainBundle] loadNibNamed:@"MenuViewCell" owner:self options:nil][0];
//            cell.titleLabel.font = Font(14);
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        }
//        cell.titleLabel.text = distanceArr[indexPath.row];
//        return cell;
    }else if ([tableView isEqual:self.factoryMenu]){
        static NSString * Identifier = @"Identifier";
        FactoryMenuViewCell * cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"FactoryMenuViewCell" owner:self options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSArray * arr = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J"];
        if (indexPath.row < 10) {
            cell.titleLabel.text = [NSString stringWithFormat:@"%@.%@",arr[indexPath.row],self.storeDataSource[indexPath.row][@"name"]];
        } else {
            cell.titleLabel.text = [NSString stringWithFormat:@"%@",self.storeDataSource[indexPath.row][@"name"]];
        }
        cell.addressLabel.text = self.storeDataSource[indexPath.row][@"address"];
        
        NSString * distance = self.storeDataSource[indexPath.row][@"distance"];
        CGFloat dis = [distance floatValue];
        if (dis > 20) {
            distance = @"超出20";
        }
        cell.distanceLabel.text = [NSString stringWithFormat:@"%@KM",distance];
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 81.0 - 0.5, cell.frame.size.width, 0.5)];
        [separator setBackgroundColor:UIColorFromRGB(0xdbdbdb)];
        [cell.contentView addSubview:separator];
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:self.disMenuView]) {
//--------------------------------------------------------------------------------------------------
//                                      不要删除这段注释
//--------------------------------------------------------------------------------------------------
//        currentRow = indexPath.row;
////        currentPage = 1;
//        [self.storeDataSource removeAllObjects];
//        //切换字体颜色
//        if (currentRow != historyRow)
//        {
//            NSIndexPath * currIndex = [NSIndexPath indexPathForRow:currentRow
//                                                         inSection:0];
//            NSIndexPath * historyIndex = [NSIndexPath indexPathForRow:historyRow
//                                                            inSection:0];
//            MenuViewCell * cell = (MenuViewCell *)[tableView cellForRowAtIndexPath:currIndex];
//            MenuViewCell * hisCell = (MenuViewCell *)[tableView cellForRowAtIndexPath:historyIndex];
//            cell.titleLabel.textColor  = UICOLOR(60, 183, 21);
//            hisCell.titleLabel.textColor = [UIColor blackColor];
//            historyRow = currentRow;
//        }
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        [self.storeDataSource removeAllObjects];
//        
//        self.distanceButton.tag = [tagArr[indexPath.row] integerValue];
//        [self distanceButtonClick];
//        [self.distanceButton setTitle:distanceArr[indexPath.row] forState:UIControlStateNormal];
//        
//        if (currentRow == 0) {//5000
//            rangeSpan = K_500;
//        }else
//            if (currentRow == 1)//3000
//            {
//                rangeSpan = K_1000;
//            }else
//                if (currentRow == 2)//1000
//                {
//                    rangeSpan = K_3000;
//                }else{//500
//                    rangeSpan = K_5000;
//                }
//        
//        if (self.userLocation) {
//            for(id annotation in self.mapView.annotations) {
//                if([annotation isKindOfClass:[MAUserLocation class]]) {
//                    continue;
//                }
//                [self.mapView removeAnnotation:annotation];
//            }
//            [self.mapView setRegion:MACoordinateRegionMake(self.userLocation.coordinate, kSpanMake(rangeSpan)) animated:YES];
//            [self reGoecodeSearchData];
//            
//            
//        }else{
//            [self loadDataWithDistance:kDistance];
//        }
    }else if ([tableView isEqual:self.factoryMenu]){
        
        NearStoreDetail1ViewController * nearStoreDetail = [[NearStoreDetail1ViewController alloc] initWithNibName:@"NearStoreDetail1ViewController" bundle:nil];
        
        nearStoreDetail.store = self.storeDataSource[indexPath.row];
        nearStoreDetail.drugStoreCode = self.storeDataSource[indexPath.row][@"code"];
        
        [self.navigationController pushViewController:nearStoreDetail animated:YES];
        
        //        NearStoreDetailViewController * nearStoreDetail = [[NearStoreDetailViewController alloc] init];
        //
        //        nearStoreDetail.store = self.storeDataSource[indexPath.row];
        //        nearStoreDetail.drugStoreCode = self.storeDataSource[indexPath.row][@"code"];
        //        [self.navigationController pushViewController:nearStoreDetail animated:YES];
    }
    
}

#pragma mark -------地图定位回调---------

-(void)mapView:(MAMapView*)mapView didUpdateUserLocation:(MAUserLocation*)userLocation updatingLocation:(BOOL)updatingLocation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //下面为定位回调数据操作
    if (!isEqualCoordinate(self.userLocation.coordinate, userLocation.coordinate, 0.001)) {
        self.userLocation = userLocation;
        setHistoryConfig(@"latitude", [NSString stringWithFormat:@"%f",userLocation.coordinate.latitude]);
        setHistoryConfig(@"longitude", [NSString stringWithFormat:@"%f",userLocation.coordinate.longitude]);
        [self.mapView setRegion:MACoordinateRegionMake(self.userLocation.coordinate, kSpanMake(K_500)) animated:YES];
        [self reGoecodeSearchData];
    }else{
        if(app.currentNetWork == kNotReachable) {
            //[self.mapView setRegion:MACoordinateRegionMake(CLLocationCoordinate2DMake(0.0, 0.0), kSpanMake(K_500)) animated:YES];
        }
    }
}

//定位失败
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"定位失败!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    //alertView.delegate = self;
    //alertView.tag = 1990;
    [alertView show];
   
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1990) {
        if (buttonIndex == 0) {
            NSString *latitude = getHistoryConfig(@"latitude");
            NSString * longitude = getHistoryConfig(@"longitude");
            if (latitude.length == 0 || longitude.length == 0) {
                return;
            }else{
                NSString * latitude = getHistoryConfig(@"latitude");
                NSString * longitude = getHistoryConfig(@"longitude");
                
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([latitude doubleValue],[longitude doubleValue]);
                [self.mapView setRegion:MACoordinateRegionMake(coordinate, kSpanMake(K_500)) animated:YES];
                [self loadDataWithDistance:kDistance];
            }
        }
    }
}

/*
 myDistacnce = @[@5000000,@2000000,@1000000,@500000,@300000,@200000,@100000,@50000,@30000,@10000,@5000,@2000,@1000,@500,@200,@100,@50,@25];
 */
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (mapView.zoomLevel != mapViewZoomLevel) {
        mapViewZoomLevel = mapView.zoomLevel;
        NSLog(@"mapView.zoomLevel = %f",mapViewZoomLevel);
        
        NSLog(@"最大缩放级别 = %f",mapView.maxZoomLevel);
        NSLog(@"最小缩放级别 = %f",mapView.minZoomLevel);
        
        int level = round(mapViewZoomLevel);
        
        
        
        if (level < 12 || level > 17) {
            NSLog(@"mapView.level int = %d",level);
            return;
        }
        NSNumber * distanceLevel = myDistacnce[level-3];
        float dis = [distanceLevel floatValue]/1000;
        [self buttonDisEnabled];
        [self loadDataWithDistance:dis];
    }
}





- (void)backToPreviousController:(id)sender
{
    [time invalidate];
    self.mapView.showsUserLocation = NO;
    [self.mapView removeFromSuperview];
    self.mapView.delegate = nil;
    self.mapSearchAPI.delegate = nil;
    _mapView = nil;
    time = nil;
    [SVProgressHUD dismiss];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    
}

- (void)reGoecodeSearchData{
    //逆地址解析
    CLLocation * location = self.userLocation.location;
    AMapReGeocodeSearchRequest * request = [[AMapReGeocodeSearchRequest alloc] init];
    request.searchType = AMapSearchType_ReGeocode;
    request.requireExtension = YES;
    
    AMapGeoPoint * point = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    request.radius = self.distanceButton.tag;
    request.location = point;
    [self.mapSearchAPI AMapReGoecodeSearch:request];
}

//逆地理编码成功
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    self.response = response;
    [self loadDataWithDistance:kDistance];
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    
}

#pragma mark --------定位成功后,加载数据--------

- (void)loadDataWithDistance:(CGFloat)distance{
    
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:DURATION_SHORT];
        return;
    }
    
    NSString *city = nil;
    NSString *province = nil;
    NSString *county = nil;
    
    if (self.userLocation) {//如果定位成功
        AMapAddressComponent * addressComponent = self.response.regeocode.addressComponent;
        city = addressComponent.city;
        province = addressComponent.province;
        county = addressComponent.district;
    }else{//否则加载本地数据
        city = getHistoryConfig(@"city");
        province = getHistoryConfig(@"province");
        county = getHistoryConfig(@"county");
    }
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    if (city.length > 0) {
        setting[@"city"] = city;
        setting[@"province"] = province;
        setting[@"county"] = county;
    }else{
        return;
    }
    
    //查询省编码
    [[HTTPRequestManager sharedInstance] locationEncodeWithParam:setting
                                                   completionSuc:^(id resultObj)
     {
         if ([resultObj[@"result"] isEqualToString:@"OK"]) {
             setHistoryConfig(@"province", province);
             setHistoryConfig(@"city", city);
             setHistoryConfig(@"county", county);
             //请求参数
             NSMutableDictionary * setting = [NSMutableDictionary dictionary];
             setting[@"province"]   = resultObj[@"body"][@"provinceCode"];
             setting[@"city"]        = resultObj[@"body"][@"cityCode"];
             setting[@"currPage"]    = @1;
             setting[@"pageSize"]    = @0;
             if (distance == 0) {
                 setting[@"distance"] = @(0.5);
             }else{
                 setting[@"distance"] = @(distance);
             }
             float longitude = 0;
             float latitude = 0;
             if (self.userLocation) {
                 longitude  = self.userLocation.location.coordinate.longitude;
                 latitude  = self.userLocation.location.coordinate.latitude;
             }else{
                 NSString * latitudeStr = getHistoryConfig(@"latitude");
                 NSString * longitudeStr = getHistoryConfig(@"longitude");
                 latitude = [latitudeStr doubleValue];
                 longitude = [longitudeStr doubleValue];
             }
             
             
             setting[@"longitude"]   = [NSNumber numberWithFloat:longitude];
             setting[@"latitude"]    = [NSNumber numberWithFloat:latitude];
             
             //加载药店
             [[HTTPRequestManager sharedInstance] fetchDefaultPharmacy:setting completionSuc:^(id resultObj) {
                 if ([resultObj[@"result"] isEqualToString:@"OK"])
                 {
                     [self.storeDataSource removeAllObjects];
                     [self.storeDataSource addObjectsFromArray:resultObj[@"body"][@"data"]];
                     
                     //添加标注
                     NSArray * arr = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J"];
                     for(id annotation in self.mapView.annotations) {
                         if(![annotation isKindOfClass:[MyAnnotation class]]) {
                             continue;
                         }
                        [self.mapView removeAnnotation:annotation];
                     }
                     //优先显示最近的10个
                     NSMutableArray *storeAnnArr = [NSMutableArray arrayWithArray:[self.storeDataSource copy]];
                     //为前10个元素(或小于10)加标注
                     NSInteger temp = storeAnnArr.count > arr.count ? arr.count : storeAnnArr.count;
                     //设置范围 前10个元素(或小于10)
                     NSRange range = NSMakeRange(0, temp);
                     NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                     //取出前10个元素(或小于10)
                     NSMutableArray *frontTenArr = [NSMutableArray arrayWithArray:[storeAnnArr objectsAtIndexes:indexSet]];
                     
                     for (int i = 0; i < temp; i++) {
                         NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:frontTenArr[i]];
                         [dic setObject:arr[i] forKey:@"sortLetter"];
                         [frontTenArr replaceObjectAtIndex:i withObject:dic];
                     }
                     
                     if (storeAnnArr.count > arr.count) {
                         [storeAnnArr removeObjectsAtIndexes:indexSet];
                         [storeAnnArr addObjectsFromArray:frontTenArr];
                     }else{
                         [storeAnnArr replaceObjectsAtIndexes:indexSet withObjects:frontTenArr];
                     }
                     
                     for (int j= 0; j < storeAnnArr.count; j++) {
                         NSMutableDictionary * dic = [[NSMutableDictionary alloc] initWithDictionary:[storeAnnArr objectAtIndex:j]];
                         CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([dic[@"latitude"] floatValue], [dic[@"longitude"]floatValue]);
                         [self addAnnotationWithCooordinate:coordinate withInfomation:dic];
                     }
                     [self buttonEnabled];
                     [self.factoryMenu reloadData];
                     [self.factoryMenu footerEndRefreshing];
                 }
             } failure:^(id failMsg) {
                 [self.factoryMenu footerEndRefreshing];
                 NSLog(@"%@",failMsg);
             }];
             
         }
     } failure:^(id failMsg) {
         NSLog(@"%@",failMsg);
     }];
}

- (void)rightButtonClick:(MyAnnotationButton *)button{
    
}

- (void)callOutViewStore:(NSDictionary *)store
{
    NearStoreDetail1ViewController * nearStoreDetail = [[NearStoreDetail1ViewController alloc] initWithNibName:@"NearStoreDetail1ViewController" bundle:nil];
    nearStoreDetail.store = store;
    nearStoreDetail.drugStoreCode = store[@"code"];
    [self.navigationController pushViewController:nearStoreDetail animated:YES];
}

#pragma mark --------定制大头针-----------


-(void)addAnnotationWithCooordinate:(CLLocationCoordinate2D)coordinate withInfomation:(NSDictionary *)store;
{
    MyAnnotation *annotation = [[MyAnnotation alloc] init];
    annotation.coordinate = coordinate;
    annotation.title    = @"AutoNavi";
    annotation.storeDic = store;
    annotation.subtitle = @"CustomAnnotationView";
    [annotationArray addObject:annotation];
    [self.mapView addAnnotation:annotation];
    
}


#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    if(views.count > 0)
    {
        MAAnnotationView *annotationView = views[0];
        if ([annotationView isKindOfClass:[CusAnnotationView class]]) {
            
        }
        
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        NSDictionary * storeDic  = ((MyAnnotation *)annotation).storeDic;
        static NSString *customReuseIndetifier = @"customReuseIndetifier";
        
        CusAnnotationView *annotationView = (CusAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[CusAnnotationView alloc] initWithAnnotation:annotation
                                                           reuseIdentifier:customReuseIndetifier];
        }
        
        // must set to NO, so we can show the custom callout view.
        annotationView.canShowCallout   = NO;
        annotationView.delegate = self;
        annotationView.calloutOffset    = CGPointMake(0, -5);
        
        NSString *sortLetter = storeDic[@"sortLetter"];
        if (sortLetter.length > 0) {
            annotationView.annType = 1;
        }else{
            annotationView.annType = 2;
        }
        annotationView.portrait         = [UIImage imageNamed:@"hema.png"];
        annotationView.name             = @"河马";
        annotationView.tagLabel.text = sortLetter;
        annotationView.storeDic = storeDic;
        return annotationView;
    }
    
    return nil;
}

#pragma mark -------销毁地图--------

- (void)clearMapView
{
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    self.mapView.delegate = nil;
}

- (void)clearSearch
{
    self.mapSearchAPI.delegate = nil;
}

- (void)returnAction
{
    
    [self clearMapView];
    
    [self clearSearch];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end

#pragma mark ------定义Annotation------
@implementation MyAnnotation

- (id)init{
    if (self = [super init]) {
    }
    return self;
}

@end



@implementation MyAnnotationButton



@end



@implementation MyAnnotationView

#pragma mark - Override


#pragma mark - Life Cycle

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self){
        
        self.bounds = CGRectMake(0.f, 0.f, kWidth, kHeight);
        self.backgroundColor = [UIColor clearColor];
        UIImage * redImage = [UIImage imageNamed:@"point_red.png"];
        //self.bounds = RECT(0, 0, redImage.size.width*2, redImage.size.height*2);
        //[self setImage:redImage];
        self.iconView = [[UIImageView alloc] initWithFrame:RECT(0, 0, redImage.size.width*2, redImage.size.height*2)];
        self.iconView.userInteractionEnabled = YES;
        [self.iconView setImage:redImage];
        [self addSubview:self.iconView];
        
        self.tagLabel = [[UILabel alloc] initWithFrame:RECT(0, 0, redImage.size.width*2, redImage.size.height*2-11)];
        self.tagLabel.backgroundColor = [UIColor clearColor];
        self.tagLabel.text = @"A";
        self.tagLabel.font = FontB(15);
        self.tagLabel.textColor = [UIColor whiteColor];
        self.tagLabel.textAlignment = NSTextAlignmentCenter;
        [self.iconView addSubview:self.tagLabel];
        
        /* Create portrait image view and add to view hierarchy. */
        
        /* Create name label. */
    }
    
    return self;
}


@end
