//
//  MyMedicineViewController.m
//  wenyao
//
//  Created by Meng on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "MyMedicineViewController.h"
#import "Constant.h"
#import "MyMedicineTableViewCell.h"
@interface MyMedicineViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong) UITableView * mTableView;

@end

@implementation MyMedicineViewController

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
    [self setupTableView];
}

- (void)setupTableView{
    self.mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, APP_W, APP_H-NAV_H) style:UITableViewStylePlain];
    self.mTableView.separatorInset = UIEdgeInsetsZero;
    self.mTableView.delegate = self;
    self.mTableView.dataSource = self;
    [self.view addSubview:self.mTableView];
}

#pragma mark ------ tableViewDataSource ------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * MyMedicineTableViewCellIdentifier = @"MyMedicineTableViewCellIdentifier";
    MyMedicineTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:MyMedicineTableViewCellIdentifier];
    if (cell == nil) {
        UINib * nib = [UINib nibWithNibName:@"MyMedicineTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:MyMedicineTableViewCellIdentifier];
        cell = (MyMedicineTableViewCell *)[tableView dequeueReusableCellWithIdentifier:MyMedicineTableViewCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.selected = NO;
    }
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
