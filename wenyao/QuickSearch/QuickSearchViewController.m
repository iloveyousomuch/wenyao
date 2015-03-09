//
//  QuickSearchViewController.m
//  wenyao
//
//  Created by Meng on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "QuickSearchViewController.h"
#import "SearchSliderViewController.h" 
#import "SymptomMainViewController.h"
#import "QuickMedicineViewController.h"
#import "HealthIndicatorViewController.h"
#import "MedicineSubViewController.h"
#import "FactoryListViewController.h"
#import "NearMapViewController.h"
#import "DiseaseViewController.h"
#import "ScanReaderViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "HealthyScenarioViewController.h"
#import "NearStoreDetail1ViewController.h"
#import "ConsultPharmacyViewController.h"
#import "CouponGenerateViewController.h"

#define BUTTON_Y  60
#define BUTTON_H  90

#define imageView_X  20
#define imageView_Y  10
#define imageView_W  42
#define imageView_H  42

@interface QuickSearchViewController ()<UISearchBarDelegate,UITextFieldDelegate>

@property (nonatomic ,strong) UISearchBar * searchBar;
@property (nonatomic ,strong) UITextField * textField;

@end

@implementation QuickSearchViewController

- (id)init{
    if (self = [super init]) {
        self.view.backgroundColor = BG_COLOR;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(_showBack == 0) {
        self.navigationController.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"自查";
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    //[self setupSearchBar];
    [self setUpTextfield];
    [self setUpButtons];
//    [self setUpRightBarButton];
}


- (void)buttonViewWithFrame:(CGRect)frame withTitle:(NSString *)title withTag:(NSInteger)tag imageName:(NSString *)imagename{
    UIView * view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor whiteColor];
    UIImage * image = [UIImage imageNamed:imagename];
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake((100 - image.size.width)/2, imageView_Y, imageView_W, imageView_H)];
    imageView.image = image;
    [view addSubview:imageView];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView_Y + imageView_H + 10, 100, 15)];
    label.text = title;
    label.font = Font(14);
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    
    MyTapGestureRecognizer * tap = [[MyTapGestureRecognizer alloc] init];
    tap.tag = tag;
    [tap addTarget:self action:@selector(buttonClick:)];
    [view addGestureRecognizer:tap];
    [self.view addSubview:view];
}

- (void)setUpButtons{
    NSArray * titleArr = @[@"药品",@"疾病",@"症状",@"健康指标",@"健康方案",@"品牌展示"];
    NSArray * imageArr = @[@"药品icon.png",@"疾病icon.png",@"症状icon.png",@"健康指标icon.png",@"健康方案icon.png",@"品牌展示icon.png"];
    
    for (int i = 0; i < 2; i ++) {
        for (int j= 0; j < 3; j++) {
            [self buttonViewWithFrame:CGRectMake(11+100*j, BUTTON_Y + BUTTON_H * i, 99, BUTTON_H -1) withTitle:titleArr[i*3 + j] withTag:10000 + i*3 +j imageName:imageArr[i*3+j]];
        }
    }
}

- (void)buttonClick:(MyTapGestureRecognizer *)tap{
    
    switch (tap.tag) {
        case 10000://药品
        {
//            CouponGenerateViewController *generateView = [[CouponGenerateViewController alloc]initWithNibName:@"CouponGenerateViewController" bundle:nil];
//            [self.navigationController pushViewController:generateView animated:YES];
            
            
            QuickMedicineViewController * medicineViewController = [[QuickMedicineViewController alloc] init];
            medicineViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:medicineViewController animated:YES];
        }
            break;
        case 10001://疾病
        {
            
            //重用MedicineListViewController来充当DiseaseListViewController
            DiseaseViewController * diseaseViewController = [[DiseaseViewController alloc] init];
            //diseaseViewController.title = @"疾病";
            //diseaseViewController.requestType = RequestTypeDisease;
            diseaseViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:diseaseViewController animated:YES];
        }
            break;
        case 10002://症状
        {
            SymptomMainViewController * symptomMainViewController = nil;
            if(HIGH_RESOLUTION) {
                symptomMainViewController = [[SymptomMainViewController alloc] initWithNibName:@"SymptomMainViewController" bundle:nil];
            }else{
                symptomMainViewController = [[SymptomMainViewController alloc] initWithNibName:@"SymptomMainViewController-480" bundle:nil];
            }
            symptomMainViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:symptomMainViewController animated:YES];
        }
            break;
        case 10003://健康指标
        {
//            ConsultPharmacyViewController *consultPharmacyViewController = [[ConsultPharmacyViewController alloc] init];
//            consultPharmacyViewController.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:consultPharmacyViewController animated:YES];
//            return;
            
            HealthIndicatorViewController * healthIndicator = [[HealthIndicatorViewController alloc] init];
            healthIndicator.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:healthIndicator animated:YES];
        }
            break;
        case 10004://附近药店(2.1.0改为健康方案)
        {
//            附近药店
//            NearMapViewController * nearStore = [[NearMapViewController alloc] init];
//            nearStore.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:nearStore animated:YES];
            
//            健康方案
            HealthyScenarioViewController * healthyScenario = [[HealthyScenarioViewController alloc] init];
            healthyScenario.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:healthyScenario animated:YES];
        }
            break;
        case 10005://品牌展示
        {
            //[MobClick event:@"SC-changjiazhanshi"];
            FactoryListViewController *vc = [[FactoryListViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
            break;
        default:
            break;
    }

}

- (void)setUpRightBarButton{
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"扫码.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarButtonClick)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (void)rightBarButtonClick{
    
    ScanReaderViewController *scanReaderViewController = [[ScanReaderViewController alloc] initWithNibName:@"ScanReaderViewController" bundle:nil];
    scanReaderViewController.useType = 1;
    scanReaderViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scanReaderViewController animated:YES];
}

- (void)setupSearchBar{
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, APP_W, 44)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @" 搜索药品/疾病/症状";
    [self.view addSubview:self.searchBar];
}

- (void)setUpTextfield{
    UIImageView * bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, APP_W-20, 40)];
    bgImageView.userInteractionEnabled = YES;
    bgImageView.image = [UIImage imageNamed:@"重置密码_输入验证码_输入框.png"];
    [self.view addSubview:bgImageView];
    UIImage * image = [UIImage imageNamed:@"快速自查_搜索icon.png"];
    
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, APP_W-60, 20)];
    [bgImageView addSubview:self.textField];
    self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.placeholder = @" 搜索药品/疾病/症状";
    self.textField.font = [UIFont systemFontOfSize:15];
    self.textField.delegate = self;
    
    UIImageView * rightView = [[UIImageView alloc]initWithFrame:CGRectMake(self.textField.frame.origin.x + self.textField.frame.size.width , 10, image.size.width, image.size.height)];
    rightView.image = image;
    [bgImageView addSubview:rightView];
    [self.view addSubview:bgImageView];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    SearchSliderViewController * searchViewController = [[SearchSliderViewController alloc] init];
    searchViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewController animated:NO];
    return NO;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    SearchSliderViewController * searchViewController = [[SearchSliderViewController alloc] init];
    searchViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewController animated:NO];
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.searchBar resignFirstResponder];
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

@implementation MyTapGestureRecognizer


@end
