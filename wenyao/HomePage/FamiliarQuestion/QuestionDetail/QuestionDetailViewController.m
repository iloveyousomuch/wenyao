//
//  QuestionDetailViewController.m
//  wenyao
//
//  Created by qwyf0006 on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "QuestionDetailViewController.h"
#import "HTTPRequestManager.h"
#import "UIImageView+WebCache.h"
#import "Appdelegate.h"
#import "Constant.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "SBJson.h"
#import "ConsultQuizViewController.h"
#import "ReturnIndexView.h"


@interface QuestionDetailViewController ()<UITableViewDataSource,UITableViewDelegate,ReturnIndexViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (assign, nonatomic) int page;
@property (strong, nonatomic) UIView *noDataView;
@property (strong, nonatomic) NSString *logoUrl;
@property (strong, nonatomic) ReturnIndexView *indexView;

@end

@implementation QuestionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"问题详情";
    self.dataArray = [NSMutableArray arrayWithCapacity:0];

    [self setupTableView];
    [self setUpBottomView];
    
    self.noDataView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-200)/2, 90, 200, 60)];
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.noDataView.frame.size.width, self.noDataView.frame.size.height)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = @"暂无数据!";
    lab.textColor = [UIColor lightGrayColor];
    [self.noDataView addSubview:lab];
    self.noDataView.hidden = YES;
    [self.view addSubview:self.noDataView];
    
    self.view.backgroundColor = UIColorFromRGB(0xecf0f1);

    [self setUpRightItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutAction) name:QUIT_OUT object:nil];
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


- (void)logoutAction
{
    if (self.dataArray && self.dataArray.count > 0) {
        [self.dataArray removeAllObjects];
    }
}


- (void)setupTableView
{
    CGRect rect = self.view.frame;
    rect.size.height -=  (50+64) ;
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.rowHeight = 100.0f;
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = UIColorFromRGB(0xf5f5f5);
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.dataArray.count == 0) {
        self.page = 1;
        [self getQuestionDetailList];
    }
    [self.tableView reloadData];
}

- (void)viewDidCurrentView
{
    if (self.dataArray.count == 0) {
        self.page = 1;
        [self getQuestionDetailList];
    }
    [self.tableView reloadData];
}

- (void)getQuestionDetailList
{
    
    __weak QuestionDetailViewController *weakSelf = self;
    if (app.currentNetWork == kNotReachable) {
        [self loadCachedQuestionDetail];
    }else
    {
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        setting[@"classId"] = self.classId;
        setting[@"teamId"] = self.teamId;
        setting[@"currPage"] = [NSString stringWithFormat:@"%d",weakSelf.page];
        setting[@"pageSize"] = @"10";
        
        [[HTTPRequestManager sharedInstance] QueryFamiliarQuestiondetail:setting completion:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"])
            {
                NSArray *arr = resultObj[@"body"][@"data"];
                self.logoUrl = resultObj[@"body"][@"imgUrl"];
                
                if (weakSelf.page == 1) {
                    [self.dataArray removeAllObjects];
                    [app.cacheBase removeFamiliarQuestionDetailWithClassId:self.classId teamId:self.teamId];
                }
                
                
                [weakSelf cachedQuestionDetail:arr imgUrl:resultObj[@"body"][@"imgUrl"]];

                for (NSDictionary *dic in arr) {
                    [self.dataArray addObject:dic];
                }
                
                
                if (self.dataArray.count == 0) {
                    self.noDataView.hidden = NO;
                    self.tableView.hidden = YES;
                }else
                {
                    self.noDataView.hidden = YES;
                    self.tableView.hidden = NO;
                }
                
                [weakSelf.tableView reloadData];
            }
            [self.tableView footerEndRefreshing];
        } failure:^(NSError *error) {
            [self.tableView footerEndRefreshing];
        }];
    }
    
}

- (void)cachedQuestionDetail:(NSArray *)array imgUrl:(NSString *)imgUrl
{
    for (NSDictionary *dic in array)
    {
        [app.cacheBase insertIntoFamiliarQuestionDetailWithTeamId:self.teamId classId:self.classId content:dic[@"content"] role:[NSString stringWithFormat:@"%@",dic[@"role"]] imgUrl:imgUrl];
        
    }
}

- (void)loadCachedQuestionDetail
{
    if (self.dataArray.count > 0) {
        [self.dataArray removeAllObjects];
    }
    
    NSArray *arr = [app.cacheBase queryAllFamiliarQuestionDetailWithClassId:self.classId teamId:self.teamId];
    [self.dataArray addObjectsFromArray:arr];
    
    for (NSDictionary *dic in arr) {
        self.logoUrl = dic[@"imgUrl"];
    }
    
    if (self.dataArray.count == 0) {
        self.noDataView.hidden = NO;
        self.tableView.hidden = YES;
    }else
    {
        self.noDataView.hidden = YES;
        self.tableView.hidden = NO;
    }
    [self.tableView reloadData];
}

- (void)setUpBottomView
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50-64, self.view.frame.size.width, 50)];
    bgView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [bgView addSubview:line];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake((bgView.frame.size.width-275)/2, 5, 275, 40);
    [btn setBackgroundColor:UIColorFromRGB(0xff8a00)];
    [btn setTitle:@"我也要问药" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    [btn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    btn.layer.cornerRadius = 2.0;
    btn.layer.masksToBounds = YES;
    [btn addTarget:self action:@selector(askMedcineClick1) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:btn];
    [self.view addSubview:bgView];
}

- (void)askMedcineClick1
{
    UIStoryboard *sbConsult = [UIStoryboard storyboardWithName:@"ConsultMedicine" bundle:nil];
    ConsultQuizViewController *viewControllerConsult = [sbConsult instantiateViewControllerWithIdentifier:@"ConsultQuizViewController"];
    [self.navigationController pushViewController:viewControllerConsult animated:YES];
}
#pragma  mark----------------------列表代理------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.dataArray[indexPath.row];
    NSString *role;
    if ([dic[@"role"] isKindOfClass:[NSNumber class]])
    {
        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
        role = [numberFormatter stringFromNumber:dic[@"role"]];
    }else
    {
        role = dic[@"role"];
    }

    NSString *str = dic[@"content"];
    CGSize size = CGSizeZero;
    
    if ([role isEqualToString:@"1"]) {
        size = [str sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)];
    }else if ([role isEqualToString:@"2"]){
        size = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)];
    }
    return 47.0+size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.dataArray[indexPath.row];
    UITableViewCell *cell = nil;
    NSString *role;
    if ([dic[@"role"] isKindOfClass:[NSNumber class]])
    {
        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
        role = [numberFormatter stringFromNumber:dic[@"role"]];
    }else
    {
        role = dic[@"role"];
    }
    
    if ([role isEqualToString:@"1"])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell1"];
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width -234, 15, 234, 42)];
            //UIImage *image = [UIImage imageNamed:@"气泡_绿色 小.png"];
            UIImage *image = [UIImage imageNamed:@"80 1.PNG"];
            imgView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(25, 21, 25, 22) resizingMode:UIImageResizingModeStretch];
            
            [cell.contentView addSubview:imgView];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 190, 34)];
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = UIColorFromRGB(0x333333);
            [imgView addSubview:label];
            label.tag = 2;
            imgView.tag = 3;
            label.backgroundColor = [UIColor clearColor];
            label.numberOfLines = 0;
        }
    }else if ([role isEqualToString:@"2"])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell2"];
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake( 55, 15, 234, 42)];
//            UIImage *image = [UIImage imageNamed:@"气泡_白色 小.png"];
            UIImage *image = [UIImage imageNamed:@"80 2.PNG"];
            imgView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(25, 21, 25, 22) resizingMode:UIImageResizingModeStretch];
            [cell.contentView addSubview:imgView];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, 190, 34)];
            label.font = [UIFont systemFontOfSize:14];
            label.textColor = UIColorFromRGB(0x333333);
            [imgView addSubview:label];
            label.tag = 2;
            imgView.tag = 3;
            label.backgroundColor = [UIColor clearColor];
            label.numberOfLines = 0;
            
            UIImageView *logoImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 16, 40, 40)];
            logoImg.layer.cornerRadius = 20.0;
            logoImg.layer.masksToBounds = YES;
            NSLog(@"self.logoUrl===%@",self.logoUrl);
            if ([self.logoUrl isKindOfClass:[NSNull class]]) {
                [logoImg setImage:[UIImage imageNamed:@"默认药房.PNG"]];
            }else
            {
                [logoImg setImageWithURL:[NSURL URLWithString:self.logoUrl] placeholderImage:[UIImage imageNamed:@"默认药房.PNG"]];
            }
            
            [cell.contentView addSubview:logoImg];
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:3];
    NSString *str = dic[@"content"];
    NSString *content;
    
    if (str.length > 0) {
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        content = str;
        if (str.length >= 100) {
            content = [str substringWithRange:NSMakeRange(0, 99)];
            content = [content stringByAppendingString:@"..."];
        }
    }
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:2];
    
    
    if ([role isEqualToString:@"1"])
    {
        //QUESTION
        CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)];
        imgView.frame = CGRectMake(self.view.frame.size.width - size.width -27 - 10, imgView.frame.origin.y, size.width+30, 24+size.height);
        
        label.frame = CGRectMake(10, 5, size.width, size.height+10);
        
    }else if ([role isEqualToString:@"2"])
    {
        //ANSWER
        
        CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)];
        imgView.frame = CGRectMake(imgView.frame.origin.x, imgView.frame.origin.y, size.width+32, 25+size.height);
        label.frame = CGRectMake(label.frame.origin.x, 5, size.width, size.height +10);
        
    }
    
    label.text = content;
    return cell;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
