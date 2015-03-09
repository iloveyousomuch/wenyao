//
//  AppDelegate.m
//  wenyao
//
//  Created by xiezhenghong on 14-9-1.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "AppDelegate.h"
#import "Constant.h"
#import "XHDemoWeChatMessageTableViewController.h"
#import "HomePageViewController.h"
#import "QuickSearchViewController.h"
#import "HealthInformationViewController.h"
#import "UserCenterViewController.h"
#import "XMPPManager.h"
#import "XMPPLogging.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "LoginViewController.h"
#import "RemindAlarmViewController.h"
#import "HTTPRequestManager.h"
#import "XHMessageBubbleFactory.h"
#import "XHAudioPlayerHelper.h"
#import "AppGuide.h"
#import "SVProgressHUD.h"
#import "UMSocial.h"
#import "UMSocialSinaHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
#import "SBJson.h"
#import "MobClick.h"
#import "NewHomePageViewController.h"
#import "QZMyCenterViewController.h"
#import "Location.h"
#import "MessageBoxViewController.h"

AppDelegate *app = nil;

@implementation AppDelegate
@synthesize tabBarController;
@synthesize pullMessageTimer;

- (void)initNavigationBarStyle
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarTintColor:APP_COLOR_STYLE];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   [APP_COLOR_STYLE CGColor]);
    CGContextFillRect(context, rect);
    UIImage * imge = [[UIImage alloc] init];
    imge = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [[UINavigationBar appearance] setBackgroundImage:imge forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    /*
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarTintColor:APP_COLOR_STYLE];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
//    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
//    UIImage* banImage = [UIImage imageNamed:@"mainHeadBack.png"];
//    [[UINavigationBar appearance] setBackgroundImage:banImage forBarMetrics:UIBarMetricsDefault];
     */
}

//根据用户名初始化配置信息
- (void)initDataSource:(NSString *)username
{
    NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"Documents/%@",username]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:homePath]){
        [fileManager createDirectoryAtPath:homePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [self loadAppConfigure:homePath];
    _dataBase = [[DataBase alloc] initWithPath:homePath];
    [_dataBase createAllTable];
}

//根据当前登陆的账号,保存配置信息
- (void)saveAppConfigure
{
    if([self.configureList[APP_USERNAME_KEY] isEqualToString:APP_EMPTY_STRING])
        return;
    NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"Documents/%@/configure.plist",self.configureList[APP_USERNAME_KEY]]];
    BOOL result = [self.configureList writeToFile:homePath atomically:YES];
    if(result)
    {
        
        [[NSUserDefaults standardUserDefaults] setObject:self.configureList[APP_USERNAME_KEY] forKey:APP_USERNAME_KEY];
        //end;
    }
}

- (void)loadAppConfigure:(NSString *)documentsDirectory
{
    NSString *homePath = [documentsDirectory stringByAppendingString:@"/configure.plist"];
    
    self.configureList = [[NSMutableDictionary alloc] initWithContentsOfFile:homePath];
    
    if(!_configureList)
    {
        _configureList = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                         APP_EMPTY_STRING,       APP_USERNAME_KEY,
                         APP_EMPTY_STRING,       APP_PASSWORD_KEY,
                          APP_EMPTY_STRING,     APP_BEST_NAME,
                         nil];
    }
    if([self.configureList[APP_USER_TOKEN] isEqualToString:APP_EMPTY_STRING])
        self.logStatus = NO;
    else
        self.logStatus = YES;
}

- (NSString *)updateDisplayTime:(NSDate *)date
{
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:date];
    NSDateComponents *todayComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:today];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm "];
    NSString *staicString = [dateFormatter stringFromDate:date];
    NSString *dynamicString = nil;
    if (dateComponents.year == todayComponents.year && dateComponents.month == todayComponents.month && dateComponents.day == todayComponents.day)
    {
        dynamicString = @"";
    }else if ((dateComponents.year == todayComponents.year) && (dateComponents.month == todayComponents.month) && (dateComponents.day == todayComponents.day - 1)) {
        dynamicString = NSLocalizedString(@"昨天", nil);
    }else if ((dateComponents.year == todayComponents.year) && (dateComponents.weekOfYear == todayComponents.weekOfYear)) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"EEEE";
        dynamicString = [dateFormatter stringFromDate:date];
        dynamicString = NSLocalizedString(dynamicString, nil);
    }else if (dateComponents.year == todayComponents.year){
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM-dd";
        dynamicString = [dateFormatter stringFromDate:date];
    }else{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        dynamicString = [dateFormatter stringFromDate:date];
    }
    return [NSString stringWithFormat:@" %@ %@",dynamicString,staicString];
}

- (NSString *)updateFirstPageTimeDisplayer:(NSDate *)date{
    
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:date];
    NSDateComponents *todayComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfYearCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:today];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm "];
    NSString *staicString = [dateFormatter stringFromDate:date];
    NSString *dynamicString = nil;
    if (dateComponents.year == todayComponents.year && dateComponents.month == todayComponents.month && dateComponents.day == todayComponents.day){
        dynamicString = @"";
    }else if ((dateComponents.year == todayComponents.year) && (dateComponents.month == todayComponents.month) ) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM-dd";
        dynamicString = [dateFormatter stringFromDate:date];
        return dynamicString;
    }else if (dateComponents.year == todayComponents.year){
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM-dd";
        dynamicString = [dateFormatter stringFromDate:date];
        return dynamicString;
    }else{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        dynamicString = [dateFormatter stringFromDate:date];
        return dynamicString;
    }
    return [NSString stringWithFormat:@" %@ %@",dynamicString,staicString];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSUInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    if (index == 2)
    {
        if (app.dataBase) {
            BOOL hasRedPoint = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_NewDisease",_configureList[APP_PASSPORTID_KEY]]] boolValue];
            if (hasRedPoint) {
                [[NSNotificationCenter defaultCenter] postNotificationName:APP_SELECT_INDEX_DISEASE object:nil];
                self.needShowBadge = YES;
            } else {
                self.needShowBadge = NO;
            }
        }
        
        [self showDiseaseBudge:NO];
    }
}

- (void)showDiseaseBudge:(BOOL)show
{
    if (show)
    {
        [tabBarController.tabBar bringSubviewToFront:self.imageViewBudge];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%@_NewDisease",_configureList[APP_PASSPORTID_KEY]]];
        [[NSNotificationCenter defaultCenter] postNotificationName:APP_HAS_NEW_DISEASE object:nil];
        self.imageViewBudge.hidden = NO;
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%@_NewDisease",_configureList[APP_PASSPORTID_KEY]]];
        self.imageViewBudge.hidden = YES;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)tabBarInit
{
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.delegate = self;
    NSMutableArray * tabArrays = [NSMutableArray array];
    
    UINavigationController * nav = nil;
    
    
    //问药
    nav = [[UINavigationController alloc] initWithRootViewController:[[NewHomePageViewController alloc] initWithNibName:@"NewHomePageViewController" bundle:nil]];
    UITabBarItem *homeItem = [self createTabBarItem:@"首页" normalImage:@"问药.png" selectedImage:@"问药-点击态.png" itemTag:Enum_TabBar_Items_HomePage];
    nav.tabBarItem = homeItem;
    [tabArrays addObject:nav];
    
    
    //快速查询
    nav = [[UINavigationController alloc] initWithRootViewController:[[QuickSearchViewController alloc] init]];
    UITabBarItem *quickItem = [self createTabBarItem:@"自查" normalImage:@"自查.png" selectedImage:@"自查-点击态.png" itemTag:Enum_TabBar_Items_QuickSearch];
    nav.tabBarItem = quickItem;
    [tabArrays addObject:nav];
    
    
    //健康资讯
    nav = [[UINavigationController alloc] initWithRootViewController:[[HealthInformationViewController alloc] init]];
    UITabBarItem *healthItem = [self createTabBarItem:@"资讯" normalImage:@"资讯.png" selectedImage:@"资讯-点击态.png" itemTag:Enum_TabBar_Items_HealthInformation];
    nav.tabBarItem = healthItem;
    [tabArrays addObject:nav];
    
    
    //用户中心(我)
    QZMyCenterViewController *myCenterViewController = [[QZMyCenterViewController alloc] init];
    nav = [[UINavigationController alloc] initWithRootViewController:myCenterViewController];
    UITabBarItem *userItem = [self createTabBarItem:@"我的" normalImage:@"我的.png" selectedImage:@"我的-点击态.png" itemTag:Enum_TabBar_Items_UserCenter];
    nav.tabBarItem = userItem;
    [tabArrays addObject:nav];
    
    
    self.imageViewBudge = [[UIImageView alloc] initWithFrame:CGRectMake(205, 5, 10, 10)];
    self.imageViewBudge.layer.cornerRadius = 5.0f;
    self.imageViewBudge.layer.masksToBounds = YES;
    self.imageViewBudge.backgroundColor = [UIColor redColor];
    [tabBarController.tabBar addSubview:self.imageViewBudge];
    self.imageViewBudge.hidden = YES;
    
    self.myCenterBudge = [[UIImageView alloc] initWithFrame:CGRectMake(286, 5, 10, 10)];
    self.myCenterBudge.layer.cornerRadius = 5.0f;
    self.myCenterBudge.layer.masksToBounds = YES;
    self.myCenterBudge.backgroundColor = [UIColor redColor];
    [tabBarController.tabBar addSubview:self.myCenterBudge];
    self.myCenterBudge.hidden = NO;
    
    tabBarController.viewControllers = tabArrays;
    
    
    /*
    tabBarController = [[UITabBarController alloc] init];
    tabBarController.delegate = self;
//    [tabBarController.tabBar setClipsToBounds:YES];
//    [[UITabBar appearance] setShadowImage:[UIImage imageNamed:@"bj"]];
    NSMutableArray * tabArrays = [NSMutableArray array];
    
    UINavigationController * nav = nil;
    nav = [[UINavigationController alloc] initWithRootViewController:[[NewHomePageViewController alloc] initWithNibName:@"NewHomePageViewController" bundle:nil]];
    
    
    UIImage *selectedImage = [UIImage imageNamed:@"问药-点击态.png"];
    selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:[UIImage imageNamed:@"问药.png"] selectedImage:selectedImage];
    [nav.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:[UIImage imageNamed:@"问药.png"]];
    [nav.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : APP_COLOR_STYLE} forState:UIControlStateSelected];
    
    
    [tabArrays addObject:nav];
    
    //快速查询
     nav = [[UINavigationController alloc] initWithRootViewController:[[QuickSearchViewController alloc] init]];
//        nav = [[UINavigationController alloc] initWithRootViewController:[[QuickSearchViewController alloc] initWithNibName:@"QuickSearchViewController-480" bundle:nil]];
    selectedImage = [UIImage imageNamed:@"自查-点击态.png"];
    selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"自查" image:[UIImage imageNamed:@"自查.png"] selectedImage:selectedImage];
    [nav.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:[UIImage imageNamed:@"自查.png"]];
    [nav.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : APP_COLOR_STYLE} forState:UIControlStateSelected];
    [tabArrays addObject:nav];
    
    //健康资讯
    selectedImage = [UIImage imageNamed:@"资讯-点击态.png"];
    selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav = [[UINavigationController alloc] initWithRootViewController:[[HealthInformationViewController alloc] init]];
    nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"资讯" image:[UIImage imageNamed:@"资讯.png"] selectedImage:selectedImage];
    [nav.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:[UIImage imageNamed:@"资讯.png"]];
    [nav.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : APP_COLOR_STYLE} forState:UIControlStateSelected];
    [tabArrays addObject:nav];
    
    //用户中心(我)
    QZMyCenterViewController *myCenterViewController = [[QZMyCenterViewController alloc] init];
//    UserCenterViewController * userController = [[UserCenterViewController alloc] init];
//    if(HIGH_RESOLUTION){
        nav = [[UINavigationController alloc] initWithRootViewController:myCenterViewController];
//    }
    selectedImage = [UIImage imageNamed:@"我的-点击态.png"];
    selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的" image:[UIImage imageNamed:@"我的.png"] selectedImage:selectedImage];
    [nav.tabBarItem setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:[UIImage imageNamed:@"我的.png"]];
    [nav.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : APP_COLOR_STYLE} forState:UIControlStateSelected];
    [tabArrays addObject:nav];
    
    self.imageViewBudge = [[UIImageView alloc] initWithFrame:CGRectMake(205, 5, 10, 10)];
    self.imageViewBudge.layer.cornerRadius = 5.0f;
    self.imageViewBudge.layer.masksToBounds = YES;
    self.imageViewBudge.backgroundColor = [UIColor redColor];
    [tabBarController.tabBar addSubview:self.imageViewBudge];
    
    self.imageViewBudge.hidden = YES;
    
    tabBarController.viewControllers = tabArrays;
     */
}

- (UITabBarItem *) createTabBarItem:(NSString *)strTitle normalImage:(NSString *)strNormalImg selectedImage:(NSString *)strSelectedImg itemTag:(NSInteger)intTag
{
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:strTitle image:nil tag:intTag];
    
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor darkGrayColor], UITextAttributeTextColor,[UIFont systemFontOfSize:11], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:APP_COLOR_STYLE, UITextAttributeTextColor,[UIFont systemFontOfSize:11], NSFontAttributeName,  nil] forState:UIControlStateSelected];
    
    if (iOSv7) {
        [item setImage:[[UIImage imageNamed:strNormalImg] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [item setSelectedImage:[[UIImage imageNamed:strSelectedImg] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    }else{
        [item setFinishedSelectedImage:[UIImage imageNamed:strSelectedImg] withFinishedUnselectedImage:[UIImage imageNamed:strNormalImg]];
    }
    return item;
}

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10000) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:APP_UPDATE_AFTER_THREE_DAYS];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (buttonIndex == 0) {
            exit(0);
        } else {
            NSString *strDownload = [self.dicNewVersionInfo objectForKey:@"downloadUrl"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strDownload]];
        }
    } else if (alertView.tag == 10001) {
        if (buttonIndex == 0) {
            if (self.myAlertView.isClick) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:APP_UPDATE_AFTER_THREE_DAYS];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:(double)[[NSDate date] timeIntervalSince1970]] forKey:APP_LAST_TIMESTAMP];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:APP_UPDATE_AFTER_THREE_DAYS];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:APP_UPDATE_AFTER_THREE_DAYS];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSString *strDownload = [self.dicNewVersionInfo objectForKey:@"downloadUrl"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strDownload]];
        }
    } else if(alertView.tag == 101){
        [self clearAccountInformation];
        if(buttonIndex == 1)
        {
            LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            UINavigationController *navgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
            loginViewController.isPresentType = YES;
            [tabBarController presentViewController:navgationController animated:YES completion:NULL];
        }else if (buttonIndex == 0){
            exit(0);
        }
    }
    
}

- (void)updateUnreadCountBadge
{
    NSUInteger unread = [_dataBase selectTotalUnreadCountMessage];
    UINavigationController *navigationController = self.tabBarController.viewControllers[0];
//    if(unread > 0) {
//        if(unread > 99) {
//            navigationController.tabBarItem.badgeValue = @"99+";
//        }else{
//            navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",unread];
//        }
//    }else{
//        navigationController.tabBarItem.badgeValue = nil;
//    }
    if(unread > 99) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 99;
    }else{
        [UIApplication sharedApplication].applicationIconBadgeNumber = unread;
    }
    NewHomePageViewController *newHomePageViewController = ((UINavigationController *)self.tabBarController.viewControllers[0]).viewControllers[0];
    [newHomePageViewController.badgeView setValueOnly:unread];
}

- (void)clearAccountInformation
{
    [[HTTPRequestManager sharedInstance] logout:@{@"token":app.configureList[APP_USER_TOKEN]} completionSuc:^(id resultObj) {
    } failure:^(id failMsg) {
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:QUIT_OUT object:nil];
    [app showDiseaseBudge:NO];
    self.hasNewDisease = NO;
    [self releaseMessageTimer];
    [[[XMPPManager sharedInstance] xmppReconnect] deactivate];
    [[XMPPManager sharedInstance]  disconnect];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    NewHomePageViewController *newHomePageViewController = ((UINavigationController *)self.tabBarController.viewControllers[0]).viewControllers[0];
    [newHomePageViewController.badgeView setValueOnly:0];
    _dataBase = nil;
    app.logStatus = NO;
    UINavigationController *navgationController = tabBarController.viewControllers[0];
    navgationController.tabBarItem.badgeValue = nil;
    [navgationController popToRootViewControllerAnimated:YES];
    navgationController = tabBarController.viewControllers[1];
    [navgationController popToRootViewControllerAnimated:YES];
    navgationController = tabBarController.viewControllers[2];
    [navgationController popToRootViewControllerAnimated:YES];
    navgationController = tabBarController.viewControllers[3];
    [navgationController popToRootViewControllerAnimated:YES];
    
//    UserCenterViewController * userCenter = [[UserCenterViewController alloc] init];
//    userCenter.hidesBottomBarWhenPushed = NO;
//    navgationController.viewControllers = @[userCenter];
    
    [_configureList removeObjectForKey:APP_PASSPORTID_KEY];
    [_configureList removeObjectForKey:APP_USER_TOKEN];
}

- (void)quitAccount:(NSNotification *)noti
{
    [self updateUnreadCountBadge];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:APP_LOGIN_STATUS];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:APP_PASSWORD_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告!" message:@"您的账号已在其他设备登录" delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"重新登录", nil];
    alertView.tag = 101;
    [alertView show];
}

- (void)loginSucessCallBack:(NSNotification *)noti
{
    //轮询定时器获取全维药师历史消息
    [self createMessageTimer];
    [app updateUnreadCountBadge];
    [self enablePushNotification:NO];
}

- (void)queryDrugGuideList
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"status"] = @"3";
    setting[@"currPage"] = @"1";
    setting[@"pageSize"] = @"100";
    [[HTTPRequestManager sharedInstance] getDrugGuideList:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]) {
            NSArray *array = resultObj[@"body"][@"data"];
            if([array count] > 0) {
                
                if (![app.dataBase checkAllDiseaseReaded]) {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:APP_SELECT_INDEX_DISEASE object:nil];
                } else {
                    self.hasNewDisease = NO;
                }

                if([_dataBase checkAnyNewDiseaseSubscribe:array needUpdateHasRead:YES]) {
                    self.hasNewDisease = YES;
                    [self showDiseaseBudge:YES];
                }else{
                    self.hasNewDisease = NO;
                    [self showDiseaseBudge:NO];
                }
                [app.dataBase updateDiseaseSubWithArr:array];
            }
        }else{
            
        }
    } failure:^(NSError *error) {

    }];
    
}

- (void)pullUnreadMessage
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"view"] = @"100";
    [[HTTPRequestManager sharedInstance] alternativeIMSelect:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"])
        {
            NSArray *historys = resultObj[@"body"];
            //NSInteger count = historys.count - 1;
            NSMutableArray *UUIDLists = [NSMutableArray arrayWithCapacity:10];
            for(NSDictionary *dict in historys)
            {
                NSString *content = dict[@"content"];
                NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:content options:0 error:nil];
                XMPPIQ *iq = (XMPPIQ *)[document rootElement];
                NSXMLElement *notification = [iq elementForName:@"notification"];
                
//                if([dict[@"fromTag"] integerValue] == 1) {
                    if(notification && [[notification xmlns] isEqualToString:@"androidpn:iq:notification"])
                    {
                        //接受消息成功
                        NSString *UUID = [[notification elementForName:@"id"] stringValue];
                        NSDictionary *UUIDdict = @{@"id":UUID};
                        [UUIDLists addObject:UUIDdict];
                        NSString *text = [[notification elementForName:@"message"] stringValue];
                        NSString *from = [[notification elementForName:@"fromUser"] stringValue];
                        double timeStamp = [[notification elementForName:@"timestamp"] stringValueAsDouble] / 1000;
                        NSString *avatorUrl = [[notification elementForName:@"uri"] stringValue];
                        NSString *sendName = [[notification elementForName:@"to"] stringValue];
                        NSUInteger messageType = [[notification elementForName:@"msType"] stringValueAsInt32];
                        NSString *title = [[notification elementForName:@"title"] stringValue];
                        XHBubbleMessageType bubbleMessageType;
                        if([self.configureList[APP_USER_TOKEN] isEqualToString:from]) {
                            bubbleMessageType = XHBubbleMessageTypeSending;
                        }else{
                            bubbleMessageType = XHBubbleMessageTypeReceiving;
                        }
                        [app.dataBase insertMessages:[NSNumber numberWithInt:bubbleMessageType] timestamp:[NSString stringWithFormat:@"%.0f",timeStamp] UUID:UUID star:title avatorUrl:avatorUrl sendName:from recvName:sendName issend:[NSNumber numberWithInt:Sended] messagetype:[NSNumber numberWithInt:messageType] unread:[NSNumber numberWithInt:1] richbody:avatorUrl body:text];
                        
                        [app.dataBase insertHistorys:from timestamp:[NSString stringWithFormat:@"%.0f",timeStamp] body:text direction:[NSNumber numberWithInt:XHBubbleMessageTypeReceiving] messagetype:[NSNumber numberWithInt:messageType] UUID:UUID issend:[NSNumber numberWithInt:Sended] avatarUrl:@""];
                        
                    }
//                }else{
//                    if(notification && [[notification xmlns] isEqualToString:@"androidpn:iq:notification"])
//                    {
//                        NSString *UUID = [[notification elementForName:@"id"] stringValue];
//                        NSDictionary *dict = [[[notification elementForName:@"message"] stringValue] JSONValue][@"info"];
//                        
//                        NSString *text = dict[@"content"];
//                        NSString *from = dict[@"fromId"];
//                        NSString *sendName = dict[@"toId"];
//                        NSArray *tagList = dict[@"tags"];
//                        NSString *title = @"";
//                        NSUInteger source = [dict[@"source"] integerValue];
//                        if(tagList.count)
//                        {
//                            title = tagList[0][@"title"];
//                        }
//                        double timeStamp = [[notification elementForName:@"timestamp"] stringValueAsDouble] / 1000;
//
//                        [app.dataBase insertMessages:[NSNumber numberWithInt:XHBubbleMessageTypeReceiving] timestamp:[NSString stringWithFormat:@"%.0f",timeStamp] UUID:UUID star:title avatorUrl:@"" sendName:from recvName:sendName issend:[NSNumber numberWithInt:Sended] messagetype:[NSNumber numberWithInt:source] unread:[NSNumber numberWithInt:0] richbody:@"" body:text];
//                        for(NSDictionary *tag in tagList)
//                        {
//                            NSUInteger length = [tag[@"length"] integerValue];
//                            NSUInteger start = [tag[@"start"] integerValue];
//                            NSUInteger tagType = [tag[@"tag"] integerValue];
//                            NSString *tagId = tag[@"tagId"];
//                            NSString *title = tag[@"title"];
//                            [app.dataBase insertIntoTagList:UUID start:[NSNumber numberWithInt:start] length:[NSNumber numberWithInt:length] tagType:[NSNumber numberWithInt:tagType] title:title tagId:tagId];
//                        }
//
//                    }
//                }
            }
            if(UUIDLists.count > 0)
            {
                [app updateUnreadCountBadge];
                [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_NEED_UPDATE object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"offLineMessage" object:nil];
                NSMutableDictionary *setting = [NSMutableDictionary dictionary];
                setting[@"ids"] = UUIDLists;
                [[HTTPRequestManager sharedInstance] imSetReceived:setting completion:^(id resultObj) {
                    
                } failure:NULL];
            }
        }
    } failure:NULL];

}


- (void)pullOfficialMessage
{
    if(!app.logStatus)
        return;
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"endpoint"] = @"1";
    setting[@"token"] = _configureList[APP_USER_TOKEN];
    setting[@"viewType"] = @"1";
    setting[@"view"] = @"100";
    setting[@"to"] = _configureList[APP_PASSPORTID_KEY];
    [[HTTPRequestManager sharedInstance] selectQWIM:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]) {
            NSArray *array = resultObj[@"body"];
            if([array isKindOfClass:[NSString class]])
                return;
            for(NSDictionary *dict in array)
            {
                NSUInteger type = [dict[@"type"] integerValue];
                NSDictionary *info = dict[@"info"];
                NSString *content = info[@"content"];
                NSString *fromId = info[@"fromId"];
                NSString *toId = info[@"toId"];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                double timeStamp = [[formatter dateFromString:info[@"time"]] timeIntervalSince1970];
                NSString *UUID = info[@"id"];
                NSUInteger fromTag = [info[@"fromTag"] integerValue];
                NSArray *tags = info[@"tags"];
                NSUInteger msgType = [info[@"source"] integerValue];
                if(msgType == 0)
                    msgType = 1;
                
                NSString *relatedId = @"";
                
                for(NSDictionary *tag in info[@"tags"])
                {
                    NSUInteger length = [tag[@"length"] integerValue];
                    NSUInteger start = [tag[@"start"] integerValue];
                    NSUInteger tagType = [tag[@"tag"] integerValue];
                    NSString *tagId = tag[@"tagId"];
                    NSString *title = tag[@"title"];
                    [app.dataBase insertIntoTagList:UUID start:[NSNumber numberWithInt:start] length:[NSNumber numberWithInt:length] tagType:[NSNumber numberWithInt:tagType] title:title tagId:tagId];
                }
                
                if(fromTag == 2)
                {
                    [app.dataBase insertMessages:[NSNumber numberWithInt:XHBubbleMessageTypeReceiving] timestamp:[NSString stringWithFormat:@"%.0f",timeStamp] UUID:UUID star:@"" avatorUrl:@"" sendName:fromId recvName:toId issend:[NSNumber numberWithInt:Sended] messagetype:[NSNumber numberWithInt:msgType] unread:[NSNumber numberWithInt:1] richbody:@"" body:content];
                    [[NSNotificationCenter defaultCenter] postNotificationName:fromId object:nil];
                    [app.dataBase insertHistorys:fromId timestamp:[NSString stringWithFormat:@"%.0f",timeStamp] body:content direction:[NSNumber numberWithInt:XHBubbleMessageTypeReceiving] messagetype:[NSNumber numberWithInt:msgType] UUID:UUID issend:[NSNumber numberWithInt:2] avatarUrl:@""];
                }else if(fromTag == 0)
                {
                    //全维药事的推送
                    [app.dataBase insertIntoofficialMessages:fromId toId:toId timestamp:[NSString stringWithFormat:@"%.0f",timeStamp] body:content direction:[NSNumber numberWithInt:XHBubbleMessageTypeReceiving] messagetype:[NSNumber numberWithInt:msgType] UUID:UUID issend:[NSNumber numberWithInt:0] relatedid:fromId];
                }
            }
            if(array.count > 0)
            {
                [XHAudioPlayerHelper playMessageReceivedSound];
                [self updateUnreadCountBadge];
                [[NSNotificationCenter defaultCenter] postNotificationName:OFFICIAL_MESSAGE object:nil];
            }
        }
    } failure:NULL];
    [self queryDrugGuideList];
    setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    //判断当前账号是否失效
    [[HTTPRequestManager sharedInstance] checkToken:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"FAIL"])
        {
            [SVProgressHUD showErrorWithStatus:@"当前账号已失效,请重新连接!" duration:0.8f];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:APP_LOGIN_STATUS];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:APP_PASSWORD_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self clearAccountInformation];
        }
    } failure:NULL];
}

- (void)createMessageTimer
{
    pullMessageTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(pullMessageTimer, dispatch_time(DISPATCH_TIME_NOW, 3ull*NSEC_PER_SEC), 60ull*NSEC_PER_SEC , DISPATCH_TIME_FOREVER);
    dispatch_source_set_event_handler(pullMessageTimer, ^{
        [self pullOfficialMessage];
    });
    dispatch_source_set_cancel_handler(pullMessageTimer, ^{
        NSLog(@"has been canceled");
    });
     dispatch_resume(pullMessageTimer);
}

- (void)releaseMessageTimer
{
    dispatch_source_cancel(pullMessageTimer);
}

- (void)sendHeartBeat
{
    [[HTTPRequestManager sharedInstance] queryHeartBeat:@{@"source":@"1",@"version":APP_VERSION,} completeionSuc:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            NSDictionary *dicReturn = resultObj[@"body"];
            // add here
            
        }
    } failure:^(id failMsg) {
        NSLog(@"fail");
    }];
    
}

- (void)showNormalUpdateAlert:(NSDictionary *)dicUpdate
{
//    NSString *strAlertMessage = [NSString stringWithFormat:@"版本号: %@    大小: %@",dicUpdate[@"versionName"], dicUpdate[@"size"]];
    NSString *strAlertMessage = [NSString stringWithFormat:@"版本号: %@    ",dicUpdate[@"versionName"]];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发现新版本" message:strAlertMessage delegate:self cancelButtonTitle:@"暂不升级" otherButtonTitles:@"立即更新", nil];
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"customAlertView"
                                                      owner:self
                                                    options:nil];
    
    self.myAlertView = [ nibViews objectAtIndex: 0];
    
    self.myAlertView.tvViewMessage.text = dicUpdate[@"updateLog"];
    //check if os version is 7 or above
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        [alertView setValue:self.myAlertView forKey:@"accessoryView"];
    }else{
        [alertView addSubview:self.myAlertView];
    }
    alertView.tag = 10001;
    [alertView show];
}

- (void)showForceUpdateAlert:(NSDictionary *)dicUpdate
{
    NSString *strAlertMessage = [NSString stringWithFormat:@"版本号: %@    \n%@",dicUpdate[@"versionName"], dicUpdate[@"updateLog"]];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"检测到新版本" message:strAlertMessage delegate:self cancelButtonTitle:@"暂不升级" otherButtonTitles:@"立即更新", nil];
    alertView.tag = 10000;
    [alertView show];
}

- (void)checkVersion
{
    __weak AppDelegate *weakSelf = self;
    if (self.boolLoadFromFirstIn) {
        self.boolLoadFromFirstIn = NO;
        return;
    }
    self.boolLoadFromFirstIn = YES;
    [[HTTPRequestManager sharedInstance] queryLastVersion:@{@"versionCode":APP_VERSION,
                                                            @"type":@"2"} completionSuc:^(id resultObj) {
                                                                if ([resultObj[@"body"] isKindOfClass:[NSDictionary class]]) {
                                                                    NSDictionary *dicReturn = resultObj[@"body"];
                                                                    self.boolLoadFromFirstIn = NO;
                                                                    if (![resultObj[@"result"] isEqualToString:@"OK"]) {
                                                                        
                                                                    } else {
                                                                        
                                                                        weakSelf.dicNewVersionInfo = [[NSDictionary alloc] init];
                                                                        weakSelf.dicNewVersionInfo = dicReturn;
                                                                        
                                                                        NSInteger intCurVersion = [self getIntValueFromVersionStr:APP_VERSION];
                                                                        NSInteger intSysVersion = [self getIntValueFromVersionStr:dicReturn[@"versionName"]];
                                                                        NSInteger intLastSysVersion = [self getIntValueFromVersionStr:[[NSUserDefaults standardUserDefaults] objectForKey:APP_LAST_SYSTEM_VERSION]];
                                                                        [[NSUserDefaults standardUserDefaults] setObject:dicReturn[@"versionName"] forKey:APP_LAST_SYSTEM_VERSION];
                                                                        [[NSUserDefaults standardUserDefaults] synchronize];
                                                                        if ([dicReturn[@"updateInstall"] intValue] == 1) {
                                                                            // force update
                                                                            if (intCurVersion < intSysVersion) {
//                                                                                NSString *strAlertMessage = [NSString stringWithFormat:@"版本号: %@    大小: %@ \n%@",dicReturn[@"versionName"], dicReturn[@"size"], dicReturn[@"updateLog"]];
                                                                                self.isForceUpdating = YES;
                                                                                [self showForceUpdateAlert:dicReturn];
                                                                                self.dicForceUpdated = @{};
                                                                                self.dicForceUpdated = dicReturn;
                                                                            }
                                                                        } else {
                                                                            // normal update
                                                                            // add here
                                                                            self.isForceUpdating = NO;
                                                                            if ((intLastSysVersion < intSysVersion)&&intLastSysVersion!=0) {
                                                                                [self showNormalUpdateAlert:dicReturn];
                                                                            } else {
                                                                                if ([[[NSUserDefaults standardUserDefaults] objectForKey:APP_UPDATE_AFTER_THREE_DAYS] boolValue]) {
                                                                                    
                                                                                } else {
                                                                                    [self showNormalUpdateAlert:dicReturn];
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            } failure:^(id failMsg) {
                                                                NSLog(@"fail");
                                                            }];
}

- (void)setupUserDefault
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if([userDefault objectForKey:APP_VOICE_NOTIFICATION] == nil)
    {
        [userDefault setObject:[NSNumber numberWithBool:YES] forKey:APP_VOICE_NOTIFICATION];
        [userDefault setObject:[NSNumber numberWithBool:YES] forKey:APP_VIBRATION_NOTIFICATION];
        [userDefault setObject:[NSNumber numberWithBool:YES] forKey:APP_RECEIVE_INBACKGROUND];
        [userDefault setObject:[NSNumber numberWithBool:YES] forKey:ALARM_VOICE_NOTIFICATION];
        [userDefault setObject:[NSNumber numberWithBool:YES] forKey:ALARM_VIBRATION_NOTIFICATION];
    }
    [userDefault synchronize];
}

- (void)autoLoginAction
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:APP_USERNAME_KEY];
    NSString *passWord = [[NSUserDefaults standardUserDefaults] objectForKey:APP_PASSWORD_KEY];
    [[HTTPRequestManager sharedInstance] login:@{@"account":userName,@"password":passWord,@"deviceCode":app.deviceToken,@"device":@"2"} completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            NSString * str = resultObj[@"body"][@"token"];
            if (str) {
                [self initDataSource:userName];
                [self.configureList setObject:resultObj[@"body"][@"token"] forKey:APP_USER_TOKEN];
                
                [self.configureList setObject:resultObj[@"body"][@"passportId"] forKey:APP_PASSPORTID_KEY];
                [self.configureList setObject:userName forKey:APP_USERNAME_KEY];
                [self.configureList setObject:passWord forKey:APP_PASSWORD_KEY];
                NSString *nickName = resultObj[@"body"][@"nickName"];
                if(nickName && ![nickName isEqual:[NSNull null]]){
                    app.configureList[APP_NICKNAME_KEY] = nickName;
                }else{
                    app.configureList[APP_NICKNAME_KEY] = @"";
                }
                NSString *avatarUrl = resultObj[@"body"][@"avatarUrl"];
                if(avatarUrl && ![avatarUrl isEqual:[NSNull null]]){
                    app.configureList[APP_AVATAR_KEY] = avatarUrl;
                }else{
                    app.configureList[APP_AVATAR_KEY] = @"";
                }
                self.logStatus = YES;
                [self saveAppConfigure];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESS object:nil];
                XMPPJID *jid = [XMPPJID jidWithUser:resultObj[@"body"][@"passportId"] domain:OPEN_FIRE_URL resource:@"AndroidpnClient"];
                
                [[[XMPPManager sharedInstance] xmppReconnect] activate:[[XMPPManager sharedInstance] xmppStream]];
                
                [[[XMPPManager sharedInstance] xmppStream] setMyJID:jid];
                [[[XMPPManager sharedInstance] xmppStream] connectWithTimeout:-1 error:nil];
                
                
            }
        }
        
    } failure:^(NSError *error) {
        
    }];
}

- (NSInteger)getIntValueFromVersionStr:(NSString *)strVersion
{
    NSArray *arrVer = [strVersion componentsSeparatedByString:@"."];
    NSString *strVer = [arrVer componentsJoinedByString:@""];
    NSInteger intVer = [strVer integerValue];
    return intVer;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    app = self;
    [self setupUserDefault];
    [MobClick startWithAppkey:@"5355fc9256240b418f014450" reportPolicy:BATCH channelId:@"ios-appstore"];
    NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"Documents"]];
    
    _cacheBase = [[DataBase alloc] initWithPath:homePath];
    [_cacheBase createCacheTable];
    
    //[DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];
    [[XMPPManager sharedInstance] setupStream];
    self.reachabilityMonitor = [[ReachabilityMonitor alloc] initWithDelegate:self];
    [self.reachabilityMonitor startMonitoring];
    //地图定位兼容iOS8
    locationManager = [[CLLocationManager alloc] init];
    
    // fix ios8 location issue
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
#ifdef __IPHONE_8_0
        if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        {
            [locationManager performSelector:@selector(requestAlwaysAuthorization)];
            //用这个方法，plist中需要NSLocationAlwaysUsageDescription
        }
        
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [locationManager performSelector:@selector(requestWhenInUseAuthorization)];
            //用这个方法，plist里要加字段NSLocationWhenInUseUsageDescription
        }
#endif
    }
    [MAMapServices sharedServices].apiKey = AMAP_KEY;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitAccount:) name:KICK_OFF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucessCallBack:) name:LOGIN_SUCCESS object:nil];
    
    // 版本更新
//
    if (![[NSUserDefaults standardUserDefaults] objectForKey:APP_LAST_SYSTEM_VERSION]) {
        [[NSUserDefaults standardUserDefaults] setObject:APP_VERSION forKey:APP_LAST_SYSTEM_VERSION];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkVersion) name:APP_CHECK_VERSION object:nil];
//    [self checkVersion];

#ifdef __IPHONE_8_0
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }  else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
#else
    UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
#endif

    self.mapView = [[MAMapView alloc] init];
    self.mapView.showsUserLocation = YES;
    
    [self initNavigationBarStyle];
    [self tabBarInit];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
     [self.window makeKeyAndVisible];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = tabBarController;
   
    [ZBarReaderView class];
#ifdef TARGET_IPHONE_SIMULATOR
    self.deviceToken = @"12345";
#endif
    if(HIGH_RESOLUTION){
        showAppGuide(@[@"引导页1-568.jpg",@"引导页2-568.jpg"]);
    }else{
        showAppGuide(@[@"引导页1-480.jpg",@"引导页2-480.jpg"]);
    }
    
    NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"BeRead"];
    if ([str isEqualToString:@"1"]) {
        self.myCenterBudge.hidden = YES;
    }else
    {
        self.myCenterBudge.hidden = NO;
    }
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:APP_LOGIN_STATUS] boolValue])
    {
        [self performSelector:@selector(autoLoginAction) withObject:nil afterDelay:2.5f];
    }
    return YES;
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}
#endif

- (NSString *)replaceSpecialStringWith:(NSString *)string
{
    if(!string || [string isEqualToString:@""] || [string isEqual:[NSNull null]]){
        return @"";
    }
    string = [string stringByReplacingOccurrencesOfString:@"    &nbsp;&nbsp;&nbsp;&nbsp;" withString:@"    "];
    string = [string stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    string = [string stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@"<br>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@"<p/>" withString:@"\r\n"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt:" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt:" withString:@">"];
    return string;
}

-(void)initsocailShare:(NSString *)urlString
{
    //设置友盟appkey  5355fc9256240b418f014450
    [UMSocialData setAppKey:UMENG_KEY];//ok,已是全维应用
    
    //设置手机腾讯AppKey   QQ6066545
    [UMSocialQQHandler setQQWithAppId:@"1101843707"
                               appKey:@"CcKMij0UJErBOhbp"
                                  url:urlString];
    //[UMSocialQQHandler setQQWithAppId:@"1101358815" appKey:@"wjocwTf7dCReSIiF" url:urlString];
    //打开新浪微博的SSO开关
    //    [UMSocialSinaHandler openSSOWithRedirectURL:urlString];

    
    //设置微信 appId控制分享来源 url控制点击后跳转链接
    
    [UMSocialWechatHandler setWXAppId:@"wxa2c68380a4a2f5d7"
                            appSecret:@"373c55b1c94339d803d5f7e6ed4876d6"
                                  url:urlString];
    //[UMSocialWechatHandler setWXAppId:@"wxa2c68380a4a2f5d7" url:urlString];
    
    //设置来往AppId，appscret，显示来源名称和url地址
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    
    
    return  [UMSocialSnsService handleOpenURL:url];
}

#pragma mark -
#pragma mark ReachabilityDelegate
-(void)networkDisconnectFrom:(NetworkStatus)netStatus
{
    _currentNetWork = NotReachable;
    [[[XMPPManager sharedInstance] xmppStream] disconnect];
    [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
    [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_DISCONNECT object:nil];
}

- (void)networKCannotStartupWhenFinishLaunching
{
    _currentNetWork = NotReachable;
}

- (void)networkStartAtApplicationDidFinishLaunching:(NetworkStatus)netStatus
{
    _currentNetWork = netStatus;
    [[NSNotificationCenter defaultCenter] postNotificationName:NEED_RELOCATION object:nil];
}

- (void)networkRestartFrom:(NetworkStatus)oldStatus toStatus:(NetworkStatus)newStatus
{
    _currentNetWork = newStatus;
    if (app.logStatus && newStatus != kNotReachable)
    {
        [[[XMPPManager sharedInstance] xmppStream] disconnect];
        [[[XMPPManager sharedInstance] xmppStream] connectWithTimeout:-1 error:nil];
        [self pullUnreadMessage];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_RESTART object:nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if(userInfo[@"message"])
    {
        UIViewController *viewController = [((UINavigationController *)self.tabBarController.viewControllers[0]).viewControllers lastObject];
        if(tabBarController.selectedIndex == 0 && [viewController isKindOfClass:[MessageBoxViewController class ]]){
            return;
        }
        for(UINavigationController *navigationController in tabBarController.viewControllers) {
            [navigationController popToRootViewControllerAnimated:NO];
        }
        tabBarController.selectedIndex = 0;
        
        [self performSelector:@selector(openBox) withObject:nil afterDelay:0.1];
    }
}

- (void)openBox
{
    NewHomePageViewController *newHomePageViewController = ((UINavigationController *)self.tabBarController.viewControllers[0]).viewControllers[0];
    [newHomePageViewController pushIntoMessageBox:nil];
}

- (UIViewController *)retrievalPresentViewController:(UIViewController *)presentViewController
{
    UIViewController *retViewContrroler = presentViewController;
    while (retViewContrroler.presentedViewController) {
        retViewContrroler = retViewContrroler.presentedViewController;
    }
    return retViewContrroler;
}

#pragma mark -
#pragma mark LocalNotification Delegate
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[notification userInfo]];
    
    RemindAlarmViewController *remindAlarmViewController = nil;
    if(HIGH_RESOLUTION) {
        remindAlarmViewController = [[RemindAlarmViewController alloc] initWithNibName:@"RemindAlarmViewController" bundle:nil];
    }else{
        remindAlarmViewController = [[RemindAlarmViewController alloc] initWithNibName:@"RemindAlarmViewController-480" bundle:nil];
    }
    remindAlarmViewController.infoDict = info;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:remindAlarmViewController];
    if(self.tabBarController.presentedViewController){
        
    }else{
        [self.tabBarController presentViewController:navigationController animated:YES completion:^{
            
        }];
    }
}

- (void)cacheLastLocationInformation:(NSString *)city
                            location:(CLLocation *)location
{
    [[NSUserDefaults standardUserDefaults] setObject:city forKey:LAST_LOCATION_CITY];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:location.coordinate.latitude] forKey:LAST_LOCATION_LATITUDE];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:location.coordinate.longitude] forKey:LAST_LOCATION_LONGITUDE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)cacheLastLocationInformation:(NSString *)city
                            province:(NSString *)province
                    formatterAddress:(NSString *)address
                            location:(CLLocation *)location
{
    [[NSUserDefaults standardUserDefaults] setObject:city forKey:LAST_LOCATION_CITY];
    [[NSUserDefaults standardUserDefaults] setObject:province forKey:LAST_LOCATION_PROVINCE];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:location.coordinate.latitude] forKey:LAST_LOCATION_LATITUDE];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:location.coordinate.longitude] forKey:LAST_LOCATION_LONGITUDE];
    [[NSUserDefaults standardUserDefaults] setObject:address forKey:LAST_FORMAT_ADDRESS];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark -
#pragma mark PushNotification Delegate
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)_deviceToken
{
    NSString *devStr = [NSString stringWithFormat:@"%@",_deviceToken];
    NSArray *array = [devStr componentsSeparatedByString:@" "];
    self.deviceToken = [array componentsJoinedByString:@""];
    self.deviceToken = [self.deviceToken substringWithRange:NSMakeRange(1, self.deviceToken.length - 2)];
    NSLog(@"token======%@",self.deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@",error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    self.boolLoadFromFirstIn = NO;
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[XMPPManager sharedInstance] disconnect];
    [self releaseMessageTimer];
    [self enablePushNotification:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)checkNeedUpdate
{
    self.lastTimeStamp = (double)[[NSDate date] timeIntervalSince1970];//[dicReturn[@"respTime"] doubleValue];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:APP_UPDATE_AFTER_THREE_DAYS] boolValue]) {
        // 3天后提醒
        NSTimeInterval intevalLast = [[[NSUserDefaults standardUserDefaults] objectForKey:APP_LAST_TIMESTAMP] doubleValue];
        if (self.lastTimeStamp - intevalLast >= 3*24*60*60) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:APP_UPDATE_AFTER_THREE_DAYS];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self checkVersion];
            self.boolLoadFromFirstIn = YES;
        }
        return ;
    } else {
        
    }
}

- (void)enablePushNotification:(BOOL)enable
{
    if(!app.logStatus)
        return;
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"source"] = @"1";
    if(enable) {
        setting[@"backStatus"] = [NSNumber numberWithInt:0];
    }else{
        setting[@"backStatus"] = [NSNumber numberWithInt:1];
    }
    [[HTTPRequestManager sharedInstance] systemBackSet:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]) {
            
            
        }
    } failure:^(id failMsg) {
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (self.isForceUpdating) {
        if (self.currentNetWork == NotReachable) {
            if (self.dicForceUpdated != nil) {
                [self showForceUpdateAlert:self.dicForceUpdated];
            } else {
                [self checkVersion];
            }
        } else {
            [self checkVersion];
        }
        
    } else {
        [self checkNeedUpdate];
    }
    
    [self createMessageTimer];
    [self enablePushNotification:NO];
    [app updateUnreadCountBadge];
    //自动登录
    if(app.logStatus && ![[[XMPPManager sharedInstance] xmppStream] isConnected])
    {
        [[[XMPPManager sharedInstance] xmppStream] connectWithTimeout:-1 error:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NEED_RELOCATION object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self enablePushNotification:NO];
    [app updateUnreadCountBadge];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

static NSMutableDictionary * app_history = nil;

NSString * getHistoryFilePath()
{
    NSString * account = [[NSUserDefaults standardUserDefaults] objectForKey:APP_USERNAME_KEY];
    if (account == nil) {
        account = @"anonymous";
    }
    NSString * historyPath = [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),account];
    //NSLog(@"path = %@",historyPath);
    NSString * historyFile = [NSString stringWithFormat:@"%@/history.plist",historyPath];
    //NSLog(@"file = %@",historyFile);
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:historyPath]) {
        [fileManager createDirectoryAtPath:historyPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![fileManager fileExistsAtPath:historyFile]) {
        app_history = [[NSMutableDictionary alloc] init];
        [app_history writeToFile:historyFile atomically:YES];
    }else {
        app_history = [[NSMutableDictionary alloc] initWithContentsOfFile:historyFile];
        
    }
    if (!app_history) {
        app_history = [[NSMutableDictionary alloc] initWithContentsOfFile:historyFile];
    }
    return historyFile;
}

void setHistoryConfig(NSString * key , id value)
{
    NSString * historyFile = getHistoryFilePath();
    if (value) {
        app_history[key] = value;
    }else {
        [app_history removeObjectForKey:key];
    }
    [app_history writeToFile:historyFile atomically:YES];
}

id getHistoryConfig(NSString *key){
    getHistoryFilePath();
    return app_history[key];
}

