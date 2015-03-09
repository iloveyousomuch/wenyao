//
//  HealthySliderViewController.m
//  wenyao
//
//  Created by 李坚 on 15/1/20.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "HealthySliderViewController.h"
#import "Constant.h"

#import "subKnowledgeViewController.h"
#import "SubRegularDrugsViewController.h"

@interface HealthySliderViewController ()<QCSlideSwitchViewDelegate>
{
    __weak BaseViewController  *currentViewController;
}
@end

@implementation HealthySliderViewController

- (id)init{
    if (self = [super init]) {
        self.viewControllerArray = [NSMutableArray array];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViewController];
    [self setupSliderView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupViewController{
    
    SubRegularDrugsViewController *RegularDrugsView = [[SubRegularDrugsViewController alloc]init];
    RegularDrugsView.infoDict = self.infoDict;
    RegularDrugsView.navigationController = self.navigationController;
    
    subKnowledgeViewController *knowledgeView = [[subKnowledgeViewController alloc]init];
    knowledgeView.navigationController = self.navigationController;
    knowledgeView.infoDict = self.infoDict;
    currentViewController = RegularDrugsView;
    [self.viewControllerArray addObject:RegularDrugsView];
    [self.viewControllerArray addObject:knowledgeView];
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

@end
