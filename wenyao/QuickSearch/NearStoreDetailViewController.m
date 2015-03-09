//
//  NearStoreDetailViewController.m
//  wenyao
//
//  Created by Meng on 14-10-8.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "NearStoreDetailViewController.h"
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

#define SELL_CELL_H     84
#define TAG_MORE_SELL   12300

@interface NearStoreDetailViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView* m_table;
    NSMutableArray* m_data;
    NSMutableArray* m_sellList;
    
    NSInteger currentPage;
}
@property(nonatomic, retain)NSMutableDictionary* detail;
@end

@implementation NearStoreDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"药房详情";
        self.view.backgroundColor = UIColorFromRGB(0xf2f2f2);
        
        self.detail = [[NSMutableDictionary alloc] init];
        m_sellList = [[NSMutableArray alloc] init];
        m_data = [[NSMutableArray alloc] init];
        m_table = [[UITableView alloc] initWithFrame:RECT(0, 0, APP_W, APP_H-NAV_H)
                                               style:UITableViewStylePlain];
        m_table.backgroundColor = UIColorFromRGB(0xf2f2f2);
        m_table.separatorStyle = UITableViewCellSeparatorStyleNone;
        m_table.bounces = YES;
        m_table.rowHeight = 44;
        m_table.delegate = self;
        m_table.dataSource = self;
        [self.view addSubview:m_table];
        
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

- (void)loadStoreDetail:(NSMutableDictionary*)store
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
    NSDictionary* paras = @{@"drugStoreCode":self.store[@"code"], @"currPage":@(currentPage), @"pageSize":@(PAGE_ROW_NUM)};
    
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

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"row = %d m_data[indexPath.row] = %@",indexPath.row, m_data[indexPath.row]);
    CGFloat row_h = 0;
    NSDictionary* dataRow = m_data[indexPath.row];
    if (dataRow[@"proId"] == nil) {
        if (!dataRow[@"rowHeight"]) {
            row_h = 10 + 10;
        }else
        row_h = 10 + [dataRow[@"rowHeight"] floatValue];
    } else {
        row_h = SELL_CELL_H;
    }
    return row_h;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.detail==0 ? 0 : m_data.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dataRow = m_data[indexPath.row];
    NSString* str = [NSString stringWithFormat:@"cell_%@", (dataRow[@"id"]!=nil ? dataRow[@"id"]:dataRow[@"proId"])];
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:str];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:str];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGFloat card_h = (dataRow[@"proId"]==nil ?[dataRow[@"rowHeight"] floatValue] : (SELL_CELL_H-10));
        UIView* card = [[UIView alloc] initWithFrame:RECT(10, 10, APP_W-20, card_h)];
        card.tag = 50;
        card.backgroundColor = [UIColor whiteColor];
        card.layer.borderColor = [UIColor lightGrayColor].CGColor;
        card.layer.borderWidth = 0.5;
        [cell addSubview:card];
        
        if (indexPath.row == 0) {
            [self addNameDesc:card IndexPath:indexPath];
        } else if (indexPath.row == 1) {
            [self addPhoneAddress:card IndexPath:indexPath];
        } else if (indexPath.row == 2) {
            [self addPromotionMsg:card IndexPath:indexPath];
        } else if (indexPath.row == 3) {
            card.hidden = YES;
            addLabelObjEx(cell, @[@51, RECT_OBJ(20, 10,  card.FW-30, 14), [UIColor blackColor], Font(14), @"区域畅销药品"]);
            UIView* line1 = [[UIView alloc] initWithFrame:RECT(10, 34-1, APP_W-20, 1)];
            line1.backgroundColor = [UIColor lightGrayColor];
            [cell addSubview:line1];
        } else if (indexPath.row >= 4) {
            card.layer.borderWidth = 0;
            [self addSellDataRow:card IndexPath:indexPath];
            UIView* line1 = [[UIView alloc] initWithFrame:RECT(card.FX, card.EY-0.5, card.FW, 0.5)];
            line1.backgroundColor = [UIColor lightGrayColor];
            [cell addSubview:line1];
        }
    }
    
    if (indexPath.row == 0) {
        [self updateMoreText:[cell viewWithTag:50] IndexPath:indexPath];
    } else if (indexPath.row == 2) {
        [self updateMoreText:[cell viewWithTag:50] IndexPath:indexPath];
    }
    return cell;
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


- (void)addNameDesc:(UIView*)card IndexPath:(NSIndexPath *)indexPath
{
    CGFloat pos_y = 10;
    
    CGSize nameSize = getTextSize(self.detail[@"name"], Font(14), card.FW);
    UILabel* title = addLabelObjEx(card, @[@51, RECT_OBJ(10, pos_y,  card.FW, nameSize.height), [UIColor blackColor], Font(14), self.detail[@"name"]]);
    UIImageView* storeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"storeFlag.png"]];
    storeIcon.frame = RECT(title.FX+nameSize.width+10, (34-storeIcon.FH)/2, storeIcon.FW, storeIcon.FH);
    [card addSubview:storeIcon];
    storeIcon.hidden = ([self.detail[@"join"] integerValue] != 1);
    pos_y += (nameSize.height + 10);
    
    UIView* line1 = [[UIView alloc] initWithFrame:RECT(10, pos_y, card.FW-10, 0.5)];
    line1.backgroundColor = [UIColor lightGrayColor];
    [card addSubview:line1];
    pos_y += (10);
    
    NSString * str = NoNullStr(self.detail[@"introduction"]);
    if (isEmptyStr(str)) {
        str = @"暂无药店简介";
    }
    
    CGFloat desc_h = getTextSize(str, Font(12), card.FW-20).height;
    CGFloat more_h = 0;
    if (desc_h == 0) desc_h = 12;
    if (desc_h >= 12*2) {
        desc_h = 12*2;
        more_h = 2+16;
    }
    
    addLabelObjEx(card, @[@52, RECT_OBJ(10, pos_y, card.FW-20, desc_h), [UIColor darkGrayColor], Font(12), str]);
    pos_y += (desc_h + (more_h>0?2:10));
    
    if (more_h > 0) {
        BOOL isExtended = ([m_data[indexPath.row][@"extended"] intValue]==1);
        UIButton* moreBtn = [[UIButton alloc] initWithFrame:RECT(card.FW-70, pos_y, 70, 16)];
        moreBtn.tag = 53;
        moreBtn.titleLabel.font = Font(12);
        [moreBtn setTitle:(isExtended ? @"收起" : @"更多") forState:0];
        [moreBtn setTitleColor:[UIColor darkGrayColor] forState:0];
        [moreBtn addTarget:self action:@selector(onMoreBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        [card addSubview:moreBtn];
        pos_y += (moreBtn.FH+0);
        UIImageView* moreIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DownAccessory.png"]];
        moreIcon.frame = RECT(moreBtn.FW/2+12, (moreBtn.FH-moreIcon.FH*0.5)/2, moreIcon.FW*0.5+1, moreIcon.FH*0.5+1);
        moreIcon.tag = 531;
        [moreBtn addSubview:moreIcon];
    }
}

- (void)addPhoneAddress:(UIView*)card IndexPath:(NSIndexPath *)indexPath
{
    CGFloat pos_y = 10;
    
    //phone
    UIImageView* phoneIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phone.png"]];
    phoneIcon.frame = RECT(10, pos_y, phoneIcon.FW, phoneIcon.FH);
    [card addSubview:phoneIcon];
    
    UIImageView* arr1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arr_right.png"]];
    arr1.frame = RECT(card.FW-15, pos_y+3, arr1.FW*0.5+2, arr1.FH*0.5+2);
    [card addSubview:arr1];
    
    NSString* phone = (isEmptyStr(self.detail[@"mobile"]) ? @"暂无联系方式" : self.detail[@"mobile"]);
    addLabelObjEx(card, @[@51, RECT_OBJ(25, pos_y, card.FW-35, 14), [UIColor darkGrayColor], Font(13.5), phone]);
    pos_y += (14 + 10);
    
    UIButton* phoneBtn = [[UIButton alloc] initWithFrame:RECT(0, 0, card.FW, 32)];
    phoneBtn.backgroundColor = [UIColor clearColor];
    [phoneBtn addTarget:self action:@selector(onPhoneBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [phoneBtn setBackgroundImage:color2Image([UIColor clearColor]) forState:UIControlStateNormal];
    [phoneBtn setBackgroundImage:color2Image(BTN_HIGHLIGHTED) forState:UIControlStateHighlighted];
    [card insertSubview:phoneBtn atIndex:0];
    
    
    // line
    UIView* line1 = [[UIView alloc] initWithFrame:RECT(10, pos_y, card.FW-10, 0.5)];
    line1.backgroundColor = [UIColor lightGrayColor];
    [card addSubview:line1];
    pos_y += (10);
    
    
    // address
    UIImageView* addrIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"storeAddr.png"]];
    addrIcon.frame = RECT(10, pos_y, addrIcon.FW, addrIcon.FH);
    [card addSubview:addrIcon];
    
    //UIImageView* arr2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arr_right.png"]];
    //arr2.frame = RECT(card.FW-15, pos_y, arr2.FW*0.5+2, arr2.FH*0.5+2);
    //[card addSubview:arr2];
    
    CGFloat v2_h = getTextSize(self.detail[@"address"], Font(12), card.FW-20).height;
    if (v2_h == 0) v2_h = 12;
    addLabelObjEx(card, @[@52, RECT_OBJ(25, pos_y, card.FW-20, v2_h), [UIColor darkGrayColor], Font(13.5), NoNullStr(self.detail[@"address"])]).numberOfLines = 1.0f;//孟
    //pos_y += (v2_h + 10);
    pos_y = 10;
    
    //地址按钮(不要删除,备用)
//    UIButton* addressBtn = [[UIButton alloc] initWithFrame:RECT(0, phoneBtn.FH, card.FW, card.FH-phoneBtn.FH)];
//    addressBtn.backgroundColor = [UIColor clearColor];
//    [addressBtn addTarget:self action:@selector(onAdressBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
//    [addressBtn setBackgroundImage:color2Image([UIColor clearColor]) forState:UIControlStateNormal];
//    [addressBtn setBackgroundImage:color2Image(BTN_HIGHLIGHTED) forState:UIControlStateHighlighted];
//    [card insertSubview:addressBtn atIndex:0];
}

- (void)addPromotionMsg:(UIView*)card IndexPath:(NSIndexPath *)indexPath
{
    CGFloat pos_y = 10;
    addLabelObjEx(card, @[@51, RECT_OBJ(10, pos_y,  card.FW-20, 14), [UIColor blackColor], Font(14), @"营销信息"]);
    pos_y += (14 + 10);
    
    UIView* line1 = [[UIView alloc] initWithFrame:RECT(10, pos_y, card.FW-10, 0.5)];
    line1.backgroundColor = [UIColor lightGrayColor];
    [card addSubview:line1];
    pos_y += (10);
    
    CGFloat desc_h = getTextSize(self.detail[@"promotionMsg"], Font(12), card.FW-20).height;
    CGFloat more_h = 0;
    if (desc_h == 0) desc_h = 12;
    if (desc_h >= 12*2) {
        desc_h = 12*2;
        more_h = 2+16;
    }
    
    NSString* promotionMsg = (isEmptyStr(self.detail[@"promotionMsg"]) ? @"暂无营销信息" : self.detail[@"promotionMsg"]);
    addLabelObjEx(card, @[@52, RECT_OBJ(10, pos_y, card.FW-20, desc_h), [UIColor darkGrayColor], Font(12), promotionMsg]);
    pos_y += (desc_h + (more_h>0?2:10));
    
    if (more_h > 0) {
        BOOL isExtended = ([m_data[indexPath.row][@"extended"] intValue]==1);
        UIButton* moreBtn = [[UIButton alloc] initWithFrame:RECT(card.FW-70, pos_y, 70, 16)];
        moreBtn.tag = 53;
        moreBtn.titleLabel.font = Font(12);
        [moreBtn setTitle:(isExtended ? @"收起" : @"更多") forState:0];
        [moreBtn setTitleColor:[UIColor darkGrayColor] forState:0];
        [moreBtn addTarget:self action:@selector(onMoreBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        [card addSubview:moreBtn];
        pos_y += (moreBtn.FH+0);
        UIImageView* moreIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DownAccessory.png"]];
        moreIcon.frame = RECT(moreBtn.FW/2+12, (moreBtn.FH-moreIcon.FH*0.5)/2, moreIcon.FW*0.5+1, moreIcon.FH*0.5+1);
        moreIcon.tag = 531;
        [moreBtn addSubview:moreIcon];
    }
}

- (void)addSellDataRow:(UIView*)card IndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dic = m_data[indexPath.row];
    
    CGRect rect = RECT(15, 10, 54, 54);
    NSString* imgurl = PORID_IMAGE(dic[@"proId"]);
    UIImageView* webImage = [[UIImageView alloc] initWithFrame:rect];
    webImage.frame = rect;
    webImage.layer.borderColor = COLOR(207, 207, 207).CGColor;
    webImage.layer.borderWidth = 0.5;
    webImage.backgroundColor = [UIColor clearColor];
    [webImage setImageWithURL:[NSURL URLWithString:imgurl]
             placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
    webImage.clipsToBounds = YES;
    [card addSubview:webImage];
    
    
    if (dic[@"tag"] != nil) {
        UIView* flag_bg = [[UIView alloc] initWithFrame:RECT(0, webImage.FH-15, webImage.FW, 15)];
        flag_bg.backgroundColor = [UIColor blackColor];
        flag_bg.alpha = 0.6;
        [webImage addSubview:flag_bg];
        addLabelObjEx(webImage, @[@40, NSStringFromCGRect(flag_bg.frame), [UIColor whiteColor], Font(10),
                                  myFormat(@"%@", dic[@"tag"])]).textAlignment = NSTextAlignmentCenter;
    }
    
    
    CGFloat top_y = 10;
    CGFloat title_w = (card.FW - webImage.EX - 20);
    CGFloat title_h = getTextSize(dic[@"proName"], Font(14), title_w).height;
    addLabelObjEx(card, @[@51, RECT_OBJ(webImage.EX+10, top_y, title_w, title_h),
                          [UIColor blackColor], Font(14), dic[@"proName"]]);
    top_y += (title_h + 5);
    
    addLabelObjEx(card, @[@52, RECT_OBJ(webImage.EX+10, top_y, title_w, 12),
                          [UIColor darkGrayColor], Font(12), dic[@"spec"]]);
    top_y += (12 + 5);
    
    [addLabelObjEx(card, @[@53, RECT_OBJ(webImage.EX+10, top_y, title_w, 24),
                           [UIColor darkGrayColor], Font(12), dic[@"factory"]]) sizeToFit];
    top_y += (12 + 5);
    
    
    UIImageView* flagIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sellFlag.png"]];
    flagIcon.frame = RECT(10, 0, flagIcon.FW, flagIcon.FH);
    [card addSubview:flagIcon];
    
    addLabelObjEx(flagIcon, @[@59, NSStringFromCGRect(flagIcon.bounds),
                              [UIColor whiteColor], Font(10),
                              myFormat(@"%d",indexPath.row-3)]).textAlignment = NSTextAlignmentCenter;

    //NSLog(@"indexPath.row = %d",indexPath.row);
    if (indexPath.row >= 4 && indexPath.row < 14) {
        flagIcon.hidden = NO;
    }else{
        flagIcon.hidden = YES;
    }
    
    InfoButton* medicBtn = [[InfoButton alloc] initWithFrame:card.bounds];
    medicBtn.info = dic;
    medicBtn.backgroundColor = [UIColor clearColor];
    [medicBtn addTarget:self action:@selector(onSellMedicBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [medicBtn setBackgroundImage:color2Image([UIColor clearColor]) forState:UIControlStateNormal];
    [medicBtn setBackgroundImage:color2Image(BTN_HIGHLIGHTED) forState:UIControlStateHighlighted];
    [card insertSubview:medicBtn atIndex:0];
}

- (void)updateMoreText:(UIView*)card IndexPath:(NSIndexPath *)indexPath
{
    BOOL isExtended = ([m_data[indexPath.row][@"extended"] intValue]==1);
    NSString* keyField = (indexPath.row==0 ? @"introduction" : @"promotionMsg");
    NSString* value = self.detail[keyField];
    if (indexPath.row==0) {
        if (isEmptyStr(value)) {
            value = @"暂无药店简介";
        }
    } else {
        if (isEmptyStr(value)) {
            value = @"暂无营销信息";
        }
    }
    
    CGFloat desc_h = getTextSize(value, Font(12), card.FW-20).height;
    [card viewWithTag:52].FH = (isExtended ? desc_h:MIN(desc_h, 12*2));
    
    if (desc_h > 12*2) {
        [card viewWithTag:53].FY = [card viewWithTag:52].EY + 2;
        ((UIImageView*)[card viewWithTag:531]).image = [UIImage imageNamed:(isExtended? @"UpAccessory.png":@"DownAccessory.png")];
    }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)onMoreBtnTouched:(UIButton*)sender
{
    NSIndexPath* indexPath = parentCellIndexPath(sender);
    BOOL isExtended = ([m_data[indexPath.row][@"extended"] intValue]==1);
    isExtended = !isExtended;
    
    NSString* keyField = (indexPath.row==0 ? @"introduction" : @"promotionMsg");
    CGFloat text_h = getTextSize(self.detail[keyField], Font(12), APP_W-40).height;
    text_h = (isExtended ? text_h : 12*2);
    CGFloat row_h = (10+14+10) + (10+text_h) + (2+16+8);
    
    m_data[indexPath.row][@"rowHeight"] = @(row_h);
    m_data[indexPath.row][@"extended"] = (isExtended ? @1 : @0);
    
    [m_table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:0];
}



- (void)onPhoneBtnTouched:(UIButton*)sender
{
    if (isEmptyStr(self.detail[@"mobile"])) {
        return;
    }
    NSString* phones = [self.detail[@"mobile"] stringByReplacingOccurrencesOfString:@"，" withString:@","];
    phones = [phones stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray* phoneList = [phones componentsSeparatedByString:@","];
    if (phoneList.count == 1) {
        NSString* telephone = myFormat(@"tel://%@", self.detail[@"mobile"]);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telephone]];
    } else {
        ListPopView* popView = [[ListPopView alloc] initWithType:POP_RADIO];
        popView.title = @"选择联系方式";
        popView.data = phoneList;
        [popView show];
        popView.respBlock = ^(NSArray* result) {
            int index = [result[0] intValue];
            NSString* telephone = myFormat(@"tel://%@", phoneList[index]);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telephone]];
        };
    }
}

- (void)onAdressBtnTouched:(UIButton*)sender
{
    NearSubMapViewController * nearSubMap = [[NearSubMapViewController alloc] init];
    nearSubMap.annotationDict = self.store;
    [self.navigationController pushViewController:nearSubMap animated:YES];
}

- (void)onSellMedicBtnTouched:(InfoButton*)sender
{
    DrugDetailViewController * drugDetail = [[DrugDetailViewController alloc] init];
    drugDetail.proId = sender.info[@"proId"];
    [self.navigationController pushViewController:drugDetail animated:YES];
 
}

@end





