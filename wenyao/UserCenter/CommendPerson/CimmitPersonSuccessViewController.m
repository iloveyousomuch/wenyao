//
//  CimmitPersonSuccessViewController.m
//  wenyao
//
//  Created by qwyf0006 on 15/2/12.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "CimmitPersonSuccessViewController.h"
#import "QZMyCenterViewController.h"
#import "ReturnIndexView.h"
#import "AppDelegate.h"

@interface CimmitPersonSuccessViewController ()<ReturnIndexViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *completeButton;
@property (weak, nonatomic) IBOutlet UILabel *successLabel;
@property (strong ,nonatomic) ReturnIndexView *indexView;

- (IBAction)completeAction:(id)sender;

@end

@implementation CimmitPersonSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    self.title = @"提交成功";
    self.successLabel.textColor = UIColorFromRGB(0x45c01a);
    [self.completeButton setTitleColor:UIColorFromRGB(0x45c01a) forState:UIControlStateNormal];
    self.completeButton.layer.borderColor = UIColorFromRGB(0x45c01a).CGColor;
    self.completeButton.layer.borderWidth = 1;
    self.completeButton.layer.cornerRadius = 2.0;
    self.completeButton.layer.masksToBounds = YES;
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
- (void)backToPreviousController:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (IBAction)completeAction:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
