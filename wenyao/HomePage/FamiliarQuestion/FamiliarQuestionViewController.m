//
//  FamiliarQuestionViewController.m
//  wenyao
//
//  Created by qwyf0006 on 15/1/15.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "FamiliarQuestionViewController.h"
#import "QCSlideSwitchView.h"
#import "QuestionListViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "ConsultQuizViewController.h"
#import "ReturnIndexView.h"

@interface FamiliarQuestionViewController ()<QCSlideSwitchViewDelegate,ReturnIndexViewDelegate>

@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, assign) BOOL isLoadNativeCache;
@property (nonatomic, strong) QCSlideSwitchView *slideSwitchView;
@property (nonatomic, strong) UIView *noDataView;
@property (strong, nonatomic) ReturnIndexView *indexView;

@end

@implementation FamiliarQuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:UIColorFromRGB(0xffffff),UITextAttributeTextColor,[UIFont systemFontOfSize:18],UITextAttributeFont, nil]];
    
    self.noDataView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-200)/2, 90, 200, 60)];
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.noDataView.frame.size.width, self.noDataView.frame.size.height)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = @"暂无数据!";
    lab.textColor = [UIColor lightGrayColor];
    [self.noDataView addSubview:lab];
    self.noDataView.hidden = YES;
    [self.view addSubview:self.noDataView];
    
    [self setUpBottomView];
    self.viewControllers = [NSMutableArray arrayWithCapacity:0];
    self.title = self.dic[@"name"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutAction) name:QUIT_OUT object:nil];
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


- (void)setUpBottomView
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50-64, self.view.frame.size.width, 50)];
    bgView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [bgView addSubview:line];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake((bgView.frame.size.width-275)/2, 5, 275, 40);
    [btn setBackgroundColor:UIColorFromRGB(0xff8a00)];
    [btn setTitle:@"我也要问药" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    [btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    btn.layer.cornerRadius = 2.0;
    btn.layer.masksToBounds = YES;
    [btn addTarget:self action:@selector(askMedcineAction) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btn];
    [self.view addSubview:bgView];
}

//我也要问药
- (void)askMedcineAction
{
    UIStoryboard *sbConsult = [UIStoryboard storyboardWithName:@"ConsultMedicine" bundle:nil];
    ConsultQuizViewController *viewControllerConsult = [sbConsult instantiateViewControllerWithIdentifier:@"ConsultQuizViewController"];
    [self.navigationController pushViewController:viewControllerConsult animated:YES];
}


- (void)logoutAction
{
    if (self.viewControllers && self.viewControllers.count > 0) {
        [app.dataBase removeAllFamiliarQuestionChannelWithModuleId:self.dic[@"moduleId"]];
        [self.viewControllers removeAllObjects];
    }
}

- (void)cacheChannelList:(NSArray *)arrChannel
{
    for (NSDictionary *dicChannel in arrChannel) {
        [app.cacheBase insertIntoFamiliarQuestionChannel:dicChannel[@"classId"] channelName:dicChannel[@"name"] moduleId:self.dic[@"moduleId"]];
    }
}

- (void)loadCachedChannelList
{
    if (self.viewControllers.count > 0) {
        return;
    }
    NSArray *arrChannel = [app.cacheBase queryCachedFamiliarQuestionChannelListWithModuleId:self.dic[@"moduleId"]];
    [self setupViewControllerWith:arrChannel];
    if (arrChannel.count == 0) {
        self.slideSwitchView.hidden = YES;
        self.noDataView.hidden = NO;
    }
}

- (void)queryChannelList
{
    
    if(self.viewControllers.count > 0){
        return;
    }
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"moduleId"] = self.dic[@"moduleId"];
    [[HTTPRequestManager sharedInstance] queryFamiliarQuestionChannelList:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]){
            NSArray *array = resultObj[@"body"];
            [app.cacheBase removeAllFamiliarQuestionChannelWithModuleId:self.dic[@"moduleId"]];
            [self cacheChannelList:array];
            [self.viewControllers removeAllObjects];
            [self setupViewControllerWith:array];
            
            if (array.count == 0) {
                self.slideSwitchView.hidden = YES;
                self.noDataView.hidden = NO;
            }
            
        }
        
    } failure:^(NSError *error) {
        
    }];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.currentViewController)
    {
        [self.currentViewController viewWillAppear:animated];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutAction) name:QUIT_OUT object:nil];
    
    if (app.currentNetWork != kNotReachable) {
        [self queryChannelList];
    }
    else
    {
        [self loadCachedChannelList];
    }
}

- (void)setupViewControllerWith:(NSArray *)array{
    
    for (int i=0; i<array.count; i++) {
        QuestionListViewController *controller = [[QuestionListViewController alloc]init];
        self.currentViewController = controller;
        controller.title =  array[i];
        controller.title = array[i][@"name"];
        controller.classId = array[i][@"classId"];
        controller.moduleId = self.dic[@"moduleId"];
        controller.currNavigationController = self.navigationController;
        [self.viewControllers addObject:controller];
    }
    [self setupSliderView];
    
}

- (void)setupSliderView{
    
    self.slideSwitchView = [[QCSlideSwitchView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H - 50)];
    self.slideSwitchView.tabItemNormalColor = [QCSlideSwitchView colorFromHexRGB:@"666666"];
    [self.slideSwitchView.topScrollView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.slideSwitchView.tabItemSelectedColor = APP_COLOR_STYLE;
    [self.slideSwitchView.rigthSideButton.titleLabel setFont:Font(14)];
    self.slideSwitchView.slideSwitchViewDelegate = self;
    self.slideSwitchView.shadowImage = [[UIImage imageNamed:@"red_line_and_shadow.png"]
                                        stretchableImageWithLeftCapWidth:59.0f topCapHeight:0.0f];
    [self.slideSwitchView buildUI];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 35, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [self.slideSwitchView addSubview:line];
    
    self.slideSwitchView.rootScrollView.scrollEnabled = YES;
    [self.view addSubview:self.slideSwitchView];
}

- (NSUInteger)numberOfTab:(QCSlideSwitchView *)view{
    return self.viewControllers.count;
}

- (UIViewController *)slideSwitchView:(QCSlideSwitchView *)view viewOfTab:(NSUInteger)number{
    return self.viewControllers[number];
}

- (void)slideSwitchView:(QCSlideSwitchView *)view didselectTab:(NSUInteger)number
{

    if(self.currentViewController == self.viewControllers[number])
        return;
    self.currentViewController = self.viewControllers[number];
    //[self.viewControllers[number] viewWillAppear:NO];
    [self.viewControllers[number] viewDidCurrentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
