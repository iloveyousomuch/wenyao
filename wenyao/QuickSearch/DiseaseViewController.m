//
//  DiseaseViewController.m
//  quanzhi
//
//  Created by Meng on 14-9-16.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "DiseaseViewController.h"
#import "Constant.h"
#import "DiseaseClassViewController.h"
#import "DiseaseWikiViewController.h"
#import "QCSlideSwitchView.h"
#import "DiseaseSubViewController.h"
#import "SearchSliderViewController.h"
#import "ReturnIndexView.h"
#import "AppDelegate.h"
@interface DiseaseViewController ()<QCSlideSwitchViewDelegate,ReturnIndexViewDelegate>
{
    __weak BaseViewController  *currentViewController;
}
@property (nonatomic ,strong) NSMutableArray * viewControllerArray;
@property (nonatomic ,strong) QCSlideSwitchView * slideSwitchView;
@property (strong,nonatomic)   ReturnIndexView *indexView;
@end

@implementation DiseaseViewController

- (id)init{
    if (self = [super init]) {
        self.title = @"疾病";
        self.viewControllerArray = [NSMutableArray array];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViewController];
    [self setupSliderView];
    //[self setupRightBarButton];
#pragma 按钮的调整
    [self setRightItems];
    
}

-(void)setRightItems{
    UIView *jbBarItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 55)];
    //[customBarItems setBackgroundColor:[UIColor yellowColor]];
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(28, 0, 55, 55)];
    [searchButton setImage:[UIImage imageNamed:@"导航栏_搜索icon.png"]  forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(rightBarbuttonClick) forControlEvents:UIControlEventTouchDown];
    [jbBarItems addSubview:searchButton];
    
    UIButton *indexButton = [[UIButton alloc] initWithFrame:CGRectMake(65, 0, 55, 55)];
    [indexButton setImage:[UIImage imageNamed:@"icon-unfold.PNG"] forState:UIControlStateNormal];
    [indexButton addTarget:self action:@selector(showIndex) forControlEvents:UIControlEventTouchDown];
    [jbBarItems addSubview:indexButton];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -20;
    self.navigationItem.rightBarButtonItems = @[fixed,[[UIBarButtonItem alloc] initWithCustomView:jbBarItems]];
    
}

- (void)showIndex
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

//- (void)setupRightBarButton{
//    UIBarButtonItem * rightBarbutton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"导航栏_搜索icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarbuttonClick)];
//    self.navigationItem.rightBarButtonItem = rightBarbutton;
//}

- (void)rightBarbuttonClick{
    SearchSliderViewController * searchViewController = [[SearchSliderViewController alloc] init];
    searchViewController.currentSelectedViewController = diseaseViewController;
    searchViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewController animated:NO];
}

- (void)setupViewController{
    
    DiseaseSubViewController * diseaseSubViewController = [[DiseaseSubViewController alloc]init];
    //diseaseSubViewController.requestType = RequestTypeDisease;
    diseaseSubViewController.navigationController = self.navigationController;
    DiseaseWikiViewController * diseaseWikiViewController = [[DiseaseWikiViewController alloc]init];
    diseaseWikiViewController.navigationController = self.navigationController;
    currentViewController = diseaseSubViewController;
    [self.viewControllerArray addObject:diseaseSubViewController];
    [self.viewControllerArray addObject:diseaseWikiViewController];
    
}

- (void)setupSliderView{
    
    self.slideSwitchView = [[QCSlideSwitchView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H)];
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
    
    [self.view addSubview:self.slideSwitchView];
}

/*!
 * @method 顶部tab个数
 * @abstract
 * @discussion
 * @param 本控件
 * @result tab个数
 */
- (NSUInteger)numberOfTab:(QCSlideSwitchView *)view{
    return self.viewControllerArray.count;
}

/*!
 * @method 每个tab所属的viewController
 * @abstract
 * @discussion
 * @param tab索引
 * @result viewController
 */
- (UIViewController *)slideSwitchView:(QCSlideSwitchView *)view viewOfTab:(NSUInteger)number{
    return self.viewControllerArray[number];
}

- (void)slideSwitchView:(QCSlideSwitchView *)view didselectTab:(NSUInteger)number{
    [self.viewControllerArray[number] viewDidCurrentView];
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
