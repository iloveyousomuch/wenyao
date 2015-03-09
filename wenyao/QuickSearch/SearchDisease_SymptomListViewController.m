//
//  SearchDisease+SymptomListViewController.m
//  wenyao
//
//  Created by Meng on 14/12/2.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "SearchDisease_SymptomListViewController.h"
#import "DiseaseDetailViewController.h"
#import "SymptomDetailViewController.h"


@interface SearchDisease_SymptomListViewController ()
{
    UIView *_nodataView;
}
@property (nonatomic ,strong) NSMutableArray * dataSource;

@end

@implementation SearchDisease_SymptomListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [NSMutableArray array];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    //NW_queryDiseaseKeyword
}

- (void)setKwId:(NSString *)kwId
{
    _kwId = kwId;
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    setting[@"kwId"] = kwId;
    setting[@"currPage"] = @1;
    setting[@"pageSize"] = @1000;
    
    if (self.requsetType == RequsetTypeDisease) {
        [[HTTPRequestManager sharedInstance] queryDiseaseKwId:setting completion:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                [self.dataSource removeAllObjects];
                [self.dataSource addObjectsFromArray:resultObj[@"body"][@"data"]];
                if (self.dataSource.count > 0) {
                    [self.tableView reloadData];
                }else
                {
                    [self showNoDataViewWithString:@"暂无数据!"];
                }
            }
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
        }];
    } else if (self.requsetType == RequsetTypeSymptom){
        [[HTTPRequestManager sharedInstance] querySpmByKwId:setting completion:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                [self.dataSource removeAllObjects];
                [self.dataSource addObjectsFromArray:resultObj[@"body"][@"data"]];
                if (self.dataSource.count > 0) {
                    [self.tableView reloadData];
                }else{
                    [self showNoDataViewWithString:@"暂无数据!"];
                }
                
            }
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"cellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 39.5, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [cell addSubview:line];
    
    NSDictionary * dic = self.dataSource[indexPath.row];
    cell.textLabel.text = dic[@"name"];
    cell.textLabel.font = Font(16);
    cell.textLabel.textColor = UIColorFromRGB(0x333333);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic = self.dataSource[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.requsetType == RequsetTypeDisease) {
        DiseaseDetailViewController* diseaseDetail = [[DiseaseDetailViewController alloc] initWithNibName:@"DiseaseDetailViewController" bundle:nil];
        diseaseDetail.diseaseId = dic[@"diseaseId"];
        diseaseDetail.diseaseType = dic[@"type"];
        diseaseDetail.title = dic[@"name"];
        [self.navigationController pushViewController:diseaseDetail animated:YES];
    }else if (self.requsetType == RequsetTypeSymptom){
        SymptomDetailViewController * svc =[[SymptomDetailViewController alloc]init];
        svc.spmCode = dic[@"spmCode"];
        svc.title = dic[@"name"];
         svc.containerViewController = self.containerViewController;
        if (self.containerViewController) {
            [self.containerViewController.navigationController pushViewController:svc animated:YES];
        }else
        {
            [self.navigationController pushViewController:svc animated:YES];
        }
        

    }
}

//显示没有历史搜索记录view
-(void)showNoDataViewWithString:(NSString *)nodataPrompt
{
    if (_nodataView) {
        [_nodataView removeFromSuperview];
        _nodataView = nil;
    }
    _nodataView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H)];
    //_nodataView.backgroundColor = COLOR(242, 242, 242);
    _nodataView.backgroundColor = BG_COLOR;
    
    
    //    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]init];
    //    [tap addTarget:self action:@selector(keyboardHidenClick)];
    //    [_nodataView addGestureRecognizer:tap];
    UIImage * searchImage = [UIImage imageNamed:@"icon_warning.png"];
    
    UIImageView *dataEmpty = [[UIImageView alloc]initWithFrame:RECT(0, 0, searchImage.size.width, searchImage.size.height)];
    dataEmpty.center = CGPointMake(APP_W/2, 110);
    dataEmpty.image = searchImage;
    [_nodataView addSubview:dataEmpty];
    
    UILabel* lable_ = [[UILabel alloc]initWithFrame:RECT(0,dataEmpty.frame.origin.y + dataEmpty.frame.size.height + 10, nodataPrompt.length*20,30)];
    lable_.font = Font(12);
    lable_.textColor = COLOR(137, 136, 155);
    lable_.textAlignment = NSTextAlignmentCenter;
    lable_.center = CGPointMake(APP_W/2, lable_.center.y);
    lable_.text = nodataPrompt;
    
    [_nodataView addSubview:lable_];
    [self.view insertSubview:_nodataView atIndex:self.view.subviews.count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
