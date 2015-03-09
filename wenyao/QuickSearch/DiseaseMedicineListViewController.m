//
//  MedicineListViewController.m
//  quanzhi
//
//  Created by ZhongYun on 14-6-20.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "DiseaseMedicineListViewController.h"
#import "UIImageView+WebCache.h"
#import "MedicineDetailViewController.h"
#import "DrugDetailViewController.h"
#import "Categorys.h"
#import "HTTPRequestManager.h"
#import "AFNetworking.h"
#import "ZhPMethod.h"
#import "MJRefresh.h"

@interface DiseaseMedicineListViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView* m_table;
    NSMutableArray* m_data;
    int m_currPage;
    
    BOOL bisSells;
    
}
@end

@implementation DiseaseMedicineListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        if (iOSv7 && self.view.frame.origin.y==0) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = NO;
        }
        
        
        
        m_data = [[NSMutableArray alloc] init];
        m_currPage = 1;
        bisSells = NO;
        
        m_table = [[UITableView alloc] initWithFrame:RECT(0, 0, APP_W, APP_H-NAV_H)
                                               style:UITableViewStylePlain];
        m_table.backgroundColor = [UIColor clearColor];
        m_table.separatorStyle = UITableViewCellSeparatorStyleNone;
        m_table.bounces = YES;
        m_table.rowHeight = 90;
        m_table.delegate = self;
        m_table.dataSource = self;
        [self.view addSubview:m_table];
        
        
        m_table.footerPullToRefreshText = @"上拉可以加载更多数据了";
        m_table.footerReleaseToRefreshText = @"松开加载更多数据了";
        m_table.footerRefreshingText = @"正在帮你加载中";
        [m_table addFooterWithTarget:self action:@selector(footerRereshing)];
    }
    return self;
}

- (void)footerRereshing
{
    [self loadData];
}

- (void)setParams:(NSDictionary *)params
{
    _params = params;
    [self loadData];
}

- (void)loadData
{
    bisSells = NO;
    NSString* url = nil;
    NSDictionary* para = nil;
    if (self.params[@"formulaId"]) {
        url = NW_queryDiseaseFormulaProductList;
        para = @{@"diseaseId":self.params[@"diseaseId"],
                 @"formulaId":self.params[@"formulaId"],
                 @"currPage":@(m_currPage),
                 @"pageSize":@(PAGE_ROW_NUM) };
    } else if (self.params[@"type"]) {
        url = NW_queryDiseaseProductList;
        para = @{@"diseaseId":self.params[@"diseaseId"],
                 @"type":myFormat(@"%@", self.params[@"type"]),
                 @"currPage":@(m_currPage),
                 @"pageSize":@(PAGE_ROW_NUM) };
    } else if (self.params[@"factoryCode"]) {
        url = NW_queryFactoryProductList;
        para = @{@"factoryCode":self.params[@"factoryCode"],
                 @"currPage":@(m_currPage),
                 @"pageSize":@(PAGE_ROW_NUM) };
    }  else if (self.params[@"drugStoreCode"]) {
        if (m_data.count >= 20) {
            showNotice(@"最多浏览20条。");
            return;
        }
        
        bisSells = YES;
        url = NW_fetchSellWellProducts;
        para = @{@"drugStoreCode":self.params[@"drugStoreCode"],
                 @"currPage":@(m_currPage),
                 @"pageSize":@(PAGE_ROW_NUM)};
    }
    
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:url parameters:para success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([((NSString *)responseObject[@"result"]) isEqualToString:@"OK"]) {
            id result = responseObject[@"body"];
            [m_data addObjectsFromArray: ([result isKindOfClass:[NSArray class]]? result : result[@"data"])];
            [m_table reloadData];
            m_currPage ++;
            [m_table footerEndRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
}

#pragma mark - MJRefreshBaseViewDelegate


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return m_table.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [m_table cellForRowAtIndexPath:indexPath].selected = NO;
    DrugDetailViewController *vc = [[DrugDetailViewController alloc] init];
//    MedicineDetailViewController* vc = nil;
//    if(HIGH_RESOLUTION){
//        vc = [[MedicineDetailViewController alloc] initWithNibName:@"MedicineDetailViewController" bundle:nil];
//    }else{
//        vc = [[MedicineDetailViewController alloc] initWithNibName:@"MedicineDetailViewController-480" bundle:nil];
//    }
//    vc.boxProductId = @"";
    vc.proId = m_data[indexPath.row][@"proId"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dataRow = m_data[indexPath.row];
    NSString* proId = dataRow[@"id"];
    if (!proId) proId = dataRow[@"proId"];
    NSString* str = [NSString stringWithFormat:@"cell_%@", proId];
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:str];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:str];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIView* border = [[UIView alloc] initWithFrame: RECT(0, m_table.rowHeight-0.5, APP_W, 0.5)];
        border.backgroundColor = COLOR(207, 207, 207);
        [cell addSubview:border];
        
        [self addCellObjs:cell IndexPath:indexPath];
    }
    //[self updateCellObjs:cell IndexPath:indexPath];
    return cell;
}


- (void)addCellObjs:(UITableViewCell *)cell IndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* row = [m_data objectAtIndex:indexPath.row];
    
    CGRect rect = RECT(10, 10, 68, 68);
    const int BAN_E = 10;
    
    NSString* imgurl = PORID_IMAGE(row[@"proId"]);
    UIImageView* webImage = [[UIImageView alloc] initWithFrame:rect];
    webImage.tag = 50;
    webImage.layer.borderColor = COLOR(207, 207, 207).CGColor;
    webImage.layer.borderWidth = 0.5;
    webImage.backgroundColor = [UIColor clearColor];
    [webImage setImageWithURL:[NSURL URLWithString:imgurl]
              placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
    webImage.clipsToBounds = YES;
    [cell addSubview:webImage];
    
    CGFloat x = webImage.frame.origin.x+webImage.frame.size.width+BAN_E;
    UILabel* lbtitle = [[UILabel alloc] init];
    lbtitle.tag = 51;
    lbtitle.frame = RECT(x, BAN_E+5, APP_W-25-x, 26);
    lbtitle.backgroundColor = [UIColor clearColor];
    lbtitle.textAlignment = NSTextAlignmentLeft;
    lbtitle.textColor = COLOR(51, 51, 51);
    lbtitle.font = FontB(13);
    lbtitle.text = [row objectForKey:@"proName"];
    lbtitle.lineBreakMode = NSLineBreakByCharWrapping | NSLineBreakByTruncatingTail;
    lbtitle.numberOfLines = 1;
    [cell addSubview:lbtitle];
    [lbtitle sizeToFit];
    
    UILabel* lbDesc = [[UILabel alloc] init];
    lbDesc.tag = 52;
    lbDesc.frame = RECT(x, lbtitle.frame.origin.y+lbtitle.frame.size.height+7, APP_W-25-x, 12);
    lbDesc.backgroundColor = [UIColor clearColor];
    lbDesc.textAlignment = NSTextAlignmentLeft;
    lbDesc.textColor = COLOR(102, 102, 102);
    lbDesc.font = Font(12);
    lbDesc.text = [row objectForKey:@"spec"];
    lbDesc.lineBreakMode = NSLineBreakByTruncatingTail;
    [cell addSubview:lbDesc];
    [lbDesc sizeToFit];
    
    NSString* factory = row[@"factory"];
    if (factory==nil) factory = row[@"makePlace"];
    if (factory==nil) factory = row[@"makeplace"];
    UILabel* lbcomp = [[UILabel alloc] init];
    lbcomp.tag = 53;
    lbcomp.frame = RECT(x, lbDesc.frame.origin.y+lbDesc.frame.size.height+7, APP_W-25-x, 36);
    lbcomp.backgroundColor = [UIColor clearColor];
    lbcomp.textAlignment = NSTextAlignmentLeft;
    lbcomp.textColor = COLOR(102, 102, 102);
    lbcomp.font = Font(12);
    lbcomp.text = factory;
    lbcomp.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    lbcomp.numberOfLines = 0;
    [cell addSubview:lbcomp];
    [lbcomp sizeToFit];
    
    if (bisSells) {
        if (row[@"tag"] != nil) {
            UIView* flag_bg = [[UIView alloc] initWithFrame:RECT(0, webImage.FH-15, webImage.FW, 15)];
            flag_bg.backgroundColor = [UIColor blackColor];
            flag_bg.alpha = 0.6;
            [webImage addSubview:flag_bg];
            addLabelObjEx(webImage, @[@54, NSStringFromCGRect(flag_bg.frame), [UIColor whiteColor], Font(10),
                                      myFormat(@"%@", row[@"tag"])]).textAlignment = NSTextAlignmentCenter;
        }
        
        UIImageView* flagIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sellFlag.png"]];
        flagIcon.frame = RECT(10, 10, flagIcon.FW, flagIcon.FH);
        [cell addSubview:flagIcon];
        
        addLabelObjEx(flagIcon, @[@55, NSStringFromCGRect(flagIcon.bounds),
                                  [UIColor whiteColor], Font(10),
                                  myFormat(@"%d",indexPath.row+1)]).textAlignment = NSTextAlignmentCenter;
    }
}


@end
