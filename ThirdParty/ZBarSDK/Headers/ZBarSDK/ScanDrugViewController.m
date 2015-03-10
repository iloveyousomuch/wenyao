//
//  ScanDrugViewController.m
//  quanzhi
//
//  Created by xiezhenghong on 14-6-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "ScanDrugViewController.h"
#import "AppDelegate.h"
#import "Constant.h"
#import "ScanDrugTableViewCell.h"
#import "UIImageView+WebCache.h"
//#import "MedicineDetailViewController.h"
#import "DrugDetailViewController.h"
#import "SVProgressHUD.h"

@interface ScanDrugViewController ()

@end

@implementation ScanDrugViewController
@synthesize tableView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"列表";
    
    [self setupTableView];
    
    if (!app.logStatus) {
        
        [SVProgressHUD showErrorWithStatus:@"尚未登录" duration:0.8];
        
    }
    
}

- (void)setupTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.separatorColor = UIColorFromRGB(0xf2f2f2);
    [self.tableView setBackgroundColor:UIColorFromRGB(0xf2f2f2)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.view addSubview:self.tableView];
    
}

#pragma mark -
#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66.0f;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    return [self.drugList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ScanDrugIdentifier = @"ScanDrugCellIdentifier";
    ScanDrugTableViewCell *cell = (ScanDrugTableViewCell *)[atableView dequeueReusableCellWithIdentifier:ScanDrugIdentifier];
    if(cell == nil){
        UINib *nib = [UINib nibWithNibName:@"ScanDrugTableViewCell" bundle:nil];
        [atableView registerNib:nib forCellReuseIdentifier:ScanDrugIdentifier];
        cell = (ScanDrugTableViewCell *)[atableView dequeueReusableCellWithIdentifier:ScanDrugIdentifier];
    }
    NSDictionary *dict = self.drugList[indexPath.row];
    NSString *imageUrl = PORID_IMAGE(dict[@"proId"]);
    [cell.avatar setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
    cell.titleLabel.text = dict[@"proName"];
    cell.sepcLabel.text = dict[@"spec"];
    cell.factoryLabel.text = dict[@"factory"];
    if(self.userType == 1){
        cell.addLabel.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = self.drugList[indexPath.row];
    if(self.userType == 2){
        if(self.completionBolck)
            self.completionBolck(dict);
        NSUInteger count = self.navigationController.viewControllers.count - 1;
        UIViewController *viewController = self.navigationController.viewControllers[count - 2];
        [self.navigationController popToViewController:viewController animated:YES];
    }else{
        if(!dict[@"proId"]){
            [SVProgressHUD showErrorWithStatus:@"无法查询到该药品的详情!" duration:0.8f];
        }
        DrugDetailViewController *detailViewController = [[DrugDetailViewController alloc] init];

        detailViewController.proId = dict[@"proId"];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
