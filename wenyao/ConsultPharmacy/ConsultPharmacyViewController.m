//
//  ConsultPharmacyViewController.m
//  wenyao
//
//  Created by xiezhenghong on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "ConsultPharmacyViewController.h"
#import "ConsultPharmacyTableViewCell.h"
#import "PharmacyStoreViewController.h"
#import "ComboxView.h"
#import "RightAccessButton.h"
#import "HTTPRequestManager.h"
#import "MJRefresh.h"
#import "CityListViewController.h"
#import "XHDemoWeChatMessageTableViewController.h"
#import "UIImageView+WebCache.h"

#import "LLARingSpinnerView.h"
#import "SBJson.h"

#import "LoginViewController.h"
#import "DACircularProgressView.h"
#import "SVProgressHUD.h"
#import "ConsultPharmacySearchViewController.h"

#import "Location.h"


@interface ConsultPharmacyViewController ()<ComboxViewDelegate,
MAMapViewDelegate,AMapSearchDelegate,UIAlertViewDelegate,UIAlertViewDelegate,UISearchBarDelegate>
{
    ComboxView                  *leftComboxView;
    ComboxView                  *rightComboxView;
    ComboxView                  *centerComboxView;
    
    RightAccessButton           *leftButton;
    RightAccessButton           *rightButton;
    RightAccessButton           *centerButton;
    
    
    NSArray                     *leftMenuItems;
    NSArray                     *rightMenuItems;
    NSArray                     *centerMenuItems;
    
    NSUInteger                  currentPage;
    BOOL                        isShowFilter;
    NSUInteger                  leftIndex;
    NSUInteger                  rightIndex;
    NSUInteger                  centerIndex;
    
    NSMutableDictionary         *cacheSetting;
//    MAMapView                   *amapView;
//    AMapSearchAPI               *searchAPI;
    CLLocation                  *selfCurrentLocation;
    NSDictionary                *cityList;
    AMapReGeocode               *__reGeocode;
    UISearchBar                 *searchBar;
    UIBarButtonItem             *searchBarButton;
    
    UIBarButtonItem *rightBarButton;
    
}
@property (nonatomic, strong) NSString          *lastCityName;
@property (nonatomic, strong) NSString          *currentCityName;
//showType为1区域范围内       2为全国范围内
@property (nonatomic, assign) NSUInteger               showType;
@property (nonatomic, strong) NSString                 *selectedCityName;
@property (nonatomic, strong) NSMutableArray           *dataSource;
@property (nonatomic, strong) NSMutableArray            *filterDataSource;
@property (nonatomic, assign) BOOL                      resetEnable;
@property (nonatomic, strong) UILabel                   *locationWatingLabel;
@property (nonatomic, strong) UIActivityIndicatorView   *watingIndicator;
@property (nonatomic, strong) LLARingSpinnerView        *spinnerView;

@end

@implementation ConsultPharmacyViewController

@synthesize tableView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
    }
    CGRect rect = self.view.frame;
    rect.size.height -= 64;
    self.view.frame = rect;
    self.dataSource = [NSMutableArray arrayWithCapacity:15];
    self.filterDataSource = [NSMutableArray arrayWithCapacity:15];
    currentPage = 1;
    leftMenuItems = @[@"全城",@"1千米",@"3千米",@"5千米",@"10千米"];
    rightMenuItems = @[@"不限",@"已开通服务",@"24H药房",@"医保定点",@"免费送药"];
    centerMenuItems=@[@"不限",@"人气最高",@"服务最佳"];
    
    searchBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"搜索"] style:UIBarButtonItemStylePlain target:self action:@selector(searchBarButtonClick)];
    
    [self setupTableView];
    self.showType = 1;
    //[self setupHeaderView];
    //[self setupSearchBar];
    [self setupFooterView];
    UILabel *titleText = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 50, 50)];
    
    titleText.backgroundColor = [UIColor clearColor];
    
    titleText.textColor=[UIColor whiteColor];
    
    [titleText setFont:[UIFont boldSystemFontOfSize:18.0]];
    
    [titleText setText:@"附近药房"];
    
    self.navigationItem.titleView=titleText;
    
    if (app.currentNetWork != kNotReachable && [Location locationServicesAvailable]) {
        [self resetLocation:nil];
        
    }else{
        [self.spinnerView stopAnimating];
        self.dataSource = [app.cacheBase selectAllStoreList];
        
        if(self.dataSource.count == 0) {
            [SVProgressHUD showErrorWithStatus:@"定位失败" duration:0.8];
        }
        [self.tableView reloadData];
        NSString *cityName = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_CITY];
        NSString *formatAddress = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_FORMAT_ADDRESS];
        if([cityName hasSuffix:@"市"]){
            cityName = [cityName substringToIndex:cityName.length - 1];
        }
        if(!cityName || [cityName isEqualToString:@""])
        {
            cityName = @"全部";
        }
        rightBarButton = [[UIBarButtonItem alloc] initWithTitle:cityName style:UIBarButtonItemStylePlain target:self action:@selector(changeCity:)];
        self.navigationItem.rightBarButtonItems = @[rightBarButton,searchBarButton];
        self.locationWatingLabel.text = formatAddress;
        if(!formatAddress) {
            self.locationWatingLabel.text = @"定位失败";
        }
        self.showType = 2;
        [self setupHeaderView];
    }
}


- (void)setupTableView
{
    CGRect rect = self.view.frame;
    rect.size.height -= 30 + 38;
    rect.origin.y = 38;
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
    
    __weak typeof (self) weakSelf = self;
//    [self.tableView addHeaderWithCallback:^{
//        if(weakSelf.showType == 1) {
//            [weakSelf queryRegionWideWithFlag:NO];
//        }else{
//            [weakSelf queryNationwideWithFlag:NO];
//        }
//    }];
    
   
}

- (void)resetLocation:(id)sender
{
    [self.spinnerView startAnimating];
    if (![Location locationServicesAvailable]) {
        [SVProgressHUD showErrorWithStatus:@"定位失败" duration:DURATION_SHORT];
        [self.spinnerView stopAnimating];
        return;
    }
    
    [[Location sharedInstance] requetWithReGoecode:LocationCreate timeout:100 block:^(CLLocation *currentLocation, AMapReGeocodeSearchResponse *response, LocationStatus status) {
        [self.spinnerView stopAnimating];
        NSString *address = nil;
        if (status == LocationRegeocodeSuccess) {
            
            CGFloat localLongitude = [[[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_LONGITUDE] floatValue];
            if (!localLongitude || localLongitude == 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_UPDATE_ADDRESS object:nil];
            }
            __reGeocode = [response regeocode];
            selfCurrentLocation = currentLocation;
            //定位成功
            NSString *currentCity = [[[response regeocode] addressComponent] city];
            NSString *province = [[[response regeocode] addressComponent] province];
            if(!currentCity || [currentCity isEqualToString:@""])
            {
                _currentCityName = province;
            }else{
                _currentCityName = currentCity;
            }
            if (currentCity && ![currentCity isEqualToString:@""]) {
                if (!province) {
                    province = @"";
                }
                
                NSMutableDictionary *setting = [NSMutableDictionary dictionary];
                setting[@"province"] = province;
                setting[@"city"] = currentCity;
                
                [[HTTPRequestManager sharedInstance] checkOpenCity:setting completion:^(id resultObj) {
                    if([resultObj[@"result"] isEqualToString:@"OK"])
                    {
                        if([resultObj[@"body"][@"open"] integerValue] == 1) {
                            //已开通,开始判断是否和上次定位是否一致
                            //已开通
                            _lastCityName = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_CITY];
                            if (currentCity && _lastCityName && ![currentCity isEqualToString:_lastCityName]) {
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"定位显示当前您在%@，是否为您从%@切换到%@？",currentCity,_lastCityName,currentCity] delegate:self cancelButtonTitle:@"不用了" otherButtonTitles:@"切换", nil];
                                alertView.tag = 1990;
                                [alertView show];
                            }else{
                                if([[response regeocode] formattedAddress] != nil){
                                    [app cacheLastLocationInformation:currentCity province:province formatterAddress:[[response regeocode] formattedAddress] location:selfCurrentLocation];
                                }else{
                                    [app cacheLastLocationInformation:currentCity location:selfCurrentLocation];
                                }
                                [self queryCityList];
                            }
                        }else{
                            //未开通
                            [self queryCityList];
                        }
                    }else{
                        [self queryCityList];
                    }
                } failure:^(id failMsg) {
                    [self queryCityList];
                }];
                
                
            }else{
                [self queryCityList];
            }
            
            address = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_FORMAT_ADDRESS];
            
        }else{
            //定位失败
            address = @"定位失败";
            NSNumber *latitude = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_LATITUDE];
            NSNumber *longitude = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_LONGITUDE];
            
            selfCurrentLocation = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
            [self.spinnerView stopAnimating];
            self.locationWatingLabel.text = @"定位失败";
            //[self queryRegionWideWithFlag:NO];
        }
        self.locationWatingLabel.text = address;
        self.tableView.footerPullToRefreshText = @"上拉可以刷新";
        self.tableView.footerReleaseToRefreshText = @"松开刷新了";
        self.tableView.footerRefreshingText = @"正在刷新中";
        self.tableView.headerPullToRefreshText = @"下拉可以刷新";
        self.tableView.headerReleaseToRefreshText = @"松开刷新了";
        self.tableView.headerRefreshingText = @"正在刷新中";
    }];
    
    
}

- (void)setupFooterView
{
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 30 , APP_W, 30)];
    [container setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
    
    self.spinnerView = [[LLARingSpinnerView alloc] initWithFrame:CGRectMake(290, 6, 20, 20)];
    [self.spinnerView setHidesWhenStopped:NO];
    self.spinnerView.tintColor = [UIColor colorWithRed:250/255.0f green:250/255.0f blue:250/255.0f alpha:1.0f];
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setBackgroundColor:[UIColor clearColor]];
    clearButton.frame = CGRectMake(280, 0, 40, 30);
    [clearButton addTarget:self action:@selector(resetLocation:) forControlEvents:UIControlEventTouchDown];
    self.locationWatingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, 260, 18)];
    self.locationWatingLabel.text = @"正在定位";
    self.locationWatingLabel.textColor = [UIColor whiteColor];
    self.locationWatingLabel.font = [UIFont systemFontOfSize:13.0];
    
    [container addSubview:self.locationWatingLabel];
    [container addSubview:self.spinnerView];
    [self.spinnerView startAnimating];
    [container addSubview:clearButton];
    [self.view addSubview:container];

}

- (void)setupSearchBar
{
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, APP_W, 40)];
    self.tableView.tableHeaderView = searchBar;
    searchBar.delegate = self;
    searchBar.placeholder = @"搜索药店";
    [self.tableView setFrame:RECT(0, 0, APP_W, APP_H-NAV_H-STATUS_H)];
}

- (void)setupHeaderView
{
    UIImageView *headerView = nil;
    if(![self.view viewWithTag:1008])
    {
        headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 38)];
        headerView.tag = 1008;
        headerView.userInteractionEnabled = YES;
        [headerView setImage:[UIImage imageNamed:@"菜单下拉背景new.png"]];
        
        leftButton = [[RightAccessButton alloc] initWithFrame:CGRectMake(0, 0, APP_W / 3.0, 38)];
        [headerView addSubview:leftButton];
        rightButton = [[RightAccessButton alloc] initWithFrame:CGRectMake(APP_W / 3.0, 0, APP_W / 3.0, 38)];
        [headerView addSubview:rightButton];
        centerButton = [[RightAccessButton alloc] initWithFrame:CGRectMake(APP_W*2 / 3.0, 0, APP_W / 3.0, 38)];
        [headerView addSubview:centerButton];
        
        UIImageView *accessView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 6)];
        [accessView1 setImage:[UIImage imageNamed:@"arrDown.png"]];
        UIImageView *accessView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 6)];
        [accessView2 setImage:[UIImage imageNamed:@"arrDown.png"]];
        UIImageView *accessView3 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 6)];
        [accessView3 setImage:[UIImage imageNamed:@"arrDown.png"]];

        
        leftButton.accessIndicate = accessView1;
        rightButton.accessIndicate = accessView2;
        centerButton.accessIndicate=accessView3;
        [leftButton setCustomColor:UIColorFromRGB(0x666666)];
        [rightButton setCustomColor:UIColorFromRGB(0x666666)];
        [centerButton setCustomColor:UIColorFromRGB(0x666666)];
        
        [leftButton setButtonTitle:@"全城"];
        [rightButton setButtonTitle:@"不限"];
        [centerButton setButtonTitle:@"不限"];
        
        [rightButton addTarget:self action:@selector(showRightTable:) forControlEvents:UIControlEventTouchDown];
        [leftButton addTarget:self action:@selector(showLeftTable:) forControlEvents:UIControlEventTouchDown];
        [centerButton addTarget:self action:@selector(showCenterTable:) forControlEvents:UIControlEventTouchDown];
        
        leftComboxView = [[ComboxView alloc] initWithFrame:CGRectMake(0, 38, 320, [leftMenuItems count]*44)];
        leftComboxView.delegate = self;
        leftComboxView.comboxDeleagte = self;
        rightComboxView = [[ComboxView alloc] initWithFrame:CGRectMake(0, 38, 320, [rightMenuItems count]*44)];
        rightComboxView.delegate = self;
        rightComboxView.comboxDeleagte = self;
        centerComboxView=[[ComboxView alloc] initWithFrame:CGRectMake(0, 38, 320, [centerMenuItems count]*44)];
        centerComboxView.delegate=self;
        centerComboxView.comboxDeleagte=self;
        
        leftIndex = 0;
        rightIndex = 0;
        centerIndex = 0;
    }else{
        headerView = (UIImageView *)[self.view viewWithTag:1008];
    }
    
    CGRect rect = self.view.frame;
    if(self.showType == 2)
    {
        [[self.view viewWithTag:1008] removeFromSuperview];
        rect.size.height -= 30;
        rect.origin.y = 0;
        self.tableView.frame = rect;
    
    }else{
        [self.view addSubview:headerView];
        rect.size.height -= 30 + 38;
        rect.origin.y = 38;
        self.tableView.frame = rect;
    }
}

- (void)hiddenTableViewHeader
{
    self.tableView.tableHeaderView = nil;
}

- (void)showLeftTable:(id)sender
{
    [rightButton changeArrowDirectionUp:NO];
    rightButton.isToggle = NO;
    [rightComboxView dismissView];
    
    [centerButton changeArrowDirectionUp:NO];
    centerButton.isToggle = NO;
    [centerComboxView dismissView];
    
    
    
    if(leftButton.isToggle) {
        [leftComboxView dismissView];
        [leftButton changeArrowDirectionUp:NO];
    }else{
        [leftComboxView showInView:self.view];
        [leftButton changeArrowDirectionUp:YES];
        leftButton.isToggle = YES;
    }
}

- (void)showRightTable:(id)sender
{
    [leftButton changeArrowDirectionUp:NO];
    leftButton.isToggle = NO;
    [leftComboxView dismissView];
    [centerButton changeArrowDirectionUp:NO];
    centerButton.isToggle = NO;
    [centerComboxView dismissView];

    
    if(rightButton.isToggle) {
        [rightComboxView dismissView];
        [rightButton changeArrowDirectionUp:NO];
    }else{
        [rightComboxView showInView:self.view];
        [rightButton changeArrowDirectionUp:YES];
        rightButton.isToggle = YES;
    }
    
    
}


- (void)showCenterTable:(id)sender
{
    [leftButton changeArrowDirectionUp:NO];
    leftButton.isToggle = NO;
    [leftComboxView dismissView];
    [rightButton changeArrowDirectionUp:NO];
    rightButton.isToggle = NO;
    [rightComboxView dismissView];
    
    if(centerButton.isToggle) {
        [centerComboxView dismissView];
        [centerButton changeArrowDirectionUp:NO];
    }else{
        [centerComboxView showInView:self.view];
        [centerButton changeArrowDirectionUp:YES];
        centerButton.isToggle = YES;
    }
    
    
}



- (void)comboxViewDidDisappear:(ComboxView *)comboxView
{
    if([comboxView isEqual:rightComboxView]){
        [rightButton changeArrowDirectionUp:NO];
        rightButton.isToggle = NO;
    }
    else if([comboxView isEqual:centerComboxView]){
        [centerButton changeArrowDirectionUp:NO];
        centerButton.isToggle = NO;
    }
    else{
        leftButton.isToggle = NO;
        [leftButton changeArrowDirectionUp:NO];
    }
}



- (void)searchBarButtonClick
{
    ConsultPharmacySearchViewController *consultPharmacySearchViewController = [[ConsultPharmacySearchViewController alloc] init];
    if([self.locationWatingLabel.text isEqualToString:@"定位失败"]) {
        consultPharmacySearchViewController.locationStatus = NO;
    }else{
        consultPharmacySearchViewController.locationStatus = YES;
    }
    
    [self.navigationController pushViewController:consultPharmacySearchViewController animated:NO];
}

- (void)changeCity:(id)sender
{

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if(alertView.tag == 101)
    {
        //切换全国定位
        [userDefault setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%@%@",APP_ALARM_NATIONWIDE,app.configureList[APP_PASSPORTID_KEY]]];
        [userDefault synchronize];
        
        if (!rightBarButton) {
            rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"全部" style:UIBarButtonItemStylePlain target:self action:@selector(changeCity:)];
        }
        self.navigationItem.rightBarButtonItems = @[rightBarButton,searchBarButton];
        [app.cacheBase updateCitySelectedStatus:@""];
        
        [self queryNationwideWithFlag:NO];
    }else if(alertView.tag == 102){
        NSString *currentCityName = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_CITY];
        if([currentCityName hasSuffix:@"市"]){
            currentCityName = [currentCityName substringToIndex:currentCityName.length - 1];
        }
        if(buttonIndex == 1)
        {
            _selectedCityName = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_CITY];
            [app.cacheBase updateCitySelectedStatus:_selectedCityName];
            [userDefault setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%@",currentCityName]];
        }else{
            
            [userDefault setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%@",currentCityName]];
        }
        [userDefault synchronize];
        [self queryCityList];
    }else if (alertView.tag == 1990)
    {
        if (buttonIndex == 1) {
            //切换到当前城市
            [app cacheLastLocationInformation:_currentCityName province:[[__reGeocode addressComponent] province] formatterAddress:[__reGeocode formattedAddress] location:selfCurrentLocation];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_UPDATE_ADDRESS object:nil];
            if (!rightBarButton) {
                rightBarButton = [[UIBarButtonItem alloc] initWithTitle:_currentCityName style:UIBarButtonItemStylePlain target:self action:@selector(changeCity:)];
            }
            self.navigationItem.rightBarButtonItems = @[rightBarButton,searchBarButton];
            [self queryCityList];
        }else{
            [self queryCityList];
        }
        
    }
}

- (void)cacheCityList
{
    [app.cacheBase deleteCityList];
    NSArray *allKeys = [cityList allKeys];
    for(NSString *key in allKeys)
    {
        for(NSDictionary *cityValue in cityList[key])
        {
            NSString *city = cityValue[@"city"];
            NSString *cityName = cityValue[@"cityName"];
            NSString *code = cityValue[@"code"];
            NSString *cityId = cityValue[@"id"];
            NSNumber *open = cityValue[@"open"];
            NSString *province = cityValue[@"province"];
            NSString *provinceName = cityValue[@"provinceName"];
            NSString *remark = cityValue[@"remark"];
            [app.cacheBase insertIntoCityList:cityId province:province provinceName:provinceName city:city cityName:cityName open:[NSString stringWithFormat:@"%@",open] remark:remark code:code];
        }
    }
}

- (void)queryCityList
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    [[HTTPRequestManager sharedInstance] queryOpenCity:setting completion:^(id resultObj) {
        [self.spinnerView stopAnimating];
        if([resultObj[@"result"] isEqualToString:@"OK"])
        {
            cityList = resultObj[@"body"];
            NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"Documents/%@",@"cityList.plist"]];
            [cityList writeToFile:homePath atomically:YES];
            [self cacheCityList];
            NSString *currentCityName = [NSString stringWithString:_currentCityName];
            if(!currentCityName || [currentCityName isEqualToString:@""]) {
                [self.spinnerView stopAnimating];
                self.locationWatingLabel.text = @"定位失败";
                [self queryRegionWideWithFlag:NO];
                return;
            }
            NSString *originalName = [NSString stringWithString:currentCityName];
            if(![originalName hasSuffix:@"市"]){
                originalName = [NSString stringWithFormat:@"%@市",originalName];
            }
            _selectedCityName = originalName;
            
            [app.cacheBase updateCitySelectedStatus:_selectedCityName];
//            NSArray *allKeys = [cityList allKeys];

            self.showType = 1;

            if([currentCityName hasSuffix:@"市"]){
                currentCityName = [currentCityName substringToIndex:currentCityName.length - 1];
            }
            
            self.locationWatingLabel.text = [__reGeocode formattedAddress];
            
            if(![app.cacheBase checkCityInOpen:_currentCityName] && ![_currentCityName isEqualToString:@""])
            {
                //判断是否在已开通城市列表
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"当前定位城市暂未开通免费问药服务，敬请期待！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                alertView.tag = 102;
                [alertView show];
                NSString *barTitle = nil;
                if([_currentCityName hasSuffix:@"市"]){
                    barTitle = [_currentCityName substringToIndex:_currentCityName.length - 1];
                }else{
                    barTitle = _currentCityName;
                }
                rightBarButton = [[UIBarButtonItem alloc] initWithTitle:barTitle style:UIBarButtonItemStylePlain target:self action:@selector(changeCity:)];
                
                self.navigationItem.rightBarButtonItems = @[rightBarButton,searchBarButton];
                self.showType = 2;
                [self setupHeaderView];
                [self.tableView removeFooter];
                [self.spinnerView stopAnimating];
                
                return;
            }
            [self queryRegionWideWithFlag:NO];
            
            
        }
    } failure:NULL];
    
    
}

- (void)cacheStoreList:(NSArray *)storeList clearFlag:(BOOL)flag
{
    //flag为yes的话 需要清除之前的数据,flag为no的话直接插入现在的缓存
    if(flag){
        [app.cacheBase deleteAllStoreList];
    }
    for(NSDictionary *dict in storeList)
    {
        NSString *storeId = dict[@"id"];
        NSString *accountId = dict[@"accountId"];
        NSString *name = dict[@"name"];
        NSString *shortName = dict[@"shortName"];
        NSString *star = [NSString stringWithFormat:@"%@",dict[@"star"]];
        NSString *avgStar = [NSString stringWithFormat:@"%@",dict[@"avgStar"]];
        NSString *consult = [NSString stringWithFormat:@"%@",dict[@"consult"]];
        NSString *accType = [NSString stringWithFormat:@"%@",dict[@"accType"]];
        NSString *tel = dict[@"tel"];
        NSString *province = dict[@"province"];
        NSString *city = dict[@"city"];
        NSString *county = dict[@"county"];
        NSString *addr = dict[@"addr"];
        NSString *distance = [NSString stringWithFormat:@"%@",dict[@"distance"]];
        NSString *imgUrl = dict[@"imgUrl"];
        NSString *tags = [dict[@"tags"] JSONRepresentation];
        [app.cacheBase insertIntoStoreList:storeId name:name star:star avgStar:avgStar consult:consult accType:accType tel:tel province:province city:city county:county addr:addr distance:distance imgUrl:imgUrl accountId:accountId tags:tags shortName:shortName];
    }
    
}

//flag 为yes则是加载更多,为no则是 重新加载
- (void)queryNationwideWithFlag:(BOOL)flag
{

}

- (void)queryRegionWideWithFlag:(BOOL)flag
{
    _resetEnable = NO;
    NSString *barTitle = nil;
    if([self.selectedCityName hasSuffix:@"市"]){
        barTitle = [self.selectedCityName substringToIndex:self.selectedCityName.length - 1];
    }else{
        barTitle = self.selectedCityName;
    }

    rightBarButton = [[UIBarButtonItem alloc] initWithTitle:barTitle style:UIBarButtonItemStylePlain target:self action:@selector(changeCity:)];
    
    self.navigationItem.rightBarButtonItems = @[rightBarButton,searchBarButton];
    
    if(!flag)
        currentPage = 1;
    else
        currentPage++;
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    switch (leftIndex) {
        case 1:
        {
            setting[@"distance"] = [NSString stringWithFormat:@"%d",1];
            break;
        }
        case 2:
        {
            setting[@"distance"] = [NSString stringWithFormat:@"%d",3];
            break;
        }
        case 3:
        {
            setting[@"distance"] = [NSString stringWithFormat:@"%d",5];
            break;
        }
        case 4:
        {
            setting[@"distance"] = [NSString stringWithFormat:@"%d",10];
            break;
        }
        default:
            break;
    }
    switch (rightIndex)//排序的更改，1 已开通服务 2 24H 3 医保定点 4 免费送药
    {
        case 1:
        {
            setting[@"active"]=@"1";
            break;
        }
        case 2:
        {
            setting[@"tags"] = @"1";
            break;
        }
        case 3:
        {
            setting[@"tags"] = @"2";
            break;
        }
        case 4:
        {
            setting[@"tags"] = @"3";
            break;
        }
        default:
            break;
    }
    switch (centerIndex)
    {
        case 0:
        {
            setting[@"sort"] = @"0";
            break;
        }
        case 1:
        {
            setting[@"sort"] = @"1";
            break;
        }
        case 2:
        {
            setting[@"sort"] = @"2";
            break;
        }
        default:
            break;
    }
    NSArray *allKeys = [cityList allKeys];
    BOOL result = NO;
    for(NSString *key in allKeys)
    {
        for(NSDictionary *cityName in cityList[key])
            if([cityName[@"cityName"] isEqualToString:_selectedCityName]) {
                result = YES;
                setting[@"city"] = cityName[@"city"];
                setting[@"province"] = cityName[@"province"];
                break;
            }
        if(result)
            break;
    }
    if(![_currentCityName isEqualToString:@""] && ![app.cacheBase checkCityInOpen:_currentCityName])
    {
        [setting removeObjectForKey:@"city"];
        [setting removeObjectForKey:@"province"];
        rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"全部" style:UIBarButtonItemStylePlain target:self action:@selector(changeCity:)];
        
        self.navigationItem.rightBarButtonItems = @[rightBarButton,searchBarButton];
    }else{
        rightBarButton = [[UIBarButtonItem alloc] initWithTitle:barTitle style:UIBarButtonItemStylePlain target:self action:@selector(changeCity:)];
        
        self.navigationItem.rightBarButtonItems = @[rightBarButton,searchBarButton];
    }
    
    __weak typeof (self) weakSelf = self;
    setting[@"page"] = [NSString stringWithFormat:@"%lu",(unsigned long)currentPage];
    setting[@"pageSize"] = @"10";
    setting[@"longitude"] = [NSString stringWithFormat:@"%f",selfCurrentLocation.coordinate.longitude];
    setting[@"latitude"] = [NSString stringWithFormat:@"%f",selfCurrentLocation.coordinate.latitude];
    NSLog(@"经纬度信息 = %@",setting);
    [[HTTPRequestManager sharedInstance] regionwide:setting completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"])
        {
            NSArray *array = resultObj[@"body"][@"list"];
            if([[[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_CITY] isEqualToString:@""] && [[[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_PROVINCE] isEqualToString:@""])
            {
                self.showType = 1;
                
            }else{
                self.showType = 1;
            }
            [self setupHeaderView];
            [self cacheStoreList:array clearFlag:!flag];
            if(!flag)
            {
                //重新加载更多
                [self.tableView addFooterWithCallback:^{
                    [weakSelf queryRegionWideWithFlag:YES];
                }];
                [self.tableView headerEndRefreshing];
                [self.dataSource removeAllObjects];
            }else{
                [self.tableView footerEndRefreshing];
                if(array.count == 0 || array.count < 10) {
                    [self.tableView removeFooter];
                }
            }
            if([array count] > 0)
                [self.dataSource addObjectsFromArray:array];
            
            
//            NSString *itemName = nil;
//            if(self.selectedCityName) {
//                NSString *currentCityName = [NSString stringWithFormat:@"%@",self.selectedCityName];
//                if([currentCityName hasSuffix:@"市"]){
//                    currentCityName = [currentCityName substringToIndex:currentCityName.length - 1];
//                }
//                itemName = currentCityName;
//                
//            }else{
//                itemName = @"正在定位";
//            }
//            rightBarButton.title = itemName;
//            if (self.showType == 1) {
//                if (!rightBarButton) {
//                    rightBarButton = [[UIBarButtonItem alloc] initWithTitle:itemName style:UIBarButtonItemStylePlain target:self action:@selector(changeCity:)];
//                }
//            }else if (self.showType == 2){
//                if (!rightBarButton) {
//                    rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"全部" style:UIBarButtonItemStylePlain target:self action:@selector(changeCity:)];
//                }
//            }
//            
//            self.navigationItem.rightBarButtonItems = @[rightBarButton,searchBarButton];

            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        if(!flag)
            [self.tableView headerEndRefreshing];
        else
            [self.tableView footerEndRefreshing];
    }];
}

- (void)handleTags:(NSArray *)tagArray withCell:(ConsultPharmacyTableViewCell *)cell
{
    cell.key1Image.hidden = YES;
    cell.key1Label.hidden = YES;
    cell.key2Image.hidden = YES;
    cell.key2Label.hidden = YES;
    cell.key3Image.hidden = YES;
    cell.key3Label.hidden = YES;
    cell.key4Image.hidden = YES;
    cell.key4Label.hidden = YES;
    
    for(NSDictionary *dict in tagArray)
    {
        NSUInteger index = [dict[@"key"] integerValue];
        NSLog(@"标签%@",dict[@"tag"]);
        if([dict[@"tag"] isEqualToString:@"24H"]) {
            //24H营业
            cell.key2Image.hidden = NO;
            cell.key2Label.hidden = NO;
        }
        if([dict[@"tag"] isEqualToString:@"医保定点"]) {
            //医保定点
            cell.key3Image.hidden = NO;
            cell.key3Label.hidden = NO;
        }
        if([dict[@"tag"] isEqualToString:@"免费送药"]) {
            //免费送药
            cell.key1Image.hidden = NO;
            cell.key1Label.hidden = NO;
        }
    }
    if([tagArray count] >= 3){
        cell.key4Image.hidden = YES;
        cell.key4Label.hidden = YES;
    }else if([tagArray count] <= 2 && (cell.key2Label.hidden == NO)) {
        cell.key4Image.hidden = NO;
        cell.key4Label.hidden = NO;
    }else if ([tagArray count] <= 1){
        cell.key4Image.hidden = NO;
        cell.key4Label.hidden = NO;
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:self.tableView])
        return 120.0f;
    else
        return 44;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    if([atableView isEqual:self.tableView]){
        if(isShowFilter)
            return [self.filterDataSource count];
        else
            return [self.dataSource count];
    }else if([atableView isEqual:leftComboxView.tableView]){
       
        return [leftMenuItems count];
    }
    else if([atableView isEqual:rightComboxView.tableView]){
       
        return [rightMenuItems count];
    }
    else{
        return [centerMenuItems count];
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([atableView isEqual:self.tableView]) {
        static NSString *ConsultPharmacyIdentifier = @"ConsultPharmacyIdentifier";
        ConsultPharmacyTableViewCell *cell = (ConsultPharmacyTableViewCell *)[atableView dequeueReusableCellWithIdentifier:ConsultPharmacyIdentifier];
        if(cell == nil){
            UINib *nib = [UINib nibWithNibName:@"ConsultPharmacyTableViewCell" bundle:nil];
            [atableView registerNib:nib forCellReuseIdentifier:ConsultPharmacyIdentifier];
            cell = (ConsultPharmacyTableViewCell *)[atableView dequeueReusableCellWithIdentifier:ConsultPharmacyIdentifier];
            
            UIView *bkView = [[UIView alloc]initWithFrame:cell.frame];
            bkView.backgroundColor = UIColorFromRGB(0xdfe4e6);
            cell.selectedBackgroundView = bkView;
        }
        
        NSDictionary *dict = nil;
        if(isShowFilter) {
            dict = self.filterDataSource[indexPath.row];
            
        }else{
            dict = self.dataSource[indexPath.row];
        }
        NSInteger accType = [dict[@"accType"] integerValue];
        if(accType == 2) {
            //显示
            cell.verifyLogo.hidden = NO;
            cell.verifyLogo.image = [UIImage imageNamed:@"认证V.png"];
        }else{
            cell.verifyLogo.hidden = YES;
        }
        NSString *imgUrl = dict[@"imgUrl"];
        if(imgUrl && ![imgUrl isEqual:[NSNull null]]){
            [cell.drugAvatar setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"药店默认头像.png"]];
        }else{
            [cell.drugAvatar setImage:[UIImage imageNamed:@"药店默认头像.png"]];
        }
        cell.tag = indexPath.row;
        
        NSString *storeName = [NSString stringWithFormat:@"%@",dict[@"name"]];
        NSString *shortName = [NSString stringWithFormat:@"%@",dict[@"shortName"]];
        storeName = shortName.length > 0 ? shortName : storeName;
        
        cell.drugStore.frame = CGRectMake(cell.drugStore.frame.origin.x, cell.drugStore.frame.origin.y, 15 * [storeName length], cell.drugStore.frame.size.height);
        cell.drugStore.text = storeName;
        cell.verifyLogo.frame = CGRectMake(cell.drugStore.frame.origin.x + cell.drugStore.frame.size.width + 5, cell.verifyLogo.frame.origin.y, cell.verifyLogo.frame.size.width, cell.verifyLogo.frame.size.height);
        cell.locationDesc.text = dict[@"addr"];
        float star = [dict[@"star"] floatValue];
        float avgStar = [dict[@"avgStar"] floatValue];
        star = MAX(star, avgStar);
        [cell.ratingView displayRating:star / 2];
        NSUInteger consultCount = [dict[@"consult"] intValue];
        cell.consultPerson.text = [NSString stringWithFormat:@"%d人已咨询",consultCount];
        cell.consultButton.tag = indexPath.row;
        [cell.consultButton setTitle:@"在线咨询" forState:UIControlStateNormal];
        [cell.consultButton addTarget:self action:@selector(freeConsultTouched:) forControlEvents:UIControlEventTouchDown];
        float distance = [dict[@"distance"] floatValue];

//        if([_selectedCityName isEqualToString:[[reGeocode addressComponent] city]])
//        {
        if (distance < 0) {
            cell.distance.text = @"超出20KM";
        }else if (distance > 20) {
            cell.distance.text = @"超出20KM";
        }else{
            cell.distance.text = [NSString stringWithFormat:@"%.1fKM",distance];
        }
        
        
        id tags = dict[@"tags"];
        if([tags isKindOfClass:[NSString class]]){
            tags = [tags JSONValue];
        }
        
        
        cell.viewSeparator = [[UIView alloc]init];
        cell.viewSeparator.frame = CGRectMake(0, cell.frame.size.height-0.5, cell.frame.size.width, 0.5);
        cell.viewSeparator.backgroundColor = UIColorFromRGB(0xdbdbdb);
        [cell addSubview:cell.viewSeparator];
        
        if([dict[@"active"] intValue] == 0){
            [cell.consultButton setTitle:@"即将开通" forState:UIControlStateNormal];
            [cell.consultButton removeTarget:self action:@selector(freeConsultTouched:) forControlEvents:UIControlEventTouchDown];
            cell.consultPerson.text = @"0人已咨询";
            [cell.ratingView displayRating:0.0f];
            cell.key1Image.hidden = YES;
            cell.key2Image.hidden = YES;
            cell.key3Image.hidden = YES;
            cell.key4Image.hidden = YES;
            cell.key1Label.hidden = YES;
            cell.key2Label.hidden = YES;
            cell.key3Label.hidden = YES;
            cell.key4Label.hidden = YES;
        }
        else{
            [self handleTags:tags withCell:cell];
        }
        
        return cell;
    }else{
        static NSString *MenuIdentifier = @"MenuIdentifier";
        UITableViewCell *cell = [atableView dequeueReusableCellWithIdentifier:MenuIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MenuIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
            cell.textLabel.textColor = UIColorFromRGB(0x666666);
        }
        NSString *content = nil;
        if([atableView isEqual:leftComboxView.tableView])
        {
            content = leftMenuItems[indexPath.row];
            if(indexPath.row == leftIndex) {
                cell.textLabel.textColor = APP_COLOR_STYLE;
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
                imageView.image = [UIImage imageNamed:@"选中的勾.png"];
                cell.accessoryView = imageView;
            }else{
                cell.textLabel.textColor = UIColorFromRGB(0x666666);
                cell.accessoryView = nil;
            }
            
        }
        else if ([atableView isEqual:centerComboxView.tableView]){
            content = centerMenuItems[indexPath.row];
            if(indexPath.row == centerIndex) {
                cell.textLabel.textColor = APP_COLOR_STYLE;
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
                imageView.image = [UIImage imageNamed:@"选中的勾.png"];
                cell.accessoryView = imageView;
            }else{
                cell.textLabel.textColor = UIColorFromRGB(0x666666);
                cell.accessoryView = nil;
            }

        }
        else{
            content = rightMenuItems[indexPath.row];
            if(indexPath.row == rightIndex) {
                cell.textLabel.textColor = APP_COLOR_STYLE;
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
                imageView.image = [UIImage imageNamed:@"选中的勾.png"];
                cell.accessoryView = imageView;
            }else{
                cell.textLabel.textColor = UIColorFromRGB(0x666666);
                cell.accessoryView = nil;
            }
        }
        cell.textLabel.text = content;
        return cell;
    }
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (app.currentNetWork == kNotReachable) {
//        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
//        return;
//    }
    if([atableView isEqual:self.tableView]) {
        
        PharmacyStoreViewController *pharmacyStoreViewController = [[PharmacyStoreViewController alloc] initWithNibName:@"PharmacyStoreViewController" bundle:nil];
        
        NSMutableDictionary *dict = nil;
        
        if(isShowFilter) {
            dict = [self.filterDataSource[indexPath.row] mutableCopy];
        }else{
            dict = [self.dataSource[indexPath.row] mutableCopy];
            NSLog(@"=======%@",dict);
        }
        
        pharmacyStoreViewController.infoDict = dict;
        [self.navigationController pushViewController:pharmacyStoreViewController animated:YES];
        
    }else if ([atableView isEqual:leftComboxView.tableView]) {
        leftIndex = indexPath.row;
        [leftButton setButtonTitle:leftMenuItems[indexPath.row]];
        [leftComboxView dismissView];
        [self queryRegionWideWithFlag:NO];
        [leftComboxView.tableView reloadData];
    }else if ([atableView isEqual:centerComboxView.tableView]) {
        centerIndex = indexPath.row;
        [centerButton setButtonTitle:centerMenuItems[indexPath.row]];
        [centerComboxView dismissView];
        [self queryRegionWideWithFlag:NO];
        [centerComboxView.tableView reloadData];
    }else{
        rightIndex = indexPath.row;
        [rightButton setButtonTitle:rightMenuItems[indexPath.row]];
        [rightComboxView dismissView];
        [self queryRegionWideWithFlag:NO];
        [rightComboxView.tableView reloadData];
        //[self filterDataSourceLeft:NO Index:indexPath.row];
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [searchBar resignFirstResponder];
}

- (void)freeConsultTouched:(UIButton *)sender
{
    if(!app.logStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
        return;
    }
    
    NSDictionary *dict = nil;
    if(isShowFilter) {
        dict = self.filterDataSource[sender.tag];
    }else{
        dict = self.dataSource[sender.tag];
    }
    XHDemoWeChatMessageTableViewController *demoWeChatMessageTableViewController = [[XHDemoWeChatMessageTableViewController  alloc] init];
    demoWeChatMessageTableViewController.infoDict = dict;
    demoWeChatMessageTableViewController.title = dict[@"name"];
    [self.navigationController pushViewController:demoWeChatMessageTableViewController animated:YES];
}

//flag代表左边
- (void)filterDataSourceLeft:(BOOL)flag Index:(NSUInteger)index
{
    [self.filterDataSource removeAllObjects];
    if(flag)
    {
        
        
    }else{
        if(index == 1){
            //24小时营业
            [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary *dict = (NSDictionary *)obj;
                NSArray *tags = dict[@"tags"];
                for(NSDictionary *tagDict in tags) {
                    if([tagDict[@"key"] isEqualToString:@"1"]) {
                        [self.filterDataSource addObject:dict];
                        break;
                    }
                }
            }];
            isShowFilter = YES;
            
        }else if(index == 2){
            //医保定点
            [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary *dict = (NSDictionary *)obj;
                NSArray *tags = dict[@"tags"];
                for(NSDictionary *tagDict in tags) {
                    if([tagDict[@"key"] isEqualToString:@"2"]) {
                        [self.filterDataSource addObject:dict];
                        break;
                    }
                }
            }];
            
            isShowFilter = YES;
        }else{
            isShowFilter = NO;
        }
        
    }
    [self.tableView reloadData];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

@end
