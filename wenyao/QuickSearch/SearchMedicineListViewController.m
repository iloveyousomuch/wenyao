//
//  SearchMedicineListViewController.m
//  wenyao
//
//  Created by Meng on 14/12/2.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "SearchMedicineListViewController.h"
#import "DrugDetailViewController.h"
#import "MedicineListCell.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"

@interface SearchMedicineListViewController ()
{
    NSInteger currentPage;
    UIView *_nodataView;
}
@property (nonatomic ,strong) NSMutableArray * dataSource;

@end

@implementation SearchMedicineListViewController

- (instancetype)init
{
    if (self = [super init]) {
//        if (!HIGH_RESOLUTION) {
            [self.tableView setFrame:CGRectMake(0, 0, APP_W, APP_H -NAV_H)];
        [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
        self.tableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
        self.tableView.footerReleaseToRefreshText = @"松开加载更多数据了";
        self.tableView.footerRefreshingText = @"正在帮你加载中";
        currentPage = 1;
//        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 88;
    self.dataSource = [NSMutableArray array];
}

- (void)footerRereshing{
    currentPage ++;
    [self setKwId:self.kwId];
}

- (void)setKwId:(NSString *)kwId
{
    _kwId = kwId;
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    setting[@"kwId"] = kwId;
    setting[@"currPage"] = [NSString stringWithFormat:@"%d",currentPage];
    setting[@"pageSize"] = @10;
    __weak SearchMedicineListViewController *weakSelf = self;
    
    [[HTTPRequestManager sharedInstance] queryProductByKwId:setting completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            if(currentPage == 1){
                [weakSelf.dataSource removeAllObjects];
            }
            [weakSelf.dataSource addObjectsFromArray:resultObj[@"body"][@"data"]];
            if (weakSelf.dataSource.count > 0) {
                [weakSelf.tableView reloadData];
            }else{
                [self showNoDataViewWithString:@"暂无数据!"];
            }
            [weakSelf.tableView footerEndRefreshing];
            
        }
    } failure:^(NSError *error) {
        [weakSelf.tableView footerEndRefreshing];
        NSLog(@"%@",error);
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 88;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentifier = @"cellIdentifier";
    MedicineListCell * cell = (MedicineListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MedicineListCell" owner:self options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (self.dataSource[indexPath.row][@"proId"]) {
        NSString *imageUrl = PORID_IMAGE(self.dataSource[indexPath.row][@"proId"]);
        [cell.headImageView setImageWithURL:[NSURL URLWithString:imageUrl]];
    }
    if (cell.headImageView.image == nil) {
        cell.headImageView.image = [UIImage imageNamed:@"药品默认图片.png"];
    }
    
    cell.topTitle.text = self.dataSource[indexPath.row][@"name"];
    cell.middleTitle.text = self.dataSource[indexPath.row][@"spec"];
    if(self.dataSource[indexPath.row][@"factory"]){
        cell.addressLabel.text = self.dataSource[indexPath.row][@"factory"];
    }else if (self.dataSource[indexPath.row][@"makeplace"]) {
        cell.addressLabel.text = self.dataSource[indexPath.row][@"makeplace"];
    }
    //cell.addressLabel
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
    NSDictionary *dic = self.dataSource[indexPath.row];
    DrugDetailViewController * drugDetailViewController = [[DrugDetailViewController alloc] init];
    drugDetailViewController.proId = dic[@"proId"];
    [self.navigationController pushViewController:drugDetailViewController animated:YES];
    
//    SymptomDetailViewController * svc =[[SymptomDetailViewController alloc]init];
//    svc.spmCode = dic[@"spmCode"];
//    svc.title = dic[@"name"];
//    [self.navigationController pushViewController:svc animated:YES];
    
    
    //    SymptomViewController * svc =[[SymptomViewController alloc]init];
    //    svc.requestType = searchSym;
    //    svc.spmCode = dic;
    //    svc.title = dic;
    //    [self.navigationController pushViewController:svc animated:YES];
    //
    //
    //
    //
    //    DiseaseDetailViewController * diseaseDetail = [[DiseaseDetailViewController alloc] init];
    //    diseaseDetail.diseaseName = dic[@"name"];
    //    diseaseDetail.diseaseType = dic[@"type"];
    //    diseaseDetail.title = dic[@"name"];
    //    [self.navigationController pushViewController:diseaseDetail animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//显示没有历史搜索记录view
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
    UIImage * searchImage = [UIImage imageNamed:@"icon_warning.png"];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
