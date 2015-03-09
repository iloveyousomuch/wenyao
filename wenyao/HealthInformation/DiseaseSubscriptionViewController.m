//
//  DiseaseSubscriptionViewController.m
//  wenyao
//
//  Created by Pan@QW on 14-9-24.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "DiseaseSubscriptionViewController.h"
#import "DiseaseSubscriptionTableViewCell.h"
#import "AddNewDiseaseSubscriptionViewController.h"
#import "Constant.h"
#import "DetailSubscriptionListViewController.h"
#import "HTTPRequestManager.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "SVProgressHUD.h"

@interface DiseaseSubscriptionViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray    *subscriptionList;
@property (nonatomic, strong) UIImageView       *noneHintImage;
@property (nonatomic, strong) UILabel           *noneHintLabel;

@property (nonatomic, strong) dispatch_queue_t queueDisease;

@end

@implementation DiseaseSubscriptionViewController
@synthesize tableView;


- (void)setupTableView
{
    CGRect rect = self.view.frame;
    if(self.subType) {
        rect.size.height -= 64;
    }else{
        rect.size.height -= 64 + 35 + 44;
    }
    self.subscriptionList = [NSMutableArray arrayWithCapacity:10];
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.rowHeight = 70;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
}

- (void)setupHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,APP_W, 170)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 120)];
    imageView.image = [UIImage imageNamed:@"健康资讯_慢病订阅banner.png"];
    [headerView addSubview:imageView];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setBackgroundColor:[UIColor whiteColor]];
    button.frame = CGRectMake(0, imageView.frame.origin.y + imageView.frame.size.height, APP_W, headerView.frame.size.height - imageView.frame.size.height);
    [button addTarget:self action:@selector(addNewDiseaseSubscription:) forControlEvents:UIControlEventTouchDown];
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 200, 20)];
    descLabel.font = [UIFont systemFontOfSize:14.5f];
    descLabel.text = @"添加更多慢病订阅";
    [button addSubview:descLabel];
    UIImageView *addIcon = [[UIImageView alloc] initWithFrame:CGRectMake(295, 18 , 15, 15)];
    addIcon.image = [UIImage imageNamed:@"健康资讯_慢病订阅icon.png"];
    [button addSubview:addIcon];
    [headerView addSubview:button];
    UILabel *separator = [[UILabel alloc] initWithFrame:CGRectMake(0, 169, APP_W, 1)];
    [separator setBackgroundColor:APP_SEPARATE_COLOR];
    [headerView addSubview:separator];
    self.tableView.tableHeaderView = headerView;
}

- (void)addNewDiseaseSubscription:(id)sender
{
 
    if (app.logStatus) {
        AddNewDiseaseSubscriptionViewController *addNewDiseaseViewController = [[AddNewDiseaseSubscriptionViewController alloc] initWithNibName:@"AddNewDiseaseSubscriptionViewController" bundle:nil];
        addNewDiseaseViewController.diseaseSubscriptionViewController = self;
        addNewDiseaseViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:addNewDiseaseViewController animated:YES];
    } else {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        
        loginViewController.isPresentType = NO;
        loginViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:loginViewController animated:YES];
    }
}

- (void)queryDrugGuideList:(BOOL)forece
{
    if([self.subscriptionList count] == 0 || forece)
    {
//        dispatch_barrier_async(self.queueDisease, ^{
            NSMutableDictionary *setting = [NSMutableDictionary dictionary];
            setting[@"token"] = app.configureList[APP_USER_TOKEN];
            setting[@"status"] = @"3";
            setting[@"currPage"] = @"1";
            setting[@"pageSize"] = @"100";
            [[HTTPRequestManager sharedInstance] getDrugGuideList:setting completion:^(id resultObj) {
                if([resultObj[@"result"] isEqualToString:@"OK"]) {
                    NSArray *array = resultObj[@"body"][@"data"];
                    
                    NSLog(@"the subscription list is %@, the return count is %@",self.subscriptionList, array);
                    //                [app.dataBase deleteAllDiseaseSubList];
                    if([array count] > 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.noneHintImage.hidden = YES;
                            self.noneHintLabel.hidden = YES;
                        });
                        
                        
                        if([app.dataBase checkAddNewDiseaseSubscribe:array]) {
                            if (self.subscriptionList.count == 0) {
                                self.subscriptionList = [app.dataBase queryAllDiseaseSub];
                            }
                            NSMutableArray *arrAdd = [@[] mutableCopy];
                            [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                NSDictionary *dict = (NSDictionary *)obj;
                                if (![app.dataBase getDiseaseFromDiseaseSubWithGuideId:dict[@"guideId"]]) {
                                    [arrAdd addObject:obj];
                                }
                            }];
                            [app.dataBase updateDiseaseSubWithArr:array];
                            [self.subscriptionList addObjectsFromArray:arrAdd];
                            NSMutableArray *arrDelete = [@[] mutableCopy];
                            [self.subscriptionList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                NSDictionary *dict = (NSDictionary *)obj;
                                if (![app.dataBase getDiseaseFromDiseaseSubWithGuideId:dict[@"guideId"]]) {
                                    [arrDelete addObject:obj];
                                }
                            }];
                            [self.subscriptionList removeObjectsInArray:arrDelete];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                            });
                            
                        } else if (self.subscriptionList.count == 0) {
                            [self.subscriptionList removeAllObjects];
                            [self.subscriptionList addObjectsFromArray:array];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                            });
                        } else {
                            NSMutableArray *arrDelete = [@[] mutableCopy];
                            [self.subscriptionList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                NSDictionary *dict = (NSDictionary *)obj;
                                if (![app.dataBase getDiseaseFromDiseaseSubWithGuideId:dict[@"guideId"]]) {
                                    [arrDelete addObject:obj];
                                }
                            }];
                            [self.subscriptionList removeObjectsInArray:arrDelete];
                            [app.dataBase updateDiseaseSubWithArr:array];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                            });
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.noneHintImage.hidden = NO;
                            self.noneHintLabel.hidden = NO;
                            [self.tableView reloadData];
                        });
                        
                        [self.subscriptionList removeAllObjects];
//                        [self.tableView reloadData];
                    }
                    
                }else{
                    
                }
            } failure:^(NSError *error) {
                NSLog(@"error is %@",error);
            }];

//        });
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    self.queueDisease = dispatch_queue_create("com.quanwei.perry", DISPATCH_QUEUE_CONCURRENT);
    [self.view setBackgroundColor:APP_BACKGROUND_COLOR];
    self.noneHintImage = [[UIImageView alloc] initWithFrame:CGRectMake(110, 200, 99, 99)];
    self.noneHintImage.image = [UIImage imageNamed:@"健康资讯_慢病订阅_未订阅.png"];
    self.noneHintLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 310, 200, 25)];
    self.noneHintLabel.textColor = UICOLOR(119, 133, 146);
    self.noneHintLabel.text = @"您还没有添加订阅哦!";
    [self setupTableView];
    [self setupHeaderView];
    [self.tableView addSubview:self.noneHintImage];
    [self.tableView addSubview:self.noneHintLabel];
    self.noneHintImage.hidden = YES;
    self.noneHintLabel.hidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hadNewDisease) name:APP_HAS_NEW_DISEASE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hadLogoutSuccess) name:QUIT_OUT object:nil];
}

- (void)hadNewDisease
{
    [self loadDiseaseListFromLocal];
}

- (void)hadLogoutSuccess
{
    [app showDiseaseBudge:NO];
}

- (void)loadDiseaseListFromLocal
{
    if (self.subscriptionList.count > 0) {
        [self.subscriptionList removeAllObjects];
    }
    self.subscriptionList = [app.dataBase queryAllDiseaseSub];
    if(self.subscriptionList.count > 0){
        self.noneHintImage.hidden = YES;
        self.noneHintLabel.hidden = YES;
    }
    else{
        self.noneHintImage.hidden = NO;
        self.noneHintLabel.hidden = NO;
    }
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([app.dataBase checkAllDiseaseReaded]) {
        [app showDiseaseBudge:NO];
    }
    if (app.logStatus) {
        
        if (app.currentNetWork == kNotReachable) {
            [self loadDiseaseListFromLocal];
        } else {
            [self queryDrugGuideList:YES];
        }
        
    } else {
        [self.subscriptionList removeAllObjects];
        [self.tableView reloadData];
        if(self.subscriptionList.count <= 0){
            self.noneHintImage.hidden = NO;
            self.noneHintLabel.hidden = NO;
        }
        [app showDiseaseBudge:NO];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        __block NSDictionary *dict = self.subscriptionList[indexPath.row];
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        setting[@"token"] = app.configureList[APP_USER_TOKEN];
        setting[@"drugGuideId"] = dict[@"guideId"];
        
        [[HTTPRequestManager sharedInstance] deleteMsgDrugGuide:setting completion:^(id resultObj) {
            if([resultObj[@"result"] isEqualToString:@"OK"]){
                NSDictionary *dicDelete = self.subscriptionList[indexPath.row];
                [app.dataBase deleteDiseaseSubWithGuideId:dicDelete[@"guideId"]];
//                if ([app.dataBase checkAllDiseaseReaded]) {
//                    [app showDiseaseBudge:NO];
//                }
                [self.subscriptionList removeObjectAtIndex:indexPath.row];
                [self.tableView reloadData];
                if(self.subscriptionList.count == 0) {
                    self.noneHintImage.hidden = NO;
                    self.noneHintLabel.hidden = NO;
                }
            }
        } failure:NULL];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    return [self.subscriptionList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *DiseaseSubscriptionCellIdentifier = @"DiseaseSubscriptionIdentifier";
    DiseaseSubscriptionTableViewCell *cell = (DiseaseSubscriptionTableViewCell *)[atableView dequeueReusableCellWithIdentifier:DiseaseSubscriptionCellIdentifier];
    if(cell == nil)
    {
        UINib *nib = [UINib nibWithNibName:@"DiseaseSubscriptionTableViewCell" bundle:nil];
        [atableView registerNib:nib forCellReuseIdentifier:DiseaseSubscriptionCellIdentifier];
        cell = (DiseaseSubscriptionTableViewCell *)[atableView dequeueReusableCellWithIdentifier:DiseaseSubscriptionCellIdentifier];
    }
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 57 - 0.5, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [cell addSubview:line];
    
    NSDictionary *dict = self.subscriptionList[indexPath.row];
    BOOL hasRead = [app.dataBase getHasReadFromDiseaseSubWithGuideId:dict[@"guideId"]];
    if (hasRead) {
        cell.indicateImage.hidden = YES;
    } else {
        cell.indicateImage.hidden = NO;
    }
    cell.titleLabel.text = dict[@"title"];
    cell.contentLabel.frame = CGRectMake(12, cell.titleLabel.frame.origin.y + 23, cell.contentLabel.frame.size.width, cell.contentLabel.frame.size.height);
    cell.contentLabel.text = dict[@"content"];
    NSString *strTime;
    if ([dict[@"displayTime"] isKindOfClass:[NSNull class]]) {
        strTime = @"";
    } else {
        strTime = dict[@"displayTime"];
    }
    
    if (strTime.length >= 10) {
        cell.dateLabel.text = [strTime substringToIndex:10];
    } else {
        cell.dateLabel.text = strTime;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        return;
    }
    if (app.logStatus == YES) {
        NSDictionary *dict = self.subscriptionList[indexPath.row];
        DetailSubscriptionListViewController *detailSubscriptionViewController = [[DetailSubscriptionListViewController alloc] init];
        [app.dataBase updateHasReadFromDiseaseWithId:dict[@"guideId"] hasRead:YES];
        DiseaseSubscriptionTableViewCell *cell = (DiseaseSubscriptionTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.indicateImage.hidden = YES;
        detailSubscriptionViewController.infoDict = dict;
        detailSubscriptionViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailSubscriptionViewController animated:YES];
    } else {


    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
