//
//  SearchViewController.m
//  wenyao
//
//  Created by Meng on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "SearchSliderViewController.h"
#import "QCSlideSwitchView.h"
#import "ThreeChildrenViewController.h"
#import "SearchRootViewController.h"
#import "MedicineListViewController.h"
#import "DiseaseDetailViewController.h"
#import "SymptomViewController.h"


@interface SearchSliderViewController ()<UISearchBarDelegate,UITextFieldDelegate,QCSlideSwitchViewDelegate,SearchRootViewControllerDelegate>
{
    UISearchBar* m_searchBar;
    UITextField* m_searchField;
    
    __weak SearchRootViewController * currentViewController;
}

@property (nonatomic ,strong) NSMutableArray * searchHistoryArray;

@property (nonatomic ,strong) QCSlideSwitchView * sliderSwtichView;
@property (nonatomic ,strong) NSMutableArray * viewControllerArray;
@end

@implementation SearchSliderViewController
{
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for(UIViewController *controller in self.viewControllerArray) {
        [controller viewWillAppear:YES];
    }
    [m_searchBar becomeFirstResponder];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [m_searchField resignFirstResponder];
}

- (void)dealloc
{

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewControllerArray = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldValueChanged:) name:UITextFieldTextDidChangeNotification object:m_searchBar];
    // Do any additional setup after loading the view.
    UIView* status_bg = [[UIView alloc] initWithFrame:RECT(0, 0, APP_W, STATUS_H)];
    status_bg.backgroundColor = APP_COLOR_STYLE;
    [self.view addSubview:status_bg];

    UIView* searchbg = [[UIView alloc] initWithFrame:CGRectMake(0, STATUS_H, APP_W, NAV_H)];
    searchbg.backgroundColor=APP_COLOR_STYLE;
    [self.view addSubview:searchbg];
    
    m_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, STATUS_H, APP_W-50, NAV_H)];
    m_searchBar.tintColor = [UIColor blueColor];
    m_searchBar.backgroundColor = APP_COLOR_STYLE;
    m_searchBar.placeholder = @"搜索药品";
    m_searchBar.delegate = self;
    //m_searchBar.showsCancelButton = YES;
    [self.view addSubview:m_searchBar];
    
    if (iOSv7) {
        UIView* barView = [m_searchBar.subviews objectAtIndex:0];
        [[barView.subviews objectAtIndex:0] removeFromSuperview];
        UITextField* searchField = [barView.subviews objectAtIndex:0];
        searchField.font = [UIFont systemFontOfSize:13.0f];
        [searchField setReturnKeyType:UIReturnKeySearch];
        m_searchField = searchField;
    } else {
        [[m_searchBar.subviews objectAtIndex:0] removeFromSuperview];
        UITextField* searchField = [m_searchBar.subviews objectAtIndex:0];
        searchField.delegate = self;
        searchField.font = [UIFont systemFontOfSize:13.0f];
        [searchField setReturnKeyType:UIReturnKeySearch];
        m_searchField = searchField;
    }
    
    UIButton* cancelBtn = [[UIButton alloc] initWithFrame:RECT(APP_W-60, STATUS_H, 60, NAV_H)];
    cancelBtn.backgroundColor = [UIColor clearColor];
    cancelBtn.titleLabel.font = FontB(16);
    [cancelBtn setTitle:@"取消" forState:0];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:0];
    [cancelBtn addTarget:self action:@selector(onCancelBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.tag = 888;
    [self.view addSubview:cancelBtn];
    
    [self setupViewController];
    [self setupSliderView];
}

- (void)searchBarText:(NSString *)text
{
    m_searchBar.text = text;
}



- (void)textFieldValueChanged:(NSNotification *)notification
{
    UISearchBar * searchBar = (UISearchBar *)notification.object;
    
    if (currentViewController == self.viewControllerArray[0])
    {
        currentViewController.histroySearchType = 0;
        
    }else
        if (currentViewController == self.viewControllerArray[1])
    {
        currentViewController.histroySearchType = 1;
        
    }else
        if (currentViewController == self.viewControllerArray[2])
    {
        currentViewController.histroySearchType = 2;
    }
    NSString * key = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    currentViewController.keyWord = key;
}


- (void)setupViewController{
    ThreeChildrenViewController * medicineSearch = [[ThreeChildrenViewController alloc] init];
    medicineSearch.title = @"药品";
    medicineSearch.navigation = self.navigationController;
    medicineSearch.delegate = self;
    currentViewController = medicineSearch;
    
    ThreeChildrenViewController * diseaseSearch = [[ThreeChildrenViewController alloc] init];
    diseaseSearch.title = @"疾病";
    diseaseSearch.delegate = self;
    diseaseSearch.navigation = self.navigationController;
    
    ThreeChildrenViewController * symptomSearch = [[ThreeChildrenViewController alloc] init];
    symptomSearch.title = @"症状";
    symptomSearch.delegate = self;
   // symptomSearch.navigation = self.navigationController;
    symptomSearch.containerViewController = self;
    
    [self.viewControllerArray addObject:medicineSearch];
    [self.viewControllerArray addObject:diseaseSearch];
    [self.viewControllerArray addObject:symptomSearch];
    
    if (self.currentSelectedViewController == symptomViewController)
    {
        currentViewController = symptomSearch;
    }else if (self.currentSelectedViewController == diseaseViewController)
    {
        currentViewController = diseaseSearch;
    }else{
        currentViewController = medicineSearch;
    }
    
}

- (void)setupSliderView
{
    self.sliderSwtichView = [[QCSlideSwitchView alloc] initWithFrame:CGRectMake(0, NAV_H+STATUS_H, APP_W, APP_H-NAV_H)];
//    NSLog(@"the slider view frame is %@",NSStringFromCGRect(self.sliderSwtichView.frame));
    self.sliderSwtichView.tabItemNormalColor = [QCSlideSwitchView colorFromHexRGB:@"666666"];
    [self.sliderSwtichView.rigthSideButton.titleLabel setFont:Font(14)];
    [self.sliderSwtichView.topScrollView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.sliderSwtichView.topScrollView.frame = CGRectMake(0, 0, APP_W, 80);
    
    
    self.sliderSwtichView.tabItemSelectedColor = APP_COLOR_STYLE;
    self.sliderSwtichView.slideSwitchViewDelegate = self;
    self.sliderSwtichView.shadowImage = [[UIImage imageNamed:@"red_line_and_shadow.png"]
                                        stretchableImageWithLeftCapWidth:64.0f topCapHeight:0.0f];
    
    if (self.currentSelectedViewController == medicineViewController)
    {
        self.sliderSwtichView.userSelectedChannelID = 100;
    }else if (self.currentSelectedViewController == diseaseViewController)
    {
        self.sliderSwtichView.userSelectedChannelID = 101;
    }else{
        self.sliderSwtichView.userSelectedChannelID = 102;
    }
    
    [self.sliderSwtichView buildUI];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 35 - 0.5, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [self.sliderSwtichView addSubview:line];
    [self.view addSubview:self.sliderSwtichView];
}

- (void)onCancelBtnTouched:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark ------ QCSliderViewDelegate ------
/*!
 * @method 顶部tab个数
 * @abstract
 * @discussion
 * @param 本控件
 * @result tab个数
 */
- (NSUInteger)numberOfTab:(QCSlideSwitchView *)view
{
    return self.viewControllerArray.count;
}

/*!
 * @method 每个tab所属的viewController
 * @abstract
 * @discussion
 * @param tab索引
 * @result viewController
 */
- (UIViewController *)slideSwitchView:(QCSlideSwitchView *)view viewOfTab:(NSUInteger)number
{
    return self.viewControllerArray[number];
}

- (void)slideSwitchView:(QCSlideSwitchView *)view didselectTab:(NSUInteger)number
{
    //m_searchBar.text = @"";

    currentViewController = self.viewControllerArray[number];
    switch (number) {
        case 0:
            m_searchBar.placeholder = @"搜索药品";
            currentViewController.histroySearchType = 0;
            break;
        case 1:
            m_searchBar.placeholder = @"搜索疾病";
            currentViewController.histroySearchType = 1;
            break;
        case 2:
            m_searchBar.placeholder = @"搜索症状";
            currentViewController.histroySearchType = 2;
            break;
        default:
            break;
    }
    NSString * key = [m_searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    currentViewController.keyWord = key;
    
    //滑动block  隐藏软键盘
    __block SearchSliderViewController *blockSelf = self;
    currentViewController.scrollBlock = ^(void){
        [blockSelf hidekeyboard];
    };

    //[currentViewController viewDidCurrentView];
}

- (void)hidekeyboard
{
    CGRect rect = m_searchField.frame;
    [m_searchField resignFirstResponder];
    m_searchField.frame = rect;
    m_searchBar.tintColor = [UIColor blueColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
