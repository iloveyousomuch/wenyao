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

@interface subKnowledgeViewController ()
{
    int currentPage;
}
@end

@implementation subKnowledgeViewController

- (id)init{
    if (self = [super init]) {
        self.regularList = [NSMutableArray array];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView setFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H)];
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
        self.tableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
        self.tableView.footerReleaseToRefreshText = @"松开加载更多数据了";
        self.tableView.footerRefreshingText = @"正在帮你加载中";
        currentPage = 1;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"健康知识";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidCurrentView{
    
    [self loadData];
}

- (void)loadData{
    
    NSLog(@"%@",self.infoDict);
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"currClassId"] = self.infoDict[@"id"];
    setting[@"currPage"] = @(currentPage);
    setting[@"pageSize"] = @(PAGE_ROW_NUM);

    [[HTTPRequestManager sharedInstance]findKnowledge:setting completionSuc:^(id resultObj){
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                [self.regularList addObjectsFromArray:resultObj[@"body"][@"data"]];
//                [self.tableView reloadData];
                currentPage++;
                [self.tableView footerEndRefreshing];
            }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        [self.tableView footerEndRefreshing];
        [SVProgressHUD showErrorWithStatus:@"加载失败!" duration:0.8f];
    }];
}

- (void)footerRereshing{
    
    [self loadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.regularList.count;
}



@end