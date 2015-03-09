//
//  CouponHomePageViewController.m
//  wenyao
//
//  Created by 李坚 on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "CouponHomePageViewController.h"
#import "CouponTableViewCell.h"
#import "CouponDeatilViewController.h"
#import "Constant.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "UIViewController+isNetwork.h"
#import "ReturnIndexView.h"
#import "AppDelegate.h"

@interface CouponHomePageViewController ()<ReturnIndexViewDelegate>
{
    UIView *_nodataView;
    int currentPage;
//    BOOL isCityExist;
}
@property (strong, nonatomic) ReturnIndexView *indexView;
@end

@implementation CouponHomePageViewController

- (void)BtnClick{
    
    if(![self isNetWorking]){
        [[self.view viewWithTag:999] removeFromSuperview];
        [self subViewDidLoad];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if([self isNetWorking]){
        
        [self addNetView];
        return;
    }
    [self subViewDidLoad];
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
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 18) ];
    titleLabel.text = @"优惠活动";
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    titleLabel.textColor = UIColorFromRGB(0xffffff);
    
    self.navigationItem.titleView = titleLabel;
}

- (void)subViewDidLoad{
    
//    if(self.provinceName && ![self.provinceName isEqualToString:@""]
//       && self.cityName && ![self.cityName isEqualToString:@""]){
//        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
//        setting[@"province"] = self.provinceName;
//        setting[@"city"] = self.cityName;
//        [[HTTPRequestManager sharedInstance] checkOpenCity:setting completion:^(id resultObj)
//         {
//             if([resultObj[@"result"] isEqualToString:@"OK"]) {
//                 if([resultObj[@"body"][@"open"] integerValue] == 0) {
//                     isCityExist = NO;
//                     [self showNoDataViewWithString:@"您所在城市未开通免费问药服务，敬请期待！"];
//                     return;
//                 }else{
//                     isCityExist = YES;
//                 }
//             }
//         }failure:^(id failMsg) {
//             
//         }];
//    }else{
//        isCityExist = NO;
//    }
    
    self.couponArray = [[NSMutableArray alloc]init];
    
    //    self.navigationItem.prompt = @"Add photos with faces to Googlyify them!";
    // Do any additional setup after loading the view from its nib.
    self.tableView.frame = CGRectMake(4, 0, APP_W, APP_H - 64);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 216.0f;
    self.tableView.backgroundColor = UIColorFromRGB(0xf5f5f5);
    
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    self.tableView.footerPullToRefreshText = @"上拉加载更多数据";
    self.tableView.footerReleaseToRefreshText = @"松开加载更多数据";
    self.tableView.footerRefreshingText = @"正在加载中";
    currentPage = 1;
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)footerRereshing{
    
    [self loadData];
}

#pragma mark - HTTP请求
- (void)loadData{
    
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"page"] = @(currentPage);
    setting[@"pageSize"] = @(PAGE_ROW_NUM);
    
    if(self.provinceName && ![self.provinceName isEqualToString:@""]){
    setting[@"province"] = self.provinceName;//省名称
    }
    if(self.cityName && ![self.cityName isEqualToString:@""]){
        setting[@"city"] = self.cityName;//市名称
    }
    
    [[HTTPRequestManager sharedInstance]couponList:setting completionSuc:^(id resultObj){
        if([resultObj[@"result"] isEqualToString:@"OK"]){
            if(resultObj[@"body"][@"list"] && [resultObj[@"body"][@"list"] isKindOfClass:[NSArray class]]){
                
                [self.couponArray addObjectsFromArray:resultObj[@"body"][@"list"]];
                [self.tableView reloadData];
                currentPage++;
                [self.tableView footerEndRefreshing];
            }
        }
        else {
            if(resultObj[@"msg"] && [resultObj[@"msg"] isKindOfClass:[NSString class]]){
                [self showNoDataViewWithString:resultObj[@"msg"]];
            }
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        [self.tableView footerEndRefreshing];
        [SVProgressHUD showErrorWithStatus:@"加载失败!" duration:0.8f];
    }];
    
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    return self.couponArray.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *Identifier = @"couponCell";
    
    CouponTableViewCell *cell = (CouponTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:Identifier];
    if(cell == nil){
        UINib *nib = [UINib nibWithNibName:@"CouponTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:Identifier];
        cell = (CouponTableViewCell *)[tableView dequeueReusableCellWithIdentifier:Identifier];
        UIView *selectedView = [[UIView alloc]initWithFrame:cell.frame];
        selectedView.backgroundColor = UIColorFromRGB(0xffffff);
        
        cell.selectedBackgroundView = selectedView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.titleLabel.text = self.couponArray[indexPath.row][@"title"];
    
    [cell.backImage setImageWithURL:[NSURL URLWithString:self.couponArray[indexPath.row][@"url"]] placeholderImage:[UIImage imageNamed:@"type1.png"]];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSIndexPath *selection = [tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
    
    CouponDeatilViewController *detailView = [[CouponDeatilViewController alloc]initWithNibName:@"CouponDeatilViewController" bundle:nil];
    detailView.promotionId = self.couponArray[indexPath.row][@"id"];
    detailView.infoDic = self.couponArray[indexPath.row];
    [self.navigationController pushViewController:detailView animated:YES];
}


-(void)showNoDataViewWithString:(NSString *)nodataPrompt
{
    if (_nodataView) {
        [_nodataView removeFromSuperview];
    }
    _nodataView = [[UIView alloc]initWithFrame:self.view.bounds];
    //_nodataView.backgroundColor = COLOR(242, 242, 242);
    _nodataView.backgroundColor = BG_COLOR;
    
    //    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]init];
    //    [tap addTarget:self action:@selector(keyboardHidenClick)];
    //    [_nodataView addGestureRecognizer:tap];
    UIImage * noCollectImage = [UIImage imageNamed:@"无收藏.png"];
    
    UIImageView *dataEmpty = [[UIImageView alloc]initWithFrame:RECT(0, 0, noCollectImage.size.width, noCollectImage.size.height)];
    dataEmpty.center = CGPointMake(APP_W/2, 110);
    dataEmpty.image = noCollectImage;
    [_nodataView addSubview:dataEmpty];
    
    UILabel* lable_ = [[UILabel alloc]initWithFrame:RECT(0,dataEmpty.frame.origin.y + dataEmpty.frame.size.height + 10, nodataPrompt.length*20,30)];
    lable_.font = Font(12);
    lable_.textColor = COLOR(137, 136, 155);
    lable_.textAlignment = NSTextAlignmentCenter;
    lable_.center = CGPointMake(APP_W/2, lable_.center.y);
    lable_.text = nodataPrompt;
    
    [_nodataView addSubview:lable_];
    //[[UIApplication sharedApplication].keyWindow addSubview:_nodataView];
    [self.view insertSubview:_nodataView atIndex:self.view.subviews.count];
}


@end
