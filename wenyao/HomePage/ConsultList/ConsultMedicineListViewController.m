//
//  ConsultMedicineListViewController.m
//  wenyao
//
//  Created by chenzhipeng on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "ConsultMedicineListViewController.h"
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "ConsultMedicineCell.h"
#import "ConsultViewModel.h"
#import "Constant.h"
#import "Location.h"
#import "SVProgressHUD.h"
#import "MessageBoxViewController.h"
#import "XMPPManager.h"
#import "XHMessageBubbleFactory.h"
#import "XHMessage.h"
#import "SVProgressHUD.h"
#import "LoginViewController.h"
#import "XMPPIQ+XMPPMessage.h"
#import "MBProgressHUD.h"
#import "MJRefresh.h"
#import "ConsultMedicineMyFavCell.h"

#define K_NODATA_MYFAV @"您还未关注任何药房哦!"
#define k_NONETWORK_MYFAV @"您的网络不太给力，请重试"

typedef enum
{
    Enum_DataNormal = 0x00000001,               //数据正常
    Enum_needRelocation = 0x00000001 << 1,      //需要重新定位
    Enum_noData = 0x00000001 << 2,              //没有数据
    Enum_cityNotOpen = 0x00000001 << 3          //城市未开通
}EnumDataStatus;

@interface ConsultMedicineListViewController ()<CLLocationManagerDelegate, ConsultPharmacyListDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewRelocation;
@property (weak, nonatomic) IBOutlet UIButton *btnRelocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) ConsultViewModel *viewModelConsult;
@property (weak, nonatomic) IBOutlet UITableView *tbViewContent;
@property (strong, nonatomic) NSMutableSet *setSelected;
@property (strong, nonatomic) NSMutableSet *setMyFavSelected;
@property (strong, nonatomic) CLLocation *userLocation;
@property (nonatomic, strong) NSString          *lastCityName;
@property (nonatomic, strong) NSString *lastProvinceName;
@property (weak, nonatomic) IBOutlet UILabel *lblNoData;
@property (nonatomic, strong) NSString          *currentCityName;
@property (nonatomic, strong) NSString *currentProvinceName;
@property (nonatomic, strong) AMapReGeocode     *aMapReGeocode;
@property (nonatomic, strong) MBProgressHUD *progressWait;
@property (weak, nonatomic) IBOutlet UILabel *lblCityNotOpen;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseMyFav;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseAround;
@property (weak, nonatomic) IBOutlet UIImageView *imgAround;
@property (weak, nonatomic) IBOutlet UIImageView *imgMyFav;
@property (weak, nonatomic) IBOutlet UIView *viewNearPharmacy;
@property (weak, nonatomic) IBOutlet UIView *viewFavPharmacy;
@property (weak, nonatomic) IBOutlet UITableView *tbViewMyFav;
@property (weak, nonatomic) IBOutlet UILabel *lblMyFavNoNetWork;

@property (nonatomic, assign) NSInteger curPage;
@property (nonatomic, assign) NSInteger pageSize;

- (IBAction)btnPressed_choosePharmacySource:(id)sender;

- (IBAction)btnPressed_updateLocation:(id)sender;
- (IBAction)btnPressed_submit:(id)sender;
@end

@implementation ConsultMedicineListViewController

/**
 *  根据不同情况控制界面隐藏
 *
 *  @param enumDataType 枚举: Enum_DataNormal 数据正常
                            Enum_needRelocation 需要显示重新定位.
                            Enum_noData  没有数据
                            Enum_cityNotOpen 当前城市未开通
 
 */
- (void)appealLocationAndDataStatus:(EnumDataStatus)enumDataType
{
    if (enumDataType == Enum_DataNormal) {
        self.tbViewContent.hidden = NO;
        self.viewRelocation.hidden = YES;
        self.lblCityNotOpen.hidden = YES;
        self.lblNoData.hidden = YES;
    } else if (enumDataType == Enum_needRelocation) {
        self.tbViewContent.hidden = YES;
        self.viewRelocation.hidden = NO;
        self.lblCityNotOpen.hidden = YES;
        self.lblNoData.hidden = YES;
    } else if (enumDataType == Enum_noData) {
        self.tbViewContent.hidden = YES;
        self.viewRelocation.hidden = YES;
        self.lblCityNotOpen.hidden = YES;
        self.lblNoData.hidden = NO;
    } else if (enumDataType == Enum_cityNotOpen) {
        self.tbViewContent.hidden = YES;
        self.viewRelocation.hidden = YES;
        self.lblCityNotOpen.hidden = NO;
        self.lblNoData.hidden = YES;
    }
}

- (void)setNaviBar
{
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    lblTitle.text = @"选择咨询的药房";
    lblTitle.font = [UIFont systemFontOfSize:18];
    lblTitle.textColor = UIColorFromRGB(0xffffff);
    self.navigationItem.titleView = lblTitle;
    
    UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    btnNext.frame = CGRectMake(0, 0, 30, 30);
    btnNext.titleLabel.font = [UIFont systemFontOfSize:15];
    btnNext.titleLabel.textAlignment = NSTextAlignmentRight;
    [btnNext setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [btnNext setTitle:@"提交" forState:UIControlStateNormal];
    [btnNext addTarget:self action:@selector(btnPressed_submit:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *nextBtnItem = [[UIBarButtonItem alloc] initWithCustomView:btnNext];
    self.navigationItem.rightBarButtonItem = nextBtnItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviBar];
    self.viewModelConsult = [[ConsultViewModel alloc] init];
    self.viewModelConsult.delegate = self;
    self.setSelected = [NSMutableSet set];
    self.setMyFavSelected = [NSMutableSet set];
    [self appealLocationAndDataStatus:Enum_DataNormal];
    self.curPage = 1;
    self.pageSize = 10;
    __weak ConsultMedicineListViewController *weakSelf = self;
    if (app.currentNetWork != NotReachable) {
        [self.tbViewMyFav addFooterWithCallback:^{
            weakSelf.curPage++;
            [weakSelf requestForMyFavPharmacyList:app.configureList[APP_USER_TOKEN]];
            
        }];
    }
    
    CGFloat latitude = [[[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_LATITUDE] floatValue];
    CGFloat longitude = [[[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_LONGITUDE] floatValue];
    NSString *strCity = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_CITY];
    NSString *strProvince = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_PROVINCE];
    if (latitude == 0) {
        [self appealLocationAndDataStatus:Enum_noData];
        [self startUserLocation];
    } else {
        if (app.currentNetWork != NotReachable) {
            CLLocation *curLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            [self requestForNearPharmacyList:curLocation withCity:strCity withProvince:strProvince];
        } else {
            [self loadLocalPharmacyList];
        }
    }
    [self btnPressed_choosePharmacySource:self.btnChooseAround];
    [self appealLocationAndDataStatus:Enum_noData];
//    self.tbViewContent.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//    self.tbViewContent.layer.borderWidth = 0.5;
    self.tbViewContent.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.btnRelocation.layer.cornerRadius = 4.0f;
    self.btnRelocation.layer.borderWidth = 1.0f;
    self.btnRelocation.layer.masksToBounds = YES;
    self.btnRelocation.layer.borderColor = [UIColorFromRGB(0x45c01a) CGColor];
    self.view.backgroundColor = UIColorFromRGB(0xf5f5f5);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUserLocation) name:NEED_RELOCATION object:nil];
}

- (void)requestForNearPharmacyList:(CLLocation *)location withCity:(NSString *)strCity withProvince:(NSString *)strProvince
{
    [self.viewModelConsult getNearPharmacyListWithCount:5 Latitude:location.coordinate.latitude Longitude:location.coordinate.longitude CityName:strCity ProvinceName:strProvince];
}

- (void)requestForMyFavPharmacyList:(NSString *)token
{
    if (app.currentNetWork != NotReachable) {
        [self.viewModelConsult getMyFavPharmacyListWithCount:self.pageSize page:self.curPage token:token];
    } else {
        [self.viewModelConsult getCachedMyFavPharmacyList];
        if (self.viewModelConsult.arrMyFavPharmacyList.count > 0) {
            self.tbViewMyFav.hidden = NO;
            self.lblMyFavNoNetWork.hidden = YES;
            [self.tbViewMyFav reloadData];
        } else {
            self.tbViewMyFav.hidden = YES;
            self.lblMyFavNoNetWork.text = k_NONETWORK_MYFAV;
            self.lblMyFavNoNetWork.hidden = NO;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self getCurrentLocation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)loadLocalPharmacyList
{
    [self.viewModelConsult getCachedNearPharmacyList];
    if (self.viewModelConsult.arrNearPharmacyList.count <= 0) {
        [self appealLocationAndDataStatus:Enum_noData];
    } else {
        [self appealLocationAndDataStatus:Enum_DataNormal];
        [self.setSelected addObject:@0];
        [self.setSelected addObject:@1];
        [self.tbViewContent reloadData];
    }
    
}
#pragma mark - Location methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        //切换到当前城市
        [app cacheLastLocationInformation:[[_aMapReGeocode addressComponent] city] province:[[_aMapReGeocode addressComponent] province] formatterAddress:[_aMapReGeocode formattedAddress] location:self.userLocation];
        
        [self requestForNearPharmacyList:self.userLocation withCity:self.currentCityName withProvince:self.currentProvinceName];
        [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_UPDATE_ADDRESS object:nil];
    }else{
//        [self loadLocalPharmacyList];
        [self requestForNearPharmacyList:self.userLocation withCity:self.lastCityName withProvince:self.currentProvinceName];
    }
}

- (void)startUserLocation
{
    if (![Location locationServicesAvailable]) {
        CGFloat latitude = [[[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_LATITUDE] floatValue];
        if (latitude == 0 || !latitude) {
            [self appealLocationAndDataStatus:Enum_noData];
        } else {
            [self loadLocalPharmacyList];
        }
        [self.progressWait hide:YES];
        return;
    }
    
    [[Location sharedInstance] requetWithReGoecode:LocationCreate timeout:100 block:^(CLLocation *currentLocation, AMapReGeocodeSearchResponse *response, LocationStatus status) {
        if(status == LocationRegeocodeSuccess) {
            self.userLocation = currentLocation;
            NSString *currentCity = [[[response regeocode] addressComponent] city];
            NSString *currentProvince = [[[response regeocode] addressComponent] province];
            self.aMapReGeocode = [response regeocode];
            _currentCityName = currentCity;
            _currentProvinceName = currentProvince;
            CGFloat latitude = [[[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_LATITUDE] floatValue];
            if (latitude == 0 || !latitude) {
                [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_UPDATE_ADDRESS object:nil];
            }
            //首先判断是否已经开通城市
            if(currentCity && ![currentCity isEqualToString:@""]) {
                NSMutableDictionary *setting = [NSMutableDictionary dictionary];
                setting[@"province"] = [[[response regeocode] addressComponent] province];
                setting[@"city"] = currentCity;
                [[HTTPRequestManager sharedInstance] checkOpenCity:setting completion:^(id resultObj) {
                    if([resultObj[@"result"] isEqualToString:@"OK"]) {
                        if([resultObj[@"body"][@"open"] integerValue] == 1) {
                            //已开通,开始判断是否和上次定位是否一致
                            _lastCityName = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_CITY];
                            _lastProvinceName = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_PROVINCE];
                            [self.progressWait hide:YES];
                            if (currentCity && _lastCityName && ![currentCity isEqualToString:_lastCityName])
                            {
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"定位显示当前您在%@，是否为您从%@切换到%@？",currentCity,_lastCityName,currentCity] delegate:self cancelButtonTitle:@"不用了" otherButtonTitles:@"切换", nil];
                                [alertView show];
                            }else{
                                if([[response regeocode] formattedAddress] != nil){
                                    [app cacheLastLocationInformation:currentCity province:currentProvince formatterAddress:[[response regeocode] formattedAddress] location:self.userLocation];
                                }else{
                                    [app cacheLastLocationInformation:currentCity location:self.userLocation];
                                }

                               [self requestForNearPharmacyList:currentLocation withCity:currentCity withProvince:currentProvince];
                            }
                        }else{
                            //缓存加载上一次数据
                            [self.progressWait hide:YES];
                            [self appealLocationAndDataStatus:Enum_cityNotOpen];
//                            [self loadLocalPharmacyList];
                        }
                    } else {
                        [self.progressWait hide:YES];
                        [self appealLocationAndDataStatus:Enum_noData];
                    }
                } failure:^(id failMsg) {
                    //加载上一次数据
                    [self.progressWait hide:YES];
                    [self loadLocalPharmacyList];
                }];
            }else{
                //加载上一次数据
                [self.progressWait hide:YES];
                [self loadLocalPharmacyList];
            }
        }else{
            [self.progressWait hide:YES];
            CGFloat latitude = [[[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_LATITUDE] floatValue];
            if (latitude == 0) {
                [self appealLocationAndDataStatus:Enum_needRelocation];
            } else {
                [self appealLocationAndDataStatus:Enum_DataNormal];
                [self loadLocalPharmacyList];
            }
        }
    }];
}

#pragma mark - UITableView methods
- (BOOL)containSelectInSet:(NSInteger)indexObj isMyFav:(BOOL)isMyFav
{
    if (isMyFav) {
        BOOL isExisted = NO;
        if ([self.setMyFavSelected containsObject:[NSNumber numberWithInt:indexObj]]) {
            isExisted = YES;
        }
        return isExisted;
    } else {
        BOOL isExisted = NO;
        if ([self.setSelected containsObject:[NSNumber numberWithInt:indexObj]]) {
            isExisted = YES;
        }
        return isExisted;
    }
}

- (void)operateSelectInSet:(NSInteger)indexObj isMyFav:(BOOL)isMyFav
{
    if (isMyFav) {
        if (![self containSelectInSet:indexObj isMyFav:YES]) {
            [self.setMyFavSelected addObject:[NSNumber numberWithInt:indexObj]];
        } else {
            [self.setMyFavSelected removeObject:[NSNumber numberWithInt:indexObj]];
        }
    } else {
        if (![self containSelectInSet:indexObj isMyFav:NO]) {
            [self.setSelected addObject:[NSNumber numberWithInt:indexObj]];
        } else {
            [self.setSelected removeObject:[NSNumber numberWithInt:indexObj]];
        }
    }
}

- (NSString *)checkStr:(id)obj
{
    if (([obj isKindOfClass:[NSString class]])&&[(NSString *)obj length]>0) {
        return (NSString *)obj;
    } else {
        return @"";
    }
}

- (void)configureCell:(ConsultMedicineCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.viewModelConsult.arrNearPharmacyList[indexPath.row];
    cell.lblTitle.text = [self checkStr:dic[@"shortName"]].length > 0 ? [self checkStr:dic[@"shortName"]] : [self checkStr:dic[@"name"]];
    cell.lblDistance.text = [NSString stringWithFormat:@"%@ KM",dic[@"distance"]];
}

- (void)configureMyFavCell:(ConsultMedicineMyFavCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.viewModelConsult.arrMyFavPharmacyList[indexPath.row];
    cell.lblTitle.text = [self checkStr:dic[@"shortName"]].length > 0 ? [self checkStr:dic[@"shortName"]] : [self checkStr:dic[@"name"]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tbViewContent) {
        ConsultMedicineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConsultMedicineCell"];
        [self configureCell:cell forIndexPath:indexPath];
        if ([self containSelectInSet:indexPath.row isMyFav:NO]) {
            cell.imgSelect.hidden = NO;
            cell.lblTitle.textColor = UICOLOR(69, 192, 26);
            cell.contentView.backgroundColor = [UIColor clearColor];
        } else {
            cell.imgSelect.hidden = YES;
            cell.lblTitle.textColor = [UIColor blackColor];
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        return cell;
    } else {
        ConsultMedicineMyFavCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConsultMedicineMyFavCell"];
        [self configureMyFavCell:cell forIndexPath:indexPath];
        if ([self containSelectInSet:indexPath.row isMyFav:YES]) {
            cell.imgSelect.hidden = NO;
            cell.lblTitle.textColor = UICOLOR(69, 192, 26);
            cell.contentView.backgroundColor = [UIColor clearColor];
        } else {
            cell.imgSelect.hidden = YES;
            cell.lblTitle.textColor = [UIColor blackColor];
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tbViewContent) {
        static ConsultMedicineCell *sizingCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sizingCell = [tableView dequeueReusableCellWithIdentifier:@"ConsultMedicineCell"];
        });
        [self configureCell:sizingCell forIndexPath:indexPath];
        sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(sizingCell.bounds));
        [sizingCell setNeedsLayout];
        [sizingCell layoutIfNeeded];
        CGSize sizeFinal = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        return sizeFinal.height+1.0f;
    } else {
        static ConsultMedicineMyFavCell *sizingCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sizingCell = [tableView dequeueReusableCellWithIdentifier:@"ConsultMedicineMyFavCell"];
        });
        [self configureMyFavCell:sizingCell forIndexPath:indexPath];
        sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(sizingCell.bounds));
        [sizingCell setNeedsLayout];
        [sizingCell layoutIfNeeded];
        CGSize sizeFinal = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        return sizeFinal.height+1.0f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tbViewMyFav) {
        return self.viewModelConsult.arrMyFavPharmacyList.count;
    }
    return self.viewModelConsult.arrNearPharmacyList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tbViewContent) {
        [self operateSelectInSet:indexPath.row isMyFav:NO];
        ConsultMedicineCell *selectCell = (ConsultMedicineCell *)[tableView cellForRowAtIndexPath:indexPath];
        if ([self containSelectInSet:indexPath.row isMyFav:NO]) {
            selectCell.imgSelect.hidden = NO;
            selectCell.lblTitle.textColor = UICOLOR(69, 192, 26);
            selectCell.contentView.backgroundColor = [UIColor clearColor];
        } else {
            selectCell.imgSelect.hidden = YES;
            selectCell.lblTitle.textColor = [UIColor blackColor];
            selectCell.contentView.backgroundColor = [UIColor whiteColor];
        }
    } else {
        [self operateSelectInSet:indexPath.row isMyFav:YES];
        ConsultMedicineMyFavCell *selectCell = (ConsultMedicineMyFavCell *)[tableView cellForRowAtIndexPath:indexPath];
        if ([self containSelectInSet:indexPath.row isMyFav:YES]) {
            selectCell.imgSelect.hidden = NO;
            selectCell.lblTitle.textColor = UICOLOR(69, 192, 26);
            selectCell.contentView.backgroundColor = [UIColor clearColor];
        } else {
            selectCell.imgSelect.hidden = YES;
            selectCell.lblTitle.textColor = [UIColor blackColor];
            selectCell.contentView.backgroundColor = [UIColor whiteColor];
        }
    }
}

#pragma mark - HttpResponse methods
- (void)ConsultPharmacySuccessWithTag:(TagConsultPharmacy)tag
{
    if (tag == ConsultPharmacyNearList) {
        if (self.viewModelConsult.arrNearPharmacyList.count <= 0) {
            [self appealLocationAndDataStatus:Enum_noData];
        } else {
            [self appealLocationAndDataStatus:Enum_DataNormal];
            [self.setSelected addObject:@0];
            [self.setSelected addObject:@1];
            [self.tbViewContent reloadData];
        }
    } else if (tag == ConsultPharmacyMyFav) {
        if (self.viewModelConsult.arrMyFavPharmacyList.count <= 0) {
            self.lblMyFavNoNetWork.text = K_NODATA_MYFAV;
            self.lblMyFavNoNetWork.hidden = NO;
            self.tbViewMyFav.hidden = YES;
        } else {
            self.lblMyFavNoNetWork.hidden = YES;
            self.tbViewMyFav.hidden = NO;
            [self.tbViewMyFav reloadData];
        }
        [self.tbViewMyFav footerEndRefreshing];
    }
}

- (void)ConsultPharmacyFailWithTag:(TagConsultPharmacy)tag msg:(NSString *)strResponse
{
    if (tag == ConsultPharmacyNearList) {
        [self appealLocationAndDataStatus:Enum_noData];
    } else if (tag == ConsultPharmacyMyFav) {
        self.lblMyFavNoNetWork.hidden = NO;
        self.tbViewMyFav.hidden = YES;
        [self.tbViewMyFav footerEndRefreshing];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)checkLogin
{
    if (!app.logStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
        return NO;
    } else {
        return YES;
    }
}

- (IBAction)btnPressed_choosePharmacySource:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn == self.btnChooseMyFav) {
        if (self.btnChooseMyFav.selected == YES) {
            return;
        } else {
            if (![self checkLogin]) {
                return;
            }
            self.btnChooseMyFav.selected = YES;
            self.btnChooseAround.selected = NO;
            self.imgMyFav.highlighted = YES;
            self.imgAround.highlighted = NO;
            self.viewFavPharmacy.hidden = NO;
            self.viewNearPharmacy.hidden = YES;
            if (self.viewModelConsult.arrMyFavPharmacyList.count>0) {
                return;
            }
            [self requestForMyFavPharmacyList:app.configureList[APP_USER_TOKEN]];
        }
    } else {
        if (self.btnChooseAround.selected == YES) {
            return;
        } else {
            self.btnChooseAround.selected = YES;
            self.btnChooseMyFav.selected = NO;
            self.imgMyFav.highlighted = NO;
            self.imgAround.highlighted = YES;
            self.viewFavPharmacy.hidden = YES;
            self.viewNearPharmacy.hidden = NO;
        }
    }
}

- (IBAction)btnPressed_updateLocation:(id)sender {
    self.progressWait = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressWait.mode = MBProgressHUDModeIndeterminate;
    self.progressWait.labelText = @"正在重新定位";
    [self startUserLocation];
}

- (void)showAlertWithMsg:(NSString *)strMsg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:strMsg delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
    [alert show];
}

- (IBAction)btnPressed_submit:(id)sender
{
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        return;
    }
    if (![self checkLogin]) {
        return;
    }
    __block NSMutableArray *selectedArr = [@[] mutableCopy];
    for (NSNumber *num in self.setSelected) {
        NSDictionary *dicContent = self.viewModelConsult.arrNearPharmacyList[[num integerValue]];
        [selectedArr addObject:dicContent];
    }
    if (self.viewModelConsult.arrMyFavPharmacyList.count > 0) {
        
        [self.setMyFavSelected enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            NSNumber *num = obj;
            NSDictionary *dicTemp = self.viewModelConsult.arrMyFavPharmacyList[[num integerValue]];
            BOOL exist = NO;
            for (int i = 0; i < selectedArr.count; i++) {
                NSDictionary *dicExist = selectedArr[i];
                if ([dicTemp[@"accountId"] isEqualToString:dicExist[@"accountId"]]) {
                    exist = YES;
                }
            }
            if (exist == NO) {
                [selectedArr addObject:dicTemp];
            } else {
            }
        }];
    }
    if (selectedArr.count <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请至少选择一家药房" duration:0.8f];
        return;
    }
    if (selectedArr.count > 5) {
        [SVProgressHUD showErrorWithStatus:@"最多只能选择5个药房" duration:0.8f];
        return;
    }
    [self.setSelected removeAllObjects];
    __block NSDate *date = [NSDate date];
    NSLog(@"comment content is %@, selected arr is %@",self.dicConsult,selectedArr);
    [selectedArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *storeDict = (NSDictionary *)obj;
        NSString *messageSenderId = storeDict[@"accountId"];
        
        NSString *UUID = [XMPPStream generateUUID];
        
        [app.dataBase insertMessages:[NSNumber numberWithInt:XHBubbleMessageTypeSending] timestamp:[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]] UUID:UUID star:@"0" avatorUrl:@"" sendName:app.configureList[APP_PASSPORTID_KEY] recvName:messageSenderId issend:[NSNumber numberWithInt:SendFailure] messagetype:[NSNumber numberWithInt:XHBubbleMessageMediaTypeText] unread:[NSNumber numberWithInt:0] richbody:@"" body:self.dicConsult[@"consult_content"]];
        
        [app.dataBase insertHistorys:messageSenderId timestamp:[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]] body:self.dicConsult[@"consult_content"] direction:[NSNumber numberWithInt:XHBubbleMessageTypeSending] messagetype:[NSNumber numberWithInt:XHBubbleMessageMediaTypeText] UUID:UUID issend:[NSNumber numberWithInt:SendFailure] avatarUrl:@""];
        
        double timeDouble = [date timeIntervalSince1970] * 1000;
        if(![[[XMPPManager sharedInstance] xmppStream] isConnected])
        {
            [SVProgressHUD showErrorWithStatus:@"网络连接不可用，请稍后重试" duration:0.8f];
            return;
        }
        XMPPIQ *messageIq = [XMPPIQ messageTypeWithText:self.dicConsult[@"consult_content"] withTo:messageSenderId avatarUrl:@"" from:app.configureList[APP_PASSPORTID_KEY] timestamp:timeDouble UUID:UUID];
        [[[XMPPManager sharedInstance] xmppStream] sendIQ:messageIq withTag:0];
    }];
    
    
    MessageBoxViewController *messageBoxViewController = [[MessageBoxViewController alloc] initWithNibName:@"MessageBoxViewController" bundle:nil];
    [self.navigationController pushViewController:messageBoxViewController animated:YES];
    
    
}
@end
