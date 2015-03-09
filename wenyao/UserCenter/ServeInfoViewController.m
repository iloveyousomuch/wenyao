//
//  ServeInfoViewController.m
//  wenyao
//
//  Created by Meng on 14-9-30.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "ServeInfoViewController.h"
#import "Constant.h"
#import "AppDelegate.h"
#import "ReturnIndexView.h"

@interface ServeInfoViewController ()<UIWebViewDelegate,ReturnIndexViewDelegate>

@property (nonatomic ,strong) UIWebView * webView;
@property (nonatomic ,strong) ReturnIndexView *indexView;

@end

@implementation ServeInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
        
    }
    return self;
}

- (id)init{
    if (self = [super init]) {
        
        if (iOSv7 && self.view.frame.origin.y==0) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = NO;
        }
        
       
        //self.webView.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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


- (void)setWebRequestType:(WebRequestType)webRequestType
{
    _webRequestType = webRequestType;
    
    /*
     
     问药用户端--隐私保护	http://xxxxx/app/helpClass/yhysbh
     问药用户端--法律声明	http://xxxxx/app/helpClass/yhflsm
     
     问药用户端--功能介绍	http://xxxxx/app/helpClass/yhgnjs
     问药用户端--关于问药	http://xxxxx/app/helpClass/yhgywy
     问药用户端—-服务条款	http://xxxxx/app/helpClass/hyfwtk
     
     */
    
    NSString * str = nil;
    switch (webRequestType) {
        case WebRequestTypeServeClauses://服务条款
        {
            str = @"helpClass/yhfwtk";
            self.title = @"用户协议";
        }
            break;
        case WebRequestTypeFunctionIntroduce://功能介绍
        {
            str = @"helpClass/yhgnjs";
            self.title = @"功能介绍";
        }
            break;
        case WebRequestTypeUserProtocol://用户协议
        {
            str = @"helpClass/yhyhxy";
            self.title = @"用户协议";
        }
            break;
        case WebRequestTypeAboutWenyao://关于问药
        {
            str = @"helpClass/yhgnjs";
            self.title = @"关于问药";
        }
            break;
            
        default:
            break;
    }
    NSString * url = myFormat(@"%@%@",BASE_URL_V2,str);
    NSLog(@"url = %@",url);
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, APP_W, APP_H - NAV_H)];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.delegate = self;
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
