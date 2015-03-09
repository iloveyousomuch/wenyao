//
//  QuestionListViewController.m
//  wenyao
//
//  Created by qwyf0006 on 15/1/15.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "QuestionListViewController.h"
#import "QuestionListCell.h"
#import "HTTPRequestManager.h"
#import "UIImageView+WebCache.h"
#import "Appdelegate.h"
#import "Constant.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "SBJson.h"
#import "QuestionDetailViewController.h"


@interface QuestionListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataList;
@property (assign, nonatomic) int page;
@property (strong, nonatomic) UIView *noDataView;


@end

@implementation QuestionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataList = [NSMutableArray arrayWithCapacity:0];
    
    [self setupTableView];
    [self setUpHeaderView];
    
    self.noDataView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-200)/2, 90, 200, 60)];
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.noDataView.frame.size.width, self.noDataView.frame.size.height)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = @"暂无数据!";
    lab.textColor = [UIColor lightGrayColor];
    [self.noDataView addSubview:lab];
    self.noDataView.hidden = YES;
    [self.view addSubview:self.noDataView];
    
    self.tableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
    self.tableView.footerReleaseToRefreshText = @"松开加载更多数据了";
    self.tableView.footerRefreshingText = @"正在帮你加载中";
    __weak QuestionListViewController *weakSelf = self;
    [self.tableView addFooterWithCallback:^{
        if (app.currentNetWork != kNotReachable) {
            weakSelf.page ++;
            [weakSelf getQuestionList];
        }else
        {
            [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试！" duration:0.8];
            [weakSelf.tableView footerEndRefreshing];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutAction) name:QUIT_OUT object:nil];
   
}



- (void)logoutAction
{
    if (self.dataList && self.dataList.count >0) {
        [self.dataList removeAllObjects];
    }
}

//网络获取我的列表数据
- (void)getQuestionList
{
    __weak QuestionListViewController *weakSelf = self;
    if (app.currentNetWork == kNotReachable) {
        [self loadCacheQuestionList];
    }else
    {
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        setting[@"classId"] = self.classId;
        setting[@"currPage"] = [NSString stringWithFormat:@"%d",weakSelf.page];
        setting[@"pageSize"] = @"10";
        
        [[HTTPRequestManager sharedInstance] QueryFamiliarQuestionlist:setting completion:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                NSArray *array = resultObj[@"body"][@"data"];
                if (weakSelf.page == 1) {
                    //删除缓存
                    [self.dataList removeAllObjects];
                    [app.cacheBase removeFamiliarQuestionListWithClassId:self.classId moduleId:self.moduleId];
                }
                
                [weakSelf cacheMyQuestionList:array];
                
                for (NSDictionary *dic in array) {
                    [weakSelf.dataList addObject:[dic mutableCopy]];
                }
                
                if (self.dataList.count == 0) {
                    self.noDataView.hidden = NO;
                    self.tableView.hidden = YES;
                }else
                {
                    self.noDataView.hidden = YES;
                    self.tableView.hidden = NO;
                }
                [weakSelf.tableView reloadData];
            }
            [self.tableView footerEndRefreshing];
        } failure:^(NSError *error) {
            [self.tableView footerEndRefreshing];
        }];
        
    }
    
    
}

//加载缓存数据

- (void)loadCacheQuestionList
{
    if (self.dataList.count > 0) {
        [self.dataList removeAllObjects];
    }
    
    NSArray *arr = [app.cacheBase queryAllFamiliarQuestionListWithClassId:self.classId moduleId:self.moduleId];
    NSLog(@"arr===%@",arr);
    [self.dataList addObjectsFromArray:arr];
    if (self.dataList.count == 0) {
        self.noDataView.hidden = NO;
        self.tableView.hidden = YES;
    }else
    {
        self.noDataView.hidden = YES;
        self.tableView.hidden = NO;
    }
    [self.tableView reloadData];
}

//缓存数据列表
- (void)cacheMyQuestionList:(NSArray *)array
{
    for (int i=0; i<array.count; i++) {
        NSDictionary *dic = array[i];
        
        [app.cacheBase insertIntoFamiliarQuestionListWithTeamId:dic[@"teamId"] answer:dic[@"answer"] question:dic[@"question"] classId:dic[@"classId"] moduleId:self.moduleId imgUrl:dic[@"imgUrl"]];
        
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.dataList.count == 0) {
        self.page = 1;
        [self getQuestionList];
    }
    [self.tableView reloadData];
}

- (void)viewDidCurrentView
{
    if (self.dataList.count == 0) {
        self.page = 1;
        [self getQuestionList];
    }
    [self.tableView reloadData];
}

- (void)setupTableView
{
    CGRect rect = self.view.frame;
    rect.size.height -= (64 + 35 + 50);
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.hidden = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.tableView setBackgroundColor:UIColorFromRGB(0xecf0f1)];
    self.tableView.separatorColor = UIColorFromRGB(0xdbdbdb);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [self.tableView setSeparatorInset:(UIEdgeInsetsMake(0, 0, 0, 0))];
    }
    [self.view addSubview:self.tableView];
}

- (void)setUpHeaderView
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 26)];
    bgView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, bgView.frame.size.width, bgView.frame.size.height)];
    lab.text = @"常见用药问题";
    lab.font = [UIFont systemFontOfSize:12];
    lab.textColor = UIColorFromRGB(0x999999);
    [bgView addSubview:lab];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 26-0.5, self.view.frame.size.width, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [bgView addSubview:line];
    
    [self.view addSubview:bgView];
    self.tableView.tableHeaderView = bgView;
    
}


#pragma mark--------------------列表代理--------------------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *titleStr = self.dataList[indexPath.row][@"question"];
    NSString *contentStr = self.dataList[indexPath.row][@"answer"];
    NSString *title;
    NSString *content;
    
    if (titleStr.length > 0) {
        titleStr = [titleStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        title = titleStr;
        if (titleStr.length >= 50) {
            title = [titleStr substringWithRange:NSMakeRange(0, 50)];
        }
    }
    
    if (contentStr.length > 0) {
        contentStr = [contentStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        content = contentStr;
        if (contentStr.length >= 40) {
            content = [contentStr substringWithRange:NSMakeRange(0, 40)];
        }
        
    }
    
    //改变title视图
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(289, CGFLOAT_MAX)];
    
    //改变content视图
    CGSize contentSize = [content sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(216, CGFLOAT_MAX)];
    return 65 + titleSize.height + contentSize.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *QuestionListCellIdentifier = @"QuestionListCell";
    QuestionListCell *cell = (QuestionListCell *)[tableView dequeueReusableCellWithIdentifier:QuestionListCellIdentifier];
    if(cell == nil)
    {
        UINib *nib = [UINib nibWithNibName:@"QuestionListCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:QuestionListCellIdentifier];
        cell = (QuestionListCell *)[tableView dequeueReusableCellWithIdentifier:QuestionListCellIdentifier];
        
    }
    
    NSString *titleStr = self.dataList[indexPath.row][@"question"];
    NSString *contentStr = self.dataList[indexPath.row][@"answer"];
    NSString *title;
    NSString *content;
    
    if (titleStr.length > 0) {
        titleStr = [titleStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        title = titleStr;
        if (titleStr.length >= 50) {
            title = [titleStr substringWithRange:NSMakeRange(0, 50)];
            title = [title stringByAppendingString:@"..."];
        }
    }
    
    if (contentStr.length > 0) {
        contentStr = [contentStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        content = contentStr;
        if (contentStr.length >= 40) {
            content = [contentStr substringWithRange:NSMakeRange(0, 40)];
            content = [content stringByAppendingString:@"..."];
        }
    }
    
    cell.titleLabel.text = title;
    cell.contentLabel.text = content;
    [cell.logoImage setImageWithURL:self.dataList[indexPath.row][@"imgUrl"] placeholderImage:[UIImage imageNamed:@"默认药房.PNG"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        
    }];
    [cell showData];
    
    //改变title和logo视图
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(289, CGFLOAT_MAX)];
    cell.titleLabel.frame = CGRectMake(cell.titleLabel.frame.origin.x, cell.titleLabel.frame.origin.y, titleSize.width, titleSize.height);
    cell.logoImage.frame = CGRectMake(cell.logoImage.frame.origin.x, cell.titleLabel.frame.origin.y+cell.titleLabel.frame.size.height+14, cell.logoImage.frame.size.width, cell.logoImage.frame.size.height);
    
    //改变content视图
    CGSize contentSize = [content sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(216, CGFLOAT_MAX)];
    
    float singleLabelHeight = 15.5;
    int line = contentSize.height/singleLabelHeight;
    
    cell.contentLabel.frame = CGRectMake(cell.contentLabel.frame.origin.x, cell.titleLabel.frame.origin.y+cell.titleLabel.frame.size.height+21, contentSize.width, contentSize.height+(line-1)*3);

    cell.labelBgView.frame = CGRectMake(cell.contentLabel.frame.origin.x-10, cell.contentLabel.frame.origin.y-8, cell.contentLabel.frame.size.width+30, cell.contentLabel.frame.size.height+21);
    cell.labelBgView.layer.cornerRadius = 4.0;
    cell.labelBgView.layer.masksToBounds = YES;
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    QuestionDetailViewController *detailVC = [[QuestionDetailViewController alloc]init];
    detailVC.classId = self.dataList[indexPath.row][@"classId"];
    detailVC.teamId = self.dataList[indexPath.row][@"teamId"];
    [self.currNavigationController pushViewController:detailVC animated:YES];
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
