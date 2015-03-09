//
//  CommendSuccessViewController.m
//  wenyao
//
//  Created by qwyf0006 on 15/2/12.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "CommendSuccessViewController.h"
#import "ReturnIndexView.h"
#import "AppDelegate.h"

@interface CommendSuccessViewController ()<ReturnIndexViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *commendLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (strong, nonatomic) ReturnIndexView *indexView;

@end

@implementation CommendSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    self.title = @"我的推荐人";
    self.commendLabel.textColor = UIColorFromRGB(0x333333);
    self.tipsLabel.text = @"1.您已经填写了推荐人信息，谢谢合作！\n2.将问药app推荐给您身边的朋友，年终有机会拿到我们的小礼品哦！";
    self.tipsLabel.textColor = UIColorFromRGB(0x45c01a);
    self.phoneNumber.text = self.phoneStr;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:13],NSParagraphStyleAttributeName:paragraphStyle};
    self.tipsLabel.attributedText = [[NSAttributedString alloc] initWithString:self.tipsLabel.text attributes:attributes];
    
    self.tempLabel.textColor = UIColorFromRGB(0x999999);
    self.phoneNumber.textColor = UIColorFromRGB(0x999999);
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
