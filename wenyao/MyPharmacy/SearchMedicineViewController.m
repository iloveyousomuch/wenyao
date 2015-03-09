//
//  SearchMedicineViewController.m
//  wenyao
//
//  Created by xiezhenghong on 14-10-8.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "SearchMedicineViewController.h"
#import "SearchMedicineTableViewCell.h"
#import "HTTPRequestManager.h"
#import "SVProgressHUD.h"
#import "TagCollectionView.h"
#import "TagCollectionFlowLayout.h"
#import "MJRefresh.h"


@interface SearchMedicineViewController ()<UISearchBarDelegate,
UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,
TagCollectionViewDelegate,UITextFieldDelegate>
{
    UITextField         *alertTextField;
    UIButton *contentView;
    UILabel *lable;
    NSInteger currentPage;

}
@property (nonatomic, strong) UISearchBar   *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchDisplay;
@property (nonatomic, strong) UITableView       *tableView;
@property (nonatomic, strong) NSMutableArray    *resultArray;


@end

@implementation SearchMedicineViewController

- (void)backToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)setupSearchBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 265,44)];
    self.searchBar.placeholder = @"输入药品名称";
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = UIColorFromRGB(0x4501a);
    self.searchBar.tintColor = [UIColor blueColor];
    self.navigationItem.titleView = self.searchBar;
    
    
    //回退按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(backToPrevious:)];
}

- (void)setupTableView
{
    self.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height - 64);
    CGRect rect = self.view.frame;
    rect.origin.x = 0;
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    self.tableView.footerPullToRefreshText = @"上拉可以加载更多数据了";
    self.tableView.footerReleaseToRefreshText = @"松开加载更多数据了";
    self.tableView.footerRefreshingText = @"正在帮你加载中";
    currentPage = 1;
    
    [self.view addSubview:self.tableView];
}

- (void)footerRereshing{
    
    currentPage ++;
    [self queryMedicineWithKeyword:self.searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self queryMedicineWithKeyword:searchText];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(searchBar.text.length == 0 && ![text isEqualToString:@""]) {
        [self.tableView reloadData];
    }else if(searchBar.text.length == 1 && [text isEqualToString:@""]) {
        [self.tableView reloadData];
    }
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.searchBar resignFirstResponder];
}

- (void)queryMedicineWithKeyword:(NSString *)keyword
{
    if([keyword isEqualToString:@""]) {
        [self.resultArray removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"keyword"] = keyword;
    setting[@"currPage"] = [NSString stringWithFormat:@"%d",currentPage];
    setting[@"pageSize"] = @"10";
    
    __weak SearchMedicineViewController *weakSelf = self;
    [[HTTPRequestManager sharedInstance] queryProductByKeyword:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]) {
            if(currentPage == 1){
                [weakSelf.resultArray removeAllObjects];
            }
            [weakSelf.resultArray addObjectsFromArray:resultObj[@"body"][@"data"]];
        }
        [weakSelf.tableView footerEndRefreshing];
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        [weakSelf.tableView footerEndRefreshing];
        NSLog(@"%@",error);
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    self.resultArray = [NSMutableArray arrayWithCapacity:15];
    [self setupTableView];
    [self setupSearchBar];
    [self.navigationItem setHidesBackButton:YES];
    [self registerNotification];
    
}

- (void)dealloc
{
    [self unregisterNotification];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardBounds;
    [keyboardBoundsValue getValue:&keyboardBounds];
    CGFloat keyboardHeight = keyboardBounds.size.height;
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    rect.size.height -= keyboardHeight;
    self.tableView.frame = rect;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardBounds;
    [keyboardBoundsValue getValue:&keyboardBounds];
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    self.tableView.frame = rect;
}

- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
}

- (void)unregisterNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField.text.length >= 20 && ![string isEqualToString:@""])
        return NO;
    return YES;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    contentView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 38)];
    [contentView setBackgroundImage:[UIImage imageNamed:@"横条提醒_背景.png"] forState:UIControlStateNormal];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 9, 260, 20)];
    label.font = [UIFont systemFontOfSize:14.0];
    label.text = @"搜索不到？试试手动添加吧~";
    label.textColor = UIColorFromRGB(0xaa7711);
    [contentView addSubview:label];
    UIImageView *detailView = [[UIImageView alloc] initWithFrame:CGRectMake(300, 13, 12, 12)];
    detailView.image = [UIImage imageNamed:@"向右箭头_黄.png"];
    [contentView  addSubview:detailView];
    [contentView addTarget:self action:@selector(showManualInput:) forControlEvents:UIControlEventTouchDown];
    return contentView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(self.searchBar.text.length > 0) {
        return 38.0f;
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    return self.resultArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(atableView.contentOffset.y != 0){
        [self.searchBar resignFirstResponder];
    }
    static NSString *SearchMedicineTableViewCellIdentifier = @"SearchMedicineTableViewCellIdentifier";
    SearchMedicineTableViewCell *cell = (SearchMedicineTableViewCell *)[atableView dequeueReusableCellWithIdentifier:SearchMedicineTableViewCellIdentifier];
    if(cell == nil){
        UIView *view_bg = [[UIView alloc]initWithFrame:cell.frame];
        
        view_bg.backgroundColor = UIColorFromRGB(0xdfe4e6);
        cell.selectedBackgroundView = view_bg;
        UINib *nib = [UINib nibWithNibName:@"SearchMedicineTableViewCell" bundle:nil];
        [atableView registerNib:nib forCellReuseIdentifier:SearchMedicineTableViewCellIdentifier];
        cell = (SearchMedicineTableViewCell *)[atableView dequeueReusableCellWithIdentifier:SearchMedicineTableViewCellIdentifier];
    
    }
    
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 80-0.5, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [cell addSubview:line];
    
    NSDictionary *dict = self.resultArray[indexPath.row];
    cell.medicineName.text = dict[@"name"];
    cell.medicineNorms.text = dict[@"spec"];
    cell.medicineFactory.text = dict[@"makeplace"];
    return cell;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = self.resultArray[indexPath.row];
    if(self.selectBlock)
    {
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        setting[@"productId"] = dict[@"proId"];
        [[HTTPRequestManager sharedInstance] getProductUsage:setting completion:^(id resultObj) {
            if([resultObj[@"result"] isEqualToString:@"OK"]) {
                NSDictionary *dataRow = @{@"productName":dict[@"name"],
                                          @"productId":dict[@"proId"]
                                          };
                
                NSMutableDictionary *source = [NSMutableDictionary dictionaryWithDictionary:dataRow];
                [source addEntriesFromDictionary:resultObj[@"body"]];
                if(source[@"dayPerCount"]) {
                    source[@"drugTime"] = source[@"dayPerCount"];
                    [source removeObjectForKey:@"dayPerCount"];
                }
                self.selectBlock(source);
                [self.navigationController popViewControllerAnimated:YES];
            }
        } failure:NULL];
    }
}

- (void)showManualInput:(id)sender
{
    [self.searchBar resignFirstResponder];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"secondCustomAlertView" owner:self options:nil];
    
    self.customAlertView = [nibViews objectAtIndex: 0];


    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        [alertView setValue:self.customAlertView forKey:@"accessoryView"];
    }else{
        [alertView addSubview:self.customAlertView];
    }
    self.customAlertView.textField.text = self.searchBar.text;
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        NSString *drugName = self.customAlertView.textField.text;
        drugName = [drugName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(drugName.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"药品名称的不能为空!" duration:0.8f];
            return;
        }else if(drugName.length > 20){
            [SVProgressHUD showErrorWithStatus:@"药品名称不能超过二十位!" duration:0.8f];
            return;
        }
        if(self.selectBlock) {
            NSDictionary *dict = @{@"productName":drugName};
            self.selectBlock(dict);
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
