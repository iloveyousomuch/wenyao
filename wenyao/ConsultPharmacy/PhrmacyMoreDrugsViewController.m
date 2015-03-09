//
//  PhrmacyMoreDrugsViewController.m
//  wenyao
//
//  Created by 李坚 on 15/1/22.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "PhrmacyMoreDrugsViewController.h"
#import "Constant.h"
#import "MJRefresh.h"
#import "HTTPRequestManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "medicineTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "DrugDetailViewController.h"
#import "SVProgressHUD.h"
#import "ReturnIndexView.h"
#import "AppDelegate.h"

@interface PhrmacyMoreDrugsViewController ()<ReturnIndexViewDelegate>
{
    int currentPage;
    NSMutableArray *sellList;
}
@property (strong, nonatomic) ReturnIndexView *indexView;
@end

@implementation PhrmacyMoreDrugsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setBackgroundColor:UIColorFromRGB(0xecf0f1)];
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    self.tableView.footerPullToRefreshText = @"上拉加载更多数据";
    self.tableView.footerReleaseToRefreshText = @"松开加载更多数据";
    self.tableView.footerRefreshingText = @"正在加载中";
    sellList = [NSMutableArray array];
    currentPage = 1;
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
    self.title = @"商品";
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
    setting[@"groupId"] = self.groupId;
    setting[@"currPage"] = @(currentPage);
    setting[@"pageSize"] = @(PAGE_ROW_NUM);
    
    [[HTTPRequestManager sharedInstance]fetchSellWellProducts:setting completionSuc:^(id resultObj){
        if([resultObj[@"result"] isEqualToString:@"OK"]){
            
            [sellList addObjectsFromArray:resultObj[@"body"][@"data"]];
            [self.tableView reloadData];
            currentPage++;
            [self.tableView footerEndRefreshing];
        }
        else{
            
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        [self.tableView footerEndRefreshing];
        [SVProgressHUD showErrorWithStatus:@"加载失败!" duration:0.8f];
    }];

}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return sellList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 95.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * cellIdentifier = @"cellIdentifier";
    medicineTableViewCell * cell = (medicineTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"medicineTableViewCell" owner:self options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 95 - 0.5, APP_W, 0.5)];
        line.backgroundColor = UIColorFromRGB(0xdbdbdb);
        [cell addSubview:line];
    }
    
    NSDictionary* dic = sellList[indexPath.row];
    
    cell.whatForLable.layer.borderWidth = 0.5f;
    cell.whatForLable.layer.borderColor = UIColorFromRGB(0xdbdbdb).CGColor;
    
    NSString* imgurl = PORID_IMAGE(dic[@"proId"]);
    [cell.medicineImage setImageWithURL:[NSURL URLWithString:imgurl]
                       placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
    
    NSString *str = [NSString stringWithFormat:@"NO.%d@2x.png",indexPath.row +1];
    cell.numberImage.image = [UIImage imageNamed:str];
    
    cell.nameLable.text = dic[@"proName"];
    cell.mlLable.text = dic[@"spec"];
    cell.compaleLable.text = dic[@"factory"];
    cell.whatForLable.text = dic[@"tag"];
    
    
    cell.nameLable.textColor = UIColorFromRGB(0x333333);
    cell.nameLable.font = Font(15.0f);
    cell.mlLable.textColor = UIColorFromRGB(0x999999);
    cell.mlLable.font = Font(13.0f);
    cell.compaleLable.textColor = UIColorFromRGB(0x999999);
    cell.compaleLable.font = Font(13.0f);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DrugDetailViewController * drugDetail = [[DrugDetailViewController alloc] init];
    drugDetail.proId = sellList[indexPath.row][@"proId"];
    [self.navigationController pushViewController:drugDetail animated:YES];
}
@end
