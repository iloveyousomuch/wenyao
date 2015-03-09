//
//  NewHomePageViewController.m
//  wenyao
//
//  Created by garfield on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "NewHomePageViewController.h"
#import "SmallTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "HTTPRequestManager.h"
#import "PharmacyStoreViewController.h"
#import "Constant.h"
#import "MessageBoxViewController.h"
#import "FamiliarQuestionViewController.h"
#import "ConsultPharmacyViewController.h"
#import "ConsultQuizViewController.h"
#import "CouponHomePageViewController.h"
#import "Location.h"
#import "SearchSliderViewController.h"
#import "ScanReaderViewController.h"
#import "SBJSON.h"
#import "LoginViewController.h"
#import "SVProgressHUD.h"
#import "MJRefresh.h"



@interface NewHomePageViewController ()<XLCycleScrollViewDatasource,XLCycleScrollViewDelegate,UIAlertViewDelegate>
{
    CLLocation          *userLocation;
    XLCycleScrollView   *cycleScrollView;
}

@property (nonatomic, strong) NSMutableArray    *themeList;
@property (nonatomic, strong) NSArray           *consultList;
@property (nonatomic, strong) NSMutableArray    *recommendedList;
@property (nonatomic, strong) NSString          *lastCityName;
@property (nonatomic, strong) NSString          *currentProvinceName;
@property (nonatomic, strong) NSString          *currentCityName;
@property (nonatomic, strong) NSString          *bannerImage;
@property (nonatomic, strong) AMapReGeocode     *aMapReGeocode;

@end

@implementation NewHomePageViewController

- (void)pushIntoMessageBox:(id)sender
{
    if(!app.logStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
        return;
    }
    MessageBoxViewController *messageBox = [[MessageBoxViewController alloc] initWithNibName:@"MessageBoxViewController" bundle:nil];
    messageBox.hidesBottomBarWhenPushed = YES;
    if(sender) {
        [self.navigationController pushViewController:messageBox animated:YES];
    }else{
        [self.navigationController pushViewController:messageBox animated:YES];
    }
}

- (void)scanAction:(id)sender
{
    ScanReaderViewController *scanReaderViewController = [[ScanReaderViewController alloc] initWithNibName:@"ScanReaderViewController" bundle:nil];
    scanReaderViewController.useType = 3;
    scanReaderViewController.pageType = 2;
    scanReaderViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scanReaderViewController animated:YES];
}

- (void)searchAction:(id)sender
{
    SearchSliderViewController * searchViewController = [[SearchSliderViewController alloc] init];
    searchViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewController animated:NO];
}

- (IBAction)pushIntoFreeConsult:(id)sender
{
    UIStoryboard *sbConsult = [UIStoryboard storyboardWithName:@"ConsultMedicine" bundle:nil];
    ConsultQuizViewController *viewControllerConsult = [sbConsult instantiateViewControllerWithIdentifier:@"ConsultQuizViewController"];
    [self.navigationController pushViewController:viewControllerConsult animated:YES];
}

- (IBAction)pushIntoNearByStore:(id)sender
{

    ConsultPharmacyViewController *consultPharmacyViewController = [[ConsultPharmacyViewController alloc] init];
    consultPharmacyViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:consultPharmacyViewController animated:YES];
}

- (void)setupView
{
    cycleScrollView = [[XLCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 119)];
    cycleScrollView.delegate = self;
    cycleScrollView.datasource = self;
    cycleScrollView.scrollView.scrollEnabled = NO;
    cycleScrollView.pageControl.hidden = YES;
    [self.scrollerView addSubview:cycleScrollView];
    self.consultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.recommendedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.recommendedTableView.transform = CGAffineTransformMakeRotation(- M_PI / 2.0f);
    self.consultTableView.transform = CGAffineTransformMakeRotation(- M_PI / 2.0f);
}

- (void)setupConstraint
{
//    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.recommededBottomView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:300];
//    [self.view addConstraint:constraint];
    CGFloat constant = 10.f;
    if(HIGH_RESOLUTION) {
        constant = 80;
    }
    _bottomLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.scrollerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.consultView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:constant];
    _bottomLayoutConstraint.priority = 1000.0f;
    self.recommededView.hidden = YES;
}

- (void)cacheProblemModule:(NSArray *)problemList clearFlag:(BOOL)flag
{
    if (flag)
    {
        [app.cacheBase deleteAllProblemModule];
    }
    for(NSDictionary *dict in problemList)
    {
        NSString *imgUrl = dict[@"imgUrl"];
        NSString *moduleId = [NSString stringWithFormat:@"%@",dict[@"moduleId"]];
        NSString *name = dict[@"name"];
        [app.cacheBase insertIntoProblemModule:imgUrl moduleId:moduleId name:name];
    }
}

- (void)loadCacheProblemModule
{
    self.consultList = [app.cacheBase selectAllProblemModule];
    [self.consultTableView reloadData];
}

- (void)cacheRecommendStoreList:(NSArray *)storeList clearFlag:(BOOL)flag
{
    //flag为yes的话 需要清除之前的数据,flag为no的话直接插入现在的缓存
    if(flag){
        [app.cacheBase deleteRecommendAllStoreList];
    }
    for(NSDictionary *dict in storeList)
    {
        NSString *storeId = dict[@"id"];
        NSString *accountId = dict[@"accountId"];
        NSString *name = dict[@"name"];
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
        [app.cacheBase insertIntoRecommendStoreList:storeId name:name star:star avgStar:avgStar consult:consult accType:accType tel:tel province:province city:city county:county addr:addr distance:distance imgUrl:imgUrl accountId:accountId tags:tags];
    }
}


- (void)loadRecommendStoreCache
{
    self.recommendedList = [app.cacheBase selectALLRecommendStoreList];
    if(self.recommendedList == nil)
        self.recommendedList = [NSMutableArray arrayWithCapacity:8];
    if(self.recommendedList.count == 0)
    {
        self.recommededView.hidden = YES;
        [self.scrollerView removeConstraint:_bottomLayoutConstraint];
        [self.scrollerView addConstraint:_bottomLayoutConstraint];
    }else{
        self.recommededView.hidden = NO;
        [self.scrollerView removeConstraint:_bottomLayoutConstraint];
        [self.recommendedTableView reloadData];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        //切换到当前城市
        [app cacheLastLocationInformation:[[_aMapReGeocode addressComponent] city] province:[[_aMapReGeocode addressComponent] province] formatterAddress:[_aMapReGeocode formattedAddress] location:userLocation];

        [self queryRecommendedList:userLocation cityName:[[_aMapReGeocode addressComponent] city] provinceName:[[_aMapReGeocode addressComponent] province]];
        
    }else{
        [self loadRecommendStoreCache];
    }
}

- (void)reloadRecommendOnly
{
    if(![Location locationServicesAvailable])
    {
        [self loadRecommendStoreCache];
        return;
    }
    [[Location sharedInstance] requetWithReGoecodeOnly:LocationCreate timeout:10 block:^(CLLocation *currentLocation, AMapReGeocodeSearchResponse *response, LocationStatus status) {
        [self handleLoactionWith:currentLocation response:response status:status];
    }];
}

- (void)startUserLocation
{
    if(![Location locationServicesAvailable])
    {
        [self loadRecommendStoreCache];
        return;
    }
    [[Location sharedInstance] requetWithReGoecode:LocationCreate timeout:10 block:^(CLLocation *currentLocation, AMapReGeocodeSearchResponse *response, LocationStatus status) {
        [self handleLoactionWith:currentLocation response:response status:status];
    }];
}

- (void)handleLoactionWith:(CLLocation *)currentLocation response:(AMapReGeocodeSearchResponse *)response status:(LocationStatus)status
{
    if(status == LocationRegeocodeSuccess) {
        
        userLocation = currentLocation;
        NSString *currentCity = [[[response regeocode] addressComponent] city];
        _aMapReGeocode = [response regeocode];
        [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_UPDATE object:nil];
        
        _currentCityName = currentCity;
        //首先判断是否已经开通城市
        if(currentCity && ![currentCity isEqualToString:@""]) {
            NSString *province = [[[response regeocode] addressComponent] province];
            _currentProvinceName = province;
            if (!province) {
                province = @"";
            }
            NSMutableDictionary *setting = [NSMutableDictionary dictionary];
            setting[@"province"] = province;
            setting[@"city"] = currentCity;
            [[HTTPRequestManager sharedInstance] checkOpenCity:setting completion:^(id resultObj)
            {
                if([resultObj[@"result"] isEqualToString:@"OK"]) {
                    if([resultObj[@"body"][@"open"] integerValue] == 1) {
                        //已开通,开始判断是否和上次定位是否一致
                        _lastCityName = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_CITY];
                        BOOL shouldShowAlert = app.tabBarController.selectedIndex == 0 && [[((UINavigationController *)self.tabBarController.viewControllers[0]).viewControllers lastObject] isKindOfClass:[NewHomePageViewController class]];
                        if (currentCity && _lastCityName && ![currentCity isEqualToString:_lastCityName] && shouldShowAlert)
                        {
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"定位显示当前您在%@，是否为您从%@切换到%@？",currentCity,_lastCityName,currentCity] delegate:self cancelButtonTitle:@"不用了" otherButtonTitles:@"切换", nil];
                            [alertView show];
                        }else{
                            if([[response regeocode] formattedAddress] != nil){
                                [app cacheLastLocationInformation:currentCity province:province formatterAddress:[[response regeocode] formattedAddress] location:userLocation];
                            }else{
                                [app cacheLastLocationInformation:currentCity location:userLocation];
                            }
                            [self queryRecommendedList:currentLocation cityName:[[[response regeocode] addressComponent] city] provinceName:[[[response regeocode] addressComponent] province]];
                        }
                    }else{
                        //缓存加载上一次数据
                        [self loadRecommendStoreCache];
                    }
                }
            } failure:^(id failMsg) {
                //加载上一次数据
                [self loadRecommendStoreCache];
            }];
        }else{
            //加载上一次数据
            [self loadRecommendStoreCache];
        }
    }else{
        [self loadRecommendStoreCache];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"问药";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"首页_消息.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pushIntoMessageBox:)];
    
    UIView *customBarItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 55)];
    //[customBarItems setBackgroundColor:[UIColor yellowColor]];
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(28, 0, 55, 55)];
    [searchButton setImage:[UIImage imageNamed:@"首页_搜索.png"]  forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchDown];
    [customBarItems addSubview:searchButton];
    
    UIButton *scanButton = [[UIButton alloc] initWithFrame:CGRectMake(65, 0, 55, 55)];
    [scanButton setImage:[UIImage imageNamed:@"首页_扫码.png"] forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(scanAction:) forControlEvents:UIControlEventTouchDown];
    [customBarItems addSubview:scanButton];
    

    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -20;
    self.navigationItem.rightBarButtonItems = @[fixed,[[UIBarButtonItem alloc] initWithCustomView:customBarItems]];
    
    self.consultList = [NSArray array];
    self.recommendedList = [NSMutableArray array];
    [self setupView];
    [self setupConstraint];

    _badgeView = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(22, -2, 40, 40)];
    _badgeView.shadow = NO;
    _badgeView.userInteractionEnabled = NO;
    _badgeView.hideWhenZero = YES;
    _badgeView.tag = 888;
    _badgeView.hidden = YES;
    [self.navigationController.navigationBar addSubview:_badgeView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUserLocation) name:NEED_RELOCATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRequestData) name:NETWORK_RESTART object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRecommendOnly) name:LOCATION_UPDATE_ADDRESS object:nil];
    
    __weak typeof (self) __weakSelf = self;
    
    [self.scrollerView addHeaderWithCallback:^{
        [__weakSelf startUserLocation];
        [__weakSelf queryBannerImage];
        [__weakSelf queryConsultList:YES];
        [__weakSelf.scrollerView headerEndRefreshing];
    }];
    self.scrollerView.headerPullToRefreshText = @"下拉刷新";
    self.scrollerView.headerReleaseToRefreshText = @"松开刷新";
    self.scrollerView.headerRefreshingText = @"正在刷新";
}

- (void)reloadRequestData
{
    [self queryConsultList:NO];
    if(self.recommendedList == 0) {
        [self reloadRecommendOnly];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.badgeView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.badgeView.value > 0) {
        self.badgeView.hidden = NO;
    }
    [self queryConsultList:NO];
    [self queryBannerImage];
}

- (void)queryBannerImage
{
    if(!self.bannerImage) {
        [[HTTPRequestManager sharedInstance] promotionBanner:[NSMutableDictionary dictionary] completion:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"])
            {
                self.bannerImage = resultObj[@"body"][@"banner"];
                [cycleScrollView reloadData];
            }
        } failure:NULL];
    }
}

- (void)queryRecommendedList:(CLLocation *)location
                    cityName:(NSString *)cityName
                provinceName:(NSString *)provinceName
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"longitude"] = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
    setting[@"latitude"] = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
    setting[@"province"] = provinceName;
    setting[@"city"] = cityName;
    setting[@"size"] = @"8";
    setting[@"type"] = @"1";
    [[HTTPRequestManager sharedInstance] searchStoreOffer:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]) {
            [self.recommendedList removeAllObjects];
            self.recommededView.hidden = NO;
            [self.scrollerView removeConstraint:_bottomLayoutConstraint];
            for(NSDictionary *dict in resultObj[@"body"][@"list"]) {
                NSString *name = dict[@"name"];
                if(!dict || [dict[@"name"] isEqualToString:@""])
                    continue;
                [self.recommendedList addObject:dict];
            }
            [self.recommendedTableView reloadData];
            [self cacheRecommendStoreList:self.recommendedList clearFlag:YES];
        }
    } failure:NULL];
}

- (void)queryConsultList:(BOOL)clear
{
    if(self.consultList.count > 0 && !clear)
        return;
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    [[HTTPRequestManager sharedInstance] problemModule:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"])
        {
            NSArray *array = resultObj[@"body"];
            self.consultList = array;
            [self cacheProblemModule:array clearFlag:YES];
            [self.consultTableView reloadData];
        }
    } failure:^(id failMsg) {
        [self loadCacheProblemModule];
    }];
}

#pragma mark -
#pragma mark XLCycleScrollViewDelegate
- (void)didClickPage:(XLCycleScrollView *)csView atIndex:(NSInteger)index
{
    //进入优惠码详情
    CouponHomePageViewController *couponHomePageViewController = [[CouponHomePageViewController alloc] initWithNibName:@"CouponHomePageViewController" bundle:nil];
    
    
    couponHomePageViewController.hidesBottomBarWhenPushed = YES;
    couponHomePageViewController.provinceName = _currentProvinceName;
    couponHomePageViewController.cityName = _currentCityName;
    
    [self.navigationController pushViewController:couponHomePageViewController animated:YES];
}

- (NSInteger)numberOfPages
{
    return 1;
}

- (UIView *)pageAtIndex:(NSInteger)index
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,320, 119)];
    [imageView setImageWithURL:[NSURL URLWithString:self.bannerImage] placeholderImage:[UIImage imageNamed:@"首页_banner.jpg"]];
    return imageView;
}

#pragma mark
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([tableView isEqual:self.consultTableView])
        return self.consultList.count;
    else
        return self.recommendedList.count;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SmallHomePageTableViewCellIdentfier = @"SmallHomePageCellIdentifier";
    SmallTableViewCell *cell = (SmallTableViewCell *)[atableView dequeueReusableCellWithIdentifier:SmallHomePageTableViewCellIdentfier];
    if(cell == nil)
    {
        UINib *nib = [UINib nibWithNibName:@"SmallTableViewCell" bundle:nil];
        [atableView registerNib:nib forCellReuseIdentifier:SmallHomePageTableViewCellIdentfier];
        cell = (SmallTableViewCell *)[atableView dequeueReusableCellWithIdentifier:SmallHomePageTableViewCellIdentfier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dict = nil;
    if([atableView isEqual:_consultTableView]) {
        dict = self.consultList[indexPath.row];
        [cell.avatarImage setImageWithURL:[NSURL URLWithString:dict[@"imgUrl"]] placeholderImage:[UIImage imageNamed:@"默认药品图片_V2.png"]];
        cell.titleLabel.text = dict[@"name"];
    }else{
        dict = self.recommendedList[indexPath.row];
        [cell.avatarImage setImageWithURL:[NSURL URLWithString:dict[@"imgUrl"]] placeholderImage:[UIImage imageNamed:@"药店默认头像.png"]];
        NSString *storeName = [NSString stringWithFormat:@"%@",dict[@"name"]];
        NSString *shortName = [NSString stringWithFormat:@"%@",dict[@"shortName"]];
        storeName = shortName.length > 0 ? shortName : storeName;
        if(storeName.length > 5) {
            storeName = [NSString stringWithFormat:@"%@...",[storeName substringToIndex:5]];
        }
        cell.titleLabel.text = storeName;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = nil;
    if([atableView isEqual:_consultTableView]) {
        dict = _consultList[indexPath.row];
        FamiliarQuestionViewController *familiarVC = [[FamiliarQuestionViewController alloc] init];
        familiarVC.dic = dict;
        familiarVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:familiarVC animated:YES];
    }else{
        dict = _recommendedList[indexPath.row];
        PharmacyStoreViewController *pharmacyStoreViewController = [[PharmacyStoreViewController alloc] initWithNibName:@"PharmacyStoreViewController" bundle:nil];
        pharmacyStoreViewController.hidesBottomBarWhenPushed = YES;
        pharmacyStoreViewController.infoDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        [self.navigationController pushViewController:pharmacyStoreViewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
