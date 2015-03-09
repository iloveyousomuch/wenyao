//
//  MycollectViewController.m
//  wenyao
//
//  Created by Meng on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "MycollectViewController.h"
#import "QCSlideSwitchView.h"
#import "MedicineCollectViewController.h"
#import "OtherCollectViewController.h"
#import "ReturnIndexView.h"
#import "AppDelegate.h"

@interface MycollectViewController ()<QCSlideSwitchViewDelegate,ReturnIndexViewDelegate>
{
   __weak OtherCollectViewController  *currentViewController;
    BaseTableViewController * currentTab;
}
@property (nonatomic ,strong)NSMutableArray * viewControllerArray;
@property (nonatomic ,strong) QCSlideSwitchView * slideSwitchView;
@property (nonatomic ,strong) ReturnIndexView *indexView;
@end

@implementation MycollectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.viewControllerArray = [NSMutableArray array];
        if (iOSv7 && self.view.frame.origin.y==0) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = NO;
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.title = @"我的收藏";
    //[self setUpViewController];
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


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUpViewController];
    if (currentTab) {
        [currentTab viewDidCurrentView];
    }
}

- (void)setUpViewController{

    if(self.viewControllerArray.count > 0)
        return;
    //药品收藏
    MedicineCollectViewController * medicineCollect = [[MedicineCollectViewController alloc]init];
    medicineCollect.title = @"药品";
    medicineCollect.navigationController = self.navigationController;
    [self.viewControllerArray addObject:medicineCollect];
    //症状收藏
    OtherCollectViewController * symptomCollectViewController = [[OtherCollectViewController alloc]init];
    symptomCollectViewController.title = @"症状";
    symptomCollectViewController.navigationController = self.navigationController;
    symptomCollectViewController.containerViewController = self;
    [self.viewControllerArray addObject:symptomCollectViewController];
    //疾病收藏
    OtherCollectViewController * diseaseCollectViewController = [[OtherCollectViewController alloc] init];
    diseaseCollectViewController.title = @"疾病";
    diseaseCollectViewController.navigationController = self.navigationController;
    [self.viewControllerArray addObject:diseaseCollectViewController];
    //资讯收藏
    OtherCollectViewController * infomationCollectViewController = [[OtherCollectViewController alloc] init];
    infomationCollectViewController.title = @"资讯";
    infomationCollectViewController.navigationController = self.navigationController;
    [self.viewControllerArray addObject:infomationCollectViewController];
    [self setupSilderView];
    
}

- (void)setupSilderView{
    self.slideSwitchView = [[QCSlideSwitchView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H)];
    self.slideSwitchView.tabItemNormalColor = [QCSlideSwitchView colorFromHexRGB:@"7c7c7c"];
    [self.slideSwitchView.topScrollView setBackgroundColor:UICOLOR(246, 246, 246)];
    self.slideSwitchView.tabItemSelectedColor = APP_COLOR_STYLE;
    //self.slideSwitchView.scrollViewSelectedChannelID =
    self.slideSwitchView.slideSwitchViewDelegate = self;
    self.slideSwitchView.shadowImage = [[UIImage imageNamed:@"red_line_and_shadow.png"]
                                        stretchableImageWithLeftCapWidth:59.0f topCapHeight:0.0f];
    [self.slideSwitchView buildUI];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 35 - 0.5, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [self.slideSwitchView addSubview:line];
    
    [self.view addSubview:self.slideSwitchView];
    
}

- (NSUInteger)numberOfTab:(QCSlideSwitchView *)view
{
    return self.viewControllerArray.count;
}

- (UIViewController *)slideSwitchView:(QCSlideSwitchView *)view viewOfTab:(NSUInteger)number{
    return self.viewControllerArray[number];
}

- (void)slideSwitchView:(QCSlideSwitchView *)view didselectTab:(NSUInteger)number{
    if (number != 0) {
        currentViewController = self.viewControllerArray[number];
    }
    currentTab = self.viewControllerArray[number];
    switch (number) {
        case 0:
        {
            MedicineCollectViewController * medicine = (MedicineCollectViewController *)self.viewControllerArray[number];
            [medicine viewDidCurrentView];
            break;
        }
        case 1:
        {
            currentViewController.collectType = symptomCollect;
            break;
        }
        case 2:
        {
            currentViewController.collectType = diseaseCollect;
            break;
        }
        case 3:
        {
            currentViewController.collectType = messageCollect;
            break;
        }
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
