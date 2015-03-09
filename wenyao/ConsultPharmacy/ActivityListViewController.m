//
//  ActivityListViewController.m
//  wenyao
//
//  Created by xiezhenghong on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "ActivityListViewController.h"
#import "AppDelegate.h"
#import "Constant.h"
#import "ActivityDetailTableViewCell.h"
#import "ActivityDetailViewController.h"
#import "MarketDetailViewController.h"
#import "MJRefresh.h"
#import "ReturnIndexView.h"

@interface ActivityListViewController ()<ReturnIndexViewDelegate>

@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) ReturnIndexView *indexView;

@end

@implementation ActivityListViewController
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setupTableView
{
    CGRect rect = self.view.frame;
    rect.size.height -= 64;
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    __weak typeof (self) weakSelf = self;
    [self.tableView addFooterWithCallback:^{
        [weakSelf.tableView footerEndRefreshing];
        weakSelf.currentPage += 1;
        [weakSelf.tableView reloadData];
    }];
    
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _currentPage = 1;
    [self setupTableView];
    self.title = @"活动";
    [self.view setBackgroundColor:UICOLOR(236, 240, 240)];
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


#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 94.0f;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    return MIN(self.infoList.count, 10 * _currentPage);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ActivityDetailTableCellIdentifier = @"ActivityDetailTableCellIdentifier";
    ActivityDetailTableViewCell *cell = (ActivityDetailTableViewCell *)[atableView dequeueReusableCellWithIdentifier:ActivityDetailTableCellIdentifier];
    if(cell == nil){
        UINib *nib = [UINib nibWithNibName:@"ActivityDetailTableViewCell" bundle:nil];
        [atableView registerNib:nib forCellReuseIdentifier:ActivityDetailTableCellIdentifier];
        cell = (ActivityDetailTableViewCell *)[atableView dequeueReusableCellWithIdentifier:ActivityDetailTableCellIdentifier];
    }
    NSDictionary *dict = self.infoList[indexPath.row];
    cell.titleLabel.text = dict[@"title"];
    cell.dateLabel.text = [dict[@"createTime"] substringToIndex:10];
    cell.contentLabel.text = dict[@"content"];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 93.5, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [cell addSubview:line];
    
    return cell;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = self.infoList[indexPath.row];
    MarketDetailViewController *marketDetailViewController = nil;
    
    if(HIGH_RESOLUTION) {
        marketDetailViewController = [[MarketDetailViewController alloc] initWithNibName:@"MarketDetailViewController" bundle:nil];
    }else{
        marketDetailViewController = [[MarketDetailViewController alloc] initWithNibName:@"MarketDetailViewController-480" bundle:nil];
    }
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
    infoDict[@"activityId"] = dict[@"activityId"];
    if(dict[@"groupId"])
    {
        infoDict[@"groupId"] = dict[@"groupId"];
    }else{
         infoDict[@"groupId"] = self.groupId;
    }
    marketDetailViewController.infoDict = infoDict;
    marketDetailViewController.userType = 1;
    [self.navigationController pushViewController:marketDetailViewController animated:YES];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
