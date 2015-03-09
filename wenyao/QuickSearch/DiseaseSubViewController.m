//
//  DiseaseSubViewController.m
//  wenyao
//
//  Created by Meng on 14-10-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "DiseaseSubViewController.h"

#import "MedicineSubCell.h"
#import "AFNetworking.h"
#import "DiseaseDetailViewController.h"
#import "SVProgressHUD.h"

#import "AppDelegate.h"

#define SECTION_H 45
#define SECTION_LABEL_H 15

@interface DiseaseSubViewController ()
{
    
    BOOL isExtend;
    NSInteger didSection;
}
@property (nonatomic,retain)NSMutableArray *dataSource;
@property (nonatomic,retain)NSMutableArray *subDataSource;
@end

@implementation DiseaseSubViewController

- (id)init{
    if (self = [super init]) {
        self.title = @"常见疾病";
        self.tableView.frame = CGRectMake(0, 0, APP_W, APP_H-NAV_H-35.0f);
        //self.tableView.separatorInset = UIEdgeInsetsZero;
        self.dataSource = [NSMutableArray array];
        self.subDataSource = [NSMutableArray array];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        didSection = 1000;
        isExtend = NO;
    }
    return self;
}

- (void)cacheAllData:(NSMutableArray *)arrDiseaseList
{
    [app.cacheBase removeAllQuickSearchDiseaseList];
    for (NSDictionary *dic in arrDiseaseList) {
        [app.cacheBase insertQuickSearchDiseaseListWithClassId:dic[@"classId"]
                                                          name:dic[@"name"]
                                                      SubClass:dic[@"subClass"]];
    }
    
}

- (void)queryAllDisease
{
    self.dataSource = [app.cacheBase queryAllQuickSearchDiseaseList];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    
    if (self.dataSource.count > 0) {
        return;
    }else{
        [self.dataSource removeAllObjects];
        [self loadDiseaseData];
    }
}

- (void)loadDiseaseData{
    if (app.currentNetWork == kNotReachable) {
        [self queryAllDisease];
        if(!self.dataSource.count > 0){
            [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
            return;
        }
   
    } else {
        NSMutableDictionary * setting = [NSMutableDictionary dictionary];
        setting[@"currPage"] = @1;
        setting[@"pageSize"] = @200;
        NSLog(@"setting = %@",setting);
        [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeNone];
        [[HTTPRequestManager sharedInstance] queryDiseaseClass:setting completion:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                NSArray * arr = resultObj[@"body"][@"data"];
                for (NSDictionary * dic in arr) {
                    [self.dataSource addObject:dic];
                }
                [SVProgressHUD dismiss];
                [self.tableView reloadData];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [self cacheAllData:self.dataSource];
                });
            }
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
            NSLog(@"%@",error);
        }];
    }

}

- (void)backToPreviousController:(id)sender
{
    [super backToPreviousController:sender];
    [SVProgressHUD dismiss];
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
    //添加Button
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.tag = section;
    [button addTarget:self action:@selector(sectionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, APP_W, SECTION_H);
    [mView addSubview:button];
    //添加标题Label
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (SECTION_H-SECTION_LABEL_H)/2-1, 140, SECTION_LABEL_H+2)];
    titleLabel.text = self.dataSource[section][@"name"];
    titleLabel.font = Font(16);
    titleLabel.textColor = UIColorFromRGB(0x333333);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [button addSubview:titleLabel];
    
    UILabel * line = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, mView.frame.size.height+0.5, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [mView addSubview:line];
    
    //展开image图标定义
    UIImageView *imageViewArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"展开"]];
    imageViewArrow.frame = CGRectMake(0, mView.frame.size.height - 4, APP_W, 5);
    [mView addSubview:imageViewArrow];
    
    
    if(didSection == section){
        if(isExtend){
            //只有当有section被点击且是展开的时候，显示image
            imageViewArrow.hidden = NO;
        }
        else{
            imageViewArrow.hidden = YES;
        }
    }
    else{
        imageViewArrow.hidden = YES;
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
        cell.titleLabel.font = Font(15);
        cell.titleLabel.textColor = UIColorFromRGB(0x333333);
        UILabel *line1 = [[UILabel alloc]initWithFrame:CGRectMake(cell.titleLabel.frame.origin.x, 40 - 0.5, 500, 0.5)];
        line1.backgroundColor = UIColorFromRGB(0xdbdbdb);
        [cell addSubview:line1];
        
        cell.selectedBackgroundView = [[UIView alloc]init];
        cell.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xdfe4e6);
    }
    
    cell.titleLabel.text = self.subDataSource[indexPath.row][@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSIndexPath*    selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
//    if (app.currentNetWork == kNotReachable) {
//        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
//        return;
//    }
    DiseaseDetailViewController* diseaseDetail = [[DiseaseDetailViewController alloc] initWithNibName:@"DiseaseDetailViewController" bundle:nil];
    diseaseDetail.diseaseId = self.subDataSource[indexPath.row][@"diseaseId"];
    diseaseDetail.diseaseType = @"A";
    diseaseDetail.title = self.subDataSource[indexPath.row][@"name"];
    [self.navigationController pushViewController:diseaseDetail animated:YES];
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
            [self.subDataSource addObjectsFromArray:self.dataSource[button.tag][@"subClass"]];
            if (self.subDataSource.count == 0) {
                [SVProgressHUD showErrorWithStatus:@"暂无数据" duration:DURATION_SHORT];
            }
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
        [self.subDataSource addObjectsFromArray:self.dataSource[button.tag][@"subClass"]];
        if (self.subDataSource.count == 0) {
            [SVProgressHUD showErrorWithStatus:@"暂无数据" duration:DURATION_SHORT];
        }
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
- (void)viewDidCurrentView{
    if (self.dataSource.count > 0) {
        return;
    }else{
        [self.dataSource removeAllObjects];
        [self loadDiseaseData];
    }
}



@end
