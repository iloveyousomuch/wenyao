//
//  SymptomMainViewController.m
//  quanzhi
//
//  Created by xiezhenghong on 14-8-7.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "SymptomMainViewController.h"
#import "BodyPartViewController.h"
#import "SearchSliderViewController.h"
#import "Constant.h"
#import "SymptomViewController.h"
#import "ReturnIndexView.h"
#import "AppDelegate.h"
@interface SymptomMainViewController ()<UISearchBarDelegate,UITextFieldDelegate,QCSlideSwitchViewDelegate,ReturnIndexViewDelegate>

@property (nonatomic, strong) NSMutableArray   *menuList;
@property (nonatomic ,strong) UISearchBar *searchBar;
@property (strong,nonatomic) ReturnIndexView *indexView;
@end

@implementation SymptomMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"症状";
    self.menuList = [NSMutableArray arrayWithCapacity:2];
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(searchItemClick)];
    self.navigationItem.rightBarButtonItem = searchItem;
    [self setupViewController];
    [self setupSilderView];
    //[self setupSearchBar];
    //[self setupRightBarButton];
#pragma 按钮的调整
    [self setRightItems];
    self.slideSwitchView.userInteractionEnabled = YES;
    self.slideSwitchView.tabItemNormalColor = UIColorFromRGB(0xffffff);
    
}

-(void)setRightItems{
    UIView *zzBarItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 55)];
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(28, 0, 55, 55)];
    [searchButton setImage:[UIImage imageNamed:@"导航栏_搜索icon.png"]  forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(rightBarbuttonClick) forControlEvents:UIControlEventTouchDown];
    [zzBarItems addSubview:searchButton];
    
    UIButton *indexButton = [[UIButton alloc] initWithFrame:CGRectMake(65, 0, 55, 55)];
    [indexButton setImage:[UIImage imageNamed:@"icon-unfold.PNG"] forState:UIControlStateNormal];
    [indexButton addTarget:self action:@selector(showIndex) forControlEvents:UIControlEventTouchDown];
    [zzBarItems addSubview:indexButton];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -20;
    self.navigationItem.rightBarButtonItems = @[fixed,[[UIBarButtonItem alloc] initWithCustomView:zzBarItems]];
    
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
    searchViewController.currentSelectedViewController = symptomViewController;
    searchViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewController animated:NO];
}

- (void)setupSearchBar
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 44)];
    [titleView setBackgroundColor:[UIColor clearColor]];
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 5, 222.5, 34)];
    self.searchBar.backgroundColor = [UIColor clearColor];
    self.searchBar.placeholder = @"输入症状名、疾病名或药品名";
    self.searchBar.delegate = self;
    [titleView addSubview:self.searchBar];
    self.navigationItem.titleView = titleView;
    
    if (iOSv7) {
        UIView* barView = [self.searchBar.subviews objectAtIndex:0];
        [[barView.subviews objectAtIndex:0] removeFromSuperview];
        UITextField* searchField = [barView.subviews objectAtIndex:0];
        searchField.delegate = self;
        searchField.font = [UIFont systemFontOfSize:13.0f];
        [searchField setReturnKeyType:UIReturnKeySearch];
    }
}

- (void)setupViewController
{
    BodyPartViewController *bodyViewController = nil;
    if(HIGH_RESOLUTION){
        bodyViewController = [[BodyPartViewController alloc] initWithNibName:@"BodyPartViewController" bundle:nil];
    }else{
        bodyViewController = [[BodyPartViewController alloc] initWithNibName:@"BodyPartViewController-480" bundle:nil];
    }
    bodyViewController.title = @"部位查找";
    SymptomViewController *symptomWikipedia = [[SymptomViewController alloc] init];
    symptomWikipedia.requestType = wikiSym;
    bodyViewController.containerViewController = self;
    symptomWikipedia.containerViewController = self;
    [self.menuList addObject:bodyViewController];
    [self.menuList addObject:symptomWikipedia];
}

- (void)searchItemClick{
    [self.searchBar resignFirstResponder];
}

- (void)setupSilderView
{
    self.slideSwitchView.tabItemNormalColor = [QCSlideSwitchView colorFromHexRGB:@"666666"];
    [self.slideSwitchView.rigthSideButton.titleLabel setFont:Font(14)];
    self.slideSwitchView.topScrollView.frame = CGRectMake(0, 0, APP_W, 40);
    [self.slideSwitchView.topScrollView setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 35, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xcccccc);
    [self.view addSubview:line];
    
    self.slideSwitchView.tabItemSelectedColor = APP_COLOR_STYLE;
    self.slideSwitchView.slideSwitchViewDelegate = self;
    self.slideSwitchView.shadowImage = [[UIImage imageNamed:@"red_line_and_shadow.png"]
                                        stretchableImageWithLeftCapWidth:59.0f topCapHeight:0.0f];
    [self.slideSwitchView buildUI];
}

#pragma mark - 滑动tab视图代理方法
- (NSUInteger)numberOfTab:(QCSlideSwitchView *)view
{
    // you can set the best you can do it ;
    return [self.menuList count];
}

- (UIViewController *)slideSwitchView:(QCSlideSwitchView *)view viewOfTab:(NSUInteger)number
{
    return self.menuList[number];
}

- (void)slideSwitchView:(QCSlideSwitchView *)view willselectTab:(NSUInteger)number{
     [self.searchBar resignFirstResponder];
}

- (void)slideSwitchView:(QCSlideSwitchView *)view didselectTab:(NSUInteger)number
{
    
    BaseViewController *viewController = self.menuList[number];
    
    [viewController viewDidCurrentView];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    SearchSliderViewController * searchViewController = [[SearchSliderViewController alloc] init];
    searchViewController.currentSelectedViewController = symptomViewController;
    searchViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewController animated:NO];
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.searchBar resignFirstResponder];
}

@end
