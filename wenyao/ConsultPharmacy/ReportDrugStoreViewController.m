//
//  ReportDrugStoreViewController.m
//  wenyao
//
//  Created by xiezhenghong on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "ReportDrugStoreViewController.h"
#import "HTTPRequestManager.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "Constant.h"
#import "LoginViewController.h"

@interface ReportDrugStoreViewController ()<UITableViewDataSource,
UITableViewDelegate,UITextViewDelegate>

@property (nonatomic, strong) NSMutableArray        *typeList;
@property (nonatomic, assign) NSInteger             selectIndex;

@property (nonatomic, strong) UILabel               *countLabel;
@property (nonatomic, strong) UILabel               *hintLabel;

@end

@implementation ReportDrugStoreViewController
@synthesize tableView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//输入框需要弹起
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    CGSize size = self.tableView.contentSize;
    size.height += 266;
    [self.tableView setContentSize:size];
    [self.tableView setContentOffset:CGPointMake(0, 266 - 64) animated:YES];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    CGSize size = self.tableView.contentSize;
    size.height -= 266;
    [self.tableView setContentSize:size];
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
//    self.countLabel.text = [NSString stringWithFormat:@"%d/200",textView.text.length];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(textView.text.length <= 1 && [text isEqualToString:@""]){
        self.hintLabel.hidden = NO;
    }else{
        self.hintLabel.hidden = YES;
    }
    if(textView.text.length >= 200 && ![text isEqualToString:@""])
        return NO;
    
    return YES;
}

- (void)tapEmptyField
{
    [self.textView resignFirstResponder];
}

- (void)setupTableView
{
    CGRect rect = self.view.frame;
    rect.size.height -= 64;
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
    

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEmptyField)];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 125)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300,80)];
    label.text = @"问药致力于为用户打造诚实可信的药店移动端公众服务平台，我们坚决反对药店存在欺骗、误导用户的行为。欢迎广大用户积极举报不诚信药店，我们将及时处理。";
    
    label.font = [UIFont systemFontOfSize:14.5];
    label.textColor = [UIColor blackColor];
    [label setBackgroundColor:[UIColor clearColor]];
    label.numberOfLines = 5;
//    label.center = header.center;
    [header addSubview:label];

    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 95, 320, 30)];
    UILabel *labelReason = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 20)];
    labelReason.font = [UIFont systemFontOfSize:14.5f];
    labelReason.text = @"请选择举报原因:";
    [container addSubview:labelReason];
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(10, 33.5, 300, 1.5)];
    [separator setBackgroundColor:APP_COLOR_STYLE];
    [container addSubview:separator];
    
    [header addSubview:container];
    
    self.tableView.tableHeaderView = header;
    [header addGestureRecognizer:tapGesture];
    //意见反馈_输入框@2x
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    UIImageView *backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 160)];
    backImage.image = [UIImage imageNamed:@"意见反馈_输入框.png"];
    backImage.center = footerView.center;
    [footerView addSubview:backImage];
    
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, 300, 135)];
    self.textView.font = [UIFont systemFontOfSize:13.5];
    [self.textView setBackgroundColor:[UIColor clearColor]];
    self.textView.delegate = self;
    [footerView addSubview:self.textView];
    
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 150, 60, 10)];
    self.countLabel.textColor = [UIColor lightGrayColor];
    self.countLabel.font = [UIFont systemFontOfSize:13.5f];
    self.countLabel.text = @"0/200";
    [footerView addSubview:self.countLabel];
    
    self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 16, 120, 20)];
    self.hintLabel.textColor = [UIColor lightGrayColor];
    self.hintLabel.font = [UIFont systemFontOfSize:13.5f];
    self.hintLabel.text = @"请输入举报原因吧~";
    [footerView addSubview:self.hintLabel];
    [footerView addGestureRecognizer:tapGesture];
    self.tableView.tableFooterView = footerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.selectIndex = -1;
//    if (iOSv7 && self.view.frame.origin.y==0) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.extendedLayoutIncludesOpaqueBars = NO;
//        self.modalPresentationCapturesStatusBarAppearance = NO;
//    }
    self.title = @"举报药房";
    UIBarButtonItem *submitBarButton = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(submitAction:)];
    self.navigationItem.rightBarButtonItem = submitBarButton;
    self.typeList = [NSMutableArray arrayWithCapacity:15];
    [self setupTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChangeFunc) name:UITextViewTextDidChangeNotification object:self.textView];
    
}

- (void)textViewDidChangeFunc
{
    if (self.textView.text.length > 200) {
        self.textView.text = [self.textView.text substringToIndex:200];
    }
    self.countLabel.text = [NSString stringWithFormat:@"%d/200",self.textView.text.length];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self queryComplaintType];
}

- (void)queryComplaintType
{
    if(self.typeList.count == 0){
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        [[HTTPRequestManager sharedInstance] queryComplaintType:setting completion:^(id resultObj) {
            if([resultObj[@"result"] isEqualToString:@"OK"]){
                NSArray *array = resultObj[@"body"];
                if(array.count > 0){
                    [self.typeList removeAllObjects];
                    [self.typeList addObjectsFromArray:array];
                }
                [self.tableView reloadData];
            }
        } failure:NULL];
    }
}

- (void)submitAction:(id)sender
{
    if(!app.logStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
        return;
    }
    if(self.selectIndex == -1) {
        [SVProgressHUD showErrorWithStatus:@"请选择举报原因!" duration:0.8f];
        return;
    }
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"group"] = self.infoDict[@"id"];
    setting[@"type"] = self.typeList[self.selectIndex][@"key"];
    if(self.textView.text.length > 0)
        setting[@"content"] = self.textView.text;
    [self.textView resignFirstResponder];
    [[HTTPRequestManager sharedInstance] storeComplaint:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]){
            [SVProgressHUD showSuccessWithStatus:@"举报成功" duration:0.8f];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSError *error) {
        NSLog(@"error %@",[error description]);
    }];
}

//

#pragma mark -
#pragma mark UITableViewDelegate
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 30.0f;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEmptyField)];
//    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 20)];
//    label.font = [UIFont systemFontOfSize:14.5f];
//    label.text = @"请选择举报原因:";
//    [container addSubview:label];
//    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(10, 28.5, 300, 1.5)];
//    [separator setBackgroundColor:APP_COLOR_STYLE];
//    [container addSubview:separator];
//    [container addGestureRecognizer:tapGesture];
//    return container;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 53.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEmptyField)];
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
//    container.backgroundColor = [UIColor grayColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 23, 300, 20)];
    label.font = [UIFont systemFontOfSize:14.5f];
    label.text = @"请填写举报原因:";
    [container addSubview:label];
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(10, 51.5, 300, 1.5)];
    [separator setBackgroundColor:APP_COLOR_STYLE];
    [container addSubview:separator];
    [container addGestureRecognizer:tapGesture];
    return container;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 42.0f;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    return [self.typeList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableViewCellIdentifier = @"TableViewCellIdentifier";
    UITableViewCell *cell = [atableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableViewCellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(15, 41.5, APP_W - 15, 0.5)];
        line.backgroundColor = UIColorFromRGB(0xdbdbdb);
        [cell addSubview:line];
    }
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14.5f];
    cell.textLabel.text = self.typeList[indexPath.row][@"value"];
    if(indexPath.row == self.selectIndex) {
        cell.textLabel.textColor = APP_COLOR_STYLE;
        UIImageView *selectedIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        selectedIcon.image = [UIImage imageNamed:@"选中的勾.png"];
        cell.accessoryView = selectedIcon;
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
        cell.accessoryView = nil;
    }
    return cell;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.textView resignFirstResponder];
    self.selectIndex = indexPath.row;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
