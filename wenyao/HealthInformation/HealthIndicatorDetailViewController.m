//
//  HealthIndicatorDetailViewController.m
//  quanzhi
//
//  Created by xiezhenghong on 14-7-3.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "HealthIndicatorDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "HTTPRequestManager.h"
#import "Constant.h"
#import "AppDelegate.h"
#import "UMSocial.h"
#import "Constant.h"
#import "LoginViewController.h"
#import "UIViewController+isNetwork.h"
#import "SVProgressHUD.h"
#import "ReturnIndexView.h"

@interface HealthIndicatorDetailViewController ()<UMSocialUIDelegate,UMSocialDataDelegate,NSURLSessionDelegate,ReturnIndexViewDelegate>
@property (strong, nonatomic) ReturnIndexView *indexView;
@end

@implementation HealthIndicatorDetailViewController

- (id)init
{
    if (self = [super init])
    {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void) getHealthIndicatorDetails:(NSString *)strMessage
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL * url = [NSURL URLWithString:strMessage];
    __weak HealthIndicatorDetailViewController *weakSelf = self;
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithURL:url
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        
                                                        if(error == nil)
                                                        {
                                                            NSString * text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                            [weakSelf.webView loadHTMLString:text baseURL:nil];
                                                            [SVProgressHUD dismiss];
                                                        } else {
                                                            [SVProgressHUD dismissWithError:@"加载失败"];
                                                        }
                                                    }];
    [dataTask resume];
    
}

- (void)setupUI
{
    if(self.infoDict[@"readNum"] == nil) {
        self.infoDict[@"readNum"] = @"0";
    }
    if(self.infoDict[@"pariseNum"] == nil) {
        self.infoDict[@"pariseNum"] = @"0";
    }
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    CGSize size = [self.infoDict[@"title"] sizeWithFont:[UIFont systemFontOfSize:20.0] constrainedToSize:CGSizeMake(APP_W - 20, 2000)];
    self.titleLabel.font = Font(20.0f);
    self.titleLabel.text = self.infoDict[@"title"];
    self.titleLabel.numberOfLines = 0;
                   self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y, APP_W - 20, size.height);
    
    [self.imageView setImageWithURL:[NSURL URLWithString:self.infoDict[@"imgUrl"]] placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
    if ([self.infoDict[@"source"] length] > 0) {
        self.sourceLabel.text = [NSString stringWithFormat:@"来源: %@",self.infoDict[@"source"]];
    } else {
        self.sourceLabel.text = @"";
    }
    
    self.dateLabel.frame = CGRectMake(self.dateLabel.frame.origin.x,self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 6, self.dateLabel.frame.size.width, self.dateLabel.frame.size.height);
    self.dateLabel.text = [self.infoDict[@"publishTime"] substringToIndex:10];
    self.readLabel.text = [NSString stringWithFormat:@"%@",self.infoDict[@"readNum"]];
    if ([self.infoDict[@"pariseNum"] intValue]>99) {
        self.praiseLabel.text = [NSString stringWithFormat:@"99+"];
    } else {
        self.praiseLabel.text = [NSString stringWithFormat:@"%@",self.infoDict[@"pariseNum"]];
    }
    self.eyeImageView.frame = CGRectMake(self.eyeImageView.frame.origin.x, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 6, self.eyeImageView.frame.size.width, self.eyeImageView.frame.size.height);
    self.readLabel.frame = CGRectMake(self.readLabel.frame.origin.x, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 6, self.readLabel.frame.size.width, self.readLabel.frame.size.height);
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(20, self.dateLabel.frame.origin.y + self.dateLabel.frame.size.height + 8, APP_W - 40, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [self.scrollView addSubview:line];
    
    self.webView.frame = CGRectMake(0, line.frame.origin.y + 5, APP_W, APP_H - line.frame.origin.y - 44);
    
//    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"分享icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(shareClick:)];
//    self.navigationItem.rightBarButtonItem = shareButton;
    [self setUpRightItem];

    NSString *strParameter = [NSString stringWithFormat:@"?adviceId=%@",self.infoDict[@"adviceId"]];
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",QueryHealthAdviceContent,strParameter];
    [self getHealthIndicatorDetails:strUrl];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]]];
    self.webView.scrollView.scrollEnabled = NO;
    self.footerView.frame = CGRectMake(0, self.view.frame.size.height - 40, APP_W, 40);
    [self addReadNumber];
    if (app.logStatus) {
        [self checkCollect];
        [self checkPraise];
    } else {
        self.collectLabel.text = @"收藏";
        self.collectImage.image = [UIImage imageNamed:@"健康资讯详情页_收藏icon.png"];
        self.praiseImage.tag = 0;
        self.praiseImage.image = [UIImage imageNamed:@"健康资讯详情页_赞icon.png"];
    }

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
    self.indexView = [ReturnIndexView sharedManagerWithImage:@[@"icon home.PNG",@"icon share.PNG"] title:@[@"首页",@"分享"]];
    self.indexView.delegate = self;
    [self.indexView show];
}
- (void)RetunIndexView:(ReturnIndexView *)ReturnIndexView didSelectedIndex:(NSIndexPath *)indexPath
{
    [self.indexView hide];
    if (indexPath.row == 0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self performSelector:@selector(delayPopToHome) withObject:nil afterDelay:0.01];
    }else if (indexPath.row == 1){
        [self shareClick];
    }
    
}
- (void)delayPopToHome
{
    [app.tabBarController setSelectedIndex:0];
}
#pragma mark---------------------------------------------跳转到首页-----------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"健康资讯";
    if([self isNetWorking]){
        [self addNetView];
        return;
    }
    [self subViewDidLoad];
}

- (void)BtnClick{
    
    if(![self isNetWorking]){
        for(UIView *v in [self.view subviews]){
            if(v.tag == 999){
                [v removeFromSuperview];
            }
        }
        [self subViewDidLoad];
    }
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

- (void)subViewDidLoad{
    [SVProgressHUD showWithStatus:@"正在加载中"];
    if (self.intFromBanner == 0) {
        [self setupUI];
    } else {
        NSDictionary *dicAdvice = @{@"adviceId":self.guideId};
        [[HTTPRequestManager sharedInstance] getHealthAdviceInfo:dicAdvice completion:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                self.infoDict = [resultObj[@"body"] mutableCopy];
                [self setupUI];
            } else {
                [SVProgressHUD dismissWithError:@"加载失败"];
            }
        } failure:^(NSError *error) {
            [SVProgressHUD dismissWithError:@"加载失败"];
        }];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hadLoginSuccess) name:LOGIN_SUCCESS object:nil];
    
    self.webView.backgroundColor = [UIColor whiteColor];
}

- (void)shareClick
{
    NSString *htmlUrl = THEME_URL(self.infoDict[@"adviceId"]);
    
    NSLog(@"分享链接 = %@",htmlUrl);
    [app initsocailShare:htmlUrl];
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:UMENG_KEY
                                      shareText:self.infoDict[@"title"]
                                     shareImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.infoDict[@"imgUrl"]]]]
                                shareToSnsNames:@[UMShareToWechatTimeline,UMShareToWechatSession,UMShareToQQ,UMShareToSina]
                                       delegate:self];
    
}

- (void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{
    NSLog(@"platformName = %@  socialData = %@",platformName,socialData);
    
    NSString *htmlUrl = THEME_URL(self.infoDict[@"adviceId"]);
    socialData.shareText = nil;
    socialData.shareImage = nil;
    //短信、qq好友
    if (platformName == UMShareToQQ) {
        [UMSocialData defaultData].extConfig.smsData.shareImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.infoDict[@"imgUrl"]]]];
        [UMSocialData defaultData].extConfig.smsData.shareText = [NSString stringWithFormat:@"我在全维药事手机客户端分享了信息《%@》%@ 手机客户端下载%@",self.infoDict[@"title"],htmlUrl,APP_DOWNLOAD];
        [UMSocialData defaultData].extConfig.qqData.shareImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.infoDict[@"imgUrl"]]]];
        [UMSocialData defaultData].extConfig.qqData.shareText = [NSString stringWithFormat:@"我在全维药事手机客户端分享了信息《%@》%@ 手机客户端下载%@",self.infoDict[@"title"],htmlUrl,APP_DOWNLOAD];
        //微信
    }else if (platformName == UMShareToWechatSession){
        [UMSocialData defaultData].extConfig.wechatSessionData.title = self.infoDict[@"title"];
        [UMSocialData defaultData].extConfig.wechatSessionData.shareText = self.infoDict[@"introduction"];
        socialData.shareImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.infoDict[@"imgUrl"]]]];
    }//微信朋友圈
    else if (platformName == UMShareToWechatTimeline){
        [UMSocialData defaultData].extConfig.wechatTimelineData.title = self.infoDict[@"title"];
        socialData.shareImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.infoDict[@"imgUrl"]]]];
        //新浪微博、腾讯微博 self.infoDict[@"htmlUrl"]
    }else if (platformName == UMShareToSina) {
        socialData.shareText = [NSString stringWithFormat:@"我在全维药事手机客户端分享了信息《%@》%@ 手机客户端下载%@",self.infoDict[@"title"],htmlUrl,APP_DOWNLOAD];
        socialData.shareImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.infoDict[@"imgUrl"]]]];
        //其他分享平台
    }
    
}
//分享成功回调
- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    NSLog(@"share success = %@",response);
    if (response.responseCode == UMSResponseCodeSuccess)//分享成功
    {
        [[HTTPRequestManager sharedInstance] shareAdvice:@{@"adviceId":self.infoDict[@"adviceId"]} completeionSuc:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                NSLog(@"sever Machine share count +1 = %@",resultObj);
            }
        } failure:^(id failMsg) {
            NSLog(@"%@",failMsg);
        }];
    }
}

- (IBAction)prasieOnce:(id)sender
{
    if (app.logStatus) {
        NSMutableDictionary *setting = [NSMutableDictionary dictionaryWithCapacity:10];
        setting[@"adviceId"] = self.infoDict[@"adviceId"];
        setting[@"token"] = app.configureList[APP_USER_TOKEN];
        __weak HealthIndicatorDetailViewController *weakSelf = self;
        if(self.praiseImage.tag == 0) {
            [[HTTPRequestManager sharedInstance] praiseAdvice:setting completion:^(id resultObj) {
                if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                    NSUInteger count = [self.infoDict[@"pariseNum"] intValue];
                    count++;
                    weakSelf.infoDict[@"pariseNum"] = [NSString stringWithFormat:@"%d",count];
                    weakSelf.praiseLabel.text = [NSString stringWithFormat:@"%d",count];
                    weakSelf.praiseImage.image = [UIImage imageNamed:@"健康资讯详情页_已赞icon.png"];
                    weakSelf.praiseImage.tag = 1;
                    [UIView animateWithDuration:0.5 animations:^{
                        weakSelf.praiseImage.transform = CGAffineTransformMakeScale(1.5, 1.5);
                    } completion:^(BOOL finished) {
                        weakSelf.praiseImage.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    }];
                    if (weakSelf.intFromBanner == 0) {
                        
                    } else {
                        [weakSelf.infoList.tableView reloadData];
                    }
                }
            } failure:NULL];
        }else{
            [[HTTPRequestManager sharedInstance] cancelPraiseAdvice:setting completion:^(id resultObj) {
                if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                    NSInteger count = [self.infoDict[@"pariseNum"] intValue];
                    count--;
                    weakSelf.infoDict[@"pariseNum"] = [NSString stringWithFormat:@"%d",count];
                    weakSelf.praiseLabel.text = [NSString stringWithFormat:@"%d",count];
                    weakSelf.praiseImage.image = [UIImage imageNamed:@"健康资讯详情页_赞icon.png"];
                    weakSelf.praiseImage.tag = 0;
                    [UIView animateWithDuration:0.5 animations:^{
                        weakSelf.praiseImage.transform = CGAffineTransformMakeScale(1.5, 1.5);
                    } completion:^(BOOL finished) {
                        weakSelf.praiseImage.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    }];
                    if (weakSelf.intFromBanner == 0) {
                        
                    } else {
                        [weakSelf.infoList.tableView reloadData];
                    }
                }
            } failure:NULL];
        }
    } else {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
    }
}

- (void)addReadNumber
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionaryWithCapacity:10];
    setting[@"adviceId"] = self.infoDict[@"adviceId"];
//    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    __weak HealthIndicatorDetailViewController *weakSelf = self;
    
    [[HTTPRequestManager sharedInstance] readAdvice:setting completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            NSInteger count = [weakSelf.infoDict[@"readNum"] intValue];
            count++;
            [weakSelf.infoDict setObject:[NSString stringWithFormat:@"%d",count] forKey:@"readNum"];
            weakSelf.readLabel.text = [NSString stringWithFormat:@"%d",count];
            if (weakSelf.intFromBanner == 0) {
                
            } else {
                [weakSelf.infoList.tableView reloadData];
            }
        }
    } failure:NULL];
}

- (IBAction)collectClick:(id)sender
{
    if (app.logStatus) {
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        setting[@"token"] = app.configureList[APP_USER_TOKEN];
        setting[@"objId"] = self.infoDict[@"adviceId"];
        setting[@"objType"] = [NSNumber numberWithInt:5];
        
        if([self.collectLabel.text isEqualToString:@"收藏"]){
            setting[@"method"] = @"2";
        }else{
            setting[@"method"] = @"3";
        }
        [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
            if([resultObj[@"result"] isEqualToString:@"OK"]) {
                if([self.collectLabel.text isEqualToString:@"收藏"]){
                    self.collectLabel.text = @"已收藏";
                    self.collectImage.image = [UIImage imageNamed:@"健康资讯详情页_已收藏icon.png"];
                }else{
                    self.collectLabel.text = @"收藏";
                    self.collectImage.image = [UIImage imageNamed:@"健康资讯详情页_收藏icon.png"];
                }
            }else{
                
            }
        } failure:NULL];
    } else {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
        return;
    }
}

- (void)checkPraise
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"adviceId"] = self.infoDict[@"adviceId"];
    __weak HealthIndicatorDetailViewController *weakSelf = self;
    [[HTTPRequestManager sharedInstance] checkPraiseAdvice:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]){
            NSUInteger count = [resultObj[@"body"][@"returnVal"] intValue];
            if(count == 0) {
                weakSelf.praiseImage.tag = 0;
                weakSelf.praiseImage.image = [UIImage imageNamed:@"健康资讯详情页_赞icon.png"];

            }else{
                weakSelf.praiseImage.tag = 1;
                weakSelf.praiseImage.image = [UIImage imageNamed:@"健康资讯详情页_已赞icon.png"];

            }
        }
    } failure:NULL];
    
}


- (IBAction)checkCollect
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"objId"] = self.infoDict[@"adviceId"];
    setting[@"method"] = @"1";
    setting[@"objType"] = @"5";
    [[HTTPRequestManager sharedInstance] favoriteCollect:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]){
            NSUInteger likeCount = [resultObj[@"body"][@"result"] integerValue];
            if(likeCount == 0) {
                self.collectLabel.text = @"收藏";
                self.collectImage.image = [UIImage imageNamed:@"健康资讯详情页_收藏icon.png"];
            }else{
                self.collectLabel.text = @"已收藏";
                self.collectImage.image = [UIImage imageNamed:@"健康资讯详情页_已收藏icon.png"];
            }
        }else{
            
        }
    } failure:NULL];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGRect rect = webView.frame;
    rect.size = [webView scrollView].contentSize;
    
    webView.frame = rect;
    self.sourceLabel.frame = CGRectMake(self.sourceLabel.frame.origin.x, webView.frame.origin.y+webView.frame.size.height + 5.0f, self.sourceLabel.frame.size.width, self.sourceLabel.frame.size.height);

    //self.footerView.frame = rect;
    self.scrollView.contentSize = CGSizeMake(APP_W, rect.origin.y + rect.size.height + 30.0f);
}

- (void)hadLoginSuccess
{
    [self checkPraise];
    [self checkCollect];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    [self.webView stopLoading];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
