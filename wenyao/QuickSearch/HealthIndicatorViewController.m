//
//  HealthIndicatorViewController.m
//  wenyao
//
//  Created by Meng on 14-9-24.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "HealthIndicatorViewController.h"
#import "HealthDetailViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "ReturnIndexView.h"

@interface HealthIndicatorViewController ()<ReturnIndexViewDelegate>
@property (nonatomic, strong) NSMutableArray        *healthArray;
@property (nonatomic, strong) ReturnIndexView *indexView;
@end 

@implementation HealthIndicatorViewController

- (id)init{
    if (self = [super init]) {
        self.title = @"健康指标";
        self.tableView.frame = CGRectMake(0, 0, APP_W, APP_H-NAV_H);
        [self.tableView setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)cacheAllIndicatorList:(NSMutableArray *)arrIndicator
{
    [app.cacheBase removeAllQuickSearchHealIndicatorList];
    if (arrIndicator.count > 0) {
        for (NSDictionary *dic in arrIndicator) {
            [app.cacheBase insertQuickSearchHealIndicatorListWithHealthId:dic[@"healthId"]
                                                                     name:dic[@"name"]
                                                                      url:dic[@"url"]];
        }
    }
}

- (void)getAllCachedIndicator
{
    self.healthArray = [app.cacheBase queryAllQuickSearchHealthIndicatorList];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"currPage"] = @"1";
    setting[@"pageSize"] = @"0";
    
    if (app.currentNetWork == kNotReachable) {
        [self getAllCachedIndicator];
        if(!self.healthArray.count > 0){
            [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
            return;
        }
    } else {
        [[HTTPRequestManager sharedInstance] queryHealthProgram:setting completion:^(id resultObj) {
            [self.healthArray removeAllObjects];
            NSArray *array = resultObj[@"body"][@"data"];
            if([array count]) {
                [self.healthArray addObjectsFromArray:array];
                [self cacheAllIndicatorList:self.healthArray];
                [self.tableView reloadData];
            }
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.healthArray = [NSMutableArray arrayWithCapacity:10];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    return [self.healthArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *HealthIndicator = @"HealthIndicatorIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:HealthIndicator];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HealthIndicator];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.selectedBackgroundView = [[UIView alloc]init];
        cell.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xdfe4e6);
    }
    UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(15, 49.5, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [cell addSubview:line];
    
    NSDictionary *dict = self.healthArray[indexPath.row];
    cell.textLabel.text = dict[@"name"];
    cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    cell.textLabel.textColor = UIColorFromRGB(0x333333);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath*    selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (app.currentNetWork == kNotReachable) {
//        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
//        return;
//    }
    NSDictionary *dict = self.healthArray[indexPath.row];
    HealthDetailViewController *detailViewController = [[HealthDetailViewController alloc] init];
    NSLog(@"dict = %@",dict);
    detailViewController.htmlUrl = dict[@"url"];
    detailViewController.title = dict[@"name"];
    [self.navigationController pushViewController:detailViewController animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
