//
//  NearStoreDetail1ViewController.m
//  wenyao
//
//  Created by 李坚 on 14/12/8.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "NearStoreDetail1ViewController.h"
#import "medicineTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "HTTPRequestManager.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "Categorys.h"
#import "Constant.h"
#import "ZhPMethod.h"
#import "ListPopView.h"
#import "NearMapViewController.h"
#import "MedicineListCell.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "DrugDetailViewController.h"
#import "NearSubMapViewController.h"


@interface NearStoreDetail1ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *m_table;
    
    NSMutableArray *m_data;
    NSMutableArray *m_sellList;
    NSMutableArray *sellMedicine;
    NSInteger currentPage;
    
    UIView *view;
    UILabel *infoLable;
    
    UIView *separtor1;
    UIView *separtor2;
    UIView *separtor3;
    UIView *boLine;
    UIView *separtor4;
}
@end

@implementation NearStoreDetail1ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"药房详情";
        self.view.backgroundColor = UIColorFromRGB(0xf2f2f2);
        
        m_table = [[UITableView alloc] initWithFrame:RECT(0, 0, APP_W, APP_H-NAV_H)
                                               style:UITableViewStyleGrouped];
        m_table.backgroundColor = UIColorFromRGB(0xf2f2f2);
        m_table.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        //        m_table.bounces = YES;
        m_table.delegate = self;
        m_table.dataSource = self;
        [self.view addSubview:m_table];
        
        self.detail = [[NSMutableDictionary alloc]init];
        
        m_data = [[NSMutableArray alloc] init];
        m_sellList = [[NSMutableArray alloc] init];
        sellMedicine = [[NSMutableArray alloc] init];
        
        view = [[UIView alloc]init];;
        infoLable = [[UILabel alloc]init];
        
        currentPage = 1;
        [m_table addFooterWithTarget:self action:@selector(footerRereshing)];
        m_table.footerPullToRefreshText = @"上拉加载更多数据";
        m_table.footerReleaseToRefreshText = @"松开加载更多数据";
        m_table.footerRefreshingText = @"正在加载中";

    }
    return self;
}

- (void)setStore:(NSDictionary *)store
{
    _store = store;
    [self loadStoreDetail:store];
}

- (void)loadStoreDetail:(NSDictionary*)store
{
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary* paras = @{@"drugStoreCode":self.store[@"code"]};
    [manager POST:NW_fetchPharmacyDetail parameters:paras success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([((NSString *)responseObject[@"result"]) isEqualToString:@"OK"]) {
            [self.detail removeAllObjects];
            [self.detail addEntriesFromDictionary:responseObject[@"body"]];
            mainThread(loadSellWellData, nil);
            mainThread(convertData, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
    
}

- (void)loadSellWellData
{
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary* paras = @{@"drugStoreCode":self.detail[@"code"], @"currPage":@(currentPage), @"pageSize":@(PAGE_ROW_NUM)};
    
    [manager POST:NW_fetchSellWellProducts parameters:paras success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([((NSString *)responseObject[@"result"]) isEqualToString:@"OK"]) {
            [m_sellList removeAllObjects];
            [m_sellList addObjectsFromArray:responseObject[@"body"][@"data"]];
            [m_data addObject:@{@"rowHeight":@24}];
            [m_data addObjectsFromArray:m_sellList];
            currentPage++;
            [m_table reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)convertData
{
    [m_data removeAllObjects];
    CGFloat v1_h, v2_h, more_h, row_h;
    
    //公司名称，介绍
    v1_h = getTextSize(self.detail[@"name"], Font(14), APP_W-40).height;
    v2_h = getTextSize(self.detail[@"introduction"], Font(12), APP_W-40).height;
    more_h = 0;
    if (v2_h==0) v2_h = 12;
    if (v2_h >= 12*2) {
        v2_h = 12*2;
        more_h = 2+16;
    }
    
    row_h = (10+v1_h+10) +  (10+v2_h+more_h+10);
    [m_data addObject:[@{@"id":@(arc4random()), @"rowHeight":@(row_h), @"extended":@0} mutableCopy]];
    
    //联系方式、地址
    v1_h = 12;
    v2_h = getTextSize(self.detail[@"address"], Font(12), APP_W-50).height;
    if (v2_h==0) v2_h=12;
    row_h = (10+v1_h+10) +  (10+v2_h+10);
    [m_data addObject:[@{@"id":@(arc4random()), @"rowHeight":@(row_h)} mutableCopy]];
    
    //营销信息
    v1_h = 14;
    v2_h = getTextSize(self.detail[@"promotionMsg"], Font(12), APP_W-40).height;
    if (v2_h == 0) v2_h = 12;
    more_h = 0;
    if (v2_h >= 12*2) {
        v2_h = 12*2;
        more_h = 2+16;
    }
    row_h = (10+v1_h+10) +  (10+v2_h+more_h+10);
    [m_data addObject:[@{@"id":@(arc4random()), @"rowHeight":@(row_h), @"extended":@0} mutableCopy]];
    
    //区域畅销药品
    //[m_data addObject:@{@"id":@(arc4random()), @"rowHeight":@29}];
    //NSLog(@"convertData = %@",m_data);

    [m_table reloadData];
}

- (void)footerRereshing{
    
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary* paras = @{@"drugStoreCode":self.detail[@"code"], @"currPage":@(currentPage), @"pageSize":@(PAGE_ROW_NUM)};
    //NSLog(@"paras = %@",paras);
   
    [manager POST:NW_fetchSellWellProducts parameters:paras success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([((NSString *)responseObject[@"result"]) isEqualToString:@"OK"]) {
            [m_sellList removeAllObjects];
            [m_sellList addObjectsFromArray:responseObject[@"body"][@"data"]];
            
            [m_data addObjectsFromArray:m_sellList];
            currentPage++;
            [m_table reloadData];
            [m_table footerEndRefreshing];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self loadStoreDetail:self.store];
    
    
    
}

#pragma mark -tableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    [sellMedicine removeAllObjects];
    for(id obj in m_data){
        
        if([obj objectForKey:@"proName"] != nil){
            [sellMedicine addObject:obj];
        }
    }
    
    return (self.detail==0 ? 0 : sellMedicine.count);;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    CGSize size = [[self.detail objectForKey:@"promotionMsg"] sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(APP_W - 20, 2000)];
    CGSize introduceSize = [[self.detail objectForKey:@"introduction"] sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(APP_W - 20, 2000)];
    
    if(size.height == 0){
        if(introduceSize.height == 0){
            return 237.0f;
        }
        else{
            return 223 + introduceSize.height;
        }
    }
    else{
        if(introduceSize.height == 0){
            return 321 + size.height;
        }
        else{
            return 307 + size.height + introduceSize.height;
        }
    }

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
//    [separtor1 removeFromSuperview];
    [separtor2 removeFromSuperview];
    [separtor3 removeFromSuperview];
    [separtor4 removeFromSuperview];
    [self.yingxiaoLable removeFromSuperview];
    [infoLable removeFromSuperview];
    [view removeFromSuperview];
    [self.introductionLable removeFromSuperview];
    [self.phoneLable removeFromSuperview];
    [self.phoneImage removeFromSuperview];
    [self.addressLable removeFromSuperview];
    [self.addressImage removeFromSuperview];
    [boLine removeFromSuperview];
    
    //药店名字
    self.nameLable.text = [self.detail objectForKey:@"name"];
//    separtor1 = [[UIView alloc]initWithFrame:CGRectMake(0, 55.5, APP_W, 0.5)];
//    separtor1.backgroundColor = UIColorFromRGB(0xdbdbdb);
//    [self.footView addSubview:separtor1];
    
    //药店简介
    self.introductionLable = [[UILabel alloc]init];
   
    self.introductionLable.font = [UIFont systemFontOfSize:14.0f];
    if([self.detail objectForKey:@"introduction"] == nil){
        
        self.introductionLable.frame = CGRectMake(10, 45, APP_W - 20, 14);
        
        self.introductionLable.text = @"暂无药店简介";
        self.introductionLable.textColor = UIColorFromRGB(0xaaaaaa);
    }else{
        CGSize introduceSize = [[self.detail objectForKey:@"introduction"] sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(APP_W - 20, 2000)];
        self.introductionLable.frame = CGRectMake(10, 45, APP_W - 20, introduceSize.height);
        self.introductionLable.numberOfLines = (int)(introduceSize.height / 14.0f);
        self.introductionLable.textColor  = UIColorFromRGB(0x333333);
        self.introductionLable.text = [self.detail objectForKey:@"introduction"];
    }
    [self.footView addSubview:self.introductionLable];
    
    
    separtor2 = [[UIView alloc]initWithFrame:CGRectMake(0, self.introductionLable.frame.origin.y + self.introductionLable.frame.size.height + 10, APP_W, 0.5)];
    separtor2.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [self.footView addSubview:separtor2];
    //药店电话
    self.phoneImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, self.introductionLable.frame.origin.y + self.introductionLable.frame.size.height + 10 + 13.5, 16, 16)];
    self.phoneImage.image = [UIImage imageNamed:@"药房详情_电话icon.png"];
    [self.footView addSubview:self.phoneImage];
    
    self.phoneLable = [[UILabel alloc]init];
    self.phoneLable.userInteractionEnabled = YES;
    self.phoneLable.font = [UIFont systemFontOfSize:16.0f];
    self.phoneLable.frame = CGRectMake(40, self.introductionLable.frame.origin.y + self.introductionLable.frame.size.height + 10 + 13.5 , APP_W - 50, 16);
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takePhone:)];
  
    if([self.detail objectForKey:@"mobile"] != nil && ![[self.detail objectForKey:@"mobile"] isEqualToString:@"13222222222"]){
        self.phoneLable.textColor = UIColorFromRGB(0x333333);
        self.phoneLable.text = [self.detail objectForKey:@"mobile"];
        [self.phoneLable addGestureRecognizer:tap];
    }
    else{
        self.phoneLable.textColor = UIColorFromRGB(0xaaaaaa);
        self.phoneLable.text = @"暂无联系电话";
    }
    
    [self.footView addSubview:self.phoneLable];
    
    
    separtor3 = [[UIView alloc]initWithFrame:CGRectMake(0, separtor2.frame.origin.y + 43, APP_W, 0.5)];
    separtor3.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [self.footView addSubview:separtor3];
    //药店地址
    self.addressLable = [[UILabel alloc]init];
    self.addressLable.font = [UIFont systemFontOfSize:16.0f];
    self.addressLable.frame = CGRectMake(40, separtor3.frame.origin.y + 15, APP_W - 50,40);
    self.addressLable.numberOfLines = 2;
    if([self.detail objectForKey:@"address"] != nil){
        self.addressLable.textColor = UIColorFromRGB(0x333333);
        self.addressLable.text = [self.detail objectForKey:@"address"];
    }
    else{
        self.addressLable.textColor = UIColorFromRGB(0xaaaaaa);
        self.addressLable.text = @"暂无药店地址";
    }
    [self.footView addSubview:self.addressLable];
    
    self.addressImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, separtor3.frame.origin.y + 20, 16, 16)];
    self.addressImage.center = CGPointMake(18, self.addressLable.center.y);
    self.addressImage.image = [UIImage imageNamed:@"药房详情_定位icon.png"];
    [self.footView addSubview:self.addressImage];
    

    //粗横线
    boLine = [[UIView alloc]initWithFrame:CGRectMake(0, self.addressLable.frame.origin.y + self.addressLable.frame.size.height + 15, APP_W, 8)];
    boLine.backgroundColor = UIColorFromRGB(0xEFEFF4);
    boLine.layer.masksToBounds = YES;
    boLine.layer.borderWidth = 0.5;
    boLine.layer.borderColor = UIColorFromRGB(0xdbdbdb).CGColor;
    [self.footView addSubview:boLine];
    
    
    //营销信息
    self.yingxiaoLable = [[UILabel alloc]initWithFrame:CGRectMake(10, self.addressLable.frame.origin.y + self.addressLable.frame.size.height + 38, 200, 16)];
    self.yingxiaoLable.font = [UIFont boldSystemFontOfSize:16.0f];
    self.yingxiaoLable.textColor = UIColorFromRGB(0x333333);
    self.yingxiaoLable.text = @"营销信息";
    [self.footView addSubview:self.yingxiaoLable];
    
    separtor4 = [[UIView alloc]initWithFrame:CGRectMake(0, self.yingxiaoLable.frame.origin.y + self.yingxiaoLable.frame.size.height + 15, APP_W, 0.5)];
    separtor4.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [self.footView addSubview:separtor4];
    
    CGSize size = [[self.detail objectForKey:@"promotionMsg"] sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(APP_W - 20, 2000)];
    
    infoLable = [[UILabel alloc]init];
    
//    [self.detail setObject:@"营销信息的模拟信息，为了顾客感觉呢来看人家那看来今日快快快。营销信息的模拟信息，为了顾客感觉呢来看人家那看来今日快快快。营销信息的模拟信息，为了顾客感觉呢来看人家那看来今日快快快。营销信息的模拟信息，为了顾客感觉呢来看人家那看来今日快快快。" forKey:@"promotionMsg"];
    
    if([self.detail objectForKey:@"promotionMsg"] == nil || size.height == 0){
        
        infoLable.frame = CGRectMake(10, 238, APP_W - 20, 0);
        self.yingxiaoLable.hidden = YES;
    view = [[UIView alloc]initWithFrame:CGRectMake(0, boLine.frame.origin.y, APP_W, 62)];
    }
    else{
        self.yingxiaoLable.hidden = NO;
        infoLable.numberOfLines = (int)(size.height / 14.0f);
        
        infoLable.frame = CGRectMake(10, separtor4.frame.origin.y + 8.0f, APP_W - 20, size.height);
        
        infoLable.font = Font(14.0f);
        infoLable.textColor = UIColorFromRGB(0x333333);
        
        infoLable.text = [self.detail objectForKey:@"promotionMsg"];
        view = [[UIView alloc]initWithFrame:CGRectMake(0, infoLable.frame.origin.y + infoLable.frame.size.height + 15, APP_W, 62)];
    }
    [self.footView addSubview:infoLable];
    
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, 200, 16)];
    title.textColor = UIColorFromRGB(0x333333);
    title.font = [UIFont boldSystemFontOfSize:16.0];
    title.text = @"区域畅销商品";
    [view addSubview:title];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 51, APP_W, 1)];
    line.backgroundColor = UIColorFromRGB(0x45c01a);
    [view addSubview:line];
    view.backgroundColor = UIColorFromRGB(0xEFEFF4);
    view.layer.borderWidth = 0.5;
    view.layer.borderColor = UIColorFromRGB(0xdbdbdb).CGColor;
    [self.footView addSubview:view];
    
    return self.footView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 90.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * cellIdentifier = @"cellIdentifier";
    medicineTableViewCell * cell = (medicineTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"medicineTableViewCell" owner:self options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 90 - 0.5, APP_W, 0.5)];
        line.backgroundColor = UIColorFromRGB(0xdbdbdb);
        [cell addSubview:line];
    }
    
    NSDictionary* dic = sellMedicine[indexPath.row];
    if([dic objectForKey:@"proName"] == nil){
        
    }
    cell.whatForLable.layer.borderWidth = 0.5f;
    cell.whatForLable.layer.borderColor = UIColorFromRGB(0xdbdbdb).CGColor;
    
    NSString* imgurl = PORID_IMAGE(dic[@"proId"]);
    [cell.medicineImage setImageWithURL:[NSURL URLWithString:imgurl]
             placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];

    NSString *str = [NSString stringWithFormat:@"NO.%d@2x.png",indexPath.row +1];
    cell.numberImage.image = [UIImage imageNamed:str];

    cell.nameLable.text = dic[@"proName"];
    cell.mlLable.text = dic[@"spec"];
    cell.compaleLable.text = dic[@"factory"];
    cell.whatForLable.text = dic[@"tag"];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DrugDetailViewController * drugDetail = [[DrugDetailViewController alloc] init];
    NSLog(@"the m data pro id is %@",sellMedicine[indexPath.row][@"proId"]);
    drugDetail.proId = sellMedicine[indexPath.row][@"proId"];
    [self.navigationController pushViewController:drugDetail animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)takePhone:(UITapGestureRecognizer *)tap{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:self.phoneLable.text message: nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"呼叫", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 1){
        if ([self.phoneLable.text length] > 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.phoneLable.text]]];
        }
    }
}

@end
