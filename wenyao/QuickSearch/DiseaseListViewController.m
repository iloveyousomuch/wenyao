//
//  DiseaseListViewController.m
//  wenyao
//
//  Created by Meng on 14/12/1.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "DiseaseListViewController.h"
#import "DiseaseDetailViewController.h"

@interface DiseaseListViewController ()

@property (nonatomic ,strong) NSMutableArray * dataSource;

@end

@implementation DiseaseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [NSMutableArray array];
    //NW_queryDiseaseKeyword
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)setKeyWord:(NSString *)keyWord
{
    _keyWord = keyWord;
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    setting[@"keyword"] = self.keyWord;
    setting[@"currPage"] = @1;
    setting[@"pageSize"] = @1000;
    
    [[HTTPRequestManager sharedInstance] queryDiseaseKeyword:setting completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:resultObj[@"body"][@"data"]];
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

#pragma mark ----dataSource----
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
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
    cell.textLabel.font = Font(16);
    cell.textLabel.textColor = UIColorFromRGB(0x333333);
    return cell;
}

#pragma mark - ---delegate---
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic = self.dataSource[indexPath.row];
    DiseaseDetailViewController* diseaseDetail = [[DiseaseDetailViewController alloc] initWithNibName:@"DiseaseDetailViewController" bundle:nil];
    diseaseDetail.diseaseId = dic[@"diseaseId"];
    diseaseDetail.diseaseType = dic[@"type"];
    diseaseDetail.title = dic[@"name"];
    [self.navigationController pushViewController:diseaseDetail animated:YES];
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
