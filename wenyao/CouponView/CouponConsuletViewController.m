//
//  CouponConsuletViewController.m
//  wenyao
//
//  Created by 李坚 on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "CouponConsuletViewController.h"
#import "CouponFactoryTableViewCell.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "PharmacyStoreViewController.h"
#import "ReturnIndexView.h"
#import "AppDelegate.h"

@interface CouponConsuletViewController ()<ReturnIndexViewDelegate>
{
    int currentPage;
}
@property (strong, nonatomic)ReturnIndexView *indexView;
@end

@implementation CouponConsuletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentPage = 1;
    self.array = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view from its nib.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    self.tableView.footerPullToRefreshText = @"上拉加载更多数据";
    self.tableView.footerReleaseToRefreshText = @"松开加载更多数据";
    self.tableView.footerRefreshingText = @"正在加载中";
    
    [self loadData];
    [self setUpRightItem];
}

#pragma mark---------------------------------------------跳转到首页-----------------------------------------------

- (void)setUpRightItem
{
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -6;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-unfold.PNG"] style:UIBarButtonItemStylePlain target:self action:@selector(returnIndex)];
    self.navigationItem.rightBarButtonItems = @[fixed,rightItem];
}
- (void)returnIndex
{
    self.indexView = [ReturnIndexView sharedManagerWithImage:@[@"icon home.PNG"] title:@[@"首页"]];
    self.indexView.delegate = self;
    [self.indexView show];
}
- (void)RetunIndexView:(ReturnIndexView *)ReturnIndexView didSelectedIndex:(NSIndexPath *)indexPath
{
    [self.indexView hide];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self performSelector:@selector(delayPopToHome) withObject:nil afterDelay:0.01];
}
- (void)delayPopToHome
{
    [app.tabBarController setSelectedIndex:0];
}
#pragma mark---------------------------------------------跳转到首页-----------------------------------------------



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = @"优惠药店";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)footerRereshing{
    
    [self loadData];
}

- (void)loadData{
    
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"promotion"] = self.promotionId;
    setting[@"page"] = @(currentPage);
    setting[@"pageSize"] = @(PAGE_ROW_NUM);
    
    [[HTTPRequestManager sharedInstance]CouponStoreCollectList:setting completionSuc:^(id resultObj){
        
        [self.array addObjectsFromArray:resultObj[@"body"][@"list"]];
        [self.tableView reloadData];
        currentPage++;
        [self.tableView footerEndRefreshing];
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        [self.tableView footerEndRefreshing];
        [SVProgressHUD showErrorWithStatus:@"加载失败!" duration:0.8f];
    }];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 85.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * cellIdentifier = @"CouponFactoryCell";
    CouponFactoryTableViewCell * cell = (CouponFactoryTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"CouponFactoryTableViewCell" owner:self options:nil][0];
        //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsZero;// UIEdgeInsetsMake(0, 0, 0, 0);
        UIView *bkView = [[UIView alloc]initWithFrame:cell.frame];
        bkView.backgroundColor = UIColorFromRGB(0xdfe4e6);
        cell.selectedBackgroundView = bkView;
    }
    cell.factoryNameLabel.text = self.array[indexPath.row][@"name"];
    cell.addressLabel.text = self.array[indexPath.row][@"addr"];
    [cell.factoryImage setImageWithURL:self.array[indexPath.row][@"url"] placeholderImage:[UIImage imageNamed:@"药店默认头像.png"]];

    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 84.5, APP_W,0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [cell addSubview:line];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSIndexPath *selection = [tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
//    
//    PharmacyStoreViewController *pharmacyStoreView = [[PharmacyStoreViewController alloc]initWithNibName:@"PharmacyStoreViewController" bundle:nil];
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"id"] = self.array[indexPath.row][@"id"];
//    pharmacyStoreView.infoDict = dic;
//    [self.navigationController pushViewController:pharmacyStoreView animated:YES];
}

@end
