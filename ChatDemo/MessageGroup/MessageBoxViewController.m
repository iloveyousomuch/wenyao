//
//  MessageBoxViewController.m
//  wenyao
//
//  Created by garfield on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "MessageBoxViewController.h"
#import "HomePageTableViewCell.h"
#import "XHDemoWeChatMessageTableViewController.h"
#import "AppDelegate.h"
#import "MKNumberBadgeView.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "XMPPManager.h"
#import "MGSwipeButton.h"
#import "ReturnIndexView.h"
#import "SVProgressHUD.h"


@interface MessageBoxViewController () <MGSwipeTableCellDelegate,ReturnIndexViewDelegate>

@property (nonatomic, strong) NSMutableArray        *historyList;
@property (nonatomic, strong) UIButton              *unreadMenu;
@property (nonatomic, strong) UIButton              *backCoverView;
@property (nonatomic, strong) ReturnIndexView *indexView;

@end

@implementation MessageBoxViewController

- (void)backToPreviousController:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:NO];
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
                    NSString *shortName = dict[@"shortName"];
                    if(!shortName || [shortName isEqualToString:@""]) {
                        shortName = dict[@"groupName"];
                    }
                    [app.dataBase updateHistory:dict[@"accountId"] avatarurl:dict[@"groupUrl"] groupName:shortName groupType:[NSNumber numberWithInteger:groupType] groupId:dict[@"groupId"]];
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
    [self.tableView reloadData];
}

- (void)setAllMessageReaded
{
    [app.dataBase setAllMessageReaded];
    [self.tableView reloadData];
    //[self showUnreadMenu];
    [app updateUnreadCountBadge];
}

- (void)setupUnreadButton
{
    _backCoverView = [UIButton buttonWithType:UIButtonTypeCustom];
    _backCoverView.frame = CGRectMake(0, 0, APP_W, APP_H);
    [_backCoverView setBackgroundColor:[UIColor clearColor]];
    _backCoverView.hidden = YES;
    [self.view addSubview:_backCoverView];
    [_backCoverView addTarget:self action:@selector(dismissUnreadMenu:) forControlEvents:UIControlEventTouchDown];
    
    _unreadMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *menuImage = [UIImage imageNamed:@"全部消息标为已读.png"];
    [_unreadMenu setBackgroundImage:menuImage forState:UIControlStateNormal];

    _unreadMenu.translatesAutoresizingMaskIntoConstraints = NO;
    [_unreadMenu setTitle:@"全部消息标为已读" forState:UIControlStateNormal];
    _unreadMenu.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [_unreadMenu setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_unreadMenu addTarget:self action:@selector(setAllMessageReaded) forControlEvents:UIControlEventTouchDown];
    
    float hPadding = APP_W - menuImage.size.width - 15;
    float hWidth = menuImage.size.width;
    float vHeight = menuImage.size.height;

    [self.view addSubview:_unreadMenu];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-hPadding-[_unreadMenu(hWidth)]" options:0 metrics:@{@"hPadding":[NSNumber numberWithFloat:hPadding],@"hWidth":[NSNumber numberWithFloat:hWidth]} views:NSDictionaryOfVariableBindings(_unreadMenu,self.view)]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[_unreadMenu(vHeight)]" options:0 metrics:@{@"vHeight":[NSNumber numberWithFloat:vHeight]} views:NSDictionaryOfVariableBindings(_unreadMenu,self.view)]];
    _unreadMenu.hidden = YES;
    
    
}

- (void)showUnreadMenu
{
    [UIView animateWithDuration:0.25f animations:^{
        self.unreadMenu.hidden = !self.unreadMenu.hidden;
    } completion:^(BOOL finished) {
        if(self.unreadMenu.hidden) {
            _backCoverView.hidden = YES;
        }else{
            _backCoverView.hidden = NO;
        }
    }];
}

- (IBAction)dismissUnreadMenu:(id)sender
{
    self.unreadMenu.hidden = YES;
    _backCoverView.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:UICOLOR(236, 240, 241)];
    self.historyList = [NSMutableArray arrayWithCapacity:15];
    [[[XMPPManager sharedInstance] xmppStream] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.title = @"消息盒子";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHistory:) name:LOGIN_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHistory:) name:MESSAGE_NEED_UPDATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHistory:) name:OFFICIAL_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitAccount:) name:QUIT_OUT object:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"右上角更多.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showUnreadMenu)];
    self.historyList = [app.dataBase selectAllHistroy];
    [self setupUnreadButton];
    [self setUpRightItem];
    
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
    self.indexView = [ReturnIndexView sharedManagerWithImage:@[@"icon home.PNG",@"icon mark.PNG"] title:@[@"首页",@"全部已读"]];
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
        [self setAllMessageReaded];
    }
    
}
- (void)delayPopToHome
{
    [app.tabBarController setSelectedIndex:0];
}
#pragma mark---------------------------------------------跳转到首页-----------------------------------------------


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshInformation:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

    if(direction == MGSwipeDirectionRightToLeft && index == 0)
    {
        return [self createRightButtons:1 stick:YES];;
    }else if (direction == MGSwipeDirectionRightToLeft) {
        return [self createRightButtons:2 stick:YES];
    }
    return nil;
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSUInteger currentIndex = indexPath.row;
    if (currentIndex == 0)
    {
        //清除全维药师历史记录
        [app.dataBase deleteFromofficialMessages];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }else{
        NSDictionary *dict = self.historyList[currentIndex - 1];
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
            
            [self.historyList removeObjectAtIndex:currentIndex - 1];
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

#pragma mark
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.historyList.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    switch (index)
    {
        case 0:
        {
            cell.sendIndicateImage.hidden = YES;
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
            NSDictionary *dict = self.historyList[index - 1];
            cell.titleLabel.text = dict[@"groupName"];
            NSUInteger timestamp = [dict[@"timestamp"] integerValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
            BOOL sendStatus = [app.dataBase getMessageSendStatus:dict[@"UUID"]];
            CGRect rect = cell.contentLabel.frame;
            if(sendStatus) {
                //发送成功
                cell.sendIndicateImage.hidden = YES;
                rect.origin.x = 74;
                
            }else{
                //发送失败
                cell.sendIndicateImage.hidden = NO;
                rect.origin.x = 97;
            }
            cell.contentLabel.frame = rect;
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

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row)
    {
        case 0:
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
                NSDictionary *dict = self.historyList[indexPath.row - 1];
                messageViewController.infoDict = dict;
                messageViewController.title = dict[@"groupName"];
                messageViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:messageViewController animated:YES];
            }
        }
            break;
    }
}


@end
