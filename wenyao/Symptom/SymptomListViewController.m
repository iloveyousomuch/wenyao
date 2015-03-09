//
//  SymptomListViewController.m
//  wenyao
//
//  Created by Meng on 14/12/1.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "SymptomListViewController.h"
#import "SymptomDetailViewController.h"

@interface SymptomListViewController ()

@property (nonatomic ,strong) NSMutableArray * dataSource;

@end

@implementation SymptomListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [NSMutableArray array];
    //NW_queryDiseaseKeyword
}

- (void)setKeyWord:(NSString *)keyWord
{
    _keyWord = keyWord;
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    setting[@"keyword"] = self.keyWord;
    setting[@"currPage"] = @1;
    setting[@"pageSize"] = @1000;
    
    [[HTTPRequestManager sharedInstance] querySpmByKeyword:setting completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:resultObj[@"body"][@"data"]];
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 35;
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
    }
    NSDictionary * dic = self.dataSource[indexPath.row];
    cell.textLabel.text = dic[@"name"];
    cell.textLabel.font = Font(12);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic = self.dataSource[indexPath.row];
    
    
    SymptomDetailViewController * svc =[[SymptomDetailViewController alloc]init];
    svc.spmCode = dic[@"spmCode"];
    svc.title = dic[@"name"];
    [self.navigationController pushViewController:svc animated:YES];
    
    
//    SymptomViewController * svc =[[SymptomViewController alloc]init];
//    svc.requestType = searchSym;
//    svc.spmCode = dic;
//    svc.title = dic;
//    [self.navigationController pushViewController:svc animated:YES];
//    
//    
//    
//    
//    DiseaseDetailViewController * diseaseDetail = [[DiseaseDetailViewController alloc] init];
//    diseaseDetail.diseaseName = dic[@"name"];
//    diseaseDetail.diseaseType = dic[@"type"];
//    diseaseDetail.title = dic[@"name"];
//    [self.navigationController pushViewController:diseaseDetail animated:YES];
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
