//
//  ConsultPharmacySearchViewController.m
//  wenyao
//
//  Created by Meng on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "ConsultPharmacySearchViewController.h"
//#import "MATagButtonView.h"
#import "NSString+AbandonStringBlank.h"
#import "DetailTextView.h"
#import <CoreText/CoreText.h>
#import "AppDelegate.h"
#import "PharmacyStoreViewController.h"
#import "SBJson.h"
#import "MJRefresh.h"
@interface ConsultPharmacySearchViewController()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

{
    UISearchBar *m_searchBar;
    UITextField *m_searchField;
    
    UIView      *footView;
    
    UIView      *_nodataView;
    UIView      *bgView;
    
    NSInteger   currentPage;
    
    CGFloat currentLongitude;
    CGFloat currentLatitude;
    
    
    NSInteger searchType;//搜索类型,1表示搜本地,2表示搜服务器
}

@property (nonatomic ,strong) UITableView *mTableView;
@property (nonatomic ,strong) NSMutableArray *searchStoreHistory;
@property (nonatomic ,strong) NSMutableArray *cacheStoreList;
@property (nonatomic ,strong)             NSString *city;
@property (nonatomic ,strong)             NSString *province;
@property (nonatomic ,strong) NSMutableArray *dataSource;


@end

@implementation ConsultPharmacySearchViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [m_searchBar becomeFirstResponder];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [m_searchField resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = [NSMutableArray array];
    self.searchStoreHistory = [[NSMutableArray alloc] init];
    self.cacheStoreList = [[NSMutableArray alloc] init];
    [self setUpSearchBarView];
    [self setUpTableView];
    [self setUpTableViewFootView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkStatus) name:NETWORK_DISCONNECT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkStatus) name:NETWORK_RESTART object:nil];
    
    [self.searchStoreHistory addObjectsFromArray:[app.cacheBase queryAllSearchStoreHistory]];
    
    
    
    if (self.searchStoreHistory.count == 0) {
//        NSString *province = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_PROVINCE];
//        NSString *city = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_CITY];
        if (!self.locationStatus) {
            [self showNoDataViewWithString:@"定位失败" ImageName:nil];
        }else if (app.currentNetWork == kNotReachable){//网络中断
            [self showNoDataViewWithString:@"网络连接失败" ImageName:@"网络信号icon.png"];
        }else{
            [self showNoSearchHistory:@"暂无搜索记录"];
        }
    }
    
    [self netWorkStatus];
    
}

- (void)netWorkStatus
{
    NSString *province  = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_PROVINCE];
    NSString *city      = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_CITY];
    currentLongitude = [[[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_LONGITUDE] floatValue];
    currentLatitude = [[[NSUserDefaults standardUserDefaults] objectForKey:LAST_LOCATION_LATITUDE] floatValue];
    if (app.currentNetWork != kNotReachable) {//联网
        if (province.length > 0 && city.length > 0) {//已经有定位
            [[HTTPRequestManager sharedInstance] locationEncodeWithParam:@{@"province":province,@"city":city} completionSuc:^(id resultObj) {
                if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                    searchType = 2;
                    self.province = [NSString stringWithFormat:@"%@",resultObj[@"body"][@"provinceCode"]];
                    self.city     = [NSString stringWithFormat:@"%@",resultObj[@"body"][@"cityCode"]];
                }
            } failure:^(id failMsg) {
                
            }];
        }else{
            searchType = 1;
            self.cacheStoreList = [app.cacheBase selectAllStoreList];
        }
    }else{//断网
        searchType = 1;
        self.cacheStoreList = [app.cacheBase selectAllStoreList];
    }
}

#pragma mark ------ setup ------

- (void)setUpSearchBarView
{
    UIView* status_bg = [[UIView alloc] initWithFrame:RECT(0, 0, APP_W, STATUS_H)];
    status_bg.backgroundColor = APP_COLOR_STYLE;
    [self.view addSubview:status_bg];
    
    UIView* searchbg = [[UIView alloc] initWithFrame:CGRectMake(0, STATUS_H, APP_W, NAV_H)];
    searchbg.backgroundColor=APP_COLOR_STYLE;
    [self.view addSubview:searchbg];
    
    m_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, STATUS_H, APP_W-50, NAV_H)];
    m_searchBar.tintColor = [UIColor blueColor];
    m_searchBar.backgroundColor = APP_COLOR_STYLE;
    m_searchBar.placeholder = @"搜索药店";
    m_searchBar.delegate = self;
    [self.view addSubview:m_searchBar];
    
    if (iOSv7) {
        UIView* barView = [m_searchBar.subviews objectAtIndex:0];
        [[barView.subviews objectAtIndex:0] removeFromSuperview];
        UITextField* searchField = [barView.subviews objectAtIndex:0];
        searchField.font = [UIFont systemFontOfSize:13.0f];
        [searchField setReturnKeyType:UIReturnKeySearch];
        m_searchField = searchField;
    } else {
        [[m_searchBar.subviews objectAtIndex:0] removeFromSuperview];
        UITextField* searchField = [m_searchBar.subviews objectAtIndex:0];
        searchField.delegate = self;
        searchField.font = [UIFont systemFontOfSize:13.0f];
        [searchField setReturnKeyType:UIReturnKeySearch];
        m_searchField = searchField;
    }
    
    UIButton* cancelBtn = [[UIButton alloc] initWithFrame:RECT(APP_W-60, STATUS_H, 60, NAV_H)];
    cancelBtn.backgroundColor = [UIColor clearColor];
    cancelBtn.titleLabel.font = FontB(16);
    [cancelBtn setTitle:@"取消" forState:0];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:0];
    [cancelBtn addTarget:self action:@selector(onCancelBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.tag = 888;
    [self.view addSubview:cancelBtn];
}

- (void)setUpTableView{
    self.mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAV_H + STATUS_H, APP_W, APP_H-NAV_H-STATUS_H) style:UITableViewStylePlain];
    self.mTableView.delegate = self;
    self.mTableView.dataSource = self;
    self.mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.mTableView.backgroundColor = UIColorFromRGB(0xecf0f1);
    [self.view addSubview:self.mTableView];
}

- (void)setUpTableViewFootView{
    
    footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 40)];
    footView.backgroundColor = [UIColor whiteColor];
    footView.clipsToBounds = YES;
    
    UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"清空搜索记录icon.png"]];
    image.frame = CGRectMake(APP_W*0.35 - 20, 10, 15, 15);
    
    UIButton * clearBtn = [[UIButton alloc]initWithFrame:CGRectMake(APP_W*0.35, 10, 100, 15)];
    clearBtn.titleLabel.font = Font(15);
    [clearBtn setTitle:@"清空搜索历史" forState:0];
    [clearBtn setTitleColor:UIColorFromRGB(0x666666) forState:0];
    [clearBtn setBackgroundColor:[UIColor clearColor]];
    [clearBtn addTarget:self action:@selector(onClearBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [footView addSubview:image];
    [footView addSubview:clearBtn];
    
    self.mTableView.tableFooterView.frame = footView.frame;
    self.mTableView.tableFooterView = footView;
}

- (void)onClearBtnTouched:(UIButton *)button
{
    [app.cacheBase removeAllSearchStoreHistory];
    [self.searchStoreHistory removeAllObjects];
    [self showNoSearchHistory:@"暂无搜索记录"];
    [self.mTableView reloadData];
}

#pragma mark ----
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([NSString abandonStringBlank:m_searchBar.text].length == 0) {
        return 30;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if ([NSString abandonStringBlank:m_searchBar.text].length == 0) {
        UIView * v = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , APP_W, 12)];
        v.backgroundColor = UICOLOR(238, 238, 238);
        
        UIImage* icon = [UIImage imageNamed:@"clock.png"];
        UIImageView* iconView = [[UIImageView alloc ] initWithImage:icon];
        iconView.frame = RECT(14, 9, icon.size.width, icon.size.height);
        [v addSubview:iconView];
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(14+icon.size.width+5, 9, 200, 12)];
        label.font = [UIFont systemFontOfSize:12.0f];
        label.text = @"最近搜索";
        [v addSubview:label];
        return v;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([NSString abandonStringBlank:m_searchBar.text].length == 0) {
        return self.searchStoreHistory.count;
    }
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, APP_W-20, 15)];
        label.tag = 888;
        label.font = Font(14);
        [cell.contentView addSubview:label];
        
    }
    cell.textLabel.font = Font(14);
    
    if ([NSString abandonStringBlank:m_searchBar.text].length == 0) {//显示历史记录
        NSDictionary *dic = self.searchStoreHistory[indexPath.row];
        cell.textLabel.text = dic[@"name"];
    }else{//显示搜索内容
        NSDictionary *dic = self.dataSource[indexPath.row];
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:888];
        
        NSString *text = [NSString abandonStringBlank:dic[@"name"]];
        
        NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:text];
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString abandonStringBlank:m_searchBar.text] options:kNilOptions error:nil];
        
        NSRange range = NSMakeRange(0,text.length);
        
        [regex enumerateMatchesInString:text options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            NSRange subStringRange = [result rangeAtIndex:0];
            [mutableString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0/255.0f green:183/255.0f blue:45/255.0f alpha:1] range:subStringRange];
        }];
        label.attributedText = mutableString;
    }
    
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 34, APP_W, 0.5)];
    line.backgroundColor = [UIColor grayColor];
    line.alpha = 0.8;
    [cell.contentView addSubview:line];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PharmacyStoreViewController *pharmacyStoreViewController = [[PharmacyStoreViewController alloc] initWithNibName:@"PharmacyStoreViewController" bundle:nil];
    NSMutableDictionary *dict = nil;
    if ([NSString abandonStringBlank:m_searchBar.text].length > 0) {
        dict = self.dataSource[indexPath.row];
        for (int i = 0; i<self.searchStoreHistory.count; i++) {
            NSDictionary *storeDic = self.searchStoreHistory[i];
            if ([storeDic[@"id"] isEqualToString:dict[@"id"]]) {
                [self.searchStoreHistory removeObject:storeDic];
                break;
            }
        }
        
        if (self.searchStoreHistory.count == 5) {
            [self.searchStoreHistory removeObjectAtIndex:4];
        }
        [self.searchStoreHistory insertObject:dict atIndex:0];
        [app.cacheBase removeAllSearchStoreHistory];
        for(NSDictionary *dic in self.searchStoreHistory)
        {
            NSString *storeId = dic[@"id"];
            NSString *accountId = dic[@"accountId"];
            NSString *name = dic[@"name"];
            NSString *star = [NSString stringWithFormat:@"%@",dic[@"star"]];
            NSString *avgStar = [NSString stringWithFormat:@"%@",dic[@"avgStar"]];
            NSString *consult = [NSString stringWithFormat:@"%@",dic[@"consult"]];
            NSString *accType = [NSString stringWithFormat:@"%@",dic[@"accType"]];
            NSString *tel = dic[@"tel"];
            NSString *province = dic[@"province"];
            NSString *city = dic[@"city"];
            NSString *county = dic[@"county"];
            NSString *addr = dic[@"addr"];
            NSString *distance = [NSString stringWithFormat:@"%@",dic[@"distance"]];
            NSString *imgUrl = dic[@"imgUrl"];
            NSString *tags = [dic[@"tags"] JSONRepresentation];
            [app.cacheBase insertSearchHistoryStoreList:storeId name:name star:star avgStar:avgStar consult:consult accType:accType tel:tel province:province city:city county:county addr:addr distance:distance imgUrl:imgUrl accountId:accountId tags:tags];
        }
        
    }else{
        dict = self.searchStoreHistory[indexPath.row];
    }
    pharmacyStoreViewController.infoDict = dict;
    [self.navigationController pushViewController:pharmacyStoreViewController animated:YES];
}


#pragma mark -
#pragma mark -UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString *keyWord = [NSString abandonStringBlank:searchText];
    if (keyWord.length == 0) {
        if (_nodataView) {
            [_nodataView removeFromSuperview];
            _nodataView = nil;
        }
        [self.mTableView removeFooter];
        [self.dataSource removeAllObjects];
        self.mTableView.tableFooterView = footView;
        [self.searchStoreHistory removeAllObjects];
        [self.searchStoreHistory addObjectsFromArray:[app.cacheBase queryAllSearchStoreHistory]];
        if (self.searchStoreHistory.count == 0) {
            [self showNoSearchHistory:@"暂无搜索记录"];
        }
        [self.mTableView reloadData];
        
        
    }else{
        if (searchType == 2) {//搜索类型,1表示搜本地,2表示搜服务器
            currentPage = 1;
            [self.dataSource removeAllObjects];
            [self.mTableView addFooterWithTarget:self action:@selector(footerRereshing)];
            self.mTableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
            self.mTableView.footerReleaseToRefreshText = @"松开加载更多数据了";
            self.mTableView.footerRefreshingText = @"正在帮你加载中";
            
            [self loadDataWithString:keyWord];
        }else if (searchType == 1){//搜索类型,1表示搜本地,2表示搜服务器
            if (self.cacheStoreList.count > 0) {
                [self.dataSource removeAllObjects];
                for (NSDictionary *storeDic in self.cacheStoreList) {
                    NSString *name = storeDic[@"name"];
                    if (name.length > 0) {
                        NSRange wordRange = [name rangeOfString:keyWord options:NSCaseInsensitiveSearch];
                        if (wordRange.location != NSNotFound) {
                            [self.dataSource addObject:storeDic];
                        }
                    }
                    
                    
                }
                if (self.dataSource.count > 0) {
                    if (bgView) {
                        [bgView removeFromSuperview];
                        bgView = nil;
                    }
                    if (_nodataView) {
                        [_nodataView removeFromSuperview];
                        _nodataView = nil;
                    }
                    [self.mTableView reloadData];
                    self.mTableView.tableFooterView = nil;
                }else{
                    [self showNoDataViewWithString:@"没有搜索结果" ImageName:@"没有搜索结果icon.png"];
                }
                
            }else{
                [self showNoDataViewWithString:@"没有搜索结果" ImageName:@"没有搜索结果icon.png"];
            }
            
            
        }
        
        
        
    }
}


- (void)loadDataWithString:(NSString *)string
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"page"]        = @(currentPage);
    setting[@"pageSize"]    = @(20);
    setting[@"longitude"]   = @(currentLongitude);
    setting[@"latidude"]    = @(currentLatitude);
    setting[@"name"]        = [NSString abandonStringBlank:string];
    setting[@"province"]    = self.province;
    setting[@"city"]        = self.city;
    NSLog(@"setting = %@",setting);
    [[HTTPRequestManager sharedInstance] searchRegionPharmacy:setting completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            [self.dataSource addObjectsFromArray:resultObj[@"body"][@"list"]];
            if (self.dataSource.count > 0) {
                if (bgView) {
                    [bgView removeFromSuperview];
                    bgView = nil;
                }
                if (_nodataView) {
                    [_nodataView removeFromSuperview];
                    _nodataView = nil;
                }
                [self.mTableView reloadData];
                currentPage ++;
                [self.mTableView footerEndRefreshing];
                [self.mTableView setFrame:CGRectMake(0, NAV_H + STATUS_H, APP_W, APP_H-NAV_H)];
                self.mTableView.tableFooterView = nil;
            }else{
                [self showNoDataViewWithString:@"没有搜索结果" ImageName:@"没有搜索结果icon.png"];
            }
        }
    } failure:^(id failMsg) {
        [self.mTableView footerEndRefreshing];
    }];
}

- (void)footerRereshing
{
    [self loadDataWithString:[NSString abandonStringBlank:m_searchBar.text]];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([NSString abandonStringBlank:text].length == 0) {

    }else{
        
    }
    return YES;
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [m_searchBar resignFirstResponder];
}





- (void)onCancelBtnTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [m_searchBar resignFirstResponder];
    [m_searchField resignFirstResponder];
}

//显示没有历史搜索记录view
-(void)showNoDataViewWithString:(NSString *)nodataPrompt ImageName:(NSString *)imageName
{
    if (_nodataView) {
        [_nodataView removeFromSuperview];
        _nodataView = nil;
    }
    _nodataView = [[UIView alloc]initWithFrame:CGRectMake(0, NAV_H+STATUS_H, APP_W, APP_H-NAV_H-STATUS_H)];
    //_nodataView.backgroundColor = COLOR(242, 242, 242);
    _nodataView.backgroundColor = BG_COLOR;
    
    
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]init];
//    [tap addTarget:self action:@selector(keyboardHidenClick)];
//    [_nodataView addGestureRecognizer:tap];
    UIImage * searchImage = [UIImage imageNamed:imageName];
    
    UIImageView *dataEmpty = [[UIImageView alloc]initWithFrame:RECT(0, 0, searchImage.size.width, searchImage.size.height)];
    dataEmpty.center = CGPointMake(APP_W/2, 110);
    dataEmpty.image = searchImage;
    [_nodataView addSubview:dataEmpty];
    
    UILabel* lable_ = [[UILabel alloc]initWithFrame:RECT(0,dataEmpty.frame.origin.y + dataEmpty.frame.size.height + 10, nodataPrompt.length*20,30)];
    lable_.font = Font(12);
    lable_.textColor = COLOR(137, 136, 155);
    lable_.textAlignment = NSTextAlignmentCenter;
    lable_.center = CGPointMake(APP_W/2, lable_.center.y);
    lable_.text = nodataPrompt;
    
    [_nodataView addSubview:lable_];
    [self.view insertSubview:_nodataView atIndex:self.view.subviews.count];
}

//显示没有搜索记录

- (void)showNoSearchHistory:(NSString *)placeholder
{
    if (bgView) {
        [bgView removeFromSuperview];
        bgView = nil;
    }
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, NAV_H+STATUS_H, APP_W, APP_H-NAV_H-STATUS_H)];
    //bgView.backgroundColor = COLOR(242, 242, 242);
    bgView.backgroundColor = BG_COLOR;
    
    UILabel* lable_ = [[UILabel alloc]initWithFrame:RECT(0,140, APP_W, 30)];
    lable_.font = Font(15);
    lable_.textColor = UIColorFromRGB(0x7f8d96);
    lable_.textAlignment = NSTextAlignmentCenter;
    lable_.center = CGPointMake(APP_W/2, lable_.center.y);
    lable_.text = placeholder;
    [bgView addSubview:lable_];
    [self.view insertSubview:bgView atIndex:self.view.subviews.count];
}

@end
