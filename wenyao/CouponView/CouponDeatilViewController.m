//
//  CouponDeatilViewController.m
//  wenyao
//
//  Created by 李坚 on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "CouponDeatilViewController.h"
#import "MedicineListCell.h"
#import "CouponConsuletViewController.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "CouponGenerateViewController.h"
#import "MJRefresh.h"
#import "DrugDetailViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "ScanReaderViewController.h"
#import "ReturnIndexView.h"

@interface CouponDeatilViewController ()<ReturnIndexViewDelegate>
{
    int currentPage;
    id couponId;
    NSDictionary *dic;
    NSMutableArray *drugList;
}
@property (strong, nonatomic) ReturnIndexView *indexView;
@end

@implementation CouponDeatilViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.lineHeight.constant = 0.5f;
    
    [self setRightItems];

    
//    UIView *customBarItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
//    UIButton *scanButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 2, 55, 55)];
//    [scanButton setImage:[UIImage imageNamed:@"首页_扫码.png"] forState:UIControlStateNormal];
//    [scanButton addTarget:self action:@selector(scanAction:) forControlEvents:UIControlEventTouchDown];
//    [customBarItems addSubview:scanButton];
//    
//    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    fixed.width = -20;
//    self.navigationItem.rightBarButtonItems = @[fixed,[[UIBarButtonItem alloc] initWithCustomView:customBarItems]];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
//    [self.view addSubview:self.tableView];
    drugList = [NSMutableArray array];
    if(self.infoDic[@"products"] && [self.infoDic[@"products"]isKindOfClass:[NSArray class]])
        drugList = self.infoDic[@"products"];
    
    
    self.tableView.tableFooterView = [[UIView alloc]init];
//    [self loadBaseData];
    self.line101Height.constant = 0.5f;
    self.line102Height.constant = 0.5f;
    self.lin103Height.constant = 0.5f;
    self.line104Height.constant = 0.5f;
    self.line105Height.constant = 0.5f;
    self.footLineHeiht.constant = 0.5f;
//    [self loadBaseData];
    [self stInfomation];
}

- (void)loadBaseData{
    
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"proId"] = self.promotionId;
    
    [[HTTPRequestManager sharedInstance]couponScan:setting completionSuc:^(id resultObj){
        if([resultObj[@"result"] isKindOfClass:[NSString class]] && [resultObj[@"result"] isEqualToString:@"OK"]){
            int status = [resultObj[@"body"][@"status"] intValue];
            BOOL hiden;
            switch (status) {
                case 0:
                    hiden = YES;
                    break;
                case -13:
                    hiden = YES;
                    break;
                case -14:
                    hiden = YES;
                    break;
                default:
                    hiden = NO;
                    break;
            }
            if(!hiden){
                self.downSpace.constant = 0.0f;
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        [SVProgressHUD showErrorWithStatus:@"加载失败!" duration:0.8f];
    }];
}


//- (void)loadDrugList{
//    
//    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
//    setting[@"promotion"] = self.promotionId;
//    setting[@"page"] = @(currentPage);
//    setting[@"pageSize"] = @(10);
//    
//    [[HTTPRequestManager sharedInstance]couponDrugs:setting completionSuc:^(id resultObj){
//        
//        [drugList addObjectsFromArray:resultObj[@"body"][@"list"]];
//        [self.tableView footerEndRefreshing];
//        [self.tableView reloadData];
//        currentPage += 1;
//    } failure:^(NSError *error) {
//        NSLog(@"%@",error);
//        [self.tableView footerEndRefreshing];
//        [SVProgressHUD showErrorWithStatus:@"加载失败!" duration:0.8f];
//    }];
//}

- (void)stInfomation{
    
    self.detailButton.layer.masksToBounds = YES;
    self.detailButton.layer.cornerRadius = 2.0f;
    self.detailButton.layer.borderWidth = 1.0f;
    self.detailButton.layer.borderColor = UIColorFromRGB(0x45c01a).CGColor;
    [self.detailButton setTitleColor:UIColorFromRGB(0x45c01a) forState:UIControlStateNormal];
    self.pushBtn.layer.masksToBounds = YES;
    self.pushBtn.layer.cornerRadius = 2.0f;
 
    
    CGSize titleSize = [self.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(SCREEN_W - 100, 2000)];
    
    self.descriptionLabel.text = self.infoDic[@"desc"];
    CGSize descSize = [self.descriptionLabel.text sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(SCREEN_W - 100, 2000)];
    
    CGSize totalSize;
    totalSize.height = 175.0f;
    
    totalSize.height = totalSize.height + titleSize.height - 20;
    totalSize.height = totalSize.height + descSize.height - 20;
    
    if([self.infoDic[@"limitTotal"] intValue] == 0){
        
        totalSize.height -= 30;
        [self.tickets removeFromSuperview];
        [self.leftChanges removeFromSuperview];
        [self.line101 removeFromSuperview];
    }
    if([self.infoDic[@"limitPersonTimes"] intValue] == 0){
        
        totalSize.height -= 30;
        [self.couponTimes removeFromSuperview];
        [self.couponTimesLabel removeFromSuperview];
        [self.line102 removeFromSuperview];
    }
    else{
        self.couponTimesLabel.text = [NSString stringWithFormat:@"每人享受%d次优惠",[self.infoDic[@"limitPersonTimes"] intValue]];
    }
    self.startTime.text = self.infoDic[@"validBegin"];
    self.endTime.text = self.infoDic[@"validEnd"];
    
    switch([self.infoDic[@"type"] intValue]){
        case 1://type = 1代表折扣券
            break;
        case 2://type = 2代表代金券
            break;
        case 3://type = 3代表买赠券
            break;
    }
    self.tickets.text = [NSString stringWithFormat:@"%d次（共%d次）",[self.infoDic[@"limitTotal"] intValue] - [self.infoDic[@"statTotal"] intValue],[self.infoDic[@"limitTotal"] intValue]];
    
    
    self.consulteLabel.text = [NSString stringWithFormat:@"%d家",[self.infoDic[@"statBranch"] intValue]];
    
    self.sectionView.layer.masksToBounds = YES;
    self.sectionView.layer.borderWidth = 0.5f;
    self.sectionView.layer.borderColor = UIColorFromRGB(0xdbdbdb).CGColor;
    
    self.footerView.frame = CGRectMake(0, 0, SCREEN_W, totalSize.height + 55);
    self.tableView.tableFooterView = self.footerView;
    
    if([self.infoDic[@"title"] isKindOfClass:[NSString class]]){
        
        self.titleLabel.text = self.infoDic[@"title"];
        CGSize titleSize = [self.infoDic[@"title"] sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(SCREEN_W - 100, 2000)];
        self.headerView.frame = CGRectMake(0, 0, self.headerView.frame.size.width, titleSize.height + 24);
        self.tableView.tableHeaderView = self.headerView;
    }
    else{
        self.tableView.tableHeaderView = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = @"优惠详情";
    }

#pragma ----首页---
-(void)setRightItems{

    UIView *yhxqBarItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 55)];
    //[customBarItems setBackgroundColor:[UIColor yellowColor]];
    UIButton *scanButton = [[UIButton alloc] initWithFrame:CGRectMake(28, 0, 55, 55)];
    [scanButton setImage:[UIImage imageNamed:@"首页_扫码.png"] forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(scanAction:) forControlEvents:UIControlEventTouchDown];
    [yhxqBarItems addSubview:scanButton];
    
    UIButton *indexButton = [[UIButton alloc] initWithFrame:CGRectMake(65, 0, 55, 55)];
    [indexButton setImage:[UIImage imageNamed:@"icon-unfold.PNG"] forState:UIControlStateNormal];
    [indexButton addTarget:self action:@selector(returnIndex) forControlEvents:UIControlEventTouchDown];
    [yhxqBarItems addSubview:indexButton];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -20;
    self.navigationItem.rightBarButtonItems = @[fixed,[[UIBarButtonItem alloc] initWithCustomView:yhxqBarItems]];
    
}

- (void)returnIndex
{
    self.indexView = [ReturnIndexView sharedManagerWithImage:@[@"首页.png"] title:@[@"首页"]];
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



#pragma ----首页结束---


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(drugList.count > 0){
        return 1;
    }
    else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95.0f;
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
    
    if(drugList[indexPath.row][@"name"] && [drugList[indexPath.row][@"name"] isKindOfClass:[NSString class]]){
        cell.topTitle.text = drugList[indexPath.row][@"name"];
    }
    else{
        cell.topTitle.text = @"";
    }
    cell.topTitle.font = Font(15.0f);
    cell.topTitle.textColor = UIColorFromRGB(0x333333);
    
    cell.middleTitle.text = drugList[indexPath.row][@"spec"];
    cell.middleTitle.font = Font(13.0f);
    cell.middleTitle.textColor = UIColorFromRGB(0x999999);
    
    cell.addressLabel.text = drugList[indexPath.row][@"factory"];
    cell.addressLabel.font = Font(13.0f);
    cell.addressLabel.textColor = UIColorFromRGB(0x999999);
    
    NSString * imageUrl = PORID_IMAGE(drugList[indexPath.row][@"proId"]);
    [cell.headImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 94.5, APP_W,0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [cell addSubview:line];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSIndexPath *selection = [tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
    
    DrugDetailViewController *drugDetailView = [[DrugDetailViewController alloc]init];
    drugDetailView.useType = 1;
    drugDetailView.proId = drugList[indexPath.row][@"proId"];
    
    [self.navigationController pushViewController:drugDetailView animated:YES];
}


- (IBAction)pushIntoDeatil:(id)sender {
    
    CouponConsuletViewController *CouponConsuletView = [[CouponConsuletViewController alloc]initWithNibName:@"CouponConsuletViewController" bundle:nil];
    CouponConsuletView.promotionId = self.promotionId;
    [self.navigationController pushViewController:CouponConsuletView animated:YES];
    
}


- (void)scanAction:(id)sender
{
    ScanReaderViewController *scanReaderViewController = [[ScanReaderViewController alloc] initWithNibName:@"ScanReaderViewController" bundle:nil];
    scanReaderViewController.useType = 3;
    scanReaderViewController.pageType = 1;
    scanReaderViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scanReaderViewController animated:YES];
}


- (IBAction)pushToGenerateView:(id)sender {
    
    self.pushBtn.userInteractionEnabled = NO;

    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"promotion"] = self.infoDic[@"id"];
    if(drugList[0][@"proId"]){
        setting[@"proId"] = drugList[0][@"proId"];
    }else{
        return;
    }
    if(app.logStatus){
        setting[@"token"] = app.configureList[@"token"];
    }
    
    [[HTTPRequestManager sharedInstance]couponScanFromDetail:setting completionSuc:^(id resultObj){
        //                body不会为空，首先判断status
        if([resultObj[@"result"] isEqualToString:@"OK"] && resultObj[@"body"]){
            
            CouponGenerateViewController *generateView = [[CouponGenerateViewController alloc]initWithNibName:@"CouponGenerateViewController" bundle:nil];
            generateView.useType = 1;
            generateView.type = [resultObj[@"body"][@"status"] integerValue];
            if([resultObj[@"body"][@"status"] intValue] != 0){
                generateView.sorryText = resultObj[@"msg"];
            }
            //传值：优惠活动详情
            generateView.infoDic = resultObj[@"body"];
            //传值：商品编码
            generateView.proId = drugList[0][@"proId"];
            [self.navigationController pushViewController:generateView animated:YES];
        }
        else{
            if(resultObj[@"msg"] && [resultObj[@"msg"] isKindOfClass:[NSString class]])
                [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:0.8f];
        }
        self.pushBtn.userInteractionEnabled = YES;
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        [SVProgressHUD showErrorWithStatus:@"加载失败!" duration:0.8f];
        self.pushBtn.userInteractionEnabled = YES;
        return;
    }];
    
}
@end
