//
//  SymptomDetailViewController.m
//  quanzhi
//
//  Created by Meng on 14-8-6.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "SymptomDetailViewController.h"
#import "Constant.h"
#import "BaseInfromationViewController.h"
#import "PossibleDiseaseViewController.h"
#import "ZhPMethod.h"
#import "Categorys.h"
#import "AppDelegate.h"
#import "LogInViewController.h"
#import "HTTPRequestManager.h"
#import "SVProgressHUD.h"
#import "UIViewController+isNetwork.h"
#import "ReturnIndexView.h"

#define F_TITLE  14
#define F_DESC   12
#define TAG_TITLE       1552
#define TAG_TITLE_DES   1553
#define TAG_DESC        1554
#define TAG_ARROW       1555
#define TAG_FONT_PANEL  1556
#define TAG_FONT_P_BG   1557

#define TAG_FAV_PAN     1558
#define TAG_FAV_BTN     1559
#define TAG_FAV_IMG     1560

#define EDGE        10

@interface SymptomDetailViewController ()<UIAlertViewDelegate,ReturnIndexViewDelegate>
{
    BOOL m_collected;
    __weak BaseViewController  *currentViewController;
    UIImageView * buttonImage;
    
    NSInteger m_descFont;
    NSInteger m_titleFont;
    UIFont          *defaultFont;
    BOOL isUp;
}
@property (nonatomic ,strong)NSMutableArray * viewControllerArray;
@property (nonatomic ,strong) ReturnIndexView *indexView;
@property (nonatomic ,strong) NSString *collectButtonImageName;
@end

@implementation SymptomDetailViewController

- (id)init{
    if (self = [super init]) {
        //[self setRightBarButton];
        
        [self setRightItems];
        
        isUp = YES;
        m_descFont = F_DESC;
        m_titleFont = F_TITLE;
        m_collected = NO;
    }
    return self;
}



- (void)backToPreviousController:(id)sender
{

    if(self.containerViewController) {
        [self.containerViewController.navigationController popViewControllerAnimated:YES];
        
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    _slideSwitchView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([self isNetWorking]){
        [self addNetView];
        return;
    }
    [self subViewDidLoad];
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

- (void)subViewDidLoad{
    
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    m_collected = NO;
    self.viewControllerArray = [NSMutableArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpViewController];
    [self setupSilderView];
    
    for(UIViewController *controller in self.viewControllerArray) {
        [controller viewWillAppear:YES];
    }
    [self checkIsCollectOrNot];
}

//- (void)setRightBarButton{
//    UIImage * collectImage = [UIImage imageNamed:@"导航栏_收藏icon.png"];
//    
//    CGSize size = [@"Aa" sizeWithFont:[UIFont systemFontOfSize:19.0f]];
//    UIButton * zoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [zoomButton setFrame:CGRectMake(10, -5, size.width+20, collectImage.size.height+10)];
//    [zoomButton addTarget:self action:@selector(zoomButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    zoomButton.titleLabel.font = [UIFont systemFontOfSize:19.0f];
//    zoomButton.titleLabel.textColor = [UIColor whiteColor];
//    [zoomButton setTitle:@"Aa" forState:UIControlStateNormal];
//    
//    UIButton * collectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [collectButton setFrame:CGRectMake(zoomButton.frame.origin.x + zoomButton.frame.size.width, 0, collectImage.size.width+20, collectImage.size.height+10)];
//    [collectButton addTarget:self action:@selector(collectButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] init];
//    buttonImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, -1, collectImage.size.width, collectImage.size.height)];
//    [buttonImage addGestureRecognizer:tap];
//    [tap addTarget:self action:@selector(collectButtonClick)];
//    buttonImage.image = collectImage;
//    buttonImage.userInteractionEnabled = YES;
//    [collectButton addSubview:buttonImage];
//    
//    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, collectButton.frame.origin.x + collectButton.frame.size.width, collectImage.size.height)];
//    bgView.userInteractionEnabled = YES;
//    [bgView addSubview:zoomButton];
//    [bgView addSubview:collectButton];
//    
//    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    fixed.width = -20;
//    self.navigationItem.rightBarButtonItems = @[fixed,[[UIBarButtonItem alloc] initWithCustomView:bgView]];
//}

- (void)setRightBarButton{
    UIImage * collectImage = [UIImage imageNamed:@"右上角更多.png"];
    
    CGSize size = [@"Aa" sizeWithFont:[UIFont systemFontOfSize:19.0f]];
    UIButton * zoomButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [zoomButton setFrame:CGRectMake(10, -5, size.width+20, collectImage.size.height+10)];
    [zoomButton addTarget:self action:@selector(zoomButtonClick) forControlEvents:UIControlEventTouchUpInside];
    zoomButton.titleLabel.font = [UIFont systemFontOfSize:19.0f];
    zoomButton.titleLabel.textColor = [UIColor whiteColor];
    [zoomButton setTitle:@"Aa" forState:UIControlStateNormal];
    
    UIButton * collectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [collectButton setFrame:CGRectMake(zoomButton.frame.origin.x + zoomButton.frame.size.width-8, 0, collectImage.size.width, collectImage.size.height)];
    [collectButton addTarget:self action:@selector(returnIndex) forControlEvents:UIControlEventTouchUpInside];
    [collectButton setBackgroundImage:collectImage forState:UIControlStateNormal];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] init];
    buttonImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, -1, collectImage.size.width, collectImage.size.height)];
    [buttonImage addGestureRecognizer:tap];
    [tap addTarget:self action:@selector(returnIndex)];
    buttonImage.image = collectImage;
    self.collectButtonImageName = @"导航栏_收藏icon.png";
    buttonImage.userInteractionEnabled = YES;
    //[collectButton addSubview:buttonImage];
    
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, collectButton.frame.origin.x + collectButton.frame.size.width, collectImage.size.height)];
    bgView.userInteractionEnabled = YES;
    [bgView addSubview:zoomButton];
    [bgView addSubview:collectButton];
    
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




- (void)zoomButtonClick
{
    [currentViewController zoomClick];
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
    setting[@"objId"] = self.spmCode;
    setting[@"objType"] = @"6";
    setting[@"method"] = @"1";
    
    [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
        
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            if ([resultObj[@"body"][@"result"] isEqualToString:@"1"]) {//已收藏
                ///////////////////////////若已收藏,则取消收藏////////////////////////////
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
            }else if([resultObj[@"body"][@"result"] isEqualToString:@"0"]){//未收藏
                //////////////////////////若为收藏,则添加收藏/////////////////////////
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
// opType: 1 查询; 2 写入; 3 取消;
- (void)checkIsCollectOrNot
{
    if (app.logStatus) {
        //buttonImage.image = [UIImage imageNamed:@"导航栏_已收藏icon.png"];
        NSMutableDictionary * setting = [NSMutableDictionary dictionary];
        setting[@"token"] = app.configureList[APP_USER_TOKEN];
        setting[@"objId"] = self.spmCode;
        setting[@"objType"] = @"6";
        setting[@"method"] = @"1";
        [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
            
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                if ([resultObj[@"body"][@"result"] isEqualToString:@"1"]) {
                    buttonImage.image = [UIImage imageNamed:@"导航栏_已收藏icon.png"];
                    self.collectButtonImageName = @"导航栏_已收藏icon.png";
                }else if([resultObj[@"body"][@"result"] isEqualToString:@"0"]){
                    buttonImage.image = [UIImage imageNamed:@"导航栏_收藏icon.png"];
                    self.collectButtonImageName = @"导航栏_收藏icon.png";
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
    }else{
        buttonImage.image = [UIImage imageNamed:@"导航栏_收藏icon.png"];
        self.collectButtonImageName = @"导航栏_收藏icon.png";
    }
}


- (void)setUpViewController{
    BaseInfromationViewController * baseInformation = [[BaseInfromationViewController alloc]init];
    PossibleDiseaseViewController * possibleDisease = [[PossibleDiseaseViewController alloc]init];
    baseInformation.spmCode = self.spmCode;
    possibleDisease.spmCode = self.spmCode;
    baseInformation.title = @"基本信息";
    possibleDisease.title = @"可能疾病";
    
    possibleDisease.containerViewController = self.containerViewController;
    currentViewController = baseInformation;
    [self.viewControllerArray addObject:baseInformation];
    [self.viewControllerArray addObject:possibleDisease];
}

- (void)setupSilderView
{
    self.slideSwitchView = [[QCSlideSwitchView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H)];
    self.slideSwitchView.tabItemNormalColor = [QCSlideSwitchView colorFromHexRGB:@"7c7c7c"];
    [self.slideSwitchView.topScrollView setBackgroundColor:UICOLOR(246, 246, 246)];
    self.slideSwitchView.tabItemSelectedColor = APP_COLOR_STYLE;
    self.slideSwitchView.slideSwitchViewDelegate = self;
    self.slideSwitchView.shadowImage = [[UIImage imageNamed:@"red_line_and_shadow.png"]
                                        stretchableImageWithLeftCapWidth:59.0f topCapHeight:0.0f];
    [self.slideSwitchView buildUI];
    [self.view addSubview:self.slideSwitchView];
}

- (NSUInteger)numberOfTab:(QCSlideSwitchView *)view{
    return self.viewControllerArray.count;
}

- (UIViewController *)slideSwitchView:(QCSlideSwitchView *)view viewOfTab:(NSUInteger)number{
    return self.viewControllerArray[number];
}


- (void)slideSwitchView:(QCSlideSwitchView *)view didselectTab:(NSUInteger)number
{
    currentViewController = self.viewControllerArray[number];
    //如果是相关疾病页面  字体放大就隐藏
    if (number == 1) {
        [self.view viewWithTag:TAG_FAV_PAN].hidden = YES;
    }else{
        [self.view viewWithTag:TAG_FAV_PAN].hidden = NO;
    }
    [self.viewControllerArray[number] viewDidCurrentView];
}



@end
