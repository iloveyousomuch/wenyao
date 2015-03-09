//
//  AskMedicineShopViewController.m
//  wenyao
//
//  Created by Meng on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "AskMedicineShopViewController.h"
#import "Constant.h"



@interface AskMedicineShopViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL leftIsShow;
    BOOL rightIsShow;
}
@property (nonatomic ,strong) UITableView * rootTableView;
@property (nonatomic ,strong) UITableView * subTableView;

@property (nonatomic ,strong) NSMutableArray * leftDataSource;
@property (nonatomic ,strong) NSMutableArray * rightDataSource;
@property (nonatomic ,strong) NSMutableArray * dataSource;

@end

@implementation AskMedicineShopViewController
@synthesize rootTableView = _rootTableView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"免费问药";
    self.leftDataSource = [NSMutableArray arrayWithObjects:@"全城",@"1千米", @"3千米", @"5千米", @"10千米",  nil];
    self.rightDataSource = [NSMutableArray arrayWithObjects:@"智能排序",@"24H药店",@"医保定点", nil];
    leftIsShow = NO;
    rightIsShow = NO;
    [self setupTableView];
    [self setupTopView];
}

- (void)setupTableView{
    self.rootTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 30, APP_W, APP_H-NAV_H-TAB_H-30) style:UITableViewStylePlain];
    self.rootTableView.separatorInset = UIEdgeInsetsZero;
    self.rootTableView.delegate = self;
    self.rootTableView.dataSource = self;
    [self.view addSubview:self.rootTableView];
    
    
    self.subTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -1000, APP_W/2, 0) style:UITableViewStylePlain];
    self.subTableView.hidden = YES;
    self.subTableView.delegate = self;
    self.subTableView.dataSource = self;
    self.subTableView.separatorInset = UIEdgeInsetsZero;
    [self.view addSubview:self.subTableView];
}

- (void)setupTopView{
    UIView * topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, 30)];
    topView.backgroundColor = BG_COLOR;
    topView.tag = 888;
    [self.view addSubview:topView];
    
    NSArray * titleArr = @[@"全城",@"智能排序"];
    
    for (int i = 0; i<2; i++) {
        UIButton * indicateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [indicateButton setFrame:CGRectMake(160*i, 0, 160, 30)];
        indicateButton.tag = 100+i;//左边按钮tag100 右边按钮tag101
        [indicateButton setTitle:[titleArr objectAtIndex:i] forState:UIControlStateNormal];
        [indicateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [indicateButton addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:indicateButton];
        
        UIImageView * indicateImageView = [[UIImageView alloc]initWithFrame:CGRectMake(indicateButton.titleLabel.frame.origin.x+indicateButton.titleLabel.frame.size.width, indicateButton.titleLabel.frame.origin.y+5, 18, 10)];
        indicateImageView.tag = 1000+i;//左边ImageViewtag1000 右边ImageViewtag1001
        indicateImageView.image = [UIImage imageNamed:@"DownAccessory.png"];
        [indicateButton addSubview:indicateImageView];
    }
}

- (void)topButtonClick:(UIButton *)btn{
    UIImageView * leftImageView = (UIImageView *)[self.view viewWithTag:1000];
    UIImageView * rightImageView = (UIImageView *)[self.view viewWithTag:1001];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4f];
    if (btn.tag == 100) {
        [leftImageView setFrame:CGRectMake(btn.titleLabel.frame.origin.x+btn.titleLabel.frame.size.width, btn.titleLabel.frame.origin.y+5, 18, 10)];
        if (leftIsShow) {
            self.subTableView.hidden = YES;
            [self.subTableView setFrame:CGRectMake(0, -1000, APP_W/2, 0)];
            rightImageView.transform = CGAffineTransformMakeRotation(0);
            leftImageView.transform = CGAffineTransformMakeRotation(0);
            leftIsShow = NO;
            rightIsShow = NO;
        }else{
            self.subTableView.hidden = NO;
            if (self.subTableView.frame.origin.x == APP_W/2) {
                [self.subTableView setFrame:CGRectMake(0, -1000, APP_W/2, 0)];
            }
            [self.subTableView setFrame:CGRectMake(0, 30, APP_W/2, self.leftDataSource.count*30)];
            rightImageView.transform = CGAffineTransformMakeRotation(0);
            leftImageView.transform = CGAffineTransformMakeRotation(M_PI);
            leftIsShow = YES;
            rightIsShow = NO;
            [self.subTableView reloadData];
        }
    }else if (btn.tag == 101){
        [rightImageView setFrame:CGRectMake(btn.titleLabel.frame.origin.x+btn.titleLabel.frame.size.width, btn.titleLabel.frame.origin.y+5, 18, 10)];
        if (rightIsShow) {
            
            [self.subTableView setFrame:CGRectMake(APP_W/2, -1000, APP_W/2, 0)];
            self.subTableView.hidden = YES;
            leftImageView.transform = CGAffineTransformMakeRotation(0);
            rightImageView.transform = CGAffineTransformMakeRotation(0);
            rightIsShow = NO;
            leftIsShow = NO;
        }else{
            if (self.subTableView.frame.origin.x == 0) {
                [self.subTableView setFrame:CGRectMake(APP_W/2, -1000, APP_W/2, 0)];
            }
            self.subTableView.hidden = NO;
            [self.subTableView setFrame:CGRectMake(APP_W/2, 30, APP_W/2, self.rightDataSource.count*30)];
            leftImageView.transform = CGAffineTransformMakeRotation(0);
            rightImageView.transform = CGAffineTransformMakeRotation(M_PI);
            rightIsShow = YES;
            leftIsShow = NO;
            [self.subTableView reloadData];
        }
    }
    [UIView commitAnimations];
}

#pragma mark ------tableViewDelegate------

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:self.subTableView]) {
        return 30;
    }else
        return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:self.subTableView]) {
        if (leftIsShow) {
            return self.leftDataSource.count;
        }else if (rightIsShow){
            return self.rightDataSource.count;
        }
    }
    return self.dataSource.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView isEqual:self.subTableView]) {
        if (leftIsShow) {
            UIView * topView = (UIView *)[self.view viewWithTag:888];
            UIButton * button = (UIButton *)[topView viewWithTag:100];
            [button setTitle:self.leftDataSource[indexPath.row] forState:UIControlStateNormal];
            [self topButtonClick:button];
        }else if (rightIsShow){
            UIView * topView = (UIView *)[self.view viewWithTag:888];
            UIButton * button = (UIButton *)[topView viewWithTag:101];
            [button setTitle:self.rightDataSource[indexPath.row] forState:UIControlStateNormal];
            [self topButtonClick:button];
        }
    }
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellIdenfitier = @"cellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdenfitier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdenfitier];
    }
    if ([tableView isEqual:self.subTableView]) {
        if (leftIsShow) {
            cell.textLabel.text = self.leftDataSource[indexPath.row];
        }else if (rightIsShow){
            cell.textLabel.text = self.rightDataSource[indexPath.row];
        }
    }else{
        cell.textLabel.text = self.dataSource[indexPath.row];
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
