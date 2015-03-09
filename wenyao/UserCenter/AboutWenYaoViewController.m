//
//  AboutWenYaoViewController.m
//  wenyao
//
//  Created by Meng on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "AboutWenYaoViewController.h"
#import "FeedbackViewController.h"
#import "MBProgressHUD+Add.h"
#import "SVProgressHUD.h"
#import "ServeInfoViewController.h"
#import "introductionViewController.h"
#import "AppDelegate.h"
#import "HelpInstructViewController.h"
#import "ReturnIndexView.h"

@interface AboutWenYaoViewController ()<UIAlertViewDelegate,ReturnIndexViewDelegate>

@property (nonatomic ,strong) NSArray * titleArray;
@property (nonatomic ,strong) NSString *strDownload;
@property (nonatomic, strong) ReturnIndexView *indexView;
@property (nonatomic ,strong) UILabel *lblVersion;
@property (nonatomic ,strong) UIView *viewNewVersion;

@end

@implementation AboutWenYaoViewController

- (id)init{
    if (self = [super init]) {
        self.title = @"关于问药";
        if (iOSv7 && self.view.frame.origin.y==0) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = NO;
        }
        self.tableView.frame = CGRectMake(0, 0, APP_W, APP_H - NAV_H);
        
        UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 190)];
        topView.backgroundColor = [UIColor whiteColor];
        
        UIImageView * topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(120, 40, 80, 80)];
        topImageView.layer.masksToBounds = YES;
        topImageView.layer.cornerRadius = 10;
        topImageView.image = [UIImage imageNamed:@"80-80.png"];
        [topView addSubview:topImageView];
        
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, topImageView.frame.origin.y + topImageView.frame.size.height + 10, APP_W, 20)];
        titleLabel.text = @"问药";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = FontB(20);
        [topView addSubview:titleLabel];
        
        UILabel * versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 5, APP_W, 16)];
        versionLabel.text = [NSString stringWithFormat:@"%@",APP_VERSION];
        versionLabel.textAlignment = NSTextAlignmentCenter;
        versionLabel.font = Font(14);
        [topView addSubview:versionLabel];
        
        UILabel * line = [[UILabel alloc] initWithFrame:CGRectMake(0, 189, APP_W, 0.5)];
        line.backgroundColor = UIColorFromRGB(0xdbdbdb);
        [topView addSubview:line];
        

        
        self.tableView.tableHeaderView = topView;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.rowHeight = 44;
        self.tableView.scrollEnabled = YES;
        self.titleArray = @[@"功能介绍",@"检查版本",@"给好评",@"意见反馈",@"用户协议",@"帮助指导"];
        
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.titleArray.count;
}

- (NSInteger)getIntValueFromVersionStr:(NSString *)strVersion
{
    NSArray *arrVer = [strVersion componentsSeparatedByString:@"."];
    NSString *strVer = [arrVer componentsJoinedByString:@""];
    NSInteger intVer = [strVer integerValue];
    return intVer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellIdentifier = @"cellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = Font(14);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, APP_W, 0.5)];
        line.backgroundColor = UIColorFromRGB(0xdbdbdb);
        [cell addSubview:line];
        
        if (indexPath.row == 5) {
            UILabel *redTipImage = [[UILabel alloc]initWithFrame:CGRectMake(80, 15, 22, 15)];
            redTipImage.backgroundColor = [UIColor redColor];
            redTipImage.tag = 1009;
            redTipImage.hidden = YES;
            redTipImage.layer.cornerRadius = 5.0;
            redTipImage.layer.masksToBounds = YES;
            redTipImage.text = @"new";
            redTipImage.font = [UIFont systemFontOfSize:11];
            redTipImage.textColor = [UIColor whiteColor];
            [cell.contentView addSubview:redTipImage];

        }
        
    }
    if (indexPath.row == 1) {
        cell.accessoryType = UITableViewCellAccessoryNone;

        if (self.lblVersion == nil) {
            self.lblVersion = [[UILabel alloc] initWithFrame:CGRectMake(200, 13, 100, 21)];
            self.lblVersion.textAlignment = NSTextAlignmentRight;
            self.lblVersion.font = [UIFont systemFontOfSize:13];
            self.lblVersion.textColor = [UIColor darkGrayColor];
            [cell.contentView addSubview:self.lblVersion];
        }
        
        if (self.viewNewVersion == nil) {
            self.viewNewVersion = [[UIView alloc] initWithFrame:CGRectMake(300, 13, 10, 10)];
            self.viewNewVersion.backgroundColor = [UIColor redColor];
            self.viewNewVersion.layer.cornerRadius = 5.0f;
            self.viewNewVersion.layer.masksToBounds = YES;
            [cell.contentView addSubview:self.viewNewVersion];
        }
        
        NSInteger intAppVersion = [self getIntValueFromVersionStr:APP_VERSION];
        NSInteger intSysVersion = [self getIntValueFromVersionStr:[[NSUserDefaults standardUserDefaults] objectForKey:APP_LAST_SYSTEM_VERSION]];
        if (intAppVersion < intSysVersion) {
            
            self.lblVersion.text = @"发现新版本";
            self.viewNewVersion.hidden = NO;
            
        } else {
            self.lblVersion.text = @"已是最新版本";
            self.viewNewVersion.hidden = YES;
        }
        
    }else if (indexPath.row == 5){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UILabel *redTipImage = (UILabel *)[cell.contentView viewWithTag:1009];
        
        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"BeRead"];
        if ([str isEqualToString:@"1"]) {
            redTipImage.hidden = YES;
        }else
        {
            redTipImage.hidden = NO;
        }
    }
    else
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = self.titleArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0)//功能介绍
    {
        introductionViewController *viewControllerIntro = [[introductionViewController alloc] init];
        [self.navigationController pushViewController:viewControllerIntro animated:YES];
//#warning need change
//        ServeInfoViewController * serverInfo = [[ServeInfoViewController alloc] init];
//        serverInfo.webRequestType = WebRequestTypeFunctionIntroduce;
//        [self.navigationController pushViewController:serverInfo animated:YES];
    }else if (indexPath.row == 1)//检查更新
    {
        [MBProgressHUD showMessag:@"正在检查更新..." toView:self.view];
        __weak AboutWenYaoViewController *weakSelf = self;
        [[HTTPRequestManager sharedInstance] queryLastVersion:@{@"versionCode":APP_VERSION,
                                                                @"type":@"2"} completionSuc:^(id resultObj) {
                                                                    [MBProgressHUD hideHUDForView:nil animated:NO];
                                                                    
                                                                    NSDictionary *dicReturn = resultObj[@"body"];
                                                                    if (![resultObj[@"result"] isEqualToString:@"OK"]) {
                                                                        [MBProgressHUD hideHUDForView:self.view animated:NO];
                                                                        [SVProgressHUD showSuccessWithStatus:resultObj[@"msg"] duration:0.8f];
                                                                        self.lblVersion.text = @"已是最新版本";
                                                                        self.viewNewVersion.hidden = YES;
                                                                    } else {
                                                                        [MBProgressHUD hideHUDForView:self.view animated:NO];
                                                                        self.lblVersion.text = @"发现新版本";
                                                                        self.viewNewVersion.hidden = NO;
                                                                        self.strDownload = dicReturn[@"downloadUrl"];
//                                                                        NSString *strAlertMessage = [NSString stringWithFormat:@"版本号: %@    大小: %@ \n%@",dicReturn[@"versionName"], dicReturn[@"size"], dicReturn[@"updateLog"]];
                                                                        NSString *strAlertMessage = [NSString stringWithFormat:@"版本号: %@ \n%@",dicReturn[@"versionName"], dicReturn[@"updateLog"]];

                                                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"检测到新版本" message:strAlertMessage delegate:weakSelf cancelButtonTitle:@"暂不升级" otherButtonTitles:@"立即更新", nil];
                                                                        alertView.tag = 10000;
                                                                        [alertView show];
                                                                    }
                                                                    
                                                                } failure:^(id failMsg) {
                                                                    [MBProgressHUD hideHUDForView:self.view animated:NO];
                                                                    NSLog(@"fail");
                                                                }];
    }else if (indexPath.row == 2)//给好评
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/wen-yao-bi-yi-sheng-geng-dong/id901262090?mt=8"]];
    }else if (indexPath.row == 3)//意见反馈
    {
        FeedbackViewController * feedback = [[FeedbackViewController alloc] initWithNibName:@"FeedbackViewController" bundle:nil];
        [self.navigationController pushViewController:feedback animated:YES];
    }else if (indexPath.row == 4)//用户协议
    {
        if (app.currentNetWork != NotReachable) {
            ServeInfoViewController * serverInfo = [[ServeInfoViewController alloc] init];
            serverInfo.webRequestType = WebRequestTypeUserProtocol;
            [self.navigationController pushViewController:serverInfo animated:YES];
        } else {
            [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
            
            return;
        }
        
    }else if (indexPath.row == 5)//帮助指导
    {
        if (app.currentNetWork != kNotReachable) {
            HelpInstructViewController *helpVC = [[HelpInstructViewController alloc] init];
            [self.navigationController pushViewController:helpVC animated:YES];
        }else
        {
            [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
            return;
        }
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10000) {
        if (buttonIndex == 0) {
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.strDownload]];
        }
    }
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
