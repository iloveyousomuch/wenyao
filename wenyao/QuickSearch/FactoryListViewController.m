//
//  FactoryList.m
//  quanzhi
//
//  Created by ZhongYun on 14-6-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "FactoryListViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "HTTPRequestManager.h"
#import "AFNetworking.h"
#import "ZhPMethod.h"
#import "MJRefresh.h"
#import "FactoryDetailViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "ReturnIndexView.h"

@interface FactoryListViewController ()<UITableViewDelegate, UITableViewDataSource,ReturnIndexViewDelegate>
{
    UITableView* m_table;
    NSMutableArray* m_data;
    int m_currPage;

}
@property (strong, nonatomic) ReturnIndexView *indexView;
@end

@implementation FactoryListViewController

- (void)dealloc
{

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"品牌展示";
        self.view.backgroundColor = [UIColor whiteColor];
        
        m_currPage = 1;
        m_data = [[NSMutableArray alloc] init];
        m_table = [[UITableView alloc] initWithFrame:RECT(0, 0, APP_W, APP_H-NAV_H)
                                               style:UITableViewStylePlain];
        m_table.backgroundColor = UIColorFromRGB(0xecf0f1);
        m_table.separatorStyle = UITableViewCellSeparatorStyleNone;
     
       
        m_table.bounces = YES;
        m_table.rowHeight = 80;
        m_table.delegate = self;
        m_table.dataSource = self;
        [self.view addSubview:m_table];
        
        [m_table addFooterWithTarget:self action:@selector(refreshViewBeginRefreshing:)];
        [self setUpRightItem];
        [self loadData];
    }
    return self;
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

- (void)cacheFactoryList:(NSMutableArray *)arrFactory
{
    [app.cacheBase removeAllQuickSearchFactoryDisplayList];
    if (arrFactory.count > 0) {
        for (NSDictionary *dic in arrFactory) {
            [app.cacheBase insertQuickSearchFactoryDisplayListWithCode:dic[@"code"]
                                                               address:dic[@"address"]
                                                                  auth:dic[@"auth"]
                                                                  desc:dic[@"desc"]
                                                                imgUrl:dic[@"imgUrl"]
                                                                  name:dic[@"name"]];
        }
    }
}

- (void)getAllCachedFactory
{
    m_data = [app.cacheBase queryAllQuickSearchFactoryList];
    [m_table reloadData];
}

- (void)loadData
{
    if (app.currentNetWork == kNotReachable) {
        [self getAllCachedFactory];
        if(!m_data.count > 0){
            [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
            return;
        }
    } else {
        __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        [manager POST:NW_queryFactoryList
           parameters:@{@"currPage":@(m_currPage), @"pageSize":@(PAGE_ROW_NUM)}
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  if ([((NSString *)responseObject[@"result"]) isEqualToString:@"OK"]) {
                      id result = responseObject[@"body"];
                      
                      
                      [m_data addObjectsFromArray: ([result isKindOfClass:[NSArray class]]? result : result[@"data"])];
                      
                       NSLog(@"m_data=====%@",m_data);
                      [self cacheFactoryList:m_data];
                      [m_table reloadData];
                  }
                  [m_table footerEndRefreshing];
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [m_table footerEndRefreshing];
                  NSLog(@"%@",error);
              }];
    }
}

#pragma mark - MJRefreshBaseViewDelegate
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    //m_currPage += m_data.count;
    m_currPage += 1;
    [self loadData];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return m_table.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
//    if (app.currentNetWork == kNotReachable) {
//        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
//        return;
//    }
    FactoryDetailViewController* vc = [[FactoryDetailViewController alloc] init];
    vc.factoryId = m_data[indexPath.row][@"code"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* str = [NSString stringWithFormat:@"Cell_%@", m_data[indexPath.row][@"classId"]];
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:str];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:str];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.clipsToBounds = YES;
        cell.textLabel.font = Font(12);
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, m_table.rowHeight - 0.5, APP_W, 0.5)];
        line.backgroundColor = UIColorFromRGB(0xdbdbdb);
        [cell addSubview:line];
    }
    [[cell viewWithTag:1008] removeFromSuperview];
    [[cell viewWithTag:1009] removeFromSuperview];
    [self addCellObjs:cell IndexPath:indexPath];
    return cell;
}

- (void)addCellObjs:(UITableViewCell *)cell IndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* row = [m_data objectAtIndex:indexPath.row];
    
    CGRect rect = RECT(10, 10, 60, 60);
    const int BAN_E = 10;
    
    UIImageView* webImage = [[UIImageView alloc] initWithFrame:rect];
    webImage.layer.borderColor = COLOR(207, 207, 207).CGColor;
    webImage.layer.borderWidth = 0.5;
    webImage.backgroundColor = [UIColor clearColor];
    if(![row[@"imgUrl"] isEqual:[NSNull null]]){
        [webImage setImageWithURL:[NSURL URLWithString:row[@"imgUrl"]]
                 placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
    }else{
        [webImage setImageWithURL:[NSURL URLWithString:@""]
                 placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
    }
    
    webImage.clipsToBounds = YES;
    [cell addSubview:webImage];
    
    CGFloat x = webImage.frame.origin.x+webImage.frame.size.width+BAN_E;
    UILabel* lbtitle = [[UILabel alloc] init];
    lbtitle.frame = RECT(x, BAN_E+5, APP_W-25-x+10, 30);
    lbtitle.backgroundColor = [UIColor clearColor];
    lbtitle.textAlignment = NSTextAlignmentLeft;
    lbtitle.textColor = COLOR(51, 51, 51);
    lbtitle.font = FontB(16);
    lbtitle.tag = 1008;
    lbtitle.text = [row objectForKey:@"name"];
    lbtitle.lineBreakMode = NSLineBreakByCharWrapping | NSLineBreakByTruncatingTail;
    lbtitle.numberOfLines = 1;
    [cell addSubview:lbtitle];
    [lbtitle sizeToFit];
    
    UILabel* lbDesc = [[UILabel alloc] init];
    lbDesc.frame = RECT(x, lbtitle.frame.origin.y+lbtitle.frame.size.height+7, APP_W-25-x+10, 30);
    lbDesc.backgroundColor = [UIColor clearColor];
    lbDesc.textAlignment = NSTextAlignmentLeft;
    lbDesc.textColor = UIColorFromRGB(0x666666);
    lbDesc.font = Font(14);
    lbDesc.tag = 1009;
    lbDesc.clipsToBounds = YES;
    lbDesc.text = [row objectForKey:@"desc"];
    lbDesc.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    lbDesc.numberOfLines = 0;
    [cell addSubview:lbDesc];
    //[lbDesc sizeToFit];
}


@end
