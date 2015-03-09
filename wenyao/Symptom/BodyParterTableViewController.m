//
//  BodyParterTableViewController.m
//  quanzhi
//
//  Created by xiezhenghong on 14-8-8.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BodyParterTableViewController.h"
#import "Constant.h"
#import "SymptomViewController.h"
#import "SVProgressHUD.h"
#import "HTTPRequestManager.h"
#import "UIViewController+isNetwork.h"

@interface BodyParterTableViewController ()
{
    UIView * _nodataView;
}
@property (nonatomic, strong) NSMutableArray        *partList;

@end

@implementation BodyParterTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    if([self isNetWorking]){
        [self addNetView];
        return;
    }
    [self subViewDidLoad];
}

- (void)subViewDidLoad{
    
    self.partList = [NSMutableArray arrayWithCapacity:15];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setBackgroundColor:COLOR(242,242,242)];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_btn_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backToPreviousController:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    if([self.partList count] == 0)
    {
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        setting[@"sex"] = self.soureDict[@"sex"];
        setting[@"population"] = self.soureDict[@"population"];
        setting[@"position"] = self.soureDict[@"position"];
        setting[@"bodyCode"] = self.soureDict[@"bodyCode"];
        [[HTTPRequestManager sharedInstance] querySpmBody:setting completion:^(id resultObj) {
            [self.partList removeAllObjects];
            NSArray *array = resultObj[@"body"][@"data"];
            if([array count] > 0) {
                if (_nodataView) {
                    [_nodataView removeFromSuperview];
                    _nodataView = nil;
                }
                [self.partList addObjectsFromArray:array];
            }else{
                [self showNoDataViewWithString:@"暂无相关症状"];
            }
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            
        }];
    }
}


- (void)backToPreviousController:(id)sender
{
    if(self.containerViewController) {
        [self.containerViewController.navigationController popViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.partList.count == 0) {
        return 0;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.partList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *bodyTabelIdentifier = @"bodyTabelIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bodyTabelIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bodyTabelIdentifier];
    }
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5, 320, 0.5)];
    [separator setBackgroundColor:UIColorFromRGB(0xdbdbdb)];
    [cell addSubview:separator];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
    cell.textLabel.textColor = UIColorFromRGB(0x333333);
    cell.textLabel.text = self.partList[indexPath.row][@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SymptomViewController * svc = [[SymptomViewController alloc]init];
    svc.spmCode = self.partList[indexPath.row][@"bodyCode"];
    svc.requestType = bodySym;
    svc.requsetDic = self.soureDict;
    svc.title = self.partList[indexPath.row][@"name"];
    
    svc.containerViewController = self.containerViewController;
    
    if(self.containerViewController) {
        [self.containerViewController.navigationController pushViewController:svc animated:YES];
    }else{
        [self.navigationController pushViewController:svc animated:YES];
    }
}

#pragma mark - INDICTOR
-(void)showNoDataViewWithString:(NSString *)nodataPrompt
{
    if (_nodataView) {
        [_nodataView removeFromSuperview];
        _nodataView = nil;
    }
    if (_nodataView==nil) {
        _nodataView = [[UIView alloc]initWithFrame:self.view.bounds];
        _nodataView.backgroundColor = UIColorFromRGB(0xecf0f1);
        
        UIImageView *dataEmpty = [[UIImageView alloc]initWithFrame:RECT(0, 0, 75, 75)];
        dataEmpty.center = CGPointMake(APP_W/2, 130);
        dataEmpty.image = [UIImage imageNamed:@"无可能疾病icon.png"];
        [_nodataView addSubview:dataEmpty];
        
        UILabel* lable_ = [[UILabel alloc]initWithFrame:RECT(0,200, nodataPrompt.length*20,30)];
        lable_.tag = 201405220;
        lable_.font = Font(15);
        lable_.textColor = UIColorFromRGB(0x7e8d97);
        lable_.textAlignment = NSTextAlignmentCenter;
        lable_.center = CGPointMake(APP_W/2, 200);
        lable_.text = nodataPrompt;
        
        [_nodataView addSubview:lable_];
        [[UIApplication sharedApplication].keyWindow addSubview:_nodataView];
        [self.view insertSubview:_nodataView atIndex:self.view.subviews.count];
    }else
    {
        UILabel *label_ = (UILabel *)[_nodataView viewWithTag:201405220];
        label_.text = nodataPrompt;
        label_.textAlignment =NSTextAlignmentCenter;
        label_.frame = RECT(0,175, nodataPrompt.length*20,30);
        label_.center = CGPointMake(APP_W/2, label_.center.y);
        _nodataView.hidden = NO;
    }
}

@end
