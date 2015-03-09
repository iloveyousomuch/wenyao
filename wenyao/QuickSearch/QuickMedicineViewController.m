//
//  QuickMedicineViewController.m
//  wenyao
//
//  Created by Meng on 14-9-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "QuickMedicineViewController.h"
#import "QuickMedicineTableViewCell.h"
#import "MedicineSubViewController.h"
#import "HTTPRequestManager.h"
#import "UIImageView+WebCache.h"
#import "SearchSliderViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "ReturnIndexView.h"

@interface QuickMedicineViewController ()<ReturnIndexViewDelegate>
{
    NSArray * imageArray;
}
@property (nonatomic ,strong) NSMutableArray * dataScorce;
@property (nonatomic ,strong) NSMutableArray * data;

@property (nonatomic ,assign) NSInteger selectedIndex;
@property (strong, nonatomic) ReturnIndexView *indexView;

@end

@implementation QuickMedicineViewController

- (id)init{
    if (self = [super init]) {
        
        self.tableView.frame = CGRectMake(0, 0, APP_W, APP_H-NAV_H);
        self.tableView.rowHeight = 70;
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        self.dataScorce = [NSMutableArray array];
        self.data = [NSMutableArray array];
        imageArray = @[@"中西药品.png",@"中成药.png",@"中药饮片.png",@"汤料花茶.png",@"营养保健.png",@"医疗机械及相关.png",@"个人护理.png",@"按人群查找.png",@"热卖商品.png"];
#pragma 按钮的调整
        [self setRightItems];
        
//        UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"导航栏_搜索icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarButtonClick)];
//        self.navigationItem.rightBarButtonItem = rightBarButton;
    }
    return self;
}
#pragma ----index----
-(void)setRightItems{
    UIView *ypBarItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 55)];
    //[customBarItems setBackgroundColor:[UIColor yellowColor]];
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(28, 0, 55, 55)];
    [searchButton setImage:[UIImage imageNamed:@"导航栏_搜索icon.png"]  forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchDown];
    [ypBarItems addSubview:searchButton];
    
    UIButton *indexButton = [[UIButton alloc] initWithFrame:CGRectMake(65, 0, 55, 55)];
    [indexButton setImage:[UIImage imageNamed:@"icon-unfold.PNG"] forState:UIControlStateNormal];
    [indexButton addTarget:self action:@selector(showIndex) forControlEvents:UIControlEventTouchDown];
    [ypBarItems addSubview:indexButton];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -20;
    self.navigationItem.rightBarButtonItems = @[fixed,[[UIBarButtonItem alloc] initWithCustomView:ypBarItems]];


}

- (void)showIndex
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



- (void)cacheMedicineList
{
    [app.dataBase removeAllQuickSearchMedicine];
    if (self.data.count > 0) {
        for (int i = 0; i < self.data.count; i++) {
            NSDictionary *dic = self.data[i];
            [app.cacheBase insertQucikSearchMedicinWithClassId:dic[@"classId"]
                                                  description:dic[@"classDesc"]
                                                         name:dic[@"name"]
                                                      imgName:imageArray[i]];
        }
    }
}

- (void)getCachedAllMedicineList
{
    self.data = [app.cacheBase queryAllQuickSearchMedicineList];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationItem.title = @"药品";
    if (self.data.count > 0) {
        return;
    }
    [super viewWillAppear:animated];
    
    
    if (app.currentNetWork == kNotReachable) {
        [self getCachedAllMedicineList];
        if(!self.data.count > 0){
            [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
            return;
        }
    } else {
        [[HTTPRequestManager sharedInstance] queryProductClass:@{@"currPage":@1,@"pageSize":@0} completion:^(id resultObj) {
            //NSLog(@"药品 = %@",resultObj);
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                self.dataScorce = resultObj[@"body"][@"data"];
                
                if (self.dataScorce.count >= 9) {
                    NSRange range = NSMakeRange(0, 9);
                    [self.data addObjectsFromArray:[self.dataScorce subarrayWithRange:range]];
                    [self cacheMedicineList];
                    NSLog(@"%s,%@",__func__,self.data);
                    
                }
                [self.tableView reloadData];
            }
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
        }];
    }
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.data.count > 0) {
        self.navigationItem.title = self.data[self.selectedIndex][@"name"];
    }
}

- (void)rightBarButtonClick{
    SearchSliderViewController * searchViewController = [[SearchSliderViewController alloc] init];
    searchViewController.currentSelectedViewController = medicineViewController;
    searchViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewController animated:NO];
}

#pragma mark ------UItableViewDelegate------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * cellIdentifier = @"cellIdentifier";
    QuickMedicineTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSBundle * bundle = [NSBundle mainBundle];
        NSArray * cellViews = [bundle loadNibNamed:@"QuickMedicineTableViewCell" owner:self options:nil];
        cell = [cellViews objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
    }//@"药品默认图片.png"
    
    cell.titleLabel.text = self.data[indexPath.row][@"name"];
    cell.subTitleLabel.text = self.data[indexPath.row][@"classDesc"];
    //[cell.headImageView setImageWithURL:[NSURL URLWithString:self.dataScorce[indexPath.row][@"imageUrl"]] placeholderImage:[UIImage imageNamed:imageArray[indexPath.row]]];
    [cell.headImageView setImage:[UIImage imageNamed:imageArray[indexPath.row]]];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(48, 62 - 0.5, APP_W - 48, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [cell addSubview:line];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    MedicineSubViewController * medicineSubViewController = [[MedicineSubViewController alloc]init];
    medicineSubViewController.title = self.data[indexPath.row][@"name"];
    medicineSubViewController.classId = self.data[indexPath.row][@"classId"];
    medicineSubViewController.requestType = RequestTypeMedicine;

    self.selectedIndex = indexPath.row;
    [self.navigationController pushViewController:medicineSubViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
