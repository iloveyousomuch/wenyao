//
//  QZLikeShopViewController.m
//  wenyao
//
//  Created by Meng on 15/1/16.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "QZStoreCollectViewController.h"
#import "ConsultPharmacyTableViewCell.h"
#import "AppDelegate.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "SBJson.h"
#import "PharmacyStoreViewController.h"
#import "SVProgressHUD.h"
#import "XHDemoWeChatMessageTableViewController.h"
#import "UIViewController+isNetwork.h"
#import "ReturnIndexView.h"

@interface QZStoreCollectViewController()<ReturnIndexViewDelegate>

{
    NSInteger currentPage;
    UIView *_nodataView;
}
@property (strong, nonatomic) ReturnIndexView *indexView;
@property (nonatomic ,strong) NSMutableArray *dataSource;
@end

@implementation QZStoreCollectViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"我关注的药房";
        currentPage = 1;
        self.tableView.frame = CGRectMake(0, 0, APP_W, APP_H-NAV_H);
        self.tableView.rowHeight = 66;
        UIView *footView = [[UIView alloc]init];
        footView.backgroundColor = UIColorFromRGB(0xf5f5f5);
        self.tableView.tableFooterView = footView;
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
        self.tableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
        self.tableView.footerReleaseToRefreshText = @"松开加载更多数据了";
        self.tableView.footerRefreshingText = @"正在帮你加载中";
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dataSource = [NSMutableArray array];
    
    if (app.currentNetWork != kNotReachable) {
        currentPage = 1;
        [self loadData];
    }else{
        [self.dataSource addObjectsFromArray:[app.dataBase queryAllMyFavStoreList]];
        if (self.dataSource.count > 0) {
            [self.tableView reloadData];
        }else{
            [self addNetView];
        }
    }
}

- (void)BtnClick{
    
    if (app.currentNetWork != kNotReachable){
        
        [[self.view viewWithTag:999] removeFromSuperview];
        [self loadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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




- (void)loadData
{
    [SVProgressHUD showWithStatus:@"数据加载中" maskType:SVProgressHUDMaskTypeClear];
    [[HTTPRequestManager sharedInstance] queryStoreCollectList:@{@"token":app.configureList[APP_USER_TOKEN],@"currPage":@(currentPage),@"pageSize":@10} completionSuc:^(id resultObj) {
        [SVProgressHUD dismiss];
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            NSArray *arr = resultObj[@"body"][@"list"];
            if (arr.count > 0) {
                [self.dataSource addObjectsFromArray:arr];
            }
            currentPage ++ ;
            if (self.dataSource.count > 0) {
                [self cacheMyFavStoreList:self.dataSource];
                [self.tableView reloadData];
            }else{
                [self showNoDataViewWithString:@"您还未关注任何药房哦!"];
            }
            [self.tableView footerEndRefreshing];
        }
    } failure:^(id failMsg) {
        [SVProgressHUD dismiss];
        [self.tableView footerEndRefreshing];
    }];
}

- (void)cacheMyFavStoreList:(NSArray *)array
{
    [app.dataBase removeAllMyFavStoreList];
    for(NSDictionary *dic in array)
    {
        NSString *storeId = dic[@"id"];
        NSString *accountId = dic[@"accountId"];
        NSString *name = dic[@"name"];
        NSString *star = [NSString stringWithFormat:@"%@",dic[@"star"]];
        NSString *avgStar = [NSString stringWithFormat:@"%@",dic[@"avgStar"]];
        NSString *consult = [NSString stringWithFormat:@"%@",dic[@"consult"]];
        NSString *accType = [NSString stringWithFormat:@"%@",dic[@"accType"]];
        NSString *tel = dic[@"tel"];
        NSString *province = dic[@"province"];
        NSString *city = dic[@"city"];
        NSString *county = dic[@"county"];
        NSString *addr = dic[@"addr"];
        NSString *distance = [NSString stringWithFormat:@"%@",dic[@"distance"]];
        NSString *imgUrl = dic[@"imgUrl"];
        NSString *shortName = dic[@"shortName"];
        NSString *tags = [dic[@"tags"] JSONRepresentation];
        [app.dataBase myFavStoreList:storeId
                                               name:name
                                               star:star
                                            avgStar:avgStar
                                            consult:consult
                                            accType:accType
                                                tel:tel
                                           province:province
                                               city:city
                                             county:county
                                               addr:addr
                                           distance:distance
                                             imgUrl:imgUrl
                                          accountId:accountId
                                               tags:tags
                                        shortName:shortName];
    }
}

- (void)footerRereshing
{
    [self loadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ConsultPharmacyIdentifier = @"ConsultPharmacyIdentifier";
    ConsultPharmacyTableViewCell *cell = (ConsultPharmacyTableViewCell *)[atableView dequeueReusableCellWithIdentifier:ConsultPharmacyIdentifier];
    if(cell == nil){
        UINib *nib = [UINib nibWithNibName:@"ConsultPharmacyTableViewCell" bundle:nil];
        [atableView registerNib:nib forCellReuseIdentifier:ConsultPharmacyIdentifier];
        cell = (ConsultPharmacyTableViewCell *)[atableView dequeueReusableCellWithIdentifier:ConsultPharmacyIdentifier];
        
        UIView *bkView = [[UIView alloc]initWithFrame:cell.frame];
        bkView.backgroundColor = UIColorFromRGB(0xdfe4e6);
        cell.selectedBackgroundView = bkView;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
    }
    
    NSDictionary *dict = self.dataSource[indexPath.row];
    NSLog(@"%@",dict[@"name"]);
    NSInteger accType = [dict[@"accType"] integerValue];
    if(accType == 2) {
        //显示
        cell.verifyLogo.hidden = NO;
        cell.verifyLogo.image = [UIImage imageNamed:@"认证V.png"];
    }else{
        cell.verifyLogo.hidden = YES;
    }
    NSString *imgUrl = dict[@"imgUrl"];
    if(imgUrl && ![imgUrl isEqual:[NSNull null]]){
        [cell.drugAvatar setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"药店默认头像.png"]];
    }else{
        [cell.drugAvatar setImage:[UIImage imageNamed:@"药店默认头像.png"]];
    }
    cell.tag = indexPath.row;
    cell.drugStore.frame = CGRectMake(cell.drugStore.frame.origin.x, cell.drugStore.frame.origin.y, 15 * [dict[@"name"] length], cell.drugStore.frame.size.height);
    cell.drugStore.text = dict[@"name"];
    cell.verifyLogo.frame = CGRectMake(cell.drugStore.frame.origin.x + cell.drugStore.frame.size.width + 5, cell.verifyLogo.frame.origin.y, cell.verifyLogo.frame.size.width, cell.verifyLogo.frame.size.height);
    cell.locationDesc.text = dict[@"addr"];
    float star = [dict[@"star"] floatValue];
    float avgStar = [dict[@"avgStar"] floatValue];
    star = MAX(star, avgStar);
    [cell.ratingView displayRating:star / 2];
    NSUInteger consultCount = [dict[@"consult"] intValue];
    cell.consultPerson.text = [NSString stringWithFormat:@"%d人已咨询",consultCount];
    cell.consultButton.tag = indexPath.row;
    [cell.consultButton addTarget:self action:@selector(freeConsultTouched:) forControlEvents:UIControlEventTouchDown];
    cell.distance.hidden = YES;
    cell.distanceIcon.hidden = YES;
    [cell.locationDesc setFrame:CGRectMake(82, cell.locationDesc.frame.origin.y, 238, 21)];
//    float distance = [dict[@"distance"] floatValue];
//    
//    //        if([_selectedCityName isEqualToString:[[reGeocode addressComponent] city]])
//    //        {
//    if (distance < 0) {
//        cell.distance.text = @"超出20KM";
//    }else if (distance > 20) {
//        cell.distance.text = @"超出20KM";
//    }else{
//        cell.distance.text = [NSString stringWithFormat:@"%.1fKM",distance];
//    }
//    //        }else{
//    //            cell.distance.text = @"超出20KM";
//    //        }
    id tags = dict[@"tags"];
    if([tags isKindOfClass:[NSString class]]){
        tags = [tags JSONValue];
    }
    
    [self handleTags:tags withCell:cell];
    
    cell.viewSeparator = [[UIView alloc]init];
    cell.viewSeparator.frame = CGRectMake(0, 119.5, cell.frame.size.width, 0.5);
    cell.viewSeparator.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [cell addSubview:cell.viewSeparator];
    
    return cell;
}

//////////滑动删除//////////

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"取消关注";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络不可用!" duration:DURATION_SHORT];
        return;
    }
    
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    NSDictionary *dict = self.dataSource[indexPath.row];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"objId"] = dict[@"id"];
    setting[@"objType"] = @"7";
    setting[@"method"] = @"3";
    
    [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            if ([resultObj[@"body"][@"result"] isEqualToString:@"3"]){
                [SVProgressHUD showSuccessWithStatus:@"取消关注成功" duration:DURATION_SHORT];
                [self.dataSource removeObject:dict];
                [self cacheMyFavStoreList:self.dataSource];
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [self.tableView endUpdates];
            }
        }
    }failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [MobClick event:@"aw-yfxq"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PharmacyStoreViewController *pharmacyStoreViewController = [[PharmacyStoreViewController alloc] initWithNibName:@"PharmacyStoreViewController" bundle:nil];
    NSMutableDictionary *dict = [self.dataSource[indexPath.row] mutableCopy];
    pharmacyStoreViewController.infoDict = dict;
    [self.navigationController pushViewController:pharmacyStoreViewController animated:YES];
}

- (void)handleTags:(NSArray *)tagArray withCell:(ConsultPharmacyTableViewCell *)cell
{
    cell.key1Image.hidden = YES;
    cell.key1Label.hidden = YES;
    cell.key2Image.hidden = YES;
    cell.key2Label.hidden = YES;
    cell.key3Image.hidden = YES;
    cell.key3Label.hidden = YES;
    cell.key4Image.hidden = YES;
    cell.key4Label.hidden = YES;
    
    for(NSDictionary *dict in tagArray)
    {
        NSUInteger index = [dict[@"key"] integerValue];
        NSLog(@"标签%@",dict[@"tag"]);
        if([dict[@"tag"] isEqualToString:@"24H"]) {
            //24H营业
            cell.key2Image.hidden = NO;
            cell.key2Label.hidden = NO;
        }
        if([dict[@"tag"] isEqualToString:@"医保定点"]) {
            //医保定点
            cell.key3Image.hidden = NO;
            cell.key3Label.hidden = NO;
        }
        if([dict[@"tag"] isEqualToString:@"免费送药"]) {
            //免费送药
            cell.key1Image.hidden = NO;
            cell.key1Label.hidden = NO;
        }
    }
    if([tagArray count] >= 3){
        cell.key4Image.hidden = YES;
        cell.key4Label.hidden = YES;
    }else if([tagArray count] <= 2 && (cell.key2Label.hidden == NO)) {
        cell.key4Image.hidden = NO;
        cell.key4Label.hidden = NO;
    }else if ([tagArray count] <= 1){
        cell.key4Image.hidden = NO;
        cell.key4Label.hidden = NO;
    }
}


- (void)freeConsultTouched:(UIButton *)sender
{
//    [MobClick event:@"aw-zxzx"];
    NSDictionary *dict = self.dataSource[sender.tag];
    XHDemoWeChatMessageTableViewController *demoWeChatMessageTableViewController = [[XHDemoWeChatMessageTableViewController  alloc] init];
    demoWeChatMessageTableViewController.infoDict = dict;
    demoWeChatMessageTableViewController.title = dict[@"name"];
    [self.navigationController pushViewController:demoWeChatMessageTableViewController animated:YES];
}
//显示没有历史搜索记录view
-(void)showNoDataViewWithString:(NSString *)nodataPrompt
{
    if (_nodataView) {
        [_nodataView removeFromSuperview];
        _nodataView = nil;
    }
    _nodataView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H)];
    //_nodataView.backgroundColor = COLOR(242, 242, 242);
    _nodataView.backgroundColor = BG_COLOR;
    
    
    //    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]init];
    //    [tap addTarget:self action:@selector(keyboardHidenClick)];
    //    [_nodataView addGestureRecognizer:tap];
    UIImage * searchImage = [UIImage imageNamed:@"无收藏.png"];
    
    UIImageView *dataEmpty = [[UIImageView alloc]initWithFrame:RECT(0, 0, searchImage.size.width, searchImage.size.height)];
    dataEmpty.center = CGPointMake(APP_W/2, 110);
    dataEmpty.image = searchImage;
    [_nodataView addSubview:dataEmpty];
    
    UILabel* lable_ = [[UILabel alloc]initWithFrame:RECT(0,dataEmpty.frame.origin.y + dataEmpty.frame.size.height + 10, nodataPrompt.length*20,30)];
    lable_.font = Font(12);
    lable_.textColor = COLOR(137, 136, 155);
    lable_.textAlignment = NSTextAlignmentCenter;
    lable_.center = CGPointMake(APP_W/2, lable_.center.y);
    lable_.text = nodataPrompt;
    
    [_nodataView addSubview:lable_];
    [self.view insertSubview:_nodataView atIndex:self.view.subviews.count];
}

@end
