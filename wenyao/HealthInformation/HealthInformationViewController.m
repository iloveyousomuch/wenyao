//
//  HealthInformationViewController.m
//  wenyao
//
//  Created by Meng on 14-9-10.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "HealthInformationViewController.h"
#import "InformationListViewController.h"
#import "Constant.h"
#import "DiseaseSubscriptionViewController.h"
#import "QCSlideSwitchView.h"
#import "HTTPRequestManager.h"
#import "AppDelegate.h"
#import "DataBase.h"
#import "LoginViewController.h"
#import "SVProgressHUD.h"

@interface HealthInformationViewController ()<QCSlideSwitchViewDelegate>
{
    NSMutableArray      *viewControllers;
    UIViewController    *currentViewController;
}
@property (nonatomic, assign) BOOL isLoadNativeCache;
@property (nonatomic, strong) QCSlideSwitchView *slideSwitchView;

@end

@implementation HealthInformationViewController
@synthesize slideSwitchView;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    self.navigationItem.title = @"健康资讯";
    viewControllers = [NSMutableArray arrayWithCapacity:5];
    NSArray *arrChannel = [app.cacheBase queryCachedHealthChannelList];
    self.isLoadNativeCache = YES;
    [self setUpViewControllerWith:arrChannel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutAction) name:QUIT_OUT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpToDisease) name:APP_SELECT_INDEX_DISEASE object:nil];
}

- (void)jumpToDisease
{
    if (app.logStatus) {
        BOOL hasRedPoint = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_NewDisease",app.configureList[APP_PASSPORTID_KEY]]] boolValue];
        if (hasRedPoint) {
            [self.slideSwitchView jumpToTabAtIndex:[viewControllers count]-1];
        }
    }
    [app showDiseaseBudge:NO];
}

- (void)logoutAction
{
    if (viewControllers && viewControllers.count > 0) {
        [app.dataBase removeAllChannel];
        [viewControllers removeAllObjects];
    }
}

- (void)cacheChannelList:(NSArray *)arrChannel
{
    for (NSDictionary *dicChannel in arrChannel) {
        [app.cacheBase insertIntoHealthChannel:dicChannel[@"channelId"] channelName:dicChannel[@"channelName"] sort:[dicChannel[@"sort"] intValue]];
    }
}

- (void)queryChannelList
{
//    if (app.logStatus) {
//    }
    if (self.isLoadNativeCache) {

    } else {
        if(viewControllers.count > 0){
            if (app.hasNewDisease) {
                if (app.logStatus) {
                    if (![app.dataBase checkAllDiseaseReaded]) {
                    }
                }
            }
//            app.hasNewDisease = NO;

            return;
        }
        
    }
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    [[HTTPRequestManager sharedInstance] queryChannelList:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]){
            NSArray *array = resultObj[@"body"][@"data"];
            [app.cacheBase removeAllChannel];
            [self cacheChannelList:array];
            [viewControllers removeAllObjects];
            [self setUpViewControllerWith:array];
            
            if (app.imageViewBudge.hidden == NO) {
                if (viewControllers.count > 0) {
                    [self.slideSwitchView jumpToTabAtIndex:[viewControllers count]-1];
                    app.hasNewDisease = NO;
                }
            }
//            if ((app.dataBase)&&(![app.dataBase checkAllDiseaseReaded])) {
            
//            }
//            if (app.hasNewDisease) {
//                [self.slideSwitchView jumpToTabAtIndex:[viewControllers count]-1];
//                app.hasNewDisease = NO;
//            }
            self.isLoadNativeCache = NO;
        }else{
            
        }
    } failure:NULL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(currentViewController)
    {
        [currentViewController viewWillAppear:animated];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutAction) name:QUIT_OUT object:nil];
    
    [self queryChannelList];
}

- (void)setupSilderView
{
    if (self.slideSwitchView) {
        [self.slideSwitchView removeFromSuperview];
        self.slideSwitchView = nil;
    }
    self.slideSwitchView = [[QCSlideSwitchView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H)];
    self.slideSwitchView.userSelectedChannelID = 0;
    if (app.needShowBadge == YES) {
        self.slideSwitchView.userSelectedChannelID = viewControllers.count-1+100;
    } else {
        self.slideSwitchView.userSelectedChannelID = 100;
    }
    
    self.slideSwitchView.tabItemNormalColor = [QCSlideSwitchView colorFromHexRGB:@"7c7c7c"];
    [self.slideSwitchView.topScrollView setBackgroundColor:UICOLOR(246, 246, 246)];
    self.slideSwitchView.tabItemSelectedColor = APP_COLOR_STYLE;
    self.slideSwitchView.slideSwitchViewDelegate = self;
    self.slideSwitchView.isNeedAdjust = YES;
    self.slideSwitchView.shadowImage = [[UIImage imageNamed:@"red_line_and_shadow.png"]
                                        stretchableImageWithLeftCapWidth:59.0f topCapHeight:0.0f];
    [self.slideSwitchView buildUI];
    self.slideSwitchView.rootScrollView.scrollEnabled = NO;
    
    [self.view addSubview:self.slideSwitchView];
    
}

- (void)setUpViewControllerWith:(NSArray *)array
{

//        if([viewControllers count] > 0)
//            return;
    
    for(NSDictionary *dict in array)
    {
        InformationListViewController *controller = [[InformationListViewController alloc] init];
        controller.navigationController = self.navigationController;
        controller.infoDict = dict;
        controller.title = dict[@"channelName"];
        [viewControllers addObject:controller];

    }

    DiseaseSubscriptionViewController *subscription = [[DiseaseSubscriptionViewController alloc] init];
    subscription.navigationController = self.navigationController;
    subscription.title = @"慢病订阅";
    [viewControllers addObject:subscription];
    if ((app.dataBase)&&(![app.dataBase checkAllDiseaseReaded])) {
        currentViewController = viewControllers[viewControllers.count-1];
    } else {
        currentViewController = viewControllers[0];
    }
    
    [self setupSilderView];

}

- (NSUInteger)numberOfTab:(QCSlideSwitchView *)view
{
    return viewControllers.count;
}

- (UIViewController *)slideSwitchView:(QCSlideSwitchView *)view viewOfTab:(NSUInteger)number
{
    return viewControllers[number];
}

- (void)slideSwitchView:(QCSlideSwitchView *)view didselectTab:(NSUInteger)number
{

    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        return;
    }
    if(currentViewController == viewControllers[number])
        return;
    currentViewController = viewControllers[number];
    [viewControllers[number] viewWillAppear:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
