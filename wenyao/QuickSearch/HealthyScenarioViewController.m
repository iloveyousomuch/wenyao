//
//  HealthyScenarioViewController.m
//  wenyao
//
//  Created by Meng on 14-9-29.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "HealthyScenarioViewController.h"
#import "SVProgressHUD.h"
#import "RegularTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "SubRegularDrugsViewController.h"
#import "HealthyScenarioCell.h"
#import "AppDelegate.h"
#import "HealthySliderViewController.h"
#import "ReturnIndexView.h"

@interface HealthyScenarioViewController ()<ReturnIndexViewDelegate>
@property (nonatomic, strong) NSMutableArray *regularList;
@property (nonatomic, strong) ReturnIndexView *indexView;
@end

@implementation HealthyScenarioViewController

- (id)init
{
    if (self = [super init]) {
        self.title = @"健康方案";
        self.regularList = [NSMutableArray array];
        
//        CGRect rect = self.view.frame;
//        rect.origin.y = 10;
//        rect.origin.x = 12;
//        rect.size.width = 295;
//        rect.size.height -= 10;
//        [self.tableView setFrame:rect];
        [self.tableView setFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H)];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
       
    }
    return self;
}

- (void)cacheHealthPlanList
{
    [app.cacheBase removeAllHealthPlan];
    for (NSDictionary *dic in self.regularList) {
        [app.cacheBase insertHealthPlanListWithPlanId:dic[@"id"] desc:dic[@"desc"] elementId:dic[@"elementId"] imgPath:dic[@"imgPath"] name:dic[@"name"]];
    }
}

- (void)queryHealthPlanList
{
    if (self.regularList.count > 0) {
        [self.regularList removeAllObjects];
    }
    self.regularList = [app.cacheBase queryAllHealthPlan];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (app.currentNetWork == kNotReachable) {
        [self queryHealthPlanList];
    } else {
        if([self.regularList count] == 0)
        {
            NSMutableDictionary *setting = [NSMutableDictionary dictionary];
            setting[@"currClassId"] = @"-";
            setting[@"currPage"] = @"1";
            setting[@"pageSize"] = @"0";
            [[HTTPRequestManager sharedInstance] queryRecommendClass:setting completion:^(id resultObj) {
                if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                    NSLog(@"%s,%@",__func__,resultObj[@"body"][@"data"]);
                    [self.regularList removeAllObjects];
                    [self.regularList addObjectsFromArray:resultObj[@"body"][@"data"]];
                    [self cacheHealthPlanList];
                }
                [self.tableView reloadData];
            } failure:^(NSError *error) {
                [SVProgressHUD showErrorWithStatus:@"加载失败!" duration:0.8f];
            }];
        }
    }

}

#pragma mark -
#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 63.0f;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    return self.regularList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *RegularTableCellIdentifier = @"RegularTableCellIdentifier";
    HealthyScenarioCell * cell = (HealthyScenarioCell *)[tableView dequeueReusableCellWithIdentifier:RegularTableCellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"HealthyScenarioCell" owner:self options:nil][0];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(48, 62.5, APP_W - 48, 0.5)];
        line.backgroundColor = UIColorFromRGB(0xdbdbdb);
        [cell addSubview:line];
        
        cell.selectedBackgroundView = [[UIView alloc]init];
        cell.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xdfe4e6);
    }
    
    NSDictionary *dict = self.regularList[indexPath.row];
    cell.label.text = dict[@"name"];
    [cell.cellImageView setImageWithURL:[NSURL URLWithString:dict[@"imgPath"]] placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (app.currentNetWork == kNotReachable) {
//        [SVProgressHUD showErrorWithStatus:@"当前暂无网络,请稍后重试!" duration:0.8f];
//        return;
//    }
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }

//    SubRegularDrugsViewController * sub = [[SubRegularDrugsViewController alloc] init];
//    sub.title = self.regularList[indexPath.row][@"name"];
//    sub.infoDict = self.regularList[indexPath.row];
//    [self.navigationController pushViewController:sub animated:YES];
    
    HealthySliderViewController *healthySlider = [[HealthySliderViewController alloc]init];
    healthySlider.title = self.regularList[indexPath.row][@"name"];
    healthySlider.infoDict = self.regularList[indexPath.row];
    [self.navigationController pushViewController:healthySlider animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
