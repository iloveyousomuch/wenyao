//
//  HealthDetailViewController.m
//  wenyao
//
//  Created by Meng on 14-10-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "HealthDetailViewController.h"
#import "UIViewController+isNetwork.h"
#import "ReturnIndexView.h"
#import "AppDelegate.h"

@interface HealthDetailViewController ()<ReturnIndexViewDelegate>
{
    NSURL *url;
}
@property (nonatomic ,strong) UIWebView * webView;
@property (nonatomic ,strong) ReturnIndexView *indexView;

@end

@implementation HealthDetailViewController

- (id)init{
    if (self = [super init]) {
        self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H)];
        self.webView.backgroundColor = UIColorFromRGB(0xffffff);
        self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 10, 0, 10);
        [self.view addSubview:self.webView];
        UIScrollView * s = self.webView.scrollView;
        s.showsHorizontalScrollIndicator = NO;
        s.showsVerticalScrollIndicator = NO;
        //[s setContentSize:CGSizeMake(APP_W, APP_H-NAV_H)];
        self.view.backgroundColor = UIColorFromRGB(0xecf0f1);
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"html = %@",self.htmlUrl);
    self.webView.scalesPageToFit = YES;
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
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    url = [NSURL URLWithString:self.htmlUrl];
    if([self isNetWorking]){
        [self addNetView];
        return;
    }
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)BtnClick{
    
    if(![self isNetWorking]){
        for(UIView *v in [self.view subviews]){
            if(v.tag == 999){
                [v removeFromSuperview];
            }
        }
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
    
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
