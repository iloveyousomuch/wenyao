//
//  InformationListViewController.m
//  quanzhi
//
//  Created by xiezhenghong on 14-6-24.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "InformationListViewController.h"
#import "InformationTableViewCell.h"
#import "HTTPRequestManager.h"
#import "UIImageView+WebCache.h"
#import "Appdelegate.h"
#import "Constant.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "SBJson.h"
#import "HealthIndicatorDetailViewController.h"
#import "XLCycleScrollView.h"
#import "LoginViewController.h"
#import "CRGradientLabel.h"


@interface InformationListViewController ()<XLCycleScrollViewDelegate,XLCycleScrollViewDatasource>
{
    XLCycleScrollView *scrollView;
}
@property (nonatomic, strong) NSMutableArray    *likeArray;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, assign) BOOL loadFromLocal;

@property (nonatomic, assign) NSInteger curPage;

@end

@implementation InformationListViewController

- (id)init
{
    self = [super init];
    return self;
}


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
    
    self.infoList = [NSMutableArray arrayWithCapacity:15];
    self.likeArray = [NSMutableArray arrayWithCapacity:15];
    self.bannerList = [NSMutableArray arrayWithCapacity:3];
    [self setupTableView];
    [self setupHeaderView];
    
    self.tableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
    self.tableView.footerReleaseToRefreshText = @"松开加载更多数据了";
    self.tableView.footerRefreshingText = @"正在帮你加载中";
    __weak InformationListViewController *weakSelf = self;
    [self.tableView addFooterWithCallback:^{
        if (app.currentNetWork != kNotReachable) {
            weakSelf.curPage++;
            [weakSelf getHealthyAdviceList];
        } else {
            [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
            [weakSelf.tableView footerEndRefreshing];
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutAction) name:QUIT_OUT object:nil];
}
- (void)logoutAction
{
    if (self.infoList && self.infoList.count > 0) {
        [self.infoList removeAllObjects];
    }
    if (self.bannerList && self.bannerList.count > 0) {
        [self.bannerList removeAllObjects];
    }
}

- (void)loadAdviceListLocalCache
{
    if (self.infoList.count > 0) {
        [self.infoList removeAllObjects];
    }
    [self.infoList addObjectsFromArray:[app.cacheBase queryAllHealthAdviceListWithChannelId:self.infoDict[@"channelId"]]];
    [self.tableView reloadData];
    NSLog(@"%s,%@",__func__,self.infoList);
}

- (void)loadBannerListLocalCache
{
    if (self.bannerList.count > 0) {
        [self.bannerList removeAllObjects];
    }
    [self.bannerList addObjectsFromArray:[app.cacheBase queryAllBannerListWithChannelId:self.infoDict[@"channelId"]]];
    if([self.bannerList count] > 0) {
        if (self.bannerList.count == 1) {
            scrollView.scrollView.scrollEnabled = NO;
        } else {
            scrollView.scrollView.scrollEnabled = YES;
        }
    } else {
        scrollView.scrollView.scrollEnabled = NO;
    }
    [scrollView reloadData];
    
    NSLog(@"%s,%@",__func__,self.bannerList);
}

- (void)cacheAdviceList:(NSArray *)arrAdviceList
{
    for (int i = 0; i < arrAdviceList.count; i++) {
        NSDictionary *dicAdvice = arrAdviceList[i];
        
        [app.cacheBase insertIntoHealthAdviceList:self.infoDict[@"channelId"] adviceId:dicAdvice[@"adviceId"] iconUrl:dicAdvice[@"iconUrl"] imgUrl:dicAdvice[@"imgUrl"] introduction:dicAdvice[@"introduction"] likeNumber:[dicAdvice[@"likeNumber"] intValue] pariseNum:[dicAdvice[@"pariseNum"] intValue] publishTime:dicAdvice[@"publishTime"] publisher:dicAdvice[@"publisher"] readNum:[dicAdvice[@"readNum"] intValue] source:dicAdvice[@"source"] title:dicAdvice[@"title"]];
        
    }
}

- (void)cacheBannerList:(NSArray *)arrBannerList
{
    for (int i = 0; i < arrBannerList.count; i++) {
        NSDictionary *dicBanner = arrBannerList[i];
        [app.cacheBase insertIntoHealthBannerList:self.infoDict[@"channelId"] adviceId:dicBanner[@"adviceId"] bannerImgUrl:dicBanner[@"bannerImgUrl"]];
    }
}

- (void)getHealthyAdviceList
{
    __weak InformationListViewController *weakSelf = self;
    if (app.currentNetWork == kNotReachable) {
        [self loadAdviceListLocalCache];
    } else {
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        setting[@"channelId"] = self.infoDict[@"channelId"];
        setting[@"currPage"] = [NSString stringWithFormat:@"%d",weakSelf.curPage];
        setting[@"pageSize"] = @"10";
        
        [[HTTPRequestManager sharedInstance] queryHealthAdviceList:setting completion:^(id resultObj) {
            if([resultObj[@"result"] isEqualToString:@"OK"]){
                
                
                NSArray *array = resultObj[@"body"][@"data"];
                if (weakSelf.curPage == 1) {
                    [self.infoList removeAllObjects];
                    [app.cacheBase removeHealthAdviceListWithChannelId:self.infoDict[@"channelId"]];
                }
                
                __weak InformationListViewController *weakSelf = self;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [weakSelf cacheAdviceList:array];
                });
                
                for(NSDictionary *dict in array) {
                    [weakSelf.infoList addObject:[dict mutableCopy]];
                }
                [weakSelf.tableView reloadData];
            }
            [self.tableView footerEndRefreshing];
        } failure:^(NSError *error) {
            [self.tableView footerEndRefreshing];
        }];
    }
}

- (void)getHealthyBannerList
{
    __weak InformationListViewController *weakSelf = self;
    if (app.currentNetWork == kNotReachable) {
        [self loadBannerListLocalCache];
    } else {
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        setting[@"channelId"] = self.infoDict[@"channelId"];
        [[HTTPRequestManager sharedInstance] queryChannelBanner:setting completion:^(id resultObj) {
            if([resultObj[@"result"] isEqualToString:@"OK"]){
                [self.bannerList removeAllObjects];
                NSArray *array = resultObj[@"body"][@"data"];
                NSLog(@"the banner list is %@",array);
                [app.cacheBase removeAllBannerListWithChannelId:self.infoDict[@"channelId"]];
                __weak InformationListViewController *weakSelf = self;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [weakSelf cacheBannerList:array];
                });
                //                    [self cacheBannerList:array];
                if([array count] > 0) {
                    [self.bannerList addObjectsFromArray:array];
                    if (array.count == 1) {
                        scrollView.scrollView.scrollEnabled = NO;
                    } else {
                        scrollView.scrollView.scrollEnabled = YES;
                    }
                } else {
                    scrollView.scrollView.scrollEnabled = NO;
                }
                [scrollView reloadData];
            }
        } failure:NULL];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.infoList.count == 0)
    {
        self.curPage = 1;
        [self getHealthyAdviceList];
    }
    if(self.bannerList.count == 0)
    {
        self.curPage = 1;
        [self getHealthyBannerList];
    }
    [self.tableView reloadData];
}

- (void)setupTableView
{
    CGRect rect = self.view.frame;
    rect.size.height -= (64 + 35 + 44);
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:UIColorFromRGB(0xecf0f1)];
    self.tableView.rowHeight = 120.0f;
    [self.view addSubview:self.tableView];
}

- (void)setupHeaderView
{
    scrollView = [[XLCycleScrollView alloc] initWithFrame:CGRectMake(0, 0,APP_W, 175)];
    scrollView.delegate = self;
    scrollView.datasource = self;
    self.tableView.tableHeaderView = scrollView;
}

#pragma mark -
#pragma mark XLCycleScrollViewDelegate
- (void)didClickPage:(XLCycleScrollView *)csView atIndex:(NSInteger)index
{
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        return;
    }
    if (self.bannerList.count <= 0) {
        return;
    }
    NSDictionary *dicBanner = self.bannerList[index];
    HealthIndicatorDetailViewController *detailViewController = [[HealthIndicatorDetailViewController alloc] initWithNibName:@"HealthIndicatorDetailViewController" bundle:nil];
    detailViewController.hidesBottomBarWhenPushed = YES;
    detailViewController.intFromBanner = 1;
    detailViewController.guideId = dicBanner[@"adviceId"];
    detailViewController.infoDict = [dicBanner mutableCopy];
    [self.navigationController pushViewController:detailViewController animated:YES];
    
}

- (NSInteger)numberOfPages
{
    if (self.bannerList.count <= 0) {
        return 1;
    } else {
        if(self.bannerList.count == 1){
            scrollView.pageControl.hidden = YES;
            return 1;
        }
        else{
        scrollView.pageControl.hidden = NO;
        return [self.bannerList count];
        }
    }
}

- (UIView *)pageAtIndex:(NSInteger)index
{
    if (self.bannerList.count <= 0) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,APP_W, 175)];
        [imageView setImage:[UIImage imageNamed:@"药品默认图片.png"]];
        return imageView;
    } else {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,APP_W, 175)];
        [imageView setImageWithURL:[NSURL URLWithString:self.bannerList[index][@"bannerImgUrl"]] placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
        CRGradientLabel *gradientLabel = [[CRGradientLabel alloc] initWithFrame:CGRectMake(0, 134, APP_W, 41)];
        gradientLabel.gradientColors = @[[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.47f], [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.0f]];
        [imageView addSubview:gradientLabel];
        UILabel *bannerTitle=[[UILabel alloc]initWithFrame:CGRectMake(12, 148, APP_W-24, 15)];
        bannerTitle.text=self.bannerList[index][@"bannerTitle"];
        bannerTitle.font = Font(15);
        bannerTitle.textColor = [UIColor whiteColor];
        [imageView addSubview:bannerTitle];

        return imageView;
    }
}

#pragma mark -
#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0f;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    return [self.infoList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *InformationTableViewCellCellIdentifier = @"InformationTableViewCellCellIdentifier";
    InformationTableViewCell *cell = (InformationTableViewCell *)[atableView dequeueReusableCellWithIdentifier:InformationTableViewCellCellIdentifier];
    if(cell == nil)
    {
        UINib *nib = [UINib nibWithNibName:@"InformationTableViewCell" bundle:nil];
        [atableView registerNib:nib forCellReuseIdentifier:InformationTableViewCellCellIdentifier];
        cell = (InformationTableViewCell *)[atableView dequeueReusableCellWithIdentifier:InformationTableViewCellCellIdentifier];
        
    }
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 120 - 0.5, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [cell addSubview:line];
    
    NSDictionary *dict = self.infoList[indexPath.row];
    
    cell.titleLabel.text = dict[@"title"];
    NSString *strTime;
    if ([dict[@"publishTime"] isKindOfClass:[NSNull class]]) {
        strTime = @"";
    } else {
        strTime = dict[@"publishTime"];
    }
    
    if (strTime.length >= 10) {
        cell.dateLabel.text = [strTime substringToIndex:10];
    } else {
        cell.dateLabel.text = strTime;
    }
    
    if(dict[@"pariseNum"]){
        if ([dict[@"pariseNum"] intValue] > 99) {
             cell.praiseLabel.text = [NSString stringWithFormat:@"99+"];
        } else {
             cell.praiseLabel.text = [NSString stringWithFormat:@"%@",dict[@"pariseNum"]];
        }
    }else{
        cell.praiseLabel.text = @"0";
    }
    if(dict[@"readNum"]){
//        if ([dict[@"readNum"] intValue] > 99) {
//            cell.readedLabel.text = [NSString stringWithFormat:@"99+"];
//        } else {
            cell.readedLabel.text = [NSString stringWithFormat:@"%@",dict[@"readNum"]];
//        }
    }else{
        cell.readedLabel.text = @"0";
    }
    cell.contentLabel.text = dict[@"introduction"];
    
//    cell.avatar.frame = CGRectMake(8, 34.5, 62.5, 62.5);
    [cell.avatar setImageWithURL:[NSURL URLWithString:dict[@"iconUrl"]] placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
    
    return cell;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (app.currentNetWork == kNotReachable) {
//        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
//        return;
//    }
    self.selectedIndex = indexPath.row;
    HealthIndicatorDetailViewController *detailViewController = [[HealthIndicatorDetailViewController alloc] initWithNibName:@"HealthIndicatorDetailViewController" bundle:nil];
    detailViewController.hidesBottomBarWhenPushed = YES;
    detailViewController.infoList = self;
    detailViewController.infoDict = self.infoList[indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
