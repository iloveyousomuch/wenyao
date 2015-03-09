//
//  QZMyOrderViewController.m
//  wenyao
//
//  Created by Meng on 15/1/16.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "QZMyOrderViewController.h"
#import "ProductOrderCell.h"
#import "AppDelegate.h"
#import "OrderDetailViewController.h"
#import "MJRefresh.h"
#import "OrderTableViewCell.h"
#import "ReturnIndexView.h"

@interface QZMyOrderViewController()<ReturnIndexViewDelegate>
{
    UIView *_nodataView;
    int currentPage;
}

@property (strong, nonatomic) ReturnIndexView *indexView;
@property (nonatomic ,strong) NSMutableArray *dataSource;

@end

@implementation QZMyOrderViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"我的优惠订单";
        [self.tableView setFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H)];
        UIView *tableFooterView = [[UIView alloc]init];
        tableFooterView.backgroundColor = UIColorFromRGB(0xf5f5f5);
        self.tableView.tableFooterView = tableFooterView;
        self.tableView.separatorInset = UIEdgeInsetsZero;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
        self.tableView.footerPullToRefreshText = @"上拉加载更多数据";
        self.tableView.footerReleaseToRefreshText = @"松开加载更多数据";
        self.tableView.footerRefreshingText = @"正在加载中";
        
    }
    return self;
}

- (void)footerRereshing{
    
    currentPage ++;
    [self loadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    currentPage = 1;
    self.dataSource = [NSMutableArray array];
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


- (void)loadData{
    
    
    if (app.currentNetWork != kNotReachable) {
        
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        setting[@"token"] = app.configureList[APP_USER_TOKEN];
        setting[@"page"] = @(currentPage);
        setting[@"pageSize"] = @(10);
        
        [[HTTPRequestManager sharedInstance] promotionOrder:setting completionSuc:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                
                [self.dataSource addObjectsFromArray:resultObj[@"body"][@"list"]];
                if (self.dataSource.count > 0) {
                    [self cacheMyOrder:self.dataSource];
                    [self.tableView footerEndRefreshing];
                    [self.tableView reloadData];
                }else{
                    [self.tableView footerEndRefreshing];
                    [self showNoDataViewWithString:@"您还没有订单哦!"];
                }
            }
        } failure:^(id failMsg) {
            [self.tableView footerEndRefreshing];
        }];
    }else{
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:[app.dataBase queryAllMyOrderList]];
        if (self.dataSource.count > 0) {
            [self.tableView reloadData];
        }else{
            [self showNoDataViewWithString:@"您还没有订单哦!"];
        }
        [self.tableView footerEndRefreshing];
    }

}

- (void)cacheMyOrder:(NSArray *)array
{
    [app.dataBase removeAllMyOrderList];
    for (NSDictionary *dic in array) {
        NSString *inviter = [NSString stringWithFormat:@"%@",dic[@"inviter"]];
        if (inviter.length == 0) {
            inviter = @"";
        }
        
        [app.dataBase insertMyOrderListWithOrderId:dic[@"id"] proName:dic[@"proName"] type:[NSString stringWithFormat:@"%@",dic[@"type"]] date:dic[@"date"] discount:[NSString stringWithFormat:@"%f",[dic[@"discount"] floatValue]]  totalLargess:[NSString stringWithFormat:@"%f",[dic[@"totalLargess"] floatValue]]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    ProductOrderCell *cell = (ProductOrderCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"ProductOrderCell" owner:self options:nil][0];
    }
   
    NSDictionary *dic = self.dataSource[indexPath.row];
    cell.proName.text = dic[@"proName"];
    
    NSString *type = [NSString stringWithFormat:@"%@",dic[@"type"]];
    NSString *typeStr = nil;
    NSString *couponStr = nil;
    
    if ([type isEqualToString:@"1"]) {
        typeStr = @"折扣";
        couponStr = [NSString stringWithFormat:@"（优惠%.1f元）",[dic[@"discount"] floatValue]];
    }else if ([type isEqualToString:@"2"]){
        typeStr = @"抵现";
        couponStr = [NSString stringWithFormat:@"（优惠%.1f元）",[dic[@"discount"] floatValue]];
    }else if ([type isEqualToString:@"3"]){
        typeStr = @"买赠";
        couponStr = [NSString stringWithFormat:@"（赠送%d件商品）",[dic[@"totalLargess"] intValue]];
    }
    cell.typeLabel.text = typeStr;
    cell.date.text = dic[@"date"];
    cell.couponLabel.text = couponStr;
  
    if(indexPath.row != self.dataSource.count){
        
        cell.seperatorView.layer.masksToBounds = YES;
        cell.seperatorView.layer.borderWidth = 0.5f;
        cell.seperatorView.layer.borderColor = UIColorFromRGB(0xdbdbdb).CGColor;
    }
    
//    static NSString *cellIdentifier = @"cellIdentifier";
//    
//    OrderTableViewCell *cell = (OrderTableViewCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:cellIdentifier];
//    if (cell == nil) {
//        cell = [[NSBundle mainBundle] loadNibNamed:@"OrderTableViewCell" owner:self options:nil][0];
//    }
//    
//    NSDictionary *dic = self.dataSource[indexPath.row];
//  
//    cell.proNameLabel.text = dic[@"proName"];
//    cell.couponNameLabel.text = [self replaceSpecialStringWith:dic[@"title"]];
//    cell.consultNameLabel.text = dic[@"branch"];
//    cell.timeLabel.text = dic[@"date"];
//    cell.countLabel.text = [NSString stringWithFormat:@"%d",[dic[@"quantity"] intValue]];
//    cell.priceLabel.text = [NSString stringWithFormat:@"%.2f",[dic[@"price"] floatValue]];
//    
//    if(dic[@"inviter"] && ![dic[@"inviter"] isEqualToString:@""]){
//        cell.recommderLabel.hidden = NO;
//        cell.inviterLabel.hidden = NO;
//        cell.inviterLabel.text = [NSString stringWithFormat:@"%@",dic[@"inviter"]];
//    }else{
//        cell.recommderLabel.hidden = YES;
//        cell.inviterLabel.hidden = YES;
//    }
//    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OrderDetailViewController *orderDetail = [[OrderDetailViewController alloc] initWithNibName:@"OrderDetailViewController" bundle:nil];
    orderDetail.activityDict = self.dataSource[indexPath.row];
    [self.navigationController pushViewController:orderDetail animated:YES];
}

-(void)showNoDataViewWithString:(NSString *)nodataPrompt
{
    if (_nodataView) {
        [_nodataView removeFromSuperview];
        _nodataView = nil;
    }
    _nodataView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H)];
    //_nodataView.backgroundColor = COLOR(242, 242, 242);
    _nodataView.backgroundColor = BG_COLOR;
    
    
    //    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]init];
    //    [tap addTarget:self action:@selector(keyboardHidenClick)];
    //    [_nodataView addGestureRecognizer:tap];
    UIImage * searchImage = [UIImage imageNamed:@"无收藏.png"];
    
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

@end
