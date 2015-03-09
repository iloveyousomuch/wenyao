//
//  DrugDetailViewController.m
//  wenyao
//
//  Created by Meng on 14-9-28.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "DrugDetailViewController.h"
#import "ASIHTTPRequest.h"
#import "HTTPRequestManager.h"
#import "ASINetworkQueue.h"
#import "SBJson.h"
#import "ZhPMethod.h"
#import "KnowLedgeViewController.h"
#import "SVProgressHUD.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "DrugDetailViewController.h"
#import "UIViewController+isNetwork.h"
#import "CouponGenerateViewController.h"
#import "MyViewController.h"
#import "CouponDeatilViewController.h"
#import "ReturnIndexView.h"

#define F_TITLE  16
#define F_DESC   14
#define F_TOPTITLE  18
#define FPANEL_H        40
#define CARD_BTN_H      36

#define TAG_FONT_PANEL  1556
#define TAG_FONT_P_BG   1557
#define TAG_FAV_PAN     1558
#define TAG_FAV_BTN     1559
#define TAG_FAV_IMG     1560

#define EDGE        10


@interface DrugDetailViewController ()<ReturnIndexViewDelegate>
{
    UIFont * titleFont;
    UIFont * contentFont;
    UIFont * topTitleFont;
    TopView * topView;
    UIView *footView;
    UIImageView * buttonImage;
    
    NSInteger m_descFont;
    NSInteger m_titleFont;
    NSInteger m_topTitleFont;
    UIFont          *defaultFont;
    BOOL isUp;
    int startTime;
}
@property (strong, nonatomic) ReturnIndexView *indexView;
@property (strong, nonatomic) NSString *collectButtonImageName;
@property (nonatomic ,strong) NSMutableArray * dataSource;
@property (nonatomic ,strong) NSString * sid;//收藏时传入得id
@property(nonatomic,strong)NSString *medicineName;
@property(nonatomic,strong)NSString *medicineKnowledge;

//收藏按钮
@property (strong, nonatomic) UIButton *collectButton;
@end

@implementation DrugDetailViewController

- (id)init{
    
    if (self = [super init]) {
        
    }
    return self;
}

- (void)subViewDidLoad{
    
    
    topView = [[TopView alloc] init];
    isUp = YES;
    m_descFont = F_DESC;
    m_titleFont = F_TITLE;
    m_topTitleFont = F_TOPTITLE;
    defaultFont = [UIFont systemFontOfSize:12.0f];
    
    self.dataSource = [NSMutableArray array];
    self.tableView.backgroundColor = UIColorFromRGB(0xf2f2f2);
    
    self.tableView.tableHeaderView = topView;
    
    
    footView = [[UIView alloc]initWithFrame:CGRectMake(0, APP_H -NAV_H, SCREEN_W, 40)];
    UIButton *pushBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 5, SCREEN_W - 20, 30)];
    [pushBtn setTitle:@"立即享受优惠" forState:UIControlStateNormal];
    [pushBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [pushBtn setBackgroundColor:UIColorFromRGB(0xFF8A00)];
    pushBtn.layer.masksToBounds = YES;
    pushBtn.layer.cornerRadius = 2.0f;
    [pushBtn addTarget:self action:@selector(pushToGenerateView:) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:pushBtn];
    [self.view addSubview:footView];
    
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_btn_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(popPage:)];
    
    [self.navigationItem setLeftBarButtonItem:leftButton];
    
    titleFont = [UIFont boldSystemFontOfSize:m_titleFont];
    topTitleFont = [UIFont boldSystemFontOfSize:m_topTitleFont];
    contentFont = [UIFont systemFontOfSize:m_descFont];
    
    topView.titleFont = [UIFont boldSystemFontOfSize:m_titleFont];
    topView.topTitleFont = [UIFont boldSystemFontOfSize:m_topTitleFont];
    topView.contentFont = [UIFont systemFontOfSize:m_descFont];
    
    //[self setRightBarButton];
#pragma ---index---
    [self setRightItems];
    [self ifHasCoupon];
    
    self.tableView.backgroundColor = UIColorFromRGB(0xecf0f1);
    topView.facComeFrom = self.facComeFrom;
}

- (void)popPage:(id)sender{
    

    for (UIViewController *temp in self.navigationController.viewControllers) {
            
        if ([temp isKindOfClass:[CouponDeatilViewController class]]) {
            [self.navigationController popToViewController:temp animated:YES];
            return;
        }
    }


        
    [self.navigationController popViewControllerAnimated:YES];
   
}

- (void)ifHasCoupon{
    

    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    if(app.logStatus){
        setting[@"token"] = app.configureList[APP_USER_TOKEN];
    }
    setting[@"proId"] = self.proId;
    [[HTTPRequestManager sharedInstance]couponScan:setting completionSuc:^(id resultObj){
        if([resultObj[@"result"] isKindOfClass:[NSString class]] && [resultObj[@"result"] isEqualToString:@"OK"]){
        //                body不会为空，首先判断status
        int status = [resultObj[@"body"][@"status"] intValue];
        
        if(resultObj[@"body"] && status == 0){
            
            footView.hidden = NO;
            footView.frame = CGRectMake(0, APP_H -NAV_H - 40, SCREEN_W, 40);
            [self.tableView setFrame:CGRectMake(0, 0, APP_W, APP_H -NAV_H - 40)];
        }
        else{
            footView.hidden = YES;
            footView.frame = CGRectMake(0, APP_H -NAV_H , SCREEN_W, 40);
            [self.tableView setFrame:CGRectMake(0, 0, APP_W, APP_H -NAV_H )];
        }
        [self obtainDataSource];
        }
        else{
            footView.hidden = YES;
            footView.frame = CGRectMake(0, APP_H -NAV_H , SCREEN_W, 40);
            [self.tableView setFrame:CGRectMake(0, 0, APP_W, APP_H -NAV_H )];
            [self obtainDataSource];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        footView.hidden = YES;
        [self.tableView setFrame:CGRectMake(0, 0, APP_W, APP_H -NAV_H )];
        [self obtainDataSource];
        return;
    }];
}

- (void)pushToGenerateView:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    
    btn.userInteractionEnabled = NO;
   
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    if(app.logStatus){
        setting[@"token"] = app.configureList[APP_USER_TOKEN];
    }
    setting[@"proId"] = self.proId;;
    [[HTTPRequestManager sharedInstance]couponScan:setting completionSuc:^(id resultObj){
        //                body不会为空，首先判断status
        if(resultObj[@"body"] && resultObj[@"body"][@"status"]){
            
            CouponGenerateViewController *generateView = [[CouponGenerateViewController alloc]initWithNibName:@"CouponGenerateViewController" bundle:nil];
            generateView.useType = 3;
            //传值：优惠活动详情
            generateView.infoDic = resultObj[@"body"];
            //传值：商品编码
            generateView.proId = self.proId;;
            [self.navigationController pushViewController:generateView animated:YES];
            btn.userInteractionEnabled = YES;
        }
        else{
            btn.userInteractionEnabled = YES;
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        [SVProgressHUD showErrorWithStatus:@"加载失败!" duration:0.8f];
        btn.userInteractionEnabled = YES;
        return;
    }];

}

- (void)BtnClick{
    
    if(![self isNetWorking]){
        for(UIView *v in [self.view subviews]){
            if(v.tag == 999){
                [v removeFromSuperview];
            }
        }
        [self subViewDidLoad];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"详情";
    if([self isNetWorking]){
        [self addNetView];
        return;
    }
    if(startTime == 0){
        [self subViewDidLoad];
    }
    startTime ++;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    startTime = 0;
}


- (void)setRightItems{
    
    UIView *ypDetailBarItems=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 120, 55)];
    
    CGSize size = [@"Aa" sizeWithFont:[UIFont systemFontOfSize:19.0f]];
    UIButton * zoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [zoomButton setFrame:CGRectMake(28, 0, 55,55)];
    [zoomButton addTarget:self action:@selector(zoomButtonClick) forControlEvents:UIControlEventTouchUpInside];
    zoomButton.titleLabel.font = [UIFont systemFontOfSize:19.0f];
    zoomButton.titleLabel.textColor = [UIColor whiteColor];
    [zoomButton setTitle:@"Aa" forState:UIControlStateNormal];
    [ypDetailBarItems addSubview:zoomButton];
    
    UIButton *indexButton=[[UIButton alloc]initWithFrame:CGRectMake(65, 0, 55, 55)];
    [indexButton setImage:[UIImage imageNamed:@"icon-unfold.PNG"] forState:UIControlStateNormal];
    [indexButton addTarget:self action:@selector(returnIndex) forControlEvents:UIControlEventTouchDown];
    [ypDetailBarItems addSubview:indexButton];
    
    UIBarButtonItem *fix=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fix.width=-20;
    self.navigationItem.rightBarButtonItems=@[fix,[[UIBarButtonItem alloc]initWithCustomView:ypDetailBarItems]];
    
    
}








- (void)setRightBarButton{
    
    UIImage * collectImage = [UIImage imageNamed:@"右上角更多.png"];
    CGSize size = [@"Aa" sizeWithFont:[UIFont systemFontOfSize:19.0f]];
    UIButton * zoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [zoomButton setFrame:CGRectMake(10, -5, size.width+20, collectImage.size.height+10)];
    [zoomButton addTarget:self action:@selector(zoomButtonClick) forControlEvents:UIControlEventTouchUpInside];
    zoomButton.titleLabel.font = [UIFont systemFontOfSize:19.0f];
    zoomButton.titleLabel.textColor = [UIColor whiteColor];
    [zoomButton setTitle:@"Aa" forState:UIControlStateNormal];
    
    self.collectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.collectButton setFrame:CGRectMake(zoomButton.frame.origin.x + zoomButton.frame.size.width-8, 0, collectImage.size.width, collectImage.size.height)];
    [self.collectButton addTarget:self action:@selector(returnIndex) forControlEvents:UIControlEventTouchUpInside];
    [self.collectButton setBackgroundImage:collectImage forState:UIControlStateNormal];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] init];
    buttonImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, -1, collectImage.size.width, collectImage.size.height)];
    [buttonImage addGestureRecognizer:tap];
    [tap addTarget:self action:@selector(returnIndex)];
    buttonImage.image = collectImage;
    buttonImage.userInteractionEnabled = YES;
    //[self.collectButton addSubview:buttonImage];
    self.collectButton.enabled = NO;
    
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.collectButton.frame.origin.x + self.collectButton.frame.size.width, collectImage.size.height)];
    
    bgView.userInteractionEnabled = YES;
    [bgView addSubview:zoomButton];
    [bgView addSubview:self.collectButton];
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -12;
    self.navigationItem.rightBarButtonItems = @[fixed,[[UIBarButtonItem alloc] initWithCustomView:bgView]];
}

#pragma mark---------------------------------------------跳转到首页-----------------------------------------------

//- (void)setUpRightItem
//{
//    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    fixed.width = -12;
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"右上角更多.png"] style:UIBarButtonItemStylePlain target:self action:@selector(returnIndex)];
//    self.navigationItem.rightBarButtonItems = @[fixed,rightItem];
//}
- (void)returnIndex
{
    self.indexView = [ReturnIndexView sharedManagerWithImage:@[@"icon home.PNG",self.collectButtonImageName] title:@[@"首页",@"收藏"]];
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
        [self collectButtonClick];
    }
    
}
- (void)delayPopToHome
{
    [app.tabBarController setSelectedIndex:0];
}
#pragma mark---------------------------------------------跳转到首页-----------------------------------------------

- (void)zoomButtonClick{
    if (m_descFont == 20) {
        isUp = NO;
    }else if(m_descFont == 14){
        isUp = YES;
    }
    
    if (isUp) {
        m_descFont+=3;
        m_titleFont+=3;
        m_topTitleFont+=3;
    }else{
        m_descFont = 14;
        m_titleFont = 16;
        m_topTitleFont = 18;
    }
    topView.titleFont = [UIFont boldSystemFontOfSize:m_titleFont];
    topView.topTitleFont = [UIFont boldSystemFontOfSize:m_topTitleFont];
    topView.contentFont = [UIFont systemFontOfSize:m_descFont];
    
    titleFont = [UIFont boldSystemFontOfSize:m_titleFont];
    topTitleFont = [UIFont boldSystemFontOfSize:m_topTitleFont];
    contentFont = [UIFont systemFontOfSize:m_descFont];
    
    self.tableView.tableHeaderView = topView;
    
  
    
    
    
    [self.tableView reloadData];
}


- (void)collectButtonClick{
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
    setting[@"objId"] = self.sid;
    setting[@"objType"] = @1;
    setting[@"method"] = @"1";
    
    [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            if ([resultObj[@"body"][@"result"] isEqualToString:@"1"])//已收藏
            {
                //若已收藏,则取消收藏
                setting[@"method"] = @"3";
                [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
                    if ([resultObj[@"body"][@"result"] isEqualToString:@"3"]) {
                        [SVProgressHUD showSuccessWithStatus:@"取消收藏成功" duration:DURATION_SHORT];
                        buttonImage.image = [UIImage imageNamed:@"导航栏_收藏icon.png"];
                        self.collectButtonImageName = @"导航栏_收藏icon.png";
                    }
                } failure:^(NSError *error) {
                    NSLog(@"%@",error);
                }];
            }else if([resultObj[@"body"][@"result"] isEqualToString:@"0"])//未收藏
            {
                //若未收藏,则添加收藏
                setting[@"method"] = @"2";
                [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
                    if ([resultObj[@"body"][@"result"] isEqualToString:@"2"]) {
                        [SVProgressHUD showSuccessWithStatus:@"添加收藏成功" duration:DURATION_SHORT];
                        buttonImage.image = [UIImage imageNamed:@"导航栏_已收藏icon.png"];
                        self.collectButtonImageName = @"导航栏_已收藏icon.png";
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

// opType: 1 查询; 2 写入; 3 取消;
- (void)checkIsCollectOrNot
{
    if (app.logStatus) {
        //buttonImage.image = [UIImage imageNamed:@"导航栏_已收藏icon.png"];
        NSMutableDictionary * setting = [NSMutableDictionary dictionary];
        setting[@"token"] = app.configureList[APP_USER_TOKEN];
        setting[@"objId"] = self.sid;
        setting[@"objType"] = @"1";
        setting[@"method"] = @"1";
        [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"])
            {
                if ([resultObj[@"body"][@"result"] isEqualToString:@"1"])
                {
                    buttonImage.image = [UIImage imageNamed:@"导航栏_已收藏icon.png"];
                    self.collectButtonImageName = @"导航栏_已收藏icon.png";
                }else if([resultObj[@"body"][@"result"] isEqualToString:@"0"])
                {
                    buttonImage.image = [UIImage imageNamed:@"导航栏_收藏icon.png"];
                    self.collectButtonImageName = @"导航栏_收藏icon.png";
                }
            }else if ([resultObj[@"result"] isEqualToString:@"FAIL"])
            {
                if ([resultObj[@"msg"] isEqualToString:@"1"])
                {
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
    }else{
        buttonImage.image = [UIImage imageNamed:@"导航栏_收藏icon.png"];
        self.collectButtonImageName = @"导航栏_收藏icon.png";
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 999) {
        if (buttonIndex == 1) {
            LoginViewController * login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            login.isPresentType = YES;
            login.parentNavgationController = self.navigationController;
            UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:login];
            [self presentViewController:nav animated:YES completion:nil];
        }
    }
}


#pragma mark ------网络数据请求及解析------
- (void)obtainDataSource
{
    //初始化队列
    ASINetworkQueue *requestQueue = [[ASINetworkQueue alloc] init];
    [requestQueue setShouldCancelAllRequestsOnFailure:YES];
    [requestQueue setDelegate:self];
    [requestQueue setQueueDidFinishSelector:@selector(queueFinished:)];
    
    //初始化摘要HTTP
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:QueryProductDetail]];
    request.tag = 0;
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestFinished:)];
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"productId"] = self.proId;
    setting = [[[HTTPRequestManager sharedInstance] secretBuild:setting] mutableCopy];
    
    [request appendPostData:[NSJSONSerialization dataWithJSONObject:setting options:0 error:nil]];
    [requestQueue addOperation:request];
    [requestQueue go];
}
- (void)requestFinished:(ASIHTTPRequest *)request{
    
    self.collectButton.enabled = YES;
    NSDictionary *dict = [[request responseString] JSONValue];
    [self fillupBaseInfo:dict];
    
    NSLog(@"药品详情 = %@",dict);
    self.sid = dict[@"body"][@"headerInfo"][@"sid"];
    NSLog(@"药品详情%@",self.sid);
    self.medicineName = dict[@"body"][@"headerInfo"][@"shortName"];
    self.medicineKnowledge = dict[@"body"][@"knowledgeTitle"];
    [self checkIsCollectOrNot];
}


- (void)fillupBaseInfo:(NSDictionary *)baseInfo{
    [self.dataSource removeAllObjects];
    topView.dataDictionary = baseInfo[@"body"][@"headerInfo"];
    self.tableView.tableHeaderView = topView;
    for (NSMutableDictionary * dic in baseInfo[@"body"][@"baseInfo"]) {
        NSString * t = dic[@"title"];
        NSString * c = dic[@"content"];
        if (t.length > 0 && ([c isEqualToString:@""]||c.length == 0)) {
            dic[@"content"] = @"尚不";
        }
        
        if (![dic[@"content"] isEqualToString:@"尚不"])
        {
            [self.dataSource addObject:dic];
        }
        
        if (self.dataSource.count == 0) {
            self.tableView.hidden = YES;
        }
    
    }
    NSString *title = baseInfo[@"body"][@"knowledgeTitle"];
    NSString *content = baseInfo[@"body"][@"knowledgeContent"];
    if (title.length > 0) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setValue:@"用药小知识" forKey:@"title"];
        [dic setValue:title forKey:@"knowledgeTitle"];
        [dic setValue:content forKey:@"content"];
        [self.dataSource addObject:dic];
    }
    
    [self.tableView reloadData];
}

- (void)queueFinished:(ASINetworkQueue *)queue
{

}

//特殊字符的替换
- (NSString *)replaceSpecialStringWith:(NSString *)string{
    string = [string stringByReplacingOccurrencesOfString:@"    &nbsp;&nbsp;&nbsp;&nbsp;" withString:@"    "];
    string = [string stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@"<p/>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt:" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt:" withString:@">"];
    return string;
}
#pragma mark ------UITableViewDelegate------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.dataSource.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    [view setBackgroundColor:[UIColor clearColor]];
//    view.layer.borderWidth = 0.5;
//    view.layer.borderColor = UIColorFromRGB(0xdbdbdb).CGColor;
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary * dic = self.dataSource[indexPath.section];
    if (indexPath.row == 0) {
        return getTextSize([self replaceSpecialStringWith:dic[@"title"]], titleFont, APP_W-20).height + 20;
    }
   
    if (indexPath.row == 1) {
        if ([dic[@"title"] isEqualToString:@"用药小知识"]) {
            return getTextSize([self replaceSpecialStringWith:dic[@"title"]], titleFont, APP_W-20).height + 20;
        }
        return getTextSize([self replaceSpecialStringWith:dic[@"content"]], contentFont, APP_W -20).height + 20;
    }
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * cellIdentifier = @"cellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    [[cell viewWithTag:1008] removeFromSuperview];
    [[cell viewWithTag:1009] removeFromSuperview];
    if(indexPath.row == 0) {
        cell.textLabel.font = titleFont;
        UIView *topSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 0.5)];
        [topSeparatorView setBackgroundColor:UIColorFromRGB(0xdbdbdb)];
        topSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        topSeparatorView.tag = 1009;
        [cell addSubview:topSeparatorView];
    }else{
        cell.textLabel.font = contentFont;
        UIView *bottomSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, MAX(cell.frame.size.height - 0.5,0), APP_W, 0.5)];
        [bottomSeparatorView setBackgroundColor:UIColorFromRGB(0xdbdbdb)];
        bottomSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        bottomSeparatorView.tag = 1008;
        [cell addSubview:bottomSeparatorView];
    }
    
    NSDictionary * dic = self.dataSource[indexPath.section];
    
   
    cell.textLabel.text = dic[@"title"];
    
     if(indexPath.row == 1) {
        if ([dic[@"title"] isEqualToString:@"用药小知识"]) {
            cell.textLabel.text = [self replaceSpecialStringWith:self.medicineKnowledge];
            cell.textLabel.font = Font(contentFont.pointSize);
            cell.textLabel.textColor = UIColorFromRGB(0x333333);
            cell.textLabel.numberOfLines = 1;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            cell.textLabel.font = contentFont;
        }else{
            //cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.textColor = UIColorFromRGB(0x333333);
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.text = [self replaceSpecialStringWith:dic[@"content"]];
        }
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary * dic = self.dataSource[indexPath.section];
    if ([dic[@"title"] isEqualToString:@"用药小知识"]) {
        if (indexPath.row == 1) {
//            KnowLedgeViewController * knowLedge = [[KnowLedgeViewController alloc] init];
//            knowLedge.knowledgeTitle = dic[@"knowledgeTitle"];
//            knowLedge.knowledgeContent = dic[@"content"];
//            [self.navigationController pushViewController:knowLedge animated:YES];
            
            MyViewController * knowLedge = [[MyViewController alloc] init];
            knowLedge.knowledgeTitle = dic[@"knowledgeTitle"];
            knowLedge.knowledgeContent = dic[@"content"];
            [self.navigationController pushViewController:knowLedge animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end



@implementation TopView
{
    CGFloat h;
    UIView *warning;
}
- (id)init{
    if (self = [super init]) {
        [self initLabel];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)initLabel
{
    self.titleLabel = [[UILabel alloc] init];
    self.specLabel = [[UILabel alloc]init];
    self.factoryLabel = [[UILabel alloc]init];
    
    self.firstLabel = [[UILabel alloc] init];
    self.secondLabel = [[UILabel alloc] init];
    self.firstImageView = [[UIImageView alloc] init];
    self.secondImageView = [[UIImageView alloc] init];
}

- (void)setDataDictionary:(NSDictionary *)dataDictionary{
    _dataDictionary = dataDictionary;
    [self setUpView];
}

//特殊字符的替换
- (NSString *)replaceSpecialStringWith:(NSString *)string
{
    if(!string || [string isEqualToString:@""] || [string isEqual:[NSNull null]]){
        return @"";
    }
    string = [string stringByReplacingOccurrencesOfString:@"    &nbsp;&nbsp;&nbsp;&nbsp;" withString:@"    "];
    string = [string stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@"<p/>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt:" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt:" withString:@">"];
    return string;
}

- (void)setContentFont:(UIFont *)contentFont{
    _contentFont = contentFont;
    [self setUpView];
}

- (void)setUpView{
    /*
     headerInfo =         {
     factory = "广州奇星药业有限公司";
     factoryAuth = 0;
     registerNo = "国药准字Z44022417";
     shortName = "奇星,新雪颗粒";
     sid = 5da18eb453ab3c869ab4011cac2b88fe;
     signCode = 1b;
     spec = "1.53g*6";
     type = "处方药中成药";
     unit = "盒";
     };
     */
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIView *topSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 0.5)];
    [topSeparatorView setBackgroundColor:UIColorFromRGB(0xdbdbdb)];
    topSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    topSeparatorView.tag = 1009;
    [self addSubview:topSeparatorView];
    
    UIView *bottomSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0, MAX(self.frame.size.height - 0.5, 0), APP_W, 0.5)];
    [bottomSeparatorView setBackgroundColor:UIColorFromRGB(0xdbdbdb)];
    bottomSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    bottomSeparatorView.tag = 1008;
    [self addSubview:bottomSeparatorView];
    
    NSString * str = [self replaceSpecialStringWith:self.dataDictionary[@"shortName"]];
    
    
     [self.titleLabel setFrame:CGRectMake(10, 10, APP_W-20, getTextSize(str, self.topTitleFont, APP_W-20).height)];
    self.titleLabel.text = str;
    self.titleLabel.font = self.topTitleFont;//[UIFont boldSystemFontOfSize:18.0f];
    self.titleLabel.textColor = UIColorFromRGB(0x333333);
    [self addSubview:self.titleLabel];
    
    NSString *signcode = self.dataDictionary[@"signCode"];
    UIImage * firstImage = [[UIImage alloc] init];
    NSString * firstString = nil;
    NSString *recipeString = nil;
    
     if([signcode isEqualToString:@"1a"])
     {
         firstImage = [UIImage imageNamed:@"处方药.png"];
         firstString = @"处方药";
         recipeString = @"西药";
     }else if([signcode isEqualToString:@"1b"]){
         firstImage = [UIImage imageNamed:@"处方药.png"];
         firstString = @"处方药";
         recipeString = @"中成药";
     }else if([signcode isEqualToString:@"2a"]){
         firstImage = [UIImage imageNamed:@"otc-甲类.png"];
         firstString = @"甲类OTC非处方药";
         recipeString = @"西药";
     }else if([signcode isEqualToString:@"2b"]){
         firstImage = [UIImage imageNamed:@"otc-甲类.png"];
         firstString = @"甲类OTC非处方药";
         recipeString = @"中成药";
     }
     else if ([signcode isEqualToString:@"3a"]){
         firstImage = [UIImage imageNamed:@"otc-乙类.png"];
         firstString = @"乙类OTC非处方药";
         recipeString = @"西药";
     }else if([signcode isEqualToString:@"3b"]) {
         firstImage = [UIImage imageNamed:@"otc-乙类.png"];
         firstString = @"乙类OTC非处方药";
         recipeString = @"中成药";
     }else if([signcode isEqualToString:@"4c"]) {
         firstImage = nil;
         firstString = @"定型包装中药饮片";
     }else if([signcode isEqualToString:@"4d"]) {
         firstImage = nil;
         firstString = @"散装中药饮片";
     }else if([signcode isEqualToString:@"5"]) {
         firstImage = nil;
         firstString = @"保健食品";
     }else if([signcode isEqualToString:@"6"]) {
         firstImage = nil;
         firstString = @"食品";
     }else if([signcode isEqualToString:@"7"]) {
         firstImage = nil;
         firstString = @"机械号一类";
     }else if([signcode isEqualToString:@"8"]) {
         firstImage = nil;
         firstString = @"机械号二类";
     }else if([signcode isEqualToString:@"10"]) {
         firstImage = nil;
         firstString = @"消字号";
     }else if([signcode isEqualToString:@"11"]) {
         firstImage = nil;
         firstString = @"妆字号";
     }else if([signcode isEqualToString:@"12"]) {
         firstImage = nil;
         firstString = @"无批准号";
     }else if([signcode isEqualToString:@"13"]) {
         firstImage = nil;
         firstString = @"其他";
     }else if([signcode isEqualToString:@"9"]) {
         firstImage = nil;
         firstString = @"械字号三类";
     }
    
    //药品标签
    float logo_Y = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 8;
    //第一个view
    
    [self.firstImageView setFrame:CGRectMake(10, logo_Y, 25, 14)];
    self.firstImageView.image = firstImage;
    if(firstImage) {
        [self addSubview:self.firstImageView];
    }
    CGSize firstSize = getTextSize(firstString, self.contentFont, 200);
    
    //第一个label
    float first_label_X = 0;
    if(firstImage) {
        first_label_X = self.firstImageView.frame.origin.x + self.firstImageView.frame.size.width + 5;
    }else{
        first_label_X = 10;
    }
    [self.firstLabel setFrame:CGRectMake(first_label_X, logo_Y, firstSize.width + 30, firstSize.height)];
    self.firstLabel.text = firstString;
    self.firstLabel.font = self.contentFont;
//    self.firstLabel.font = Font(14);
    self.firstLabel.textColor = UIColorFromRGB(0x666666);
    [self addSubview:self.firstLabel];
    if(recipeString)
    {
        self.recipeImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.firstLabel.frame.origin.x + self.firstLabel.frame.size.width + 8, self.firstLabel.frame.origin.y + self.firstLabel.frame.size.height / 2 - 7.5, 20, 14)];
        if([recipeString isEqualToString:@"西药"]) {
            self.recipeImage.image = [UIImage imageNamed:@"西药.png"];
        }else{
            self.recipeImage.image = [UIImage imageNamed:@"中成药-1.png"];
        }
        [self addSubview:self.recipeImage];
        
        self.recipeLabel = [[UILabel alloc] initWithFrame:RECT(self.recipeImage.frame.origin.x + self.recipeImage.frame.size.width + 8, 35 , 100, 21)];
        [self.recipeLabel setFrame:CGRectMake(self.recipeImage.frame.origin.x + self.recipeImage.frame.size.width + 8, logo_Y - 2.5, APP_W-20,getTextSize(recipeString, self.titleFont, APP_W-20).height)];
        self.recipeLabel.textColor = UIColorFromRGB(0x666666);
        self.recipeLabel.font = self.contentFont;
        self.recipeLabel.text = recipeString;
        [self addSubview:self.recipeLabel];
    }
    
    str = [self replaceSpecialStringWith:self.dataDictionary[@"spec"]];
    [self.specLabel setFrame:CGRectMake(10, self.firstImageView.frame.origin.y + self.firstImageView.frame.size.height + 8, APP_W-20,getTextSize(str, self.titleFont, APP_W-20).height)];
    self.specLabel.text = [NSString stringWithFormat:@"%@",str];
    self.specLabel.textColor = UIColorFromRGB(0x666666);
    self.specLabel.font = self.contentFont;
    [self addSubview:self.specLabel];
    
    
    str = [self replaceSpecialStringWith:self.dataDictionary[@"factory"]];
    [self.factoryLabel setFrame:CGRectMake(10, self.specLabel.frame.origin.y + self.specLabel.frame.size.height + 8, APP_W-20,getTextSize(str, self.titleFont, APP_W-20).height)];
    self.factoryLabel.text = str;
    self.factoryLabel.font = self.contentFont;
    self.factoryLabel.textColor = UIColorFromRGB(0x666666);
    [self addSubview:self.factoryLabel];
    
//    if([self.facComeFrom isEqualToString:@"1"]){
//        UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"认证V@2x.png"]];
//        imageView.frame = CGRectMake(10 + self.factoryLabel.text.length *self.contentFont.pointSize + 5, self.specLabel.frame.origin.y + self.specLabel.frame.size.height + 8, getTextSize(str, self.titleFont, APP_W-20).height, getTextSize(str, self.titleFont, APP_W-20).height);
//        [self addSubview:imageView];
//    }
    
    self.ephedrineLabel = [[UILabel alloc] init];
    [self.ephedrineLabel setFrame:CGRectMake(30, 8, (self.contentFont.pointSize - 1.5) * 16,self.contentFont.pointSize - 1.5)];
    self.ephedrineLabel.numberOfLines = 0;
    self.ephedrineLabel.textColor = UIColorFromRGB(0x666666);
    self.ephedrineLabel.backgroundColor = UIColorFromRGB(0xecf0f1);
    self.ephedrineLabel.font = Font(self.contentFont.pointSize - 1.5);
    self.ephedrineLabel.text = @"本品含麻黄碱，请遵医嘱谨慎使用。";

    self.ephedrineImage = [[UIImageView alloc] initWithFrame:CGRectMake(9, 8 , 15, 15)];
    self.ephedrineImage.image = [UIImage imageNamed:@"麻黄碱提醒icon.png"];
    self.ephedrineImage.backgroundColor = UIColorFromRGB(0xecf0f1);

    warning = [[UIView alloc]initWithFrame:CGRectMake(10, self.factoryLabel.frame.size.height + self.factoryLabel.frame.origin.y + 5, 30 + self.ephedrineLabel.frame.size.width, self.contentFont.pointSize + 16)];
    warning.backgroundColor = UIColorFromRGB(0xecf0f1);
    [warning addSubview:self.ephedrineLabel];
    [warning addSubview:self.ephedrineImage];
    [self addSubview:warning];
    
    if([self.dataDictionary[@"isContainEphedrine"] integerValue] == 1){
        //含麻黄碱
        h = warning.frame.origin.y + warning.frame.size.height + 8;
        warning.hidden = NO;
  
    }else{
        h = warning.frame.origin.y + 8;
        warning.hidden = YES;
     
    }
    //h = self.ephedrineLabel.frame.origin.y + self.ephedrineLabel.frame.size.height + 8;

    self.frame = CGRectMake(0, 0, APP_W, h);
}



@end
