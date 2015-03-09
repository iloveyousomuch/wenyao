//
//  PharmacyStoreViewController.m
//  wenyao
//
//  Created by xiezhenghong on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "PharmacyStoreViewController.h"
#import "PharmacyCommentTableViewCell.h"
#import "HTTPRequestManager.h"
#import "EvaluationViewController.h"
#import "ReportDrugStoreViewController.h"
#import "ActivityListViewController.h"
#import "ActivityDetailViewController.h"
#import "MarkPharmacyViewController.h"
#import "XHDemoWeChatMessageTableViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "SBJson.h"
#import "UIViewController+isNetwork.h"
#import "MJRefresh.h"
#import "AFNetworking.h"
#import "medicineTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "DrugDetailViewController.h"
#import "PhrmacyMoreDrugsViewController.h"
#import "MarketDetailViewController.h"
#import "ReturnIndexView.h"


@interface PharmacyStoreViewController ()<ReturnIndexViewDelegate>
{
    BOOL isNet;
    NSMutableArray *m_sellList;
    int currentPage;
    UIView *lastFootView;
}
@property (nonatomic, strong) NSMutableArray    *arguementList;
@property (nonatomic, strong) NSMutableArray    *activityList;

@property (strong, nonatomic) IBOutlet UIButton *btnPhoneNum;
@property (strong, nonatomic) ReturnIndexView *indexView;

- (IBAction)btnPressed_PhoneNum:(id)sender;

@end

@implementation PharmacyStoreViewController
//@synthesize tableView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       
        
        
    }
    return self;
}

- (void)checkIfCollected{
    
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"objId"] = self.infoDict[@"id"];
    setting[@"objType"] = @"7";
    setting[@"method"] = @"1";
    
    [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            if ([resultObj[@"body"][@"result"] isEqualToString:@"1"]){
                self.greenBtnLabel.text = @"已关注";
                self.greenImage.image = [UIImage imageNamed:@"已关注药房.png"];
            }else if([resultObj[@"body"][@"result"] isEqualToString:@"0"]){
                self.greenBtnLabel.text = @"关注药房";
                self.greenImage.image = [UIImage imageNamed:@"关注药房.png"];
            }
        }
    }failure:^(NSError *error) {
            NSLog(@"%@",error);
        }];
}

- (void)setupTableView
{
    
    
    //初始化tableView
//    if (self.isNet) {
//        rect.size.height -= 64;
//        rect.origin.y = 64;
//    }
    self.tableView = [[UITableView alloc] init];
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
    NSLog(@"self.view frame is %@, tableview frame is %@",NSStringFromCGRect(self.view.frame),NSStringFromCGRect(self.tableView.frame));
    if([self.infoDict[@"active"] intValue] == 0){
        
        self.tableView.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H - 64);
    }else{
        self.tableView.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H - 64 - 50);
    }
//    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
//    self.tableView.footerPullToRefreshText = @"上拉加载更多数据";
//    self.tableView.footerReleaseToRefreshText = @"松开加载更多数据";
//    self.tableView.footerRefreshingText = @"正在加载中";

    lastFootView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, 50)];
    lastFootView.backgroundColor = [UIColor clearColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
    [button setTitleColor:UIColorFromRGB(0x45c01a) forState:UIControlStateNormal];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 2.0f;
    button.layer.borderColor = UIColorFromRGB(0x45c01a).CGColor;
    button.layer.borderWidth = 1.0f;
    button.frame = CGRectMake(200, 15, 108, 29);
    button.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [button setTitle:@"查看更多商品" forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(checkMoreDrugs:) forControlEvents:UIControlEventTouchUpInside];
    
    [lastFootView addSubview:button];
    self.tableView.tableFooterView = lastFootView;
    [self.view addSubview:self.tableView];
    [self footerRereshing];
    
    //在线咨询、关注药房按钮
    self.redBtn.layer.masksToBounds = YES;
    self.redBtn.layer.cornerRadius = 2.0f;
    self.redBtn.tag  = 101;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(footBtnClick:)];
    [self.redBtn addGestureRecognizer:tap1];
    
    self.greenBtn.layer.masksToBounds = YES;
    self.greenBtn.layer.cornerRadius = 2.0f;
    self.greenBtn.tag  = 102;
    if (app.logStatus == kNotReachable) {
        self.greenBtnLabel.text = @"关注药房";
        self.greenImage.image = [UIImage imageNamed:@"关注药房.png"];
    }
    else{
        [self checkIfCollected];
    }
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(footTwoClick:)];
    [self.greenBtn addGestureRecognizer:tap2];
    self.footView.frame = CGRectMake(0,SCREEN_H - 64 - 50, self.footView.frame.size.width, self.footView.frame.size.height);
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [self.footView addSubview:line];
    if([self.infoDict[@"active"] intValue] == 1){
        [self.view addSubview:self.footView];
    }

}

#pragma mark - 查看更多畅销商品按钮点击事件
- (void)checkMoreDrugs:(id)sender{
    
    if(app.currentNetWork == kNotReachable){
        
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试！" duration:1.0f];
        return;
    }
    
    PhrmacyMoreDrugsViewController *moreDrugsView = [[PhrmacyMoreDrugsViewController alloc]initWithNibName:@"PhrmacyMoreDrugsViewController" bundle:nil];
    moreDrugsView.groupId = self.infoDict[@"id"];
    [self.navigationController pushViewController:moreDrugsView animated:YES];
}

#pragma mark - 在线咨询、关注药房按钮点击事件
- (void)footBtnClick:(id)sender{
    
        if(self.useType == 1)
        {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        if(!app.logStatus) {
            LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            UINavigationController *navgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
            loginViewController.isPresentType = YES;
            [self presentViewController:navgationController animated:YES completion:NULL];
            return;
        }
        XHDemoWeChatMessageTableViewController *demoWeChatMessageTableViewController = [[XHDemoWeChatMessageTableViewController  alloc] init];
        demoWeChatMessageTableViewController.infoDict = self.infoDict;
        demoWeChatMessageTableViewController.title = self.infoDict[@"name"];
        [self.navigationController pushViewController:demoWeChatMessageTableViewController animated:YES];
}

- (void)footTwoClick:(id)sender{
    
        if (!app.logStatus) {
            LoginViewController * login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            login.isPresentType = YES;
            login.parentNavgationController = self.navigationController;
            UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:login];
            [self presentViewController:nav animated:YES completion:nil];
            return;
        }
        NSMutableDictionary * setting = [NSMutableDictionary dictionary];
        setting[@"token"] = app.configureList[APP_USER_TOKEN];
        setting[@"objId"] = self.infoDict[@"id"];
        setting[@"objType"] = @"7";
        setting[@"method"] = @"1";
        
        [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                if ([resultObj[@"body"][@"result"] isEqualToString:@"1"]) {//已收藏
                    ///////////////////////////若已收藏,则取消收藏////////////////////////////
                    setting[@"method"] = @"3";
                    [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
                        if ([resultObj[@"body"][@"result"] isEqualToString:@"3"]) {
                            [SVProgressHUD showSuccessWithStatus:@"已取消关注" duration:DURATION_SHORT];
                            self.greenBtnLabel.text = @"关注药房";
                            self.greenImage.image = [UIImage imageNamed:@"关注药房.png"];
                        }
                    } failure:^(NSError *error) {
                        NSLog(@"%@",error);
                    }];
                }else if([resultObj[@"body"][@"result"] isEqualToString:@"0"]){//未收藏
                    //////////////////////////若为收藏,则添加收藏/////////////////////////
                    setting[@"method"] = @"2";
                    [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
                        if ([resultObj[@"body"][@"result"] isEqualToString:@"2"]) {
                            [SVProgressHUD showSuccessWithStatus:@"关注成功" duration:DURATION_SHORT];
                            self.greenBtnLabel.text = @"已关注";
                            self.greenImage.image = [UIImage imageNamed:@"已关注药房.png"];
                            //                            buttonImage.image = [UIImage imageNamed:@"导航栏_已收藏icon.png"];
                        }
                    } failure:^(NSError *error) {
                        NSLog(@"%@",error);
                    }];
                    
                }
            }else if ([resultObj[@"result"] isEqualToString:@"FAIL"]){
                if ([resultObj[@"msg"] isEqualToString:@"1"]) {
                    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:ALERT_MESSAGE delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    alertView.tag = 999;
                    alertView.delegate = self;
                    [alertView show];
                    return;
                }else{
                    [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:DURATION_SHORT];
                }
            }
            
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
        }];

}

- (void)setupHeaderView
{
    [self.ratingView setImagesDeselected:@"star_none.png" partlySelected:@"star_half.png" fullSelected:@"star_full" andDelegate:nil];
    self.ratingView.userInteractionEnabled = NO;
    [self.ratingView setBackgroundColor:[UIColor clearColor]];
    CGFloat rating = [self.infoDict[@"star"] floatValue];
    float avgStar = [self.infoDict[@"avgStar"] floatValue];
    rating = MAX(rating, avgStar);
    [self.ratingView displayRating:rating / 2];
    
    self.tableView.tableHeaderView = self.headerView;
}



- (void)initUI
{
    //药店名称
    CGRect tRect = self.pharmacyName.frame;
    CGSize tSize = [self.infoDict[@"name"] sizeWithFont:[UIFont systemFontOfSize:18.0] constrainedToSize:CGSizeMake(APP_W - 24, 2000)];
    self.pharmacyName.numberOfLines = 0;
    self.pharmacyName.frame = CGRectMake(tRect.origin.x, tRect.origin.y, tSize.width, tSize.height);
    self.pharmacyName.text = self.infoDict[@"name"];
    tRect = self.pharmacyName.frame;
    //认证标志
    CGRect rect = self.pharmacyName.frame;
    if(self.pharmacyName.text.length < (int)((APP_W - 24)/18)){
        rect.origin.x = self.pharmacyName.frame.origin.x + self.pharmacyName.frame.size.width + 3;
        rect.origin.y = self.pharmacyName.frame.origin.y + 2;
    }
    else{
        rect.origin.x = ([self.infoDict[@"name"] length] - (int)((APP_W - 24)/18)) * 18 + 17;
        rect.origin.y = self.pharmacyName.frame.origin.y + 18 + 7;
    }
    rect.size.width = 15.0f;
    rect.size.height = 15.0f;
    self.verifyLogo.frame = rect;
    tRect = self.verifyLogo.frame;
    //评价星星
    self.ratingView.frame = CGRectMake(self.ratingView.frame.origin.x, tRect.origin.y + tRect.size.height + 15, self.ratingView.frame.size.width, self.ratingView.frame.size.height);
    //咨询人数
    self.consultCount.frame = CGRectMake(self.consultCount.frame.origin.x, tRect.origin.y + tRect.size.height + 17, self.consultCount.frame.size.width, self.consultCount.frame.size.height);
    self.consultCount.text = [NSString stringWithFormat:@"%@人已咨询",self.infoDict[@"consult"]];
    //免费问药按钮
    self.consultButton.frame = CGRectMake(self.consultButton.frame.origin.x, tRect.origin.y + tRect.size.height + 10, self.consultButton.frame.size.width, self.consultButton.frame.size.height);
    self.consultButton.layer.masksToBounds = YES;
    self.consultButton.layer.cornerRadius = 3.5f;
    tRect = self.ratingView.frame;
    
    //绿色标志
    self.key1Image.frame = CGRectMake(self.key1Image.frame.origin.x, tRect.origin.y + tRect.size.height + 10, self.key1Image.frame.size.width, self.key1Image.frame.size.height);
    self.key1Label.frame = CGRectMake(self.key1Label.frame.origin.x, tRect.origin.y + tRect.size.height + 10, self.key1Label.frame.size.width, self.key1Label.frame.size.height);
    tRect = self.key1Label.frame;
    self.key1Image.hidden = YES;
    self.key1Label.hidden = YES;
    self.key2Image.hidden = YES;
    self.key2Label.hidden = YES;
    self.key3Image.hidden = YES;
    self.key3Label.hidden = YES;
    self.key4Image.hidden = NO;
    self.key4Label.hidden = NO;
    
    id tags = self.infoDict[@"tags"];
    if([tags isKindOfClass:[NSString class]]){
        tags = [tags JSONValue];
    }
    
    if (![tags isKindOfClass: [NSNull class]]) {
        for(NSDictionary *dict in tags)
        {
            NSUInteger index = [dict[@"key"] integerValue];
            if(index == 1) {
                //24H营业
                self.key2Image.hidden = NO;
                self.key2Label.hidden = NO;
            }else if(index == 2) {
                //医保定点
                self.key3Image.hidden = NO;
                self.key3Label.hidden = NO;
            }else if(index == 3) {
                //免费送药
                self.key1Image.hidden = NO;
                self.key1Label.hidden = NO;
            }
        }
    }
    
    

    CGRect imageRect = self.key1Image.frame;
    CGRect labelRect = self.key1Label.frame;
    if(self.key1Image.hidden == NO){
        self.key1Image.frame = imageRect;
        self.key1Label.frame = labelRect;
        imageRect.origin.x += self.key1Label.frame.size.width + 17;
        labelRect.origin.x += self.key1Label.frame.size.width + 17;
    }
    if(self.key3Image.hidden == NO){
        self.key3Image.frame = imageRect;
        self.key3Label.frame = labelRect;
        imageRect.origin.x += self.key3Label.frame.size.width + 17;
        labelRect.origin.x += self.key3Label.frame.size.width + 17;
    }
    if(self.key2Image.hidden == NO){
        self.key2Image.frame = imageRect;
        self.key2Label.frame = labelRect;
        imageRect.origin.x += self.key2Label.frame.size.width - 3;
        labelRect.origin.x += self.key2Label.frame.size.width - 3;
    }
    if(self.key4Image.hidden == NO){
        self.key4Image.frame = imageRect;
        self.key4Label.frame = labelRect;
    }
    //横线1
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, tRect.origin.y + tRect.size.height + 15, APP_W, 0.5)];
    line1.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [self.headerView addSubview:line1];
    //电话信息
    self.contactPhone.frame = CGRectMake(self.contactPhone.frame.origin.x, tRect.origin.y + 43, self.contactPhone.frame.size.width, self.contactPhone.frame.size.height);
    self.phoneImage.frame = CGRectMake(self.phoneImage.frame.origin.x, tRect.origin.y + 43, self.phoneImage.frame.size.width, self.phoneImage.frame.size.height);
    self.btnPhoneNum.center = self.phoneImage.center;
    self.btnPhoneNum.backgroundColor = [UIColor clearColor];
    tRect = self.contactPhone.frame;
    if(self.infoDict[@"tel"] && ![self.infoDict[@"tel"] isEqualToString:@""] && ![self.infoDict[@"tel"] isEqualToString:@"13222222222"]){
        self.contactPhone.text = self.infoDict[@"tel"];
    }else{
        self.contactPhone.text = @"暂无电话信息";
    }
    //横线2
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, tRect.origin.y + tRect.size.height + 10, APP_W, 0.5)];
    line2.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [self.headerView addSubview:line2];
    //地理位置信息
    self.location.frame = CGRectMake(self.location.frame.origin.x, tRect.origin.y + 45, self.location.frame.size.width, self.location.frame.size.height);
    self.addressImage.frame = CGRectMake(self.addressImage.frame.origin.x, tRect.origin.y + 48, self.addressImage.frame.size.width, self.addressImage.frame.size.height);
    tRect = self.location.frame;
    if(self.infoDict[@"addr"] && ![self.infoDict[@"addr"] isEqualToString:@""]){
        self.location.text = [NSString stringWithFormat:@"%@%@%@",self.infoDict[@"province"],self.infoDict[@"city"],self.infoDict[@"addr"]];
    }else{
        self.location.text = @"暂无地理位置信息";
    }
    
    //横线3
    UIView *line3 = [[UIView alloc]initWithFrame:CGRectMake(0, tRect.origin.y + tRect.size.height + 10, APP_W, 0.5)];
    line3.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [self.headerView addSubview:line3];
    //设置headerView的大小
    self.headerView.frame = CGRectMake(self.headerView.frame.origin.x, self.headerView.frame.origin.y, APP_W, line3.frame.origin.y + 0.5);
}


- (void)BtnClick
{
    if(![self isNetWorking]){
        for(UIView *v in [self.view subviews]){
            if(v.tag == 999){
                [v removeFromSuperview];
            }
        }
        [self subViewDidLoad];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    currentPage = 1;
    m_sellList = [[NSMutableArray alloc]init];
    
    UILabel *titleText = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 50, 50)];
    titleText.backgroundColor = [UIColor clearColor];
    titleText.textColor=[UIColor whiteColor];
    [titleText setFont:[UIFont boldSystemFontOfSize:18.0]];

    [titleText setText:@"药房详情"];
    self.navigationItem.titleView=titleText;
    
    if([self isNetWorking]){
        [self addNetView];
        return;
    }

    [self subViewDidLoad];
    
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
    self.indexView = [ReturnIndexView sharedManagerWithImage:@[@"icon home.PNG",@"icon-report.PNG"] title:@[@"首页",@"举报"]];
    self.indexView.delegate = self;
    [self.indexView show];
}
- (void)RetunIndexView:(ReturnIndexView *)ReturnIndexView didSelectedIndex:(NSIndexPath *)indexPath
{
    [self.indexView hide];
    if (indexPath.row == 0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self performSelector:@selector(delayPopToHome) withObject:nil afterDelay:0.01];
    }else if (indexPath.row == 1){
        [self reportStore];
    }
    
}
- (void)delayPopToHome
{
    [app.tabBarController setSelectedIndex:0];
}
#pragma mark---------------------------------------------跳转到首页-----------------------------------------------


- (void)subViewDidLoad{
    
    self.consultButton.hidden = YES;

    self.activityList = [NSMutableArray arrayWithCapacity:15];
    self.arguementList = [NSMutableArray arrayWithCapacity:15];
    //    UIBarButtonItem *reportBarButton = [[UIBarButtonItem alloc] initWithTitle:@"举报" style:UIBarButtonItemStylePlain target:self action:@selector(reportStore:)];
    //
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 50)];
    [btn addTarget:self action:@selector(reportStore:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    [btn setTitle:@"举报" forState:UIControlStateNormal];
    btn.titleLabel.textColor = [UIColor whiteColor];
    UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
   // self.navigationItem.rightBarButtonItem = homeButtonItem;

    [self setupTableView];
//    
    if(self.useType == 1){
        [self queryStoreSearch];
    }else{
        [self initUI];
        [self setupHeaderView];
        [self checkArguementList];
        [self checkActivityList];
    }
    /**
     *  即将开通状态下显示
     *
     *  @param 判断self.infoDict[@""]
     *
     */
    if([self.infoDict[@"active"] intValue] == 0){
    
        self.consultCount.text = @"0人已咨询";
        [self.ratingView displayRating:0.0f];
        self.key1Image.hidden = YES;
        self.key2Image.hidden = YES;
        self.key3Image.hidden = YES;
        self.key4Image.hidden = YES;
        self.key1Label.hidden = YES;
        self.key2Label.hidden = YES;
        self.key3Label.hidden = YES;
        self.key4Label.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
}

- (void)queryStoreSearch
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"group"] = self.infoDict[@"id"];
    [[HTTPRequestManager sharedInstance] storeSearch:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"])
        {
            [self.infoDict addEntriesFromDictionary:resultObj[@"body"]];
            [self initUI];
            [self setupHeaderView];
            [self checkArguementList];
            [self checkActivityList];
        }
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"获取失败!" duration:0.8];
    }];
    
}

- (void)checkArguementList
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"groupId"] = self.infoDict[@"id"];
    setting[@"currPage"] = @"1";
    setting[@"pageSize"] = @"100";
    [[HTTPRequestManager sharedInstance] queryAppraise:setting completion:^(id resultObj) {
        NSArray *array = resultObj[@"body"][@"data"];
        if(array && array.count > 0) {
            [self.arguementList addObjectsFromArray:array];
        }
        
        
        
        [self.tableView reloadData];
    } failure:NULL];
    
    
}

- (void)checkActivityList
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"groupId"] = self.infoDict[@"id"];
    setting[@"currPage"] = @(1);
    setting[@"pageSize"] = @(100);
    [[HTTPRequestManager sharedInstance] queryBranchActivity:setting completion:^(id resultObj) {
        
        
        NSArray *array = resultObj[@"body"][@"data"];
        if(array && array.count > 0) {
            [self.activityList addObjectsFromArray:array];
        }
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
//        NSLog(@"%@",error);
    }];
    
    
}

- (IBAction)pushIntoFreeConsult:(id)sender
{
    if(self.useType == 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if(!app.logStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
        return;
    }
    
    XHDemoWeChatMessageTableViewController *demoWeChatMessageTableViewController = [[XHDemoWeChatMessageTableViewController  alloc] init];
    demoWeChatMessageTableViewController.infoDict = self.infoDict;
    demoWeChatMessageTableViewController.title = self.infoDict[@"name"];
    [self.navigationController pushViewController:demoWeChatMessageTableViewController animated:YES];
}


- (void)reportStore
{
    ReportDrugStoreViewController *reportDrugStoreViewController = [[ReportDrugStoreViewController alloc] init];
    reportDrugStoreViewController.infoDict = self.infoDict;
    [self.navigationController pushViewController:reportDrugStoreViewController animated:YES];
}


- (void)pushIntoMoreArgument:(id)sender
{
    EvaluationViewController *evaluationViewController = [[EvaluationViewController alloc] init];
    evaluationViewController.infoList = self.arguementList;
    [self.navigationController pushViewController:evaluationViewController animated:YES];
}

- (void)pushIntoMoreActivity:(id)sender
{
    ActivityListViewController *activityListViewController = [[ActivityListViewController alloc] init];
    activityListViewController.infoList = self.activityList;
    activityListViewController.groupId = self.infoDict[@"id"];
    [self.navigationController pushViewController:activityListViewController animated:YES];
}


#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 54.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 2){
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, 54)];
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(10, 15, 200, 16)];
        title.textColor = UIColorFromRGB(0x333333);
        title.font = [UIFont boldSystemFontOfSize:16.0];
        title.text = @"区域畅销商品";
        [view addSubview:title];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 42, APP_W, 2)];
        line.backgroundColor = UIColorFromRGB(0x45c01a);
        [view addSubview:line];
       
//        view.backgroundColor = UIColorFromRGB(0xEFEFF4);
//        view.layer.borderWidth = 0.5;
//        view.layer.borderColor = UIColorFromRGB(0xdbdbdb).CGColor;
//        
        return view;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 42)];
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(10, 15, 300, 20)];
    if(section == 0){
        label.text = @"评价";
    }else{
        label.text = @"活动";
    }
    label.font = [UIFont systemFontOfSize:15.0];
    [headerView setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(10, 41, 300, 1.5)];
    [separator setBackgroundColor:APP_COLOR_STYLE];
    [headerView addSubview:label];
    [headerView addSubview:separator];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2){
        return 95.0f;
    }
    if(indexPath.row == 2){
        return 45.0;
    }
    if(indexPath.section == 0){
        return 78.0f;
    }else{
        return 44.0;
    }
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    if([self.infoDict allKeys].count == 1)
        return 0;
    if(section == 0){
        if([self.infoDict[@"active"] intValue] == 0){
            return 1;
        }
        if(self.arguementList.count > 2){
            return 3;
        }else if(self.arguementList.count == 0){
            return 1;
        }else{
            return self.arguementList.count;
        }
    }
    if(section == 1){
        if([self.infoDict[@"active"] intValue] == 0){
            return 1;
        }
        if(self.activityList.count > 2){
            return 3;
        }else if (self.activityList.count == 0){
            return 1;
        }else{
            return self.activityList.count;
        }
    }
    if(section == 2 && m_sellList.count > 2){
        return 2;
    }
    else{
        return m_sellList.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    atableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if(indexPath.section == 2){
        
        NSString * cellIdentifier = @"cellIdentifier";
        medicineTableViewCell * cell = (medicineTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"medicineTableViewCell" owner:self options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 95 - 0.5, APP_W, 0.5)];
            line.backgroundColor = UIColorFromRGB(0xdbdbdb);
            [cell addSubview:line];
        }
        
        NSDictionary* dic = m_sellList[indexPath.row];
     
        cell.whatForLable.layer.borderWidth = 0.5f;
        cell.whatForLable.layer.borderColor = UIColorFromRGB(0xdbdbdb).CGColor;
        
        NSString* imgurl = PORID_IMAGE(dic[@"proId"]);
        [cell.medicineImage setImageWithURL:[NSURL URLWithString:imgurl]
                           placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
        
        NSString *str = [NSString stringWithFormat:@"NO.%d@2x.png",indexPath.row +1];
        cell.numberImage.image = [UIImage imageNamed:str];
        
        if([dic[@"proName"] isKindOfClass:[NSString class]]){
            cell.nameLable.text = dic[@"proName"];
        }
        else{
            cell.nameLable.text = @"";
        }
        cell.nameLable.textColor = UIColorFromRGB(0x333333);
        cell.nameLable.font = Font(15.0f);
        
        if([dic[@"spec"] isKindOfClass:[NSString class]]){
            cell.mlLable.text = dic[@"spec"];
        }
        else{
            cell.mlLable.text = @"";
        }
        cell.mlLable.textColor = UIColorFromRGB(0x999999);
        cell.mlLable.font = Font(13.0f);
        
        if([dic[@"factory"] isKindOfClass:[NSString class]]){
            cell.compaleLable.text = dic[@"factory"];
        }
        else{
            cell.compaleLable.text = @"";
        }
        cell.compaleLable.textColor = UIColorFromRGB(0x999999);
        cell.compaleLable.font = Font(13.0f);
        
        if([dic[@"tag"] isKindOfClass:[NSString class]]){
            cell.whatForLable.hidden = NO;
            cell.whatForLable.text = dic[@"tag"];
        }else{
            cell.whatForLable.hidden = YES;
        }
        
        return cell;
    }
    if(indexPath.row == 2)
    {
        static NSString *extentIdentifier = @"extentIdentifier";
        UITableViewCell *cell = [atableView dequeueReusableCellWithIdentifier:extentIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:extentIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:UIColorFromRGB(0xf5f5f5)];
        [button setTitleColor:UIColorFromRGB(0x45c01a) forState:UIControlStateNormal];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 2.0f;
        button.layer.borderColor = UIColorFromRGB(0x45c01a).CGColor;
        button.layer.borderWidth = 1.0f;
        button.frame = CGRectMake(200, 15, 108, 29);
        button.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        if(indexPath.section == 0) {
            
            [button setTitle:@"查看更多评价" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(pushIntoMoreArgument:) forControlEvents:UIControlEventTouchDown];
        }else{
            [button setTitle:@"查看更多活动" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(pushIntoMoreActivity:) forControlEvents:UIControlEventTouchDown];
        }
        [cell.contentView addSubview:button];
        return cell;
    }else if(indexPath.section == 0){
        
        
        static NSString *PharmacyCommentIdentifier = @"ConsultPharmacyIdentifier";
        PharmacyCommentTableViewCell *cell = (PharmacyCommentTableViewCell *)[atableView dequeueReusableCellWithIdentifier:PharmacyCommentIdentifier];
        
        if(cell == nil){
            UINib *nib = [UINib nibWithNibName:@"PharmacyCommentTableViewCell" bundle:nil];
            [atableView registerNib:nib forCellReuseIdentifier:PharmacyCommentIdentifier];
            cell = (PharmacyCommentTableViewCell *)[atableView dequeueReusableCellWithIdentifier:PharmacyCommentIdentifier];
            
            UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 74.5, APP_W, 0.5)];
            [separator setBackgroundColor:UIColorFromRGB(0xdbdbdb)];
            [cell addSubview:separator];
        }
        cell.userName.hidden = NO;
        cell.lblNoComment.hidden = YES;
        if (self.arguementList.count == 0 || [self.infoDict[@"active"] intValue] == 0) {
            
            cell.lblNoComment.font = Font(14.0f);
            cell.lblNoComment.text = @"暂无评价";
            cell.lblNoComment.textColor = UIColorFromRGB(0x333333);
            cell.lblNoComment.hidden = NO;
            cell.userName.hidden = YES;
            cell.ratingView.hidden = YES;
            
        }else{
            cell.ratingView.hidden = NO;
            NSDictionary *dict = self.arguementList[indexPath.row];
            float star = [dict[@"star"] floatValue];
            [cell.ratingView displayRating:star / 2];
            cell.ratingView.frame = CGRectMake(cell.ratingView.frame.origin.x, 15, cell.ratingView.frame.size.width, cell.ratingView.frame.size.height);
            NSString *strUserName = @"";
            if ([dict[@"sysNickname"] length] > 0) {
                strUserName = dict[@"sysNickname"];
            } else if ([dict[@"nickname"] length] > 0) {
                strUserName = dict[@"nickname"];
            } else {
                strUserName = dict[@"mobile"];
            }
            cell.userName.text = strUserName;
            cell.commentContent.text = dict[@"remark"];
        }
        
        return cell;
    }else
    {
        static NSString *PharmacyActivityIdentifier = @"PharmacyActivityIdentifier";
        UITableViewCell *cell = [atableView dequeueReusableCellWithIdentifier:PharmacyActivityIdentifier];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PharmacyActivityIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(10, 43, 320, 0.5)];
            [separator setBackgroundColor:UIColorFromRGB(0xdbdbdb)];
            [cell.contentView addSubview:separator];
        }
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        if (self.activityList.count == 0 || [self.infoDict[@"active"] intValue] == 0) {
            cell.textLabel.font = Font(14.0f);
            cell.textLabel.text = @"暂无活动，尽请期待!";
            cell.textLabel.textColor = UIColorFromRGB(0x333333);
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = Font(13);
        }else{
            NSDictionary *dict = self.activityList[indexPath.row];
            cell.textLabel.textColor = UIColorFromRGB(0x333333);
            cell.textLabel.font = [UIFont systemFontOfSize:13.0];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = dict[@"title"];
        }
        return cell;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if(indexPath.section == 0)
        return nil;
    else
        return indexPath;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 2){
        
        DrugDetailViewController * drugDetail = [[DrugDetailViewController alloc] init];
        drugDetail.proId = m_sellList[indexPath.row][@"proId"];
        [self.navigationController pushViewController:drugDetail animated:YES];
        return;
    }
    
    UITableViewCell *cell = [atableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
        if (self.activityList.count == 0) {
            return;
        }else
            [atableView deselectRowAtIndexPath:indexPath animated:YES];
    //附近药店详情页点击进入
    
        MarketDetailViewController *marketDetailViewController = nil;
        
        if(HIGH_RESOLUTION) {
            marketDetailViewController = [[MarketDetailViewController alloc] initWithNibName:@"MarketDetailViewController" bundle:nil];
        }else{
            marketDetailViewController = [[MarketDetailViewController alloc] initWithNibName:@"MarketDetailViewController-480" bundle:nil];
        }
        NSDictionary *dict = self.activityList[indexPath.row];
        NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
        infoDict[@"activityId"] = dict[@"activityId"];
        if(dict[@"groupId"])
        {
            infoDict[@"groupId"] = dict[@"groupId"];
        }else{
            infoDict[@"groupId"] = self.infoDict[@"id"];
        }
        marketDetailViewController.infoDict = infoDict;
        marketDetailViewController.userType = 1;
        [self.navigationController pushViewController:marketDetailViewController animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnPressed_PhoneNum:(id)sender {
    

    if([self.contactPhone.text isEqualToString:@"暂无电话信息"] || [self.contactPhone.text isEqualToString:@""]){
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:self.infoDict[@"tel"] message: nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"呼叫", nil];
    [alert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 1){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.infoDict[@"tel"]]]];
    }
}

- (void)footerRereshing{
    
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"groupId"] = self.infoDict[@"id"];
    setting[@"currPage"] = @(currentPage);
    setting[@"pageSize"] = @(PAGE_ROW_NUM);
    
    [[HTTPRequestManager sharedInstance]fetchSellWellProducts:setting completionSuc:^(id resultObj){
        if ([((NSString *)resultObj[@"result"]) isEqualToString:@"OK"]) {
            [m_sellList addObjectsFromArray:resultObj[@"body"][@"data"]];
            if(m_sellList.count <= 2){
                lastFootView.hidden = YES;
            }
            else{
                lastFootView.hidden = NO;
            }
            if(m_sellList.count == 0){
                
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, 50)];
                label.text = @"暂无畅销商品";
                label.textColor= UIColorFromRGB(0x333333);
                label.font = Font(15.0f);
                label.textAlignment = NSTextAlignmentCenter;
                self.tableView.tableFooterView = label;
            }
            
            [self.tableView reloadData];
            [self.tableView footerEndRefreshing];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        [self.tableView footerEndRefreshing];
    }];
}


@end
