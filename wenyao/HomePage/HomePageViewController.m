//
//  HomePageViewController.m
//  wenyao
//
//  Created by Meng on 14-9-10.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "HomePageViewController.h"
#import "UIImageView+WebCache.h"
#import "ConsultPharmacyViewController.h"
#import "TagCollectionView.h"
#import "TagCollectionFlowLayout.h"
#import "AskMedicineShopViewController.h"
#import "MyMedicineViewController.h"
#import "MyPharmacyViewController.h"
#import "HomePageTableViewCell.h"
#import "XHDemoWeChatMessageTableViewController.h"
#import "MJRefresh.h"
#import "XMPPManager.h"
#import "HealthyScenarioViewController.h"
#import "AppDelegate.h"
#import "MKNumberBadgeView.h"
#import "HTTPRequestManager.h"
#import "LoginViewController.h"
#import "AddNewMedicineViewController.h"
#import "SearchSliderViewController.h"
#import "MGSwipeButton.h"
#import "SVProgressHUD.h"
#import "ConsultQuizViewController.h"


@interface HomePageViewController ()<UITableViewDelegate,
UITableViewDataSource,MGSwipeTableCellDelegate>

@property (nonatomic, strong) NSMutableArray        *historyList;
@property (nonatomic, assign) RemindType            remindType;

@end

@implementation HomePageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarController.tabBar.backgroundColor = UIColorFromRGB(0xffffff);
        
    }
    return self;
}

- (void)setupTableView
{
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, self.headerView.frame.size.height - 0.5, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [self.headerView addSubview:line];
    
    CGRect rect = self.view.frame;
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.showsVerticalScrollIndicator = NO;
    __weak typeof (self) weakSelf = self;
    [self.tableView addHeaderWithCallback:^{
        [weakSelf.tableView headerEndRefreshing];
        if(app.currentNetWork == NotReachable)
        {
            [SVProgressHUD showErrorWithStatus:@"网络未连接，请稍后再试" duration:0.8f];
            return;
        }
        [weakSelf refreshInformation:NO];
    }];
    self.tableView.headerPullToRefreshText = @"下拉刷新";
    self.tableView.headerReleaseToRefreshText = @"松开刷新";
    self.tableView.headerRefreshingText = @"正在刷新";
    [self.view addSubview:self.tableView];
}

//收到新消息了 需要立即更新此界面
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    //收到消息,插入数据库
    NSXMLElement *notification = [iq elementForName:@"notification"];
    if(notification && [[notification xmlns] isEqualToString:@"androidpn:iq:notification"])
    {
        NSUInteger messageType = [[notification elementForName:@"msType"] stringValueAsInt32];
        if(messageType == XHBubbleMessageMediaTypeQuitout)
        {
            return YES;
        }
        [self refreshHistory:nil];
    }
    return YES;
}

- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq
{
    NSXMLElement *notification = [iq elementForName:@"notification"];
    if(notification && [[notification xmlns] isEqualToString:@"androidpn:iq:notification"])
    {
        [self refreshHistory:nil];
    }
}

- (void)refreshHistory:(NSNotification *)noti
{
    [self.historyList removeAllObjects];
    self.historyList = [app.dataBase selectAllHistroy];
    [self.tableView reloadData];
    [self refreshInformation:YES];
}

- (void)refreshInformation:(BOOL)cache
{
    NSMutableArray *relateidArray = nil;
    if(cache) {
        relateidArray = [app.dataBase selectRelatedidWithoutGroupname];
    }else{
        relateidArray = [app.dataBase selectAllRelatedid];
    }
    if(relateidArray.count == 0){
        return;
    }else{
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        NSMutableArray *accountIds = [NSMutableArray arrayWithCapacity:10];
        for(NSDictionary *dict in relateidArray){
            NSDictionary *dict2 = @{@"accountId":dict[@"relatedid"]};
            [accountIds addObject:dict2];
        }
        setting[@"accountIds"] = accountIds;
        [[HTTPRequestManager sharedInstance] queryBranhGroupByStoreAcc:setting completion:^(id resultObj) {
            if([resultObj[@"result"] isEqualToString:@"OK"]) {
                NSArray *array = resultObj[@"body"][@"data"];
                
                for(NSDictionary *dict in array)
                {
                    NSInteger groupType = [dict[@"groupType"] integerValue];
                    [app.dataBase updateHistory:dict[@"accountId"] avatarurl:dict[@"groupUrl"] groupName:dict[@"groupName"] groupType:[NSNumber numberWithInteger:groupType] groupId:dict[@"groupId"]];
                }
                self.historyList = [app.dataBase selectAllHistroy];
                [self.tableView reloadData];
            }
        } failure:NULL];
    }
}

- (void)quitAccount:(NSNotification *)noti
{
    [self.historyList removeAllObjects];
    self.remindType = RemindLogin;
    [self.tableView reloadData];
}

- (void)checkUnCompleteInformationMedicine
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"currPage"] = @"1";
    setting[@"pageSize"] = @"100";
    [[HTTPRequestManager sharedInstance] queryMyBox:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"])
        {
            NSArray *array = resultObj[@"body"][@"data"];
            BOOL checkResult = NO;
            for(NSDictionary *dict in array)
            {
                NSString *boxId = dict[@"boxId"];
                NSString *productName = dict[@"productName"];
                NSString *productId = dict[@"productId"];
                NSString *source = dict[@"source"];
                if(!source)
                    source = @"";
                NSString *useName = dict[@"useName"];
                if(!useName)
                    useName = @"";
                NSString *createtime = dict[@"createtime"];
                if(!createtime)
                    createtime = @"";
                NSString *effect = @"";
                if(dict[@"effect"]){
                    effect = dict[@"effect"];
                }
                NSString *useMethod = @"";
                if(dict[@"useMethod"])
                    useMethod = dict[@"useMethod"];
                NSString *perCount = @"";
                if(dict[@"perCount"])
                    perCount = [NSString stringWithFormat:@"%@",dict[@"perCount"]];
                if(!perCount)
                    perCount = @"";
                NSString *unit = @"";
                if(dict[@"unit"])
                    unit = dict[@"unit"];
                NSString *intervalDay = @"";
                if(dict[@"intervalDay"]){
                    intervalDay = [NSString stringWithFormat:@"%@",dict[@"intervalDay"]];
                }
                NSString *drugTime = @"";
                if(dict[@"drugTime"]){
                    drugTime = [NSString stringWithFormat:@"%@",dict[@"drugTime"]];
                }

                NSString *drugTag = @"";
                if(dict[@"drugTag"])
                    drugTag = dict[@"drugTag"];
                if(!drugTag)
                    drugTag = @"";
                NSString *productEffect = dict[@"productEffect"];
                if(!productEffect)
                    productEffect = @"";
                [app.dataBase insertIntoMybox:boxId productName:productName productId:productId source:source useName:useName createtime:createtime effect:effect useMethod:useMethod perCount:perCount unit:unit intervalDay:intervalDay drugTime:drugTime drugTag:drugTag productEffect:productEffect];
                if(dict[@"useMethod"] && ![[NSString stringWithFormat:@"%@",dict[@"useMethod"]] isEqualToString:@""] && dict[@"perCount"] && ![[NSString stringWithFormat:@"%@",dict[@"perCount"]] isEqualToString:@""] && dict[@"unit"] && ![[NSString stringWithFormat:@"%@",dict[@"unit"]] isEqualToString:@""] && dict[@"useName"] && ![[NSString stringWithFormat:@"%@",dict[@"useName"]] isEqualToString:@""])
                {
                    
                }else{
                    checkResult = YES;
                }
            }
            if(checkResult) {
                self.remindType = RemindUncompleten;
            }else{
                self.remindType = RemindNone;
            }
            [self.tableView reloadData];
        }
    } failure:NULL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.frame = [UIScreen mainScreen].bounds;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitAccount:) name:QUIT_OUT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUnCompleteInformationMedicine) name:LOGIN_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUnCompleteInformationMedicine) name:PHARMACY_NEED_UPDATE object:nil];
    
    self.remindType = RemindLogin;
    [self.view setBackgroundColor:UICOLOR(236, 240, 241)];
    self.historyList = [NSMutableArray arrayWithCapacity:15];
    [[[XMPPManager sharedInstance] xmppStream] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.title = @"我的问药";
    [self setupTableView];
    self.tableView.tableHeaderView = self.headerView;
    UIBarButtonItem *searchBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"导航栏_搜索icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pushIntoSearch:)];
    self.navigationItem.rightBarButtonItem = searchBarButton;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHistory:) name:LOGIN_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHistory:) name:MESSAGE_NEED_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHistory:) name:OFFICIAL_MESSAGE object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshInformation:NO];
}

- (IBAction)pushIntoSearch:(id)sender
{
    SearchSliderViewController * searchViewController = [[SearchSliderViewController alloc] init];
    searchViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewController animated:NO];
}

- (IBAction)pushIntoMyPharmacy:(id)sender
{
    if(!app.logStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
        return;
    }
    MyPharmacyViewController *myPharmacyViewController = [[MyPharmacyViewController alloc] init];
    myPharmacyViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myPharmacyViewController animated:YES];
}

- (IBAction)pushIntoIMPharmacy:(id)sender
{
//    if(!app.logStatus) {
//        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
//        UINavigationController *navgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
//        loginViewController.isPresentType = YES;
//        [self presentViewController:navgationController animated:YES completion:NULL];
//        return;
//    }
    
    ConsultPharmacyViewController *consultPharmacyViewController = [[ConsultPharmacyViewController alloc] init];
    consultPharmacyViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:consultPharmacyViewController animated:YES];
}

- (IBAction)pushIntoAddMedicine:(id)sender
{
//    if(!app.logStatus) {
//        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
//        UINavigationController *navgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
//        loginViewController.isPresentType = YES;
//        [self presentViewController:navgationController animated:YES completion:NULL];
//        return;
//    }
    UIStoryboard *sbConsult = [UIStoryboard storyboardWithName:@"ConsultMedicine" bundle:nil];
    ConsultQuizViewController *viewControllerConsult = [sbConsult instantiateViewControllerWithIdentifier:@"ConsultQuizViewController"];
    [self.navigationController pushViewController:viewControllerConsult animated:YES];
    return;

    AddNewMedicineViewController *addNewMedicineViewController = [[AddNewMedicineViewController alloc] init];
    __weak HomePageViewController *weakSelf = self;
    addNewMedicineViewController.blockPush = ^(){
        if(!app.logStatus) {
            LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            UINavigationController *navgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
            loginViewController.isPresentType = YES;
            [weakSelf presentViewController:navgationController animated:YES completion:NULL];
            return;
        }
        MyPharmacyViewController *myPharmacyViewController = [[MyPharmacyViewController alloc] init];
        myPharmacyViewController.hidesBottomBarWhenPushed = YES;
        [weakSelf.navigationController pushViewController:myPharmacyViewController animated:YES];
    };
    addNewMedicineViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addNewMedicineViewController animated:YES];
}

- (NSArray *)createRightButtons:(int)number stick:(BOOL)stick
{
    NSMutableArray * result = [NSMutableArray array];
    if(number == 1) {
        NSString* titles[1] = {@"清除记录"};
        UIColor * colors[1] = {[UIColor redColor]};
        for (int i = 0; i < number; ++i)
        {
            MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
                return YES;
            }];
            [result addObject:button];
        }
    }else{
        NSArray *titles = nil;

        titles = @[@"删除"];

        UIColor * colors[1] = {[UIColor redColor],};
        for (int i = 0; i < 1; ++i)
        {
            MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
                return YES;
            }];
            [result addObject:button];
        }
    }
    return result;
}

#pragma mark -
#pragma mark MGSwipeTableCellDelegate
-(NSArray*) swipeTableCell:(MGSwipeTableCell*)cell
  swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*)swipeSettings
         expansionSettings:(MGSwipeExpansionSettings*)expansionSettings;
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSUInteger index = indexPath.row;
    if(self.remindType != RemindNone) {
        index--;
    }
    if(index == 0)
        return nil;
    if(direction == MGSwipeDirectionRightToLeft && index == 1)
    {
        return nil;
    }else if (direction == MGSwipeDirectionRightToLeft) {
        return [self createRightButtons:2 stick:YES];
    }
    return nil;
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSUInteger currentIndex = indexPath.row;
    if(self.remindType != RemindNone) {
        currentIndex--;
    }
    if (currentIndex == 1)
    {
        //清除全维药师历史记录
        [app.dataBase deleteFromofficialMessages];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }else{
        NSDictionary *dict = self.historyList[currentIndex - 2];
        NSString *relatedid = dict[@"relatedid"];
        if (index == 0) {
            //清除会话 历史记录
            [app.dataBase deleteFromHistoryWithRelatedId:relatedid];
            [app.dataBase deleteFromMessagesWithName:relatedid];
            [app updateUnreadCountBadge];
            NSMutableDictionary *setting = [NSMutableDictionary dictionary];
            setting[@"token"] = app.configureList[APP_USER_TOKEN];
            setting[@"to"] = relatedid;
            [[HTTPRequestManager sharedInstance] delAllMessages:setting completion:NULL failure:NULL];
            
            [self.historyList removeObjectAtIndex:currentIndex - 2];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            //置顶或者取消置顶
            if([dict[@"stick"] integerValue] == 1)
            {
                [app.dataBase cancelHistoryStick:relatedid];
            }else{
                [app.dataBase setHistoryStick:relatedid];
            }
            self.historyList = [app.dataBase selectAllHistroy];
            [self.tableView reloadData];
        }
    }
    return YES;
}

#pragma mark ------tableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.remindType != RemindNone && indexPath.row == 0)
        return 38.0f;
    else
        return 66.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.remindType != RemindNone)
        return self.historyList.count + 3;
    else
        return self.historyList.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.remindType != RemindNone && indexPath.row == 0){
        static NSString *RemindCellIdentfier = @"RemindCellIdentifier";
        UITableViewCell *cell = [atableView dequeueReusableCellWithIdentifier:RemindCellIdentfier];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RemindCellIdentfier];
            
        }
        
        if(indexPath.row != 0){
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, self.tableView.rowHeight - 0.5, APP_W, 0.5)];
            line.backgroundColor = UIColorFromRGB(0xdbdbdb);
            [cell addSubview:line];
        }
        UIImageView *contentView = (UIImageView *)[cell.contentView viewWithTag:123];
        if(contentView) {
            [contentView removeFromSuperview];
        }
        contentView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 38)];
        [contentView setImage:[UIImage imageNamed:@"横条提醒_背景.png"]];
        UIImageView *faceImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 13, 13)];
        
        [contentView addSubview:faceImage];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 9, 260, 20)];
        label.font = [UIFont systemFontOfSize:13.0];
        if(self.remindType == RemindLogin) {
            label.text = @"免费注册登录立即获取专业用药服务。";
            faceImage.image = [UIImage imageNamed:@"笑脸icon.png"];
        }else{
            label.text = @"发现未完善的用药,为了安全立刻去完善。";
            faceImage.image = [UIImage imageNamed:@"提示icon.png"];
        }
        label.textColor = UIColorFromRGB(0xaa7711);
        [contentView addSubview:label];
        UIImageView *detailView = [[UIImageView alloc] initWithFrame:CGRectMake(300, 13, 12, 12)];
        detailView.image = [UIImage imageNamed:@"向右箭头_黄.png"];
        [contentView  addSubview:detailView];
        [cell.contentView addSubview:contentView];
        
        return cell;
    }else{
        static NSString *HomePageTableViewCellIdentfier = @"HomePageCellIdentifier";
        HomePageTableViewCell *cell = (HomePageTableViewCell *)[atableView dequeueReusableCellWithIdentifier:HomePageTableViewCellIdentfier];
        if(cell == nil)
        {
            UINib *nib = [UINib nibWithNibName:@"HomePageTableViewCell" bundle:nil];
            [atableView registerNib:nib forCellReuseIdentifier:HomePageTableViewCellIdentfier];
            cell = (HomePageTableViewCell *)[atableView dequeueReusableCellWithIdentifier:HomePageTableViewCellIdentfier];
        }
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 65, APP_W, 0.5)];
        line.backgroundColor = UIColorFromRGB(0xdbdbdb);
        [cell addSubview:line];
        
        NSUInteger index = indexPath.row;
        if(self.remindType != RemindNone)
        {
            index--;
        }
        
        cell.avatarImage.layer.masksToBounds = YES; 
        cell.avatarImage.layer.cornerRadius = 7.5f;
        switch (index)
        {
            case 0:
            {
                cell.titleLabel.text = @"健康方案";
                [cell.avatarImage setImage:[UIImage imageNamed:@"健康方案icon.png"]];
                cell.contentLabel.text = @"精选的健康方案,趁早关注保健康~";
                cell.dateLabel.text = @"";
                cell.nameIcon.image = [UIImage imageNamed:@"推荐.png"];
                break;
            }
            case 1:
            {
                cell.titleLabel.text = @"全维药事";
                [cell.avatarImage setImage:[UIImage imageNamed:@"全维药事icon.png"]];
                cell.nameIcon.image = [UIImage imageNamed:@"官方.png"];
                NSDictionary *dict = [app.dataBase selectLastOneUpdateOfficialMessage];
                if(dict){
                    cell.contentLabel.text = dict[@"body"];
                    double timestamp = [dict[@"timestamp"] doubleValue];
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
                    cell.dateLabel.text = [app updateFirstPageTimeDisplayer:date];
                }else{
                    cell.contentLabel.text = WELCOME_MESSAGE;
                
                    cell.dateLabel.text = @"";
                }
                
                NSUInteger unreadCount = [app.dataBase selectUnreadCountOfficialMessage];
                MKNumberBadgeView *badgeView = (MKNumberBadgeView *)[cell.contentView viewWithTag:888];
                if(!badgeView) {
                    badgeView = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(35, -5, 40, 40)];
                    badgeView.shadow = NO;
                    badgeView.tag = 888;
                }
                if(unreadCount != 0 )
                {
                    badgeView.value = unreadCount;
                    [cell.contentView addSubview:badgeView];
                }else{
                    [badgeView removeFromSuperview];
                }

                
                break;
            }
            default:
            {
                NSDictionary *dict = self.historyList[index - 2];
                cell.titleLabel.text = dict[@"groupName"];
                NSUInteger timestamp = [dict[@"timestamp"] integerValue];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
                cell.dateLabel.text = [app updateFirstPageTimeDisplayer:date];
                [cell.avatarImage setImageWithURL:[NSURL URLWithString:dict[@"avatarurl"]] placeholderImage:[UIImage imageNamed:@"药店默认头像.png"]];
                NSString *relatedid = dict[@"relatedid"];
                NSUInteger unreadCount = [app.dataBase selectUnreadCountMessage:relatedid];
                if([dict[@"messagetype"] integerValue] == XHBubbleMessageMediaTypeStarClient){
                    cell.contentLabel.text = [NSString stringWithFormat:@"评价内容:%@",dict[@"body"]];
                }else{
                    cell.contentLabel.text = dict[@"body"];
                }
                MKNumberBadgeView *badgeView = (MKNumberBadgeView *)[cell.contentView viewWithTag:888];
                if(!badgeView) {
                    badgeView = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(35, -5, 40, 40)];
                    badgeView.shadow = NO;
                    badgeView.tag = 888;
                }
                if(unreadCount != 0 )
                {
                    badgeView.value = unreadCount;
                    [cell.contentView addSubview:badgeView];
                }else{
                    [badgeView removeFromSuperview];
                }
                if([dict[@"groupType"] intValue] == 2) {
                    cell.nameIcon.image = [UIImage imageNamed:@"认证V.png"];
                }else{
                    cell.nameIcon.image = nil;
                }
            }
            break;
        }
        cell.delegate = self;
        return cell;
    }
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUInteger index = indexPath.row;
    if(self.remindType != RemindNone)
    {
        index--;
        if(indexPath.row == 0) {
            if(self.remindType == RemindLogin)
            {
                LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                UINavigationController *navgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
                loginViewController.isPresentType = YES;
                [self presentViewController:navgationController animated:YES completion:NULL];
            }else if (self.remindType == RemindUncompleten)
            {
                MyPharmacyViewController *myPharmacyViewController = [[MyPharmacyViewController alloc] init];
                myPharmacyViewController.hidesBottomBarWhenPushed = YES;
                myPharmacyViewController.shouldScrollToUncomplete = YES;
                [self.navigationController pushViewController:myPharmacyViewController animated:YES];
            }
            return;
        }
    }
    switch (index)
    {
        case 0:
        {
            //健康方案
            HealthyScenarioViewController * healthyScenario = [[HealthyScenarioViewController alloc] init];
            healthyScenario.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:healthyScenario animated:YES];
            break;
        }
        case 1:
        {
            XHDemoWeChatMessageTableViewController *messageViewController = [[XHDemoWeChatMessageTableViewController alloc] init];
            messageViewController.accountType = OfficialType;
            messageViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:messageViewController animated:YES];
            break;
        }
        default:
        {
            if (app.logStatus) {
                XHDemoWeChatMessageTableViewController *messageViewController = [[XHDemoWeChatMessageTableViewController alloc] init];
                NSDictionary *dict = self.historyList[index - 2];
                messageViewController.infoDict = dict;
                messageViewController.title = dict[@"groupName"];
                messageViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:messageViewController animated:YES];
            } else {
                LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                UINavigationController *navgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
                loginViewController.isPresentType = YES;
                [self presentViewController:navgationController animated:YES completion:NULL];
            }
        }
        break;
    }
    if (indexPath.row == 1) {
        
    }else{
        
    }
}

//    if(editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        NSInteger index = indexPath.row;
//        //删除该历史记录
//        if(self.remindType != RemindNone)
//        {
//            index--;
//        }
//        NSDictionary *dict = self.historyList[index - 2];
//        NSString *relatedid = dict[@"relatedid"];
//        
//        [app.dataBase deleteFromHistoryWithRelatedId:relatedid];
//        [app.dataBase setMessagesReadWithRelatedId:relatedid];
//        [self.historyList removeObjectAtIndex:index - 2];
//        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
// 
//    }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
