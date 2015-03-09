//
//  SubRegularDrugsViewController.m
//  wenyao
//
//  Created by Meng on 14-9-29.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "SubRegularDrugsViewController.h"
#import "HTTPRequestManager.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "SubRegularTableViewCell.h"
#import "MedicineListViewController.h"
#import "MJRefresh.h"
#import "AppDelegate.h"
#import "UIViewController+isNetwork.h"

@interface SubRegularDrugsViewController ()
{
    NSInteger currentPage;
}
@property (nonatomic, strong) NSMutableArray        *regularList;
@end

@implementation SubRegularDrugsViewController

- (id)init{
    if (self = [super init]) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView setFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H - 35)];
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
        self.tableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
        self.tableView.footerReleaseToRefreshText = @"松开加载更多数据了";
        self.tableView.footerRefreshingText = @"正在帮你加载中";
    }
    return self;
}

-(void)viewDidCurrentView{
    
    currentPage = 1;
    self.regularList = [[NSMutableArray alloc]init];
    [self loadData];
}

- (void)loadData
{
    
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"currClassId"] = self.infoDict[@"id"];
    setting[@"currPage"] = @(currentPage);
    setting[@"pageSize"] = @(PAGE_ROW_NUM);
    [[HTTPRequestManager sharedInstance] queryRecommendClass:setting completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            
            [self.regularList addObjectsFromArray:resultObj[@"body"][@"data"]];
            if(self.regularList.count > 0){
                [app.cacheBase insertIntoUsallyDrug:self.regularList classId:self.infoDict[@"id"]];
            }
         
            [self.tableView reloadData];
            currentPage++;
            [self.tableView footerEndRefreshing];
        }
        
    } failure:^(NSError *error) {
        [self.tableView footerEndRefreshing];
        NSString *str = [NSString stringWithFormat:@"%@",self.infoDict[@"id"]];
        self.regularList = [app.cacheBase selectUsallyDrug:str];
        [self.tableView reloadData];
        if(self.regularList.count > 0){
            [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试!" duration:1.0f];
        }
        else{
            if([self isNetWorking]){
                [self addNetView];
            }
        }
    }];
}

- (void)BtnClick{
    
    if(![self isNetWorking]){
        
        [[self.view viewWithTag:999] removeFromSuperview];
        [self loadData];
    }
}

- (void)footerRereshing
{
    [self loadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"常备药品";
}

#pragma mark -
#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 63.0f;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    return [self.regularList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SubRegularTableCellIdentifier = @"RegularTableViewCellIdentifier";
    SubRegularTableViewCell *cell = (SubRegularTableViewCell *)[tableView dequeueReusableCellWithIdentifier:SubRegularTableCellIdentifier];
    if(cell == nil){
        UINib *nib = [UINib nibWithNibName:@"SubRegularTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:SubRegularTableCellIdentifier];
        cell = (SubRegularTableViewCell *)[tableView dequeueReusableCellWithIdentifier:SubRegularTableCellIdentifier];
        UIView *bkView = [[UIView alloc]initWithFrame:cell.frame];
        bkView.backgroundColor = UIColorFromRGB(0xdbdbdb);
        cell.selectedBackgroundView = bkView;
    }
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, cell.frame.size.height - 0.5, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [cell addSubview:line];
    
    NSDictionary *dict = self.regularList[indexPath.row];
    cell.titleLabel.text = dict[@"name"];
    cell.descLabel.text = dict[@"desc"];
    [cell.avatarImage setImageWithURL:[NSURL URLWithString:dict[@"imgPath"]] placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
    if(indexPath.row == 0) {
        [cell.backImg setImage:[UIImage imageNamed:@"子常备药品推荐顶.png"]];
    }else{
        [cell.backImg setImage:[UIImage imageNamed:@"子常备药品推荐底.png"]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //NSLog(@"去药品列表 = %@",self.regularList);
    
    if(app.currentNetWork == kNotReachable){
        
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试!" duration:0.8f];
        return;
    }
    MedicineListViewController *drugListViewController = [[MedicineListViewController alloc] init];
    drugListViewController.className = @"SubRegularDrugsViewController";
    drugListViewController.classId = self.regularList[indexPath.row][@"id"];
    [self.navigationController pushViewController:drugListViewController animated:YES];
    
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
