//
//  MedicineListViewController.m
//  wenyao
//
//  Created by Meng on 14-9-28.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "MedicineListViewController.h"
#import "MedicineListCell.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "DrugDetailViewController.h"
//#import "JGProgressHUD.h"
#import "SVProgressHUD.h"
#import "UIViewController+isNetwork.h"
#import "ReturnIndexView.h"
#import "AppDelegate.h"

@interface MedicineListViewController ()<TopTableViewDelegate,ReturnIndexViewDelegate>
{
    NSInteger currentPage;
    TopTableView * topTable;
    BOOL isShow;
    UIButton * rightBarButton;
}
@property (nonatomic ,strong) NSMutableArray * dataSource;
@property (nonatomic, strong) ReturnIndexView *indexView;
@property (nonatomic ,strong) NSMutableArray * factoryArray;
@property (nonatomic, strong) UIButton        *backGoundCover;
@end

@implementation MedicineListViewController

- (id)init{
    if (self = [super init]) {
        
        self.tableView.frame = CGRectMake(0, 0, APP_W, APP_H-NAV_H);
        self.tableView.rowHeight = 88;
        
        [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];;
        
        self.tableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
        self.tableView.footerReleaseToRefreshText = @"松开加载更多数据了";
        self.tableView.footerRefreshingText = @"正在帮你加载中";
        currentPage = 1;
        topTable = [[TopTableView alloc] init];
        topTable.delegate = self;
        topTable.frame = CGRectMake(0, -500, APP_W, 380);
        self.dataSource = [NSMutableArray array];
        self.factoryArray = [NSMutableArray array];
        
        
        self.backGoundCover = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect rect = self.view.frame;
        self.backGoundCover.frame = rect;
        self.backGoundCover.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        self.backGoundCover.hidden = YES;
        [self.backGoundCover addTarget:self action:@selector(dismissMenuWithButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.backGoundCover];
        
        isShow = NO;
    }
    return self;
}

- (void)initRightBarButton{
    CGSize size = [@"全部生产厂家" sizeWithFont:Font(15)];
    rightBarButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, size.width, 20)];
    rightBarButton.backgroundColor = [UIColor clearColor];
    rightBarButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    [rightBarButton setTitle:@"全部生产厂家" forState:UIControlStateNormal];
    rightBarButton.titleLabel.font = FontB(15);
    [rightBarButton setTintColor:[UIColor blueColor]];
    [rightBarButton addTarget:self action:@selector(barButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage * arrImage = [UIImage imageNamed:@"头部下拉箭头.png"];
    
    
    UIImageView * arrImageView = [[UIImageView alloc] initWithFrame:CGRectMake(rightBarButton.frame.origin.x + rightBarButton.frame.size.width, 15, arrImage.size.width, arrImage.size.height)];
    arrImageView.image = arrImage;
    [rightBarButton addSubview:arrImageView];
    
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBarButton];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
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



- (void)setClassId:(NSString *)classId{
    _classId = [classId copy];
    if (self.isShow == 1) {
        [self initRightBarButton];
        topTable.classId = classId;
    }
    if ([self.className isEqualToString:@"SubRegularDrugsViewController"]) {
        [self loadHealthyScenarioData:classId];
        [self setUpRightItem];
        
    }else{
        [self loadDataWithClassId:classId];
    }
}

- (void)setKeyWord:(NSString *)keyWord{
    _keyWord = [keyWord copy];
    self.title = keyWord;
    [self loadDataWithKeyWord:keyWord];
}//queryProductByKeyword

//加载健康方案的药品列表
- (void)loadHealthyScenarioData:(NSString *)classId
{
    [SVProgressHUD showWithStatus:@"数据加载中..." maskType:SVProgressHUDMaskTypeClear];
    NSLog(@"id = %@",classId);
    
    [[HTTPRequestManager sharedInstance] queryRecommendProductByClass:@{@"classId": classId,@"currPage":@(currentPage),@"pageSize":@PAGE_ROW_NUM} completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            [self.dataSource addObjectsFromArray:resultObj[@"body"][@"data"]];
        }
        currentPage ++ ;
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
        [self.tableView footerEndRefreshing];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"数据加载失败" duration:DURATION_SHORT];
        NSLog(@"%@",error);
    }];
}

//加载其他带id药品列表
- (void)loadDataWithClassId:(NSString *)classId{
    [SVProgressHUD showWithStatus:@"数据加载中..." maskType:SVProgressHUDMaskTypeClear];
    NSLog(@"id = %@",classId);
    
    [[HTTPRequestManager sharedInstance] queryProductByClass:@{@"classId": classId,@"currPage":@(currentPage),@"pageSize":@PAGE_ROW_NUM} completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            [self.dataSource addObjectsFromArray:resultObj[@"body"][@"data"]];
        }
        currentPage ++ ;
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
        [self.tableView footerEndRefreshing];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"数据加载失败" duration:DURATION_SHORT];
        NSLog(@"%@",error);
    }];
}

//加载关键字药品列表
- (void)loadDataWithKeyWord:(NSString *)keyword{
    [SVProgressHUD showWithStatus:@"数据加载中..." maskType:SVProgressHUDMaskTypeClear];
    [[HTTPRequestManager sharedInstance] queryProductByKeyword:@{@"keyword": keyword,@"currPage":@(currentPage),@"pageSize":@PAGE_ROW_NUM} completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            [self.dataSource addObjectsFromArray:resultObj[@"body"][@"data"]];
        }
        NSLog(@"dataSource = %@",self.dataSource);
        currentPage ++ ;
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
        [self.tableView footerEndRefreshing];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"数据加载失败" duration:DURATION_SHORT];
        NSLog(@"%@",error);
    }];
}

- (void)footerRereshing
{
    if (self.classId) {
        if ([self.className isEqualToString:@"SubRegularDrugsViewController"]) {
            [self loadHealthyScenarioData:self.classId];
        }else{
            [self loadDataWithClassId:self.classId];
        }
    }
    
    if (self.keyWord) {
        //[self loadDataWithClassId:self.keyWord];
        [self loadDataWithKeyWord:self.keyWord];
    }
    
}

- (void)barButtonClick{
    
    
    if([self isNetWorking]){
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试！" duration:0.8f];
        return;
    }
    if (isShow == NO) {
        if (topTable.dataSource.count == 0) {
            [[HTTPRequestManager sharedInstance] queryFactoryList:@{@"classId":self.classId, @"currPage": @1,@"pageSize":@20} completion:^(id resultObj) {
                if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                    topTable.dataArr = resultObj[@"body"][@"data"];
                }
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
            }];
        }
        
        //topTable.dataArr = self.factoryArray;
        [UIView animateWithDuration:0.5 animations:^{
            topTable.frame = CGRectMake(0, 0, APP_W, 40.0 * self.self.dataSource.count);
            [self.view addSubview:topTable];
            self.backGoundCover.hidden = NO;
        }];
        isShow = YES;
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            topTable.frame = CGRectMake(0, -500, APP_W, 40.0 * self.self.dataSource.count);
            self.backGoundCover.hidden = YES;
        }];
        isShow = NO;
    }
}

#pragma mark -------topTable数据回调-------
- (void)tableViewCellSelectedReturnData:(NSArray *)dataArr withClassId:(NSString *)classId  withIndexPath:(NSIndexPath *)indexPath keyWord:(NSString *)keyword{
    [self barButtonClick];
    [rightBarButton setTitle:keyword forState:UIControlStateNormal];
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:dataArr];
    if (indexPath.row == 0) {
        //如果是第一行,那就是加载全部数据
        currentPage = 1;

        [self performSelectorOnMainThread:@selector(loadDataWithClassId:) withObject:classId waitUntilDone:YES];
        //[self loadDataWithClassId:self.classId];
    }else{
        //如果不是第一行,那就不需要上拉刷新,移除底部刷新工具
        [self.tableView removeFooter];
        [self.tableView reloadData];
    }
    
}

- (void)dismissMenuWithButton:(UIButton *)button
{
    [UIView animateWithDuration:0.5 animations:^{
        topTable.frame = CGRectMake(0, -500, APP_W, 40.0 * self.self.dataSource.count);
        self.backGoundCover.hidden = YES;
    }];
    isShow = NO;
    button.hidden = YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * cellIdentifier = @"cellIdentifier";
    MedicineListCell * cell = (MedicineListCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MedicineListCell" owner:self options:nil][0];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset = UIEdgeInsetsZero;// UIEdgeInsetsMake(0, 0, 0, 0);
        UIView *bkView = [[UIView alloc]initWithFrame:cell.frame];
        bkView.backgroundColor = UIColorFromRGB(0xdfe4e6);
        cell.selectedBackgroundView = bkView;
        
    }
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 87.5, APP_W,0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [cell addSubview:line];
    
    if (self.classId) {
        cell.topTitle.text = self.dataSource[indexPath.row][@"proName"];
    }else if (self.keyWord){
        cell.topTitle.text = self.dataSource[indexPath.row][@"name"];
    }
    
    if (self.dataSource[indexPath.row][@"proId"]) {
        NSString * imageUrl = PORID_IMAGE(self.dataSource[indexPath.row][@"proId"]);
        [cell.headImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
    }else{
        cell.headImageView.image = [UIImage imageNamed:@"药品默认图片.png"];
    }
    
    cell.middleTitle.text = self.dataSource[indexPath.row][@"spec"];
    if(self.dataSource[indexPath.row][@"factory"]){
        cell.addressLabel.text = self.dataSource[indexPath.row][@"factory"];
    }else if (self.dataSource[indexPath.row][@"makeplace"]) {
        cell.addressLabel.text = self.dataSource[indexPath.row][@"makeplace"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath*    selection = [tableView indexPathForSelectedRow];
    if (selection) {
        [tableView deselectRowAtIndexPath:selection animated:YES];
    }
    DrugDetailViewController * drugDetailViewController = [[DrugDetailViewController alloc] init];
    NSDictionary * dic = self.dataSource[indexPath.row];
    if (self.classId) {
        drugDetailViewController.proId = dic[@"proId"];
    }else{
        drugDetailViewController.proId = dic[@"proId"];
    }
    
    [self.navigationController pushViewController:drugDetailViewController animated:YES];
}

- (void)loadFactory{
    
}

- (void)BtnClick{
    
    if(![self isNetWorking]){
        for(UIView *v in [self.view subviews]){
            if(v.tag == 999){
                [v removeFromSuperview];
            }
        }
        [self setClassId:self.classId];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //NSLog(@"关键字 = %@",self.keyWord);
    if([self isNetWorking]){
        [self addNetView];
        return;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"列表";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


#pragma mark --------自定义弹出的tableView--------

@implementation TopTableView

- (id)init{
    if (self = [super init]) {
        self.mTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, APP_W, 360) style:UITableViewStylePlain];
        self.mTableView.delegate = self;
        self.mTableView.dataSource = self;
        [self addSubview:self.mTableView];
        self.mTableView.rowHeight = 40.0f;
        
        currentPage = 2;
        
        [self.mTableView addFooterWithTarget:self action:@selector(footerRereshing)];
        self.mTableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
        self.mTableView.footerReleaseToRefreshText = @"松开加载更多数据了";
        self.mTableView.footerRefreshingText = @"正在帮你加载中";
        
        historyRow = -1;
        currentRow = -1;
        
    }
    return self;
}

- (void)footerRereshing{
    [[HTTPRequestManager sharedInstance] queryFactoryList:@{@"classId":self.classId,@"currPage": @(currentPage),@"pageSize":@20} completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            [self.dataSource addObjectsFromArray:resultObj[@"body"][@"data"]];
        }
        ++currentPage;
        [self.mTableView reloadData];
        [self.mTableView footerEndRefreshing];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)setDataArr:(NSArray *)dataArr{
    self.dataSource = [NSMutableArray array];
    [self.dataSource addObjectsFromArray:dataArr];
    NSDictionary * dic = [NSDictionary dictionaryWithObject:@"全部生产厂家" forKey:@"factory"];
    [self.dataSource insertObject:dic atIndex:0];
    if(self.dataSource.count <= 9){
    self.mTableView.frame = CGRectMake(0, 0, APP_W, self.mTableView.rowHeight * self.dataSource.count);
    }
    [self.mTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellIdentfier = @"cellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentfier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentfier];
        cell.textLabel.font = Font(14);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row == historyRow) {
        UIImage * image = [UIImage imageNamed:@"勾.png"];
        UIImageView * accessView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        accessView.image = image;
        cell.accessoryView = accessView;
        cell.textLabel.textColor = UICOLOR(60, 183, 21);
    } else {
        cell.accessoryView = [[UIView alloc]init];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.textLabel.text = self.dataSource[indexPath.row][@"factory"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    currentRow = indexPath.row;
    NSIndexPath * historyPath = [NSIndexPath indexPathForRow:historyRow inSection:0];
    NSIndexPath * currentPath = [NSIndexPath indexPathForRow:currentRow inSection:0];
   
    UITableViewCell * historyCell = [tableView cellForRowAtIndexPath:historyPath];
    UITableViewCell * currentCell = [tableView cellForRowAtIndexPath:currentPath];
    
    UIImage * image = [UIImage imageNamed:@"勾.png"];
    UIImageView * accessView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    accessView.image = image;
    
    
    if (currentRow != historyRow) {
        
        historyCell.accessoryView = [[UIView alloc]init];
        historyCell.textLabel.textColor = [UIColor blackColor];
        currentCell.accessoryView = accessView;
        currentCell.textLabel.textColor = UICOLOR(60, 183, 21);
    }
    historyRow = currentRow;
    
    
    
    
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    setting[@"classId"] = self.classId;
    setting[@"currPage"] = @1;
    setting[@"pageSize"] = @10000;
    if (indexPath.row != 0) {
        setting[@"factory"] = self.dataSource[indexPath.row][@"factory"];
    }
    
    [[HTTPRequestManager sharedInstance] queryProductByClass:setting completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            if ([self.delegate respondsToSelector:@selector(tableViewCellSelectedReturnData:withClassId:withIndexPath:keyWord:)]) {
                [self.delegate tableViewCellSelectedReturnData:resultObj[@"body"][@"data"] withClassId:self.classId withIndexPath:indexPath keyWord:self.dataSource[indexPath.row][@"factory"]];
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

@end
