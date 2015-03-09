//
//  HelpInstructViewController.m
//  wenyao
//
//  Created by qwyf0006 on 15/2/3.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "HelpInstructViewController.h"
#import "Constant.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "Constant.h"
#import "ReturnIndexView.h"

@interface HelpInstructViewController ()<UIWebViewDelegate,ReturnIndexViewDelegate>

@property (strong ,nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (strong, nonatomic) ReturnIndexView *indexView;

@end

@implementation HelpInstructViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"帮助指导";
    
    //已经阅读
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"BeRead"];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, APP_W, APP_H - NAV_H)];
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];

    NSURL *url = [NSURL URLWithString:HelpInstructWebView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-40)/2, 130, 40, 40)];
    [self.view addSubview:self.indicatorView];
    self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
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

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.indicatorView stopAnimating];
    [SVProgressHUD showErrorWithStatus:@"网络未连接，请稍后重试！" duration:0.8];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
