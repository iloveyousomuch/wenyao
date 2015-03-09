//
//  AddNewMedicineViewController.m
//  wenyao
//
//  Created by Pan@QW on 14-9-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "AddNewMedicineViewController.h"
#import "HTTPRequestManager.h"
#import "ScanReaderViewController.h"
#import "LeveyPopListView.h"
#import "SearchMedicineViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "LoginViewController.h"
#import "MyPharmacyViewController.h"
#import "ASIFormDataRequest.h"
#import "NSObject+SBJson.h"

@interface AddNewMedicineViewController ()<UITableViewDataSource,
UITableViewDelegate,UIActionSheetDelegate,LeveyPopListViewDelegate,
UITextFieldDelegate,UIAlertViewDelegate,ASIHTTPRequestDelegate>
{

}
@property (nonatomic, strong) NSArray           *usageList;
@property (nonatomic, strong) NSArray           *unitList;
@property (nonatomic, strong) NSArray           *periodList;
@property (nonatomic, strong) NSMutableArray    *useNameList;
@property (nonatomic, strong) NSArray           *frequencyList;
@property (nonatomic, strong) UITextField       *alertViewTextField;

@end

@implementation AddNewMedicineViewController
@synthesize alertViewTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)setupTableView
{
    CGRect rect = [UIScreen mainScreen].bounds;
    rect.origin.x = 10;
    rect.size.width = 300.0f;
    
    rect.size.height -= 74.0f;
    
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    NSLog(@"%@",NSStringFromCGRect(self.tableView.frame));
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction:)];
    [self setupTableView];

    self.tableView.tableFooterView = self.footerView;
    self.usageList = @[@"口服",@"外用",@"其他"];
    self.unitList = @[@"粒",@"袋",@"包",@"瓶",@"克",@"毫克",@"毫升",@"片",@"支",@"滴",@"枚",@"块",@"盒",@"喷"];
    self.countField.tag = 1009;

    NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"Documents/%@",app.configureList[APP_USERNAME_KEY]]];
    homePath = [NSString stringWithFormat:@"%@/UserNameList.plist",homePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:homePath])
    {
        self.useNameList = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserNameList" ofType:@"plist"]];
        [self.useNameList writeToFile:homePath atomically:YES];
    }else{
        self.useNameList = [NSMutableArray arrayWithContentsOfFile:homePath];
    }
    self.periodList = @[@"每日",@"每2日",@"每3日",@"每4日",@"每5日",@"每6日",@"每7日",@"即需即用"];
    self.frequencyList = @[@"1次",@"2次",@"3次",@"4次",@"5次"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden) name:UIKeyboardWillHideNotification object:nil];
    
    if(self.editMode == 1)
    {
        
        self.infoDict = [NSMutableDictionary dictionaryWithDictionary:self.originDict];
        [self obtainDataSource];
        self.title = @"编辑用药";
        [self fillupDrug];
        [self adjustUseageDetailLabel];
    
        //////////////////事先判断/////////////////////
        if(![self.usageButton.titleLabel.text isEqualToString:@"口服/外用/其他"]){
            
            [self.usageButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        }
        if(![self.unitButton.titleLabel.text isEqualToString:@"单位"]){
            
            [self.unitButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        }
        if(![self.periodButton.titleLabel.text isEqualToString:@"周期"]){
            [self.periodButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        }
        if(![self.frequencyButton.titleLabel.text isEqualToString:@"次数"]){
            [self.frequencyButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
        }
        //////////////////事先判断/////////////////////
        
    }else{
        self.title = @"添加用药";
        self.infoDict = [NSMutableDictionary dictionary];
    }
}

- (void)obtainDataSource
{
    if(!self.originDict[@"productId"]){
        return;
    }
    //初始化摘要HTTP
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:QueryProductDetail]];
    request.tag = 0;
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestFinished:)];
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"productId"] = self.originDict[@"productId"];
    setting = [[[HTTPRequestManager sharedInstance] secretBuild:setting] mutableCopy];
    [request appendPostData:[NSJSONSerialization dataWithJSONObject:setting options:0 error:nil]];
    [request startAsynchronous];

}
- (void)requestFinished:(ASIHTTPRequest *)request{
    
//    NSDictionary *dict = [[request responseString] JSONValue];
//    
//    int accType = [self.infoDict[@"accType"] intValue];
//    
//    if(dict[@"body"][@"headerInfo"][@"factory"] && accType == 2){
//        
//        [self.infoDict setObject:dict[@"body"][@"headerInfo"][@"factory"] forKey:@"source"];
//        [self.tableView reloadData];
//    }
}

- (void)fillupDrug
{
    if(self.infoDict[@"useMethod"])
        [self.usageButton setTitle:self.infoDict[@"useMethod"] forState:UIControlStateNormal];
    self.countField.text = self.infoDict[@"perCount"];
    if(self.infoDict[@"unit"])
        [self.unitButton setTitle:self.infoDict[@"unit"] forState:UIControlStateNormal];
    NSUInteger intervalDay = [self.infoDict[@"intervalDay"] integerValue];
    if(!self.infoDict[@"intervalDay"])
    {
        
    }else if(intervalDay == 0) {
        self.frequencyButton.userInteractionEnabled = NO;
        [self.periodButton setTitle:[NSString stringWithFormat:@"即需即用"] forState:UIControlStateNormal];
        [self.infoDict removeObjectForKey:@"drugTime"];
        //self.infoDict[] = @"";
        [self.frequencyButton setTitle:@"次数" forState:UIControlStateNormal];
    }else if (intervalDay == 1) {
        [self.periodButton setTitle:[NSString stringWithFormat:@"每日"] forState:UIControlStateNormal];
    }else{
        [self.periodButton setTitle:[NSString stringWithFormat:@"每%@日",self.infoDict[@"intervalDay"]] forState:UIControlStateNormal];
    }
    if(self.infoDict[@"drugTime"] && ![[NSString stringWithFormat:@"%@",self.infoDict[@"drugTime"]] isEqualToString:@""]){
        [self.frequencyButton setTitle:[NSString stringWithFormat:@"%@次",self.infoDict[@"drugTime"]] forState:UIControlStateNormal];
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField.tag == 1008)
    {
        if(textField.text.length >= 10 && ![string isEqualToString:@""])
        {
            return NO;
        }
    }
    if(textField.tag == 1009)
    {
        if(textField.text.length >= 7 && ![string isEqualToString:@""])
        {
            return NO;
        }
    }
    [self.infoDict setValue:string forKey:@"perCount"];
    [self adjustUseageDetailLabel];
    return YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField.tag != 1008) {
        [self.tableView setContentSize:CGSizeMake(300, self.tableView.frame.size.height + 150)];
        [self.tableView setContentOffset:CGPointMake(0, 150) animated:YES];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.tag != 1008) {
        self.infoDict[@"perCount"] = textField.text;
        [self.tableView setContentSize:CGSizeMake(300, self.tableView.frame.size.height - 150)];
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        [textField resignFirstResponder];
        [self adjustUseageDetailLabel];
    }
    return YES;
}

- (void)keyboardWasHidden
{
    self.infoDict[@"perCount"] = self.countField.text;
    [self.tableView setContentSize:CGSizeMake(300, self.tableView.frame.size.height - 150)];
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - LeveyPopListView delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        if(self.customAlertView.textField.text.length == 0) {
            return;
        }else if(self.customAlertView.textField.text.length > 10){
            [SVProgressHUD showErrorWithStatus:@"自定义姓名不能超过十位!" duration:0.8f];
            return;
        }
        NSString *userName = self.customAlertView.textField.text;
        [self.useNameList insertObject:userName atIndex:0];
        NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"Documents/%@",app.configureList[APP_USERNAME_KEY]]];
        homePath = [NSString stringWithFormat:@"%@/UserNameList.plist",homePath];
//        BOOL result = [self.useNameList writeToFile:homePath atomically:YES];
        self.infoDict[@"useName"] = userName;
        [self.tableView reloadData];
    }
}

- (void)adjustUseageDetailLabel
{
    NSString *str1 = nil;//用法
    NSString *str2 = nil;//用量
    NSString *str3 = nil;//次数
    //第一行填满
    if(self.infoDict[@"useMethod"]){
        str1 = self.infoDict[@"useMethod"];
    }
    //第二行填满
    if(self.infoDict[@"perCount"] && self.infoDict[@"unit"]){
        str2 = [NSString stringWithFormat:@"一次%@%@",self.infoDict[@"perCount"],self.infoDict[@"unit"]];
    }
    //第三行填满
    if(self.infoDict[@"intervalDay"] && self.infoDict[@"drugTime"]){
        NSUInteger intervalDay = [self.infoDict[@"intervalDay"] integerValue];
        if(intervalDay == 0) {
            str3 = @"即需即用";
        }else{
            str3 = [NSString stringWithFormat:@"%@日%@次",self.infoDict[@"intervalDay"],self.infoDict[@"drugTime"]];
        }
    }
    _usageDetailLabel.textColor = UIColorFromRGB(0x333333);
    if(str1)
        _usageDetailLabel.text = [NSString stringWithFormat:@"%@",str1];
    if(str2)
        _usageDetailLabel.text = [NSString stringWithFormat:@"%@",str2];
    if(str3)
        _usageDetailLabel.text = [NSString stringWithFormat:@"%@",str3];
    if(str1 && str2)
        _usageDetailLabel.text = [NSString stringWithFormat:@"%@，%@",str1,str2];
    if(str1 && str3)
        _usageDetailLabel.text = [NSString stringWithFormat:@"%@，%@",str1,str3];
    if(str2 && str3)
        _usageDetailLabel.text = [NSString stringWithFormat:@"%@，%@",str2,str3];
    if(str1 && str2 && str3)
        _usageDetailLabel.text = [NSString stringWithFormat:@"%@，%@，%@",str1,str2,str3];
  
    //////////////////事先判断/////////////////////
 
    if(![self.infoDict[@"useMethod"] isEqualToString:@"口服/外用/其他"] && self.infoDict[@"useMethod"]){
        
        [self.usageButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    }
    if(![self.infoDict[@"unit"] isEqualToString:@"单位"] && self.infoDict[@"unit"]){
        
        [self.unitButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    }
    NSString *str = @"finally";
    if(self.infoDict[@"intervalDay"] ){
        [self.periodButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    }
 
    if(self.infoDict[@"drugTime"] && ![self.infoDict[@"drugTime"] isMemberOfClass:[str class]]){
        [self.frequencyButton setTitleColor:UIColorFromRGB(0x666666) forState:UIControlStateNormal];
    }
    
    //////////////////事先判断/////////////////////
    
}

#pragma mark - UIAlertViewDelegate
- (void)leveyPopListView:(LeveyPopListView *)popListView didSelectedIndex:(NSInteger)anIndex
{
    ;
    switch (popListView.tag)
    {
        case 1:{
            NSString *title = self.usageList[anIndex];
            self.infoDict[@"useMethod"] = title;
            [self.usageButton setTitle:title forState:UIControlStateNormal];
            [self.usageButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
            break;
        }
        case 2:{
            NSString *title = self.unitList[anIndex];
            self.infoDict[@"unit"] = title;
            [self.unitButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
            [self.unitButton setTitle:title forState:UIControlStateNormal];
            
            break;
        }
        case 3:{
            NSString *title = self.periodList[anIndex];
            NSString *intervalDay = [title substringWithRange:NSMakeRange(1, 1)];
            if([intervalDay isEqualToString:@"日"]) {
                intervalDay = @"1";
            }
            if([title isEqualToString:@"即需即用"]){
                intervalDay = @"0";
                self.frequencyButton.userInteractionEnabled = NO;
                NSString *title = self.frequencyList[0];
                NSString *drugTime = [title substringWithRange:NSMakeRange(0, 1)];
                self.infoDict[@"drugTime"] = [NSNumber numberWithInt:[drugTime integerValue]];
                [self.frequencyButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
                [self.frequencyButton setTitle:@"次数" forState:UIControlStateNormal];
            }else{
                self.frequencyButton.userInteractionEnabled = YES;
            }
        
            self.infoDict[@"intervalDay"] = [NSNumber numberWithInt:[intervalDay integerValue]];
            [self.periodButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
            [self.periodButton setTitle:title forState:UIControlStateNormal];
            break;
        }
        case 4:{
            NSString *title = self.frequencyList[anIndex];
            NSString *drugTime = [title substringWithRange:NSMakeRange(0, 1)];
            self.infoDict[@"drugTime"] = [NSNumber numberWithInt:[drugTime integerValue]];
            [self.frequencyButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
            [self.frequencyButton setTitle:title forState:UIControlStateNormal];
            break;
        }
        case 5:
        {
            if(anIndex == (self.useNameList.count - 1)) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alertView.tag = 999;
                NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"secondCustomAlertView" owner:self options:nil];
                self.customAlertView = [nibViews objectAtIndex: 0];
                self.customAlertView.textField.frame = CGRectMake(self.customAlertView.textField.frame.origin.x, self.customAlertView.textField.frame.origin.y, self.customAlertView.textField.frame.size.width, 48);
                self.customAlertView.textField.placeholder = @"";
                self.customAlertView.textField.font = Font(15.0f);
                self.customAlertView.textField.textColor = UIColorFromRGB(0x333333);
                
                self.customAlertView.textField.layer.masksToBounds = YES;
                self.customAlertView.textField.layer.borderWidth = 0.5;
                self.customAlertView.textField.layer.borderColor = UIColorFromRGB(0xdbdbdb).CGColor;
                self.customAlertView.textField.layer.cornerRadius = 3.0f;
                UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
                self.customAlertView.textField.leftView = paddingView;
                self.customAlertView.textField.leftViewMode = UITextFieldViewModeAlways;
                if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
                    [alertView setValue:self.customAlertView forKey:@"accessoryView"];
                }else{
                    [alertView addSubview:self.customAlertView];
                }
                
//                self.customAlertView.textField.keyboardType = UIKeyboardTypeDefault;// 设置键盘样式
                [alertView show];

            }
            else{
                self.infoDict[@"useName"] = self.useNameList[anIndex];
            }
            [self.tableView reloadData];
            break;
        }
        default:
            break;
    }
    [self adjustUseageDetailLabel];
}

- (void)leveyPopListViewDidCancel
{

}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 10)];
    [header setBackgroundColor:[UIColor clearColor]];
    return header;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
  
    if(self.infoDict[@"source"]){
        return 3;
    }
    else{
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableViewCellIdentifier = @"TableViewCellIdentifier";
    UITableViewCell *cell = [atableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableViewCellIdentifier];
        
        UIView *bkView = [[UIView alloc]initWithFrame:cell.frame];
        bkView.backgroundColor = UIColorFromRGB(0xdfe4e6);
        cell.selectedBackgroundView = bkView;
        
    }
    cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
    cell.textLabel.textColor = UIColorFromRGB(0x666666);
    
    UILabel *accessTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    accessTitle.font = [UIFont systemFontOfSize:16.0f];
    
    accessTitle.textColor = UIColorFromRGB(0x66666);
    accessTitle.textAlignment = NSTextAlignmentRight;
    
    cell.accessoryView = accessTitle;
    
    if(self.infoDict[@"source"]){
        switch (indexPath.section)
        {
            case 0:
            {
                    cell.textLabel.text = @"药品名称";
                    if(self.infoDict[@"productName"]) {
                        accessTitle.textColor = UIColorFromRGB(0x333333);
                        accessTitle.text = self.infoDict[@"productName"];
                    }else{
                        accessTitle.textColor = UIColorFromRGB(0xaaaaaa);
                        accessTitle.text = @"请添加药品";
            }
            break;
            case 1:
            {
                    cell.textLabel.text = @"来源";
                    if (self.infoDict[@"accType"] != nil) {
                        NSInteger intAccType = [self.infoDict[@"accType"] intValue];
                        if (intAccType == 2) {
                            UIView *viewSub = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
                            UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 50)];
                            lblTitle.textColor = UIColorFromRGB(0x333333);
                            lblTitle.text = self.infoDict[@"source"];
                            lblTitle.textAlignment = NSTextAlignmentRight;
                            lblTitle.font = [UIFont systemFontOfSize:16.0f];
                            
                            UIImageView *imgViewV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"认证V.png"]];
                            imgViewV.frame = CGRectMake(180, 15, 16, 16);
                            [viewSub addSubview:imgViewV];
                            [viewSub addSubview:lblTitle];
                            cell.accessoryView = viewSub;
                        }
                    }
                    accessTitle.text = self.infoDict[@"source"];
                }
                break;
            }
            case 2:{
                cell.textLabel.text = @"使用者";
                if(self.infoDict[@"useName"]) {
                    //                accessTitle.textColor = UIColorFromRGB(0x333333);
                    accessTitle.textColor = UIColorFromRGB(0x333333);
                    accessTitle.text = self.infoDict[@"useName"];
                }else{
                    accessTitle.textColor = UIColorFromRGB(0xaaaaaa);
                    accessTitle.text = @"请选择使用者";
                }
                break;
            }
            default:
                break;
        }
    }
    else{
    switch (indexPath.section)
    {
        case 0:
        {
            if(indexPath.row == 0){
                cell.textLabel.text = @"药品名称";
                if(self.infoDict[@"productName"]) {
                    //                    accessTitle.textColor = UIColorFromRGB(0x333333);
                    accessTitle.textColor = UIColorFromRGB(0x333333);
                    accessTitle.text = self.infoDict[@"productName"];
                }else{
                    accessTitle.textColor = UIColorFromRGB(0xaaaaaa);
                    accessTitle.text = @"请添加药品";
                }
            }else if(indexPath.row == 1) {
                cell.textLabel.text = @"来源";
                if (self.infoDict[@"accType"] != nil) {
                    NSInteger intAccType = [self.infoDict[@"accType"] intValue];
                    if (intAccType == 2) {
                        UIView *viewSub = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
                        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 50)];
                        lblTitle.textColor = UIColorFromRGB(0x333333);
                        lblTitle.text = self.infoDict[@"source"];
                        lblTitle.textAlignment = NSTextAlignmentRight;
                        lblTitle.font = [UIFont systemFontOfSize:16.0f];
                        
                        UIImageView *imgViewV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"认证V.png"]];
                        imgViewV.frame = CGRectMake(180, 15, 16, 16);
                        [viewSub addSubview:imgViewV];
                        [viewSub addSubview:lblTitle];
                        cell.accessoryView = viewSub;
                    }
                }
                accessTitle.text = self.infoDict[@"source"];
            }
            break;
        }
        case 1:{
            cell.textLabel.text = @"使用者";
            if(self.infoDict[@"useName"]) {
                accessTitle.textColor = UIColorFromRGB(0x333333);
                accessTitle.text = self.infoDict[@"useName"];
            }else{
                accessTitle.textColor = UIColorFromRGB(0xaaaaaa);
                accessTitle.text = @"请选择使用者";
            }
            break;
        }
        default:
            break;
    }
    }
    return cell;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.countField resignFirstResponder];
    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择药品来源" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从药品库搜索",@"扫描条形码", nil];
    
    if(self.editMode == 1 && self.infoDict[@"source"]){
        switch (indexPath.section) {
            case 0:{
                [sheet showInView:self.view];
            }
            break;
                
            case 2:
            {
                LeveyPopListView *popListView = [[LeveyPopListView alloc] initWithTitle:@"请选择用法" options:self.useNameList];
                popListView.delegate = self;
                popListView.tag = 5;
                if(self.infoDict[@"useName"])
                    popListView.selectedIndex = [self compareAdapter:self.infoDict[@"useName"] WithFilterArray:self.useNameList];
                [popListView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
                [popListView showInView:self.view animated:YES];
                break;
            }
        }
    }
    else{
        switch (indexPath.section) {
            case 0:{
                [sheet showInView:self.view];
            }
            break;
            case 1:
            {
                LeveyPopListView *popListView = [[LeveyPopListView alloc] initWithTitle:@"请选择用法" options:self.useNameList];
                popListView.delegate = self;
                popListView.tag = 5;
                if(self.infoDict[@"useName"])
                    popListView.selectedIndex = [self compareAdapter:self.infoDict[@"useName"] WithFilterArray:self.useNameList];
                [popListView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
                [popListView showInView:self.view animated:YES];
                break;
            }
            default:
            break;
        }
    }
    
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        SearchMedicineViewController *searchMedicineViewController = [[SearchMedicineViewController alloc] init];
        searchMedicineViewController.selectBlock = ^(NSMutableDictionary* dataRow){
            self.infoDict[@"productName"] = dataRow[@"productName"];
            if(dataRow[@"productId"])
                self.infoDict[@"productId"] = dataRow[@"productId"];
            [self.infoDict addEntriesFromDictionary:dataRow];
            if(self.infoDict[@"drugTime"] && !self.infoDict[@"intervalDay"]) {
                self.infoDict[@"intervalDay"] = @"1";
            }
            [self fillupDrug];
            [self adjustUseageDetailLabel];
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:searchMedicineViewController animated:NO];
    }else if (buttonIndex == 1){
        ScanReaderViewController *scanReaderViewController = [[ScanReaderViewController alloc] initWithNibName:@"ScanReaderViewController" bundle:nil];
        scanReaderViewController.useType = 2;
        scanReaderViewController.completionBolck = ^(NSMutableDictionary *dict){
            self.infoDict[@"productName"] = dict[@"proName"];
            self.infoDict[@"productId"] = dict[@"proId"];
            [dict removeObjectForKey:@"proName"];
            [dict removeObjectForKey:@"proId"];
            [self.infoDict addEntriesFromDictionary:dict];
            if(self.infoDict[@"drugTime"] && !self.infoDict[@"intervalDay"]) {
                self.infoDict[@"intervalDay"] = @"1";
            }
            
            [self fillupDrug];
            [self adjustUseageDetailLabel];
            [self.tableView reloadData];
        };
        [self.navigationController pushViewController:scanReaderViewController animated:YES];
    }
}

- (NSInteger)compareAdapter:(NSString *)adapter WithFilterArray:(NSArray *)array
{
    for(NSString *filter in array)
    {
        if([filter isEqualToString:adapter]) {
            return [array indexOfObject:filter];
        }
    }
    return -1;
}

- (IBAction)chooseUsage:(id)sender
{
    [self.countField resignFirstResponder];
    LeveyPopListView *popListView = [[LeveyPopListView alloc] initWithTitle:@"请选择用法" options:self.usageList];
    popListView.delegate = self;
    popListView.tag = 1;
    popListView.selectedIndex = [self compareAdapter:[self.usageButton titleForState:UIControlStateNormal] WithFilterArray:self.usageList];
    [popListView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
    [popListView showInView:self.view animated:YES];
}

- (IBAction)chooseUnit:(id)sender
{
    [self.countField resignFirstResponder];
    LeveyPopListView *popListView = [[LeveyPopListView alloc] initWithTitle:@"请选择用法" options:self.unitList];
    popListView.tag = 2;
    popListView.delegate = self;
    popListView.selectedIndex = [self compareAdapter:[self.unitButton titleForState:UIControlStateNormal] WithFilterArray:self.unitList];
    

    [popListView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
 
    [popListView showInView:self.view animated:YES];
    
}

- (IBAction)choosePeriod:(id)sender
{
    [self.countField resignFirstResponder];
    LeveyPopListView *popListView = [[LeveyPopListView alloc] initWithTitle:@"请选择用法" options:self.periodList];
    popListView.delegate = self;
    popListView.tag = 3;
    popListView.selectedIndex = [self compareAdapter:[self.periodButton titleForState:UIControlStateNormal] WithFilterArray:self.periodList];
    [popListView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
    [popListView showInView:self.view animated:YES];
}

- (IBAction)chooseFrequency:(id)sender
{
    [self.countField resignFirstResponder];
    LeveyPopListView *popListView = [[LeveyPopListView alloc] initWithTitle:@"请选择用法" options:self.frequencyList];
    popListView.selectedIndex = [self compareAdapter:[self.frequencyButton titleForState:UIControlStateNormal] WithFilterArray:self.frequencyList];
    popListView.delegate = self;
    popListView.tag = 4;
    [popListView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
    [popListView showInView:self.view animated:YES];
}

- (NSString *)getCurDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strCur = [dateFormatter stringFromDate:[NSDate date]];
    return strCur;
}

- (void)saveAction:(id)sender
{
    if(!app.logStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
        return;
    }
    
    if (app.currentNetWork == kNotReachable) {
        
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
         
        return;
         
    }
         
    self.infoDict[@"perCount"] = self.countField.text;
    if(!self.infoDict[@"productName"]){
        [SVProgressHUD showErrorWithStatus:@"请添加药品!" duration:0.8f];
        return;
    }
    if(!self.infoDict[@"useName"]){
        [SVProgressHUD showErrorWithStatus:@"请选择使用者!" duration:0.8f];
        return;
    }
    if(!self.infoDict[@"useMethod"]){
        [SVProgressHUD showErrorWithStatus:@"请选择用法!" duration:0.8f];
        return;
    }
    if(!self.infoDict[@"perCount"] || [self.infoDict[@"perCount"] isEqualToString:@""]){
        [SVProgressHUD showErrorWithStatus:@"请选择数量!" duration:0.8f];
        return;
    }
    if(!self.infoDict[@"unit"]){
        [SVProgressHUD showErrorWithStatus:@"请选择单位!" duration:0.8f];
        return;
    }
    if(!self.infoDict[@"intervalDay"]){
        [SVProgressHUD showErrorWithStatus:@"请选择周期!" duration:0.8f];
        return;
    }
    if(!self.infoDict[@"drugTime"] && ([self.infoDict[@"intervalDay"] integerValue] != 0)){
        [SVProgressHUD showErrorWithStatus:@"请选择次数!" duration:0.8f];
        return;
    }
    if(self.countField.text.length > 7)
    {
        [SVProgressHUD showErrorWithStatus:@"用量输入不得超过十位!" duration:0.8f];
        return;
    }
    self.navigationItem.rightBarButtonItem.enabled = NO;
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    if(self.infoDict[@"boxId"]){
        setting[@"boxId"] = self.infoDict[@"boxId"];
    }
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    if(self.infoDict[@"productId"]){
        setting[@"productId"] = self.infoDict[@"productId"];
    }
    setting[@"productName"] = self.infoDict[@"productName"];
    setting[@"useName"] = self.infoDict[@"useName"];
    setting[@"useMethod"] = self.infoDict[@"useMethod"];
    setting[@"perCount"] = self.infoDict[@"perCount"];
    setting[@"unit"] = self.infoDict[@"unit"];
    setting[@"intervalDay"] = self.infoDict[@"intervalDay"];
    if([setting[@"intervalDay"] integerValue] != 0)
        setting[@"drugTime"] = self.infoDict[@"drugTime"];

    if(self.infoDict[@"source"]){
        setting[@"source"] = self.infoDict[@"source"];
    }
    [[HTTPRequestManager sharedInstance] saveOrUpdateMyBox:setting completion:^(id resultObj) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if ([resultObj[@"result"] isEqualToString:@"OK"])
        {
            self.infoDict[@"boxId"] = resultObj[@"body"][@"boxId"];
            [self.originDict addEntriesFromDictionary:self.infoDict];
            if(self.InsertNewPharmacy) {
                self.infoDict[@"createTime"] = [self getCurDate];
                self.InsertNewPharmacy(self.infoDict);
            }
            [self savePharmacy];
            if(self.editMode == 1)
            {
                //编辑模式,需要发出通知,更新用药列表
                [[NSNotificationCenter defaultCenter] postNotificationName:PHARMACY_NEED_UPDATE object:nil];
            }
            [self.navigationController popViewControllerAnimated:NO];
            if (self.blockPush != nil) {
                self.blockPush();
            }
        }else{
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    } failure:^(NSError *error) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }];
}

- (void)setPushToMyMedicineBlock:(PushToMyMedicineList)block
{
    self.blockPush = block;
}

- (void)savePharmacy
{
    NSDictionary *dict = self.infoDict;
    NSString *boxId = dict[@"boxId"];
    NSString *productName = dict[@"productName"];
    NSString *productId = dict[@"productId"];
    NSString *source = dict[@"source"];
    if(!source)
        source = @"";
    NSString *useName = dict[@"useName"];
    if(!useName)
        useName = @"";
    NSString *createtime = @"";
    if(dict[@"createtime"])
        createtime = dict[@"createtime"];

    NSString *effect = @"";
    if(dict[@"effect"])
        effect = dict[@"effect"];
    
    NSString *useMethod = @"";
    if(dict[@"useMethod"]){
        useMethod = dict[@"useMethod"];
    }

    NSString *perCount = @"";
    if(dict[@"perCount"])
        perCount = [NSString stringWithFormat:@"%@",dict[@"perCount"]];
    NSString *unit = @"";
    if(dict[@"unit"])
        unit = dict[@"unit"];
    NSString *intervalDay = [NSString stringWithFormat:@"%@",dict[@"intervalDay"]];
    if(!intervalDay)
        intervalDay = @"";
    NSString *drugTime = @"";
    if(dict[@"drugTime"])
        drugTime = [NSString stringWithFormat:@"%@",dict[@"drugTime"]];

    NSString *drugTag = @"";
    if(dict[@"drugTag"])
        drugTag = dict[@"drugTag"];
    NSString *productEffect = dict[@"productEffect"];
    if(!productEffect)
        productEffect = @"";
    [app.dataBase insertIntoMybox:boxId productName:productName productId:productId source:source useName:useName createtime:createtime effect:effect useMethod:useMethod perCount:perCount unit:unit intervalDay:intervalDay drugTime:drugTime drugTag:drugTag productEffect:productEffect];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

@end
