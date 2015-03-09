//
//  CityListViewController.m
//  wenyao
//
//  Created by xiezhenghong on 14-10-7.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "CityListViewController.h"
#import "CityTableViewCell.h"
#import "HTTPRequestManager.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

@interface CityListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView       *tableView;

@property (nonatomic, strong) NSArray           *indexArray;

@end

@implementation CityListViewController

@synthesize tableView;

- (void)setupTableView
{
    CGRect rect = self.view.frame;
    rect.size.height -= 64;
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"切换城市";
    [self setupTableView];
    _indexArray = [self.cityList allKeys];
    _indexArray = [_indexArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    //[self queryCityList];
}

- (void)queryCityList
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    [[HTTPRequestManager sharedInstance] queryOpenCity:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]){
            self.cityList = resultObj[@"body"];
            
            [self.tableView reloadData];
        }
    } failure:NULL];
}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    [headerView setBackgroundColor:UICOLOR(242, 242, 242)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 200, 20)];
    label.textColor = [UIColor blackColor];
    

    NSMutableArray *marr = [NSMutableArray arrayWithArray:_indexArray];

    NSString *cityName = marr[section];
    
    
    label.text = cityName;
    label.font = [UIFont systemFontOfSize:13.5];
    [headerView addSubview:label];
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 29, 320, 1)];
    [separator setBackgroundColor:UICOLOR(237, 237, 237)];
    [headerView addSubview:separator];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *citys = self.cityList[_indexArray[section]];
    return [citys count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return _indexArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CityCellIdentifier = @"CityCellIdentifier";
    CityTableViewCell *cell = (CityTableViewCell *)[atableView dequeueReusableCellWithIdentifier:CityCellIdentifier];
    if(cell == nil){
        UINib *nib = [UINib nibWithNibName:@"CityTableViewCell" bundle:nil];
        [atableView registerNib:nib forCellReuseIdentifier:CityCellIdentifier];
        cell = (CityTableViewCell *)[atableView dequeueReusableCellWithIdentifier:CityCellIdentifier];
    }

    NSDictionary *dict = self.cityList[_indexArray[indexPath.section]][indexPath.row];

    cell.cityNameLabel.text = dict[@"cityName"];
    
    if([dict[@"cityName"] isEqualToString:self.currentCity])
    {
        cell.dredgeLabel.hidden = NO;
    
    }else{
        cell.dredgeLabel.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        return;
    }
    NSDictionary *dict = self.cityList[_indexArray[indexPath.section]][indexPath.row];
    if(self.selectBlock) {
        self.selectBlock(dict[@"cityName"]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
