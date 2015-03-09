//
//  FactoryMedicineListViewController.m
//  wenyao
//
//  Created by qw on 14-11-14.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "FactoryMedicineListViewController.h"
#import "HTTPRequestManager.h"
#import "MedicineListCell.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "DrugDetailViewController.h"

@interface FactoryMedicineListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tbViewContent;
@property (nonatomic, strong) NSMutableArray *arrMedicineList;
@property (nonatomic, assign) NSInteger numCurPage;

@end

@implementation FactoryMedicineListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrMedicineList = [[NSMutableArray alloc] init];
    self.navigationItem.title = @"药品列表";
    [self.tbViewContent addFooterWithTarget:self action:@selector(footerRereshing)];
    self.tbViewContent.footerPullToRefreshText = @"上拉可以加载更多数据了";
    self.tbViewContent.footerReleaseToRefreshText = @"松开加载更多数据了";
    self.tbViewContent.footerRefreshingText = @"正在帮你加载中";
    [self getAllMedicineList];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)footerRereshing
{
    self.numCurPage ++;
    [self getAllMedicineList];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Http methods
- (void)getAllMedicineList
{
    __weak FactoryMedicineListViewController *weakSelf = self;
    [[HTTPRequestManager sharedInstance] queryFactoryProductList:@{@"factoryCode":self.strFactoryID,
                                                                   @"currPage":[NSString stringWithFormat:@"%d",self.numCurPage],
                                                                   @"pageSize":@10}
                                                   completionSuc:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            if (weakSelf.numCurPage == 1) {
                [weakSelf.arrMedicineList removeAllObjects];
            }
            [weakSelf.arrMedicineList addObjectsFromArray:resultObj[@"body"][@"data"]];
            [weakSelf.tbViewContent reloadData];
            [weakSelf.tbViewContent footerEndRefreshing];
        }
    } failure:^(id failMsg) {
        NSLog(@"%@",failMsg);
    }];
}

#pragma mark - UITableView methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentifier = @"cellIdentifier";
    MedicineListCell * cell = (MedicineListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MedicineListCell" owner:self options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dicData = self.arrMedicineList[indexPath.row];
    NSString * imageUrl;
    imageUrl = PORID_IMAGE(dicData[@"proId"]);
    cell.topTitle.text = dicData[@"proName"];

    [cell.headImageView setImageWithURL:[NSURL URLWithString:imageUrl]];
    
    cell.middleTitle.text = dicData[@"spec"];
    cell.addressLabel.text = dicData[@"factoryName"];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrMedicineList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DrugDetailViewController * drugDetailViewController = [[DrugDetailViewController alloc] init];
    NSDictionary *dicData = self.arrMedicineList[indexPath.row];
    drugDetailViewController.proId = dicData[@"proId"];
    [self.navigationController pushViewController:drugDetailViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88.0f;
}

@end
