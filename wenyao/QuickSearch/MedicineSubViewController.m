//
//  MedicineSubViewController.m
//  wenyao
//
//  Created by Meng on 14-9-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "MedicineSubViewController.h"
#import "MedicineSubCell.h"
#import "AFNetworking.h"
#import "MedicineListViewController.h"
#import "DiseaseDetailViewController.h"
#import "SVProgressHUD.h"
#import "SearchSliderViewController.h"
#import "AppDelegate.h"
#import "ReturnIndexView.h"

#define SECTION_H 45
#define SECTION_LABEL_H 15

@interface MedicineSubViewController ()<ReturnIndexViewDelegate>
{

    BOOL isExtend;
    NSInteger didSection;
}

@property (nonatomic,retain)NSMutableArray *dataSource;
@property (nonatomic,retain)NSMutableArray *subDataSource;

@property (nonatomic,strong)UIImageView *imgViewArrow;
@property (nonatomic,strong)ReturnIndexView *indexView;
@end

@implementation MedicineSubViewController

- (id)init{
    if (self = [super init]) {
        self.tableView.frame = CGRectMake(0, 0, APP_W, APP_H-NAV_H);
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        self.dataSource = [NSMutableArray array];
        self.subDataSource = [NSMutableArray array];
        didSection = 1000;
        isExtend = NO;
#pragma 按钮的调整
        [self setRightItems];
//        UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"导航栏_搜索icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarButtonClick)];
//        self.navigationItem.rightBarButtonItem = rightBarButton;
        
        
        
    }
    return self;
}
-(void)setRightItems{
    UIView *ypflBarItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 55)];
    UIButton *searchButton = [[UIButton alloc] initWithFrame:CGRectMake(28, 0, 55, 55)];
    [searchButton setImage:[UIImage imageNamed:@"导航栏_搜索icon.png"]  forState:UIControlStateNormal];
    [searchButton addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchDown];
    [ypflBarItems addSubview:searchButton];
    
    UIButton *indexButton = [[UIButton alloc] initWithFrame:CGRectMake(65, 0, 55, 55)];
    [indexButton setImage:[UIImage imageNamed:@"icon-unfold.PNG"] forState:UIControlStateNormal];
    [indexButton addTarget:self action:@selector(showIndex) forControlEvents:UIControlEventTouchDown];
    [ypflBarItems addSubview:indexButton];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -20;
    self.navigationItem.rightBarButtonItems = @[fixed,[[UIBarButtonItem alloc] initWithCustomView:ypflBarItems]];
    
    
}
#pragma --index---
- (void)showIndex
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


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.dataSource.count > 0) {
        return;
    }else{
        [self.dataSource removeAllObjects];
        [self loadMedicineData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)rightBarButtonClick{
    SearchSliderViewController * searchViewController = [[SearchSliderViewController alloc] init];
    searchViewController.currentSelectedViewController = medicineViewController;
    searchViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewController animated:NO];
}

- (void)cacheAllMedicineTypeList:(NSArray *)arrSubType
{
    [app.cacheBase removeAllQuickSearchMedicineTypeList:self.classId];
    for (NSDictionary *dic in arrSubType) {
        [app.cacheBase insertQucikSearchMedicineTypeListWithClassId:dic[@"classId"]
                                                        description:dic[@"classDesc"]
                                                               name:dic[@"name"]
                                                               size:dic[@"size"]
                                                       childrenList:dic[@"childrens"]
                                                           parentID:self.classId];
    }
}

- (void)getCachedAllMedicineTypeList
{
    self.dataSource = [app.cacheBase queryAllQuickSearchMedicineTypeList:self.classId];
    [self.tableView reloadData];
}

- (void)loadMedicineData{
    if (app.currentNetWork == kNotReachable) {
        [self getCachedAllMedicineTypeList];
    } else {
        NSMutableDictionary * setting = [NSMutableDictionary dictionary];
        setting[@"currClassId"] = self.classId;
        setting[@"currPage"] = @1;
        setting[@"pageSize"] = @200;
        [[HTTPRequestManager sharedInstance] querySecondProductClass:setting completionSuc:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                NSArray * arr = resultObj[@"body"][@"data"];
                for (NSDictionary * dic in arr) {
                    [self.dataSource addObject:dic];
                }
                NSLog(@"==== %s, data source is %@",__func__,self.dataSource);
                [self cacheAllMedicineTypeList:self.dataSource];
                [self.tableView reloadData];
            }
        } failure:^(id failMsg) {
            NSLog(@"%@",failMsg);
        }];
    }

}

#pragma mark ------ section ------

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (didSection == section) {
        return self.subDataSource.count;
    }else{
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView * mView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, SECTION_H - 1)];
    mView.backgroundColor = [UIColor whiteColor];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.tag = section;
    [button addTarget:self action:@selector(sectionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, APP_W, SECTION_H);
    [mView addSubview:button];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (SECTION_H-SECTION_LABEL_H)/2-1, 140, SECTION_LABEL_H+2)];
    
    titleLabel.text = self.dataSource[section][@"name"];
    titleLabel.font = Font(16);
    titleLabel.textColor = UIColorFromRGB(0x333333);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [button addSubview:titleLabel];
    
    UILabel * subLabel = [[UILabel alloc] initWithFrame:CGRectMake(APP_W-60, (SECTION_H-SECTION_LABEL_H)/2, 60, SECTION_LABEL_H)];
    subLabel.textColor = UICOLOR(133, 133, 133);
    if (self.requestType == RequestTypeMedicine) {
        NSString * str = [NSString stringWithFormat:@"%@",self.dataSource[section][@"size"]];
        if (str.length == 0) {
            str = @"0";
        }
        subLabel.text = [NSString stringWithFormat:@"%@种分类",str];
    }
    subLabel.backgroundColor = [UIColor clearColor];
    subLabel.textAlignment = NSTextAlignmentLeft;
    subLabel.font = Font(12);
    [button addSubview:subLabel];
    
    UILabel * line = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, mView.frame.size.height+0.5, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [mView addSubview:line];
    
    UIImageView *imgViewArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"展开"]];
    imgViewArrow.frame = CGRectMake(0, mView.frame.size.height-4, APP_W, 5);
    [mView addSubview:imgViewArrow];
//
    NSLog(@"DID section is %d, section is %d",didSection,section);
    
//    if (didSection == section) {
//        imgViewArrow.hidden = NO;
//    } else {
//        imgViewArrow.hidden = YES;
//    }
    if (didSection == section) {
        if (isExtend) {
            imgViewArrow.hidden = NO;
        } else {
            imgViewArrow.hidden = YES;
        }
    } else {
        imgViewArrow.hidden = YES;
    }

    
    return mView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * cellIdentifier = @"cellIdentifier";
    MedicineSubCell * cell = (MedicineSubCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray * nibs = [[NSBundle mainBundle] loadNibNamed:@"MedicineSubCell" owner:self options:nil];
        cell = nibs[0];
        cell.contentView.backgroundColor = UICOLOR(231, 236, 238);
    
        cell.bgImageView.backgroundColor = UICOLOR(231, 236, 238);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.selectedBackgroundView = [[UIView alloc]init];
        cell.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xdfe4e6);
    }
    if (indexPath.row == 0) {

    }
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(cell.titleLabel.frame.origin.x, 40 - 0.5, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [cell addSubview:line];
    
    cell.titleLabel.text = self.subDataSource[indexPath.row][@"name"];
    cell.titleLabel.font = Font(15);
    cell.titleLabel.textColor = UIColorFromRGB(0x333333);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (app.currentNetWork == kNotReachable) {
//        [SVProgressHUD showErrorWithStatus:@"当前暂无网络,请稍后重试!" duration:0.8f];
//        return;
//    }
    NSIndexPath*    selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
    if (self.requestType == RequestTypeMedicine) {
        MedicineListViewController * medicineList = [[MedicineListViewController alloc] init];
        medicineList.isShow = 1;
        medicineList.classId = self.subDataSource[indexPath.row][@"classId"];
        [self.navigationController pushViewController:medicineList animated:YES];
    }else if (self.requestType == RequestTypeDisease){
        DiseaseDetailViewController* diseaseDetail = [[DiseaseDetailViewController alloc] initWithNibName:@"DiseaseDetailViewController" bundle:nil];
        diseaseDetail.diseaseId = self.subDataSource[indexPath.row][@"classId"];
        diseaseDetail.diseaseType = @"A";
        diseaseDetail.title = self.subDataSource[indexPath.row][@"name"];
        [self.navigationController pushViewController:diseaseDetail animated:YES];
    }
}

- (void)sectionButtonClick:(UIButton *)button{

    if (didSection == button.tag) {//与上一次点击的是同一行
        if (isExtend) {   //如果现在是展开状态(那么将其收起)
            isExtend = NO;
            NSMutableArray * arr = [[NSMutableArray alloc] init];
            for (int i = 0; i < self.subDataSource.count; i++) {
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:button.tag];
                [arr addObject:indexPath];
            }
            [self.subDataSource removeAllObjects];
            [SVProgressHUD dismiss];
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            
        }else{  //如果现在时收起状态(那么将其展开)
            didSection = button.tag;
            isExtend = YES;
            [self.subDataSource removeAllObjects];
            [self.subDataSource addObjectsFromArray:self.dataSource[button.tag][@"childrens"]];
            
            NSMutableArray * arr = [[NSMutableArray alloc] init];
            for (int i = 0; i < self.subDataSource.count; i++) {
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:button.tag];
                [arr addObject:indexPath];
            }
            [SVProgressHUD dismiss];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:button.tag] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }else{
        //先把前一段的行全部删除后(收起),再进行新段中行的增加(展开)
        NSMutableArray * arr1 = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.subDataSource.count; i++) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:didSection];
            [arr1 addObject:indexPath];
        }
        [self.subDataSource removeAllObjects];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:arr1 withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        
        didSection = button.tag;
        isExtend = YES;
        [self.subDataSource removeAllObjects];
        [self.subDataSource addObjectsFromArray:self.dataSource[button.tag][@"childrens"]];
        NSMutableArray * arr = [[NSMutableArray alloc] init];
        
        //新段中行的增加
        for (int i = 0; i < self.subDataSource.count; i++) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:button.tag];
            [arr addObject:indexPath];
        }
        [SVProgressHUD dismiss];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:button.tag] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.dataSource.count)] withRowAnimation:UITableViewRowAnimationAutomatic];
}


@end
