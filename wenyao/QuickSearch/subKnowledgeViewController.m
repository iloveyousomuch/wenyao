//
//  subKnowledgeViewController.m
//  wenyao
//
//  Created by 李坚 on 15/1/20.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "subKnowledgeViewController.h"
#import "SVProgressHUD.h"
#import "MJRefresh.h"
#import "answerTableViewCell.h"
#import "DataBase.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "UIViewController+isNetwork.h"

#define SECTION_H 50.0f
#define SECTION_LABEL_H 30.0f
@interface subKnowledgeViewController ()
{
    int currentPage;
    NSInteger didSection;
    BOOL isExtend;
    float rowHeight;
}
@end

@implementation subKnowledgeViewController

- (id)init{
    if (self = [super init]) {
        didSection = 0;
        isExtend = YES;
        self.regularList = [NSMutableArray array];
        self.tableView = [[UITableView alloc]init];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView setFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H - 35)];
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
        self.tableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
        self.tableView.footerReleaseToRefreshText = @"松开加载更多数据了";
        self.tableView.footerRefreshingText = @"正在帮你加载中";
        [self.view addSubview:self.tableView];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"常备必知";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidCurrentView{
    
    currentPage = 1;
    self.regularList = [[NSMutableArray alloc]init];
    [self loadData];
}

- (void)loadData{

    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"classId"] = self.infoDict[@"id"];
    setting[@"currPage"] = @(currentPage);
    setting[@"pageSize"] = @(15);
    
    [[HTTPRequestManager sharedInstance]findKnowledge:setting completionSuc:^(id resultObj){
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                [self.regularList addObjectsFromArray:resultObj[@"body"][@"data"]];
                NSString *str = [NSString stringWithFormat:@"%@",self.infoDict[@"id"]];
                [app.cacheBase removeAllUsallyKnowledge:str];
                
                if(self.regularList.count > 0){
                    [app.cacheBase insertIntoUsallyKnowledge:self.regularList classId:self.infoDict[@"id"]];
                }
                [self.tableView reloadData];
                currentPage++;
                [self.tableView footerEndRefreshing];
            }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        [self.tableView footerEndRefreshing];
        NSString *str = [NSString stringWithFormat:@"%@",self.infoDict[@"id"]];
        self.regularList = [app.cacheBase selectUsallyKnowledge:str];
        [self.tableView reloadData];
        if(self.regularList.count > 0){
            [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试!" duration:1.0f];
        }
        else{
            if([self isNetWorking]){
                [self addNetView];
            }
        }
    }];
}

- (void)BtnClick{
    
    if(![self isNetWorking]){
        
        [[self.view viewWithTag:999] removeFromSuperview];
        [self loadData];
    }
}

- (void)footerRereshing{
    
    [self loadData];
}

#pragma mark - UITableViewDataSource

#pragma mark ------ section ------

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return SECTION_H;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize size = [[self replaceSpecialStringWith:self.regularList[indexPath.section][@"answer"]] sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:CGSizeMake(SCREEN_W - 20, 2000)];
    
    return size.height + 20;

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.regularList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(didSection == section && isExtend)
        return 1;
    else{
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView * mView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, SECTION_H)];
    mView.backgroundColor = [UIColor whiteColor];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.tag = section;
    [button addTarget:self action:@selector(sectionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, APP_W, SECTION_H);
    [mView addSubview:button];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, (SECTION_H-SECTION_LABEL_H)/2-1, SCREEN_W - 10, SECTION_LABEL_H+2)];
    
    titleLabel.text = self.regularList[section][@"question"];
    titleLabel.textColor = UIColorFromRGB(0x333333);
    titleLabel.font = Font(15.0f);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [button addSubview:titleLabel];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, mView.frame.size.height - 0.5, SCREEN_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [mView addSubview:line];
    
    return mView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * cellIdentifier = @"cellIdentifier";
    answerTableViewCell * cell = (answerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray * nibs = [[NSBundle mainBundle] loadNibNamed:@"answerTableViewCell" owner:self options:nil];
        cell = nibs[0];
    }
    
    NSString *str = [self replaceSpecialStringWith:self.regularList[indexPath.section][@"answer"]];
    
    cell.titeLabel.text = str;
    cell.titeLabel.textColor = UIColorFromRGB(0x333333);
    
    CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:CGSizeMake(SCREEN_W - 20, 2000)];
    cell.titeLabel.frame = CGRectMake(15, 10, size.width, size.height);
//    
//    cell.layer.masksToBounds = YES;
//    cell.layer.borderWidth = 0.5f;
//    cell.layer.borderColor = UIColorFromRGB(0x666666).CGColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
}

- (void)sectionButtonClick:(UIButton *)button{
    
    if (didSection == button.tag) {//与上一次点击的是同一行
        if (isExtend) {   //如果现在是展开状态(那么将其收起)
            isExtend = NO;
        }
        else{  //如果现在时收起状态(那么将其展开)
            didSection = button.tag;
            isExtend = YES;
        }
    }
    else{
        didSection = button.tag;
        isExtend = YES;
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.regularList.count)] withRowAnimation:UITableViewRowAnimationFade];
//    [self.tableView reloadData];
}


@end