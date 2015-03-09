//
//  DetailSubscriptionListViewController.m
//  wenyao
//
//  Created by Pan@QW on 14-9-25.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "DetailSubscriptionListViewController.h"
#import "AppDelegate.h"
#import "UIScrollView+MJRefresh.h"
#import "SVProgressHUD.h"

@interface DetailSubscriptionListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray        *msgLogList;
@property (nonatomic, assign) NSInteger curPage;

@end

@implementation DetailSubscriptionListViewController
@synthesize tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    self.curPage = 1;
    self.title = self.infoDict[@"title"];
    self.msgLogList = [NSMutableArray arrayWithCapacity:10];
    [self setupTableView];
    [self queryMsgLogList];
}

- (void)queryMsgLogList
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"drugGuideId"] = self.infoDict[@"guideId"];
    setting[@"currPage"] = [NSString stringWithFormat:@"%d",self.curPage];
    setting[@"pageSize"] = @"10";
    [[HTTPRequestManager sharedInstance] queryMsgLogList:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]){
            if (self.curPage == 1) {
                [self.msgLogList removeAllObjects];
            }
            NSArray *array = resultObj[@"body"][@"data"];
//            for(NSDictionary *dict in array){
//                NSMutableDictionary *mutableDict = [dict mutableCopy];
//                mutableDict[@"expanded"] = @"0";
//                [self.msgLogList addObject:[dict mutableCopy]];
//            }
            
            for (int i = 0; i<array.count ; i++) {
                NSMutableDictionary * mutableDict = [[NSMutableDictionary alloc] initWithDictionary:array[i]];
                if (i == 0) {
                    mutableDict[@"expanded"] = @"1";
                }else{
                    mutableDict[@"expanded"] = @"0";
                }
                [self.msgLogList addObject:mutableDict];
                
            }
        
            
            [self.tableView reloadData];
            [self.tableView footerEndRefreshing];
        }
    } failure:^(NSError *error) {
        [self.tableView footerEndRefreshing];
    }];
}

- (void)setupTableView
{
    self.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height - 64);
    CGRect rect = self.view.frame;
//    rect = CGRectMake(0, 0, 320, 504);
    self.tableView = [[UIFolderTableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = APP_BACKGROUND_COLOR;
    [self.tableView setBackgroundColor:APP_BACKGROUND_COLOR];
    self.tableView.rowHeight = 44.0f;
    [self.view addSubview:self.tableView];
    
    __weak DetailSubscriptionListViewController *weakSelf = self;
    [self.tableView addFooterWithCallback:^{
        weakSelf.curPage ++;
        [weakSelf queryMsgLogList];
    }];
    self.tableView.footerPullToRefreshText = @"上拉可以刷新";
    self.tableView.footerReleaseToRefreshText = @"松开刷新了";
    self.tableView.footerRefreshingText = @"正在刷新中";
    
}

#pragma mark -
#pragma mark UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        return 44.0f;
    }else{
        NSDictionary *dict = self.msgLogList[indexPath.section];
        UIView *contentView = [self createViewFromDictionary:dict];
        return contentView.frame.size.height;
    }
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableDictionary *dict = self.msgLogList[section];
    
    if([dict[@"expanded"] isEqualToString:@"1"]){
        return 2;
    }else{
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return self.msgLogList.count;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *DetailsubscriptionIdentifier = @"DetailsubscriptionCellIdentifier";
    UITableViewCell *cell = [atableView dequeueReusableCellWithIdentifier:DetailsubscriptionIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DetailsubscriptionIdentifier];
    }
    [[cell.contentView viewWithTag:999] removeFromSuperview];
    NSMutableDictionary *dict = self.msgLogList[indexPath.section];
    
    if(indexPath.row == 0){
        cell.textLabel.text = dict[@"title"];
        cell.textLabel.font = Font(16);
        cell.textLabel.textColor = UIColorFromRGB(0x333333);
        UILabel *accessoryView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
        accessoryView.text = [dict[@"sendTime"] substringToIndex:10];
        accessoryView.font = [UIFont systemFontOfSize:12.0];
        accessoryView.textColor = UIColorFromRGB(0xbbbbbb);
        cell.accessoryView = accessoryView;
        
        
        
        
    }else{
        cell.accessoryView = nil;
        cell.textLabel.text = @"";
        UIView *contentView = [self createViewFromDictionary:dict];
        contentView.tag = 999;
        [cell.contentView addSubview:contentView];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableDictionary *dict = self.msgLogList[indexPath.section];
    if([dict[@"expanded"] isEqualToString:@"1"]){
        dict[@"expanded"] = @"0";
    }else{
        dict[@"expanded"] = @"1";
    }
    [self.tableView reloadData];
    if ([dict[@"expanded"] isEqualToString:@"1"]) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (UIView *)createViewFromDictionary:(NSDictionary *)dict
{
    // 设置点击喜欢按钮
    UIView *contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:APP_BACKGROUND_COLOR];
    
    
    CGSize size = [dict[@"content"] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(APP_W-20, 1999)];
    contentView.frame = CGRectMake(0, 0, APP_W, size.height + 15);
    
    //contentLabel
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.text = dict[@"content"];
    contentLabel.numberOfLines = 0;
    contentLabel.font = Font(14);
    contentLabel.textColor = UIColorFromRGB(0x333333);
    contentLabel.frame = CGRectMake(10, 0, APP_W-20, size.height);
    [contentView addSubview:contentLabel];
    
    //button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"普通喜欢icon.png"] forState:UIControlStateNormal];
    NSUInteger tag = [self.msgLogList indexOfObject:dict];
    //    button.tag = tag;
    [button addTarget:self action:@selector(likeClick:) forControlEvents:UIControlEventTouchDown];
    button.frame = CGRectMake(270, contentLabel.frame.origin.y + contentLabel.frame.size.height-10, 12, 12);
    [contentView addSubview:button];
    
    //btnClick
    UIButton *btnClick = [UIButton buttonWithType:UIButtonTypeCustom];
    btnClick.tag = tag;
    [btnClick addTarget:self action:@selector(likeClick:) forControlEvents:UIControlEventTouchDown];
    btnClick.frame = CGRectMake(260, contentLabel.frame.origin.y + contentLabel.frame.size.height - 20, 50, 32);
    [contentView addSubview:btnClick];

    //numberLabel
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(290, contentLabel.frame.origin.y + contentLabel.frame.size.height-12, 14, 14)];
    numberLabel.text = [NSString stringWithFormat:@"%@",dict[@"likeNumber"]];
    numberLabel.textColor = UICOLOR(173.0f, 173.0f, 173.0f);
    numberLabel.font = [UIFont systemFontOfSize:13.5];
    [contentView addSubview:numberLabel];
    
    
    
    
    
    
    
    
    if([dict[@"likeStatus"] intValue] == 0){
        [button setImage:[UIImage imageNamed:@"普通喜欢icon.png"] forState:UIControlStateNormal];
    }else{
        [button setImage:[UIImage imageNamed:@"已喜欢icon.png"] forState:UIControlStateNormal];
    }
//    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, contentView.frame.size.height - 1, APP_W, 1)];
//    separator.backgroundColor = APP_SEPARATE_COLOR;
//    [contentView addSubview:separator];
    return contentView;
}

- (void)likeClick:(UIButton *)sender
{
    NSMutableDictionary *dict = self.msgLogList[sender.tag];
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"objId"] = dict[@"msgId"];
    setting[@"objType"] = [NSNumber numberWithInt:2];
    
    if([dict[@"likeStatus"] intValue] == 0)
    {
        [[HTTPRequestManager sharedInstance] likeCountsPlus:setting completion:^(id resultObj) {
            if([resultObj[@"result"] isEqualToString:@"OK"]){
                NSMutableDictionary *dict = self.msgLogList[sender.tag];
                dict[@"likeStatus"] = @"1";
                NSInteger count = [dict[@"likeNumber"] intValue];
                count++;
                dict[@"likeNumber"] = [NSString stringWithFormat:@"%d",count];
                [self.tableView reloadData];
            }
        } failure:NULL];
    }else{
        [[HTTPRequestManager sharedInstance] likeCountsDecrease:setting completion:^(id resultObj) {
            if([resultObj[@"result"] isEqualToString:@"OK"]){
                NSMutableDictionary *dict = self.msgLogList[sender.tag];
                dict[@"likeStatus"] = @"0";
                NSInteger count = [dict[@"likeNumber"] intValue];
                count--;
                dict[@"likeNumber"] = [NSString stringWithFormat:@"%d",count];
                [SVProgressHUD showSuccessWithStatus:@"已取消喜欢" duration:0.8f];
                [self.tableView reloadData];
            }
        } failure:NULL];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
