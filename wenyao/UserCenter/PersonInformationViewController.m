//
//  PersonInformationViewController.m
//  wenyao
//
//  Created by Meng on 14-9-30.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "PersonInformationViewController.h"
#import "SJAvatarBrowser.h"
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"
#import "ChangePhoneNumberViewController.h"
#import "AppDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJson.h"
#import "UIImageView+WebCache.h"
#import "LoginViewController.h"
#import "Appdelegate.h"
#import "SDImageCache.h"
#import "UIView+Extension.h"
#import "ReturnIndexView.h"

#define FIEST_ROW_HEIGHT 80
#define SECOND_ROW_HEIGHT 40

#define F_TITLE  14
#define F_DESC   12

@interface PersonInformationViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,ChangePhoneNumberViewControllerDelegate,ReturnIndexViewDelegate>
{
    NSArray * titleArray;
    __block AppDelegate * appDelegate;
}
@property (strong, nonatomic) ReturnIndexView *indexView;
@end

@implementation PersonInformationViewController

- (id)init{
    if (self = [super init]) {
        self.title = @"个人资料";
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        titleArray = @[@"头像",@"昵称",@"性别",@"手机号"];
  
        appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
    }
    return self;
}

#pragma mark---------------------------------------------跳转到首页-----------------------------------------------

- (void)setUpRightItem
{
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -6;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-unfold.PNG"] style:UIBarButtonItemStylePlain target:self action:@selector(returnIndex)];
    self.navigationItem.rightBarButtonItems = @[fixed,rightItem];
}
- (void)returnIndex
{
    self.indexView = [ReturnIndexView sharedManagerWithImage:@[@"icon home.PNG"] title:@[@"首页"]];
    self.indexView.delegate = self;
    [self.indexView show];
}
- (void)RetunIndexView:(ReturnIndexView *)ReturnIndexView didSelectedIndex:(NSIndexPath *)indexPath
{
    [self.indexView hide];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self performSelector:@selector(delayPopToHome) withObject:nil afterDelay:0.01];
}
- (void)delayPopToHome
{
    [app.tabBarController setSelectedIndex:0];
}
#pragma mark---------------------------------------------跳转到首页-----------------------------------------------

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
}

-(void)loadData
{
    if(app.currentNetWork != kNotReachable) {
        
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        setting[@"token"] = app.configureList[APP_USER_TOKEN];
        
        [[HTTPRequestManager sharedInstance] queryMemberDetail:setting completionSuc:^(id resultObj){
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                [app.configureList addEntriesFromDictionary:resultObj[@"body"]];
                [app saveAppConfigure];
                [self.tableView reloadData];
            }
        }failure:^(id failMsg) {
            NSLog(@"%@",failMsg);
        }];
    }else{
        if(app.configureList[@"sex"]) {
            [self.tableView reloadData];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    [self setUpRightItem];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titleArray.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return FIEST_ROW_HEIGHT;
    }else
        return SECOND_ROW_HEIGHT;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellIdentifier = @"Identifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        for (UIView *viewSub in cell.contentView.subviews) {
            [viewSub removeFromSuperview];
        }
    }
    
    UILabel *lblTitle = [[UILabel alloc] init];
    lblTitle.text = titleArray[indexPath.row];
    CGSize feelSize = [lblTitle.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];//cell.contentView.frame.size.height / 2 - feelSize.height / 2
    if (indexPath.row == 0) {
        [lblTitle setFrame:CGRectMake(15, 30, 50, feelSize.height)];
    } else {
        [lblTitle setFrame:CGRectMake(15, cell.contentView.frame.size.height / 2 - feelSize.height / 2, 50, feelSize.height)];
    }
    lblTitle.textColor = UIColorFromRGB(0x333333);
    lblTitle.font = Font(16);
    [cell.contentView addSubview:lblTitle];
//    cell.textLabel.text = titleArray[indexPath.row];
//    cell.textLabel.font = Font(14);
    if (indexPath.row == 0) {
        [self makeAccessoryImageViewWithCell:cell];
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0,FIEST_ROW_HEIGHT - 0.5, 320, 0.5)];
        [separator setBackgroundColor:UIColorFromRGB(0xdbdbdb)];
        [cell addSubview:separator];
    }else{
        [self makeAccessoryLabelWithCell:cell withIndexPath:indexPath];
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0,SECOND_ROW_HEIGHT -0.5, 320, 0.5)];
        [separator setBackgroundColor:UIColorFromRGB(0xdbdbdb)];
        [cell addSubview:separator];
    }
    
    return cell;
}

- (void)makeAccessoryLabelWithCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath{
    NSString * str;
    //CGSize feelSize = [@"未设置" sizeWithFont:[UIFont systemFontOfSize:F_DESC]];
    UILabel * label = [[UILabel alloc]init];
    
    label.textAlignment = NSTextAlignmentLeft;
    if (indexPath.row == 1) {//昵称
        str = app.configureList[@"nickName"];
        if (app.configureList[@"nickName"] == nil || [str isEqualToString:@""]) {
            str = @"未设置";
        }
        
    }else if (indexPath.row == 2){//性别
        str = app.configureList[@"sex"];
        NSLog(@"str===%@",str);
//        if (app.configureList[@"sex"] == nil || [str isEqualToString:@""]) {
//            str = @"未设置";
//        }
        
    }else if (indexPath.row == 3){//手机号
        str = app.configureList[@"mobile"];
        if (app.configureList[@"mobile"] == nil || [str isEqualToString:@""]) {
            str = @"未设置";
        }
    }
  
    NSString * s = [NSString stringWithFormat:@"%@",str];
    label.textColor = UIColorFromRGB(0x333333);
    if (s) {
        if (indexPath.row == 1) {
            if([s isEqualToString:@"未设置"]){
                label.textColor = UIColorFromRGB(0x999999);
            }
            if(s.length > 0){
                label.text = s;
            }
        }
        if (indexPath.row == 2) {

            if ([str isEqualToString:@"0"]) {
                label.text = @"男";
            }else if([str isEqualToString:@"1"]){
                label.text = @"女";
            }else{
                label.textColor = UIColorFromRGB(0x999999);
                label.text = @"未设置";
            }
        }else
            label.text = s;
    }
 
    CGSize feelSize = [label.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    
    [label setFrame:CGRectMake(-10, 0, feelSize.width + 25, feelSize.height)];
    label.font = Font(16.0f);
   
    UIImage * rightImage = [UIImage imageNamed:@"向右箭头.png"];
    UIImageView *imgViewRight = [[UIImageView alloc] initWithFrame:CGRectMake(feelSize.width+5.0f, 1, rightImage.size.width+1, rightImage.size.height)];
    imgViewRight.image = rightImage;
    
    UIView *viewAccessory = [[UIView alloc] initWithFrame:CGRectMake(0, 0, feelSize.width + 5 + rightImage.size.width, feelSize.height)];
    [viewAccessory addSubview:label];
    [viewAccessory addSubview:imgViewRight];
    viewAccessory.backgroundColor = [UIColor clearColor];

    cell.accessoryView = viewAccessory;
}

- (void)makeAccessoryImageViewWithCell:(UITableViewCell *)cell{
    
    UIImage * image = [UIImage imageNamed:@"我_个人默认头像.png"];
    UIImageView * myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
    [myImageView convertIntoCircular];
    myImageView.tag = 9999;
    
    UIImage *headImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:app.configureList[APP_AVATAR_KEY]];
    if(headImage){
        myImageView.image = headImage;
    }else{
        [myImageView setImageWithURL:[NSURL URLWithString:app.configureList[APP_AVATAR_KEY]] placeholderImage:image];
    }

    myImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer * t = [[UITapGestureRecognizer alloc] init];
    [t addTarget:self action:@selector(imageViewClick:)];
    [myImageView addGestureRecognizer:t];
    
    UIImage * rightImage = [UIImage imageNamed:@"向右箭头.png"];
    UIImageView *imgViewRight = [[UIImageView alloc] initWithFrame:CGRectMake(myImageView.frame.size.width+5.0f, myImageView.frame.size.height/2-rightImage.size.height/2, rightImage.size.width+1, rightImage.size.height+1)];
    imgViewRight.image = rightImage;
    
    UIView *viewAccessory = [[UIView alloc] initWithFrame:CGRectMake(0, 0, myImageView.frame.size.width+5+rightImage.size.width, MAX(myImageView.frame.size.height, imgViewRight.frame.size.height))];
    [viewAccessory addSubview:myImageView];
    [viewAccessory addSubview:imgViewRight];
    
    cell.accessoryView = viewAccessory;
}

- (void)imageViewClick:(UITapGestureRecognizer*)sender{
    [SJAvatarBrowser showImage:(UIImageView*)sender.view];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请稍后重试" duration:0.8];
        return;
    }
    
    if (indexPath.row == 0) {
        //设置头像
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照设置头像", @"从相册选择头像", nil];
        actionSheet.tag = 100;
        [actionSheet showInView:self.view];
    }else if (indexPath.row == 1){
        //设置昵称
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 999;
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"secondCustomAlertView" owner:self options:nil];
        
        self.customAlertView = [nibViews objectAtIndex: 0];
        self.customAlertView.textField.frame = CGRectMake(self.customAlertView.textField.frame.origin.x, self.customAlertView.textField.frame.origin.y, self.customAlertView.textField.frame.size.width, 48);
        self.customAlertView.textField.placeholder = @"起一个响亮的昵称吧";
        self.customAlertView.textField.font = Font(15.0f);
        self.customAlertView.textField.textColor = UIColorFromRGB(0x333333);
        
        NSString * str = app.configureList[@"nickName"];
        if (app.configureList[@"nickName"] == nil || [str isEqualToString:@""]) {
            str = @"";
        }
        self.customAlertView.textField.text = str;
        
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
        
        self.customAlertView.textField.keyboardType = UIKeyboardTypeDefault;// 设置键盘样式
        [alertView show];
    }else if (indexPath.row == 2){
        //设置性别
        UIActionSheet * sexActionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"请选择性别" otherButtonTitles:@"男",@"女", nil];
        sexActionSheet.tag = 101;
        [sexActionSheet showInView:self.view];
    }else if (indexPath.row == 3){
        //设置手机号
//        [MobClick event:@"ag-shoujihao"];
        UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"修改手机号?", nil];
        actionSheet.tag = 102;
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag == 100) {//设置头像
        UIImagePickerControllerSourceType sourceType;
        if (buttonIndex == 0) {
            //拍照
            sourceType = UIImagePickerControllerSourceTypeCamera;
        }else if (buttonIndex == 1){
            //相册
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }else if (buttonIndex == 2){
            //取消
            return;
        }
        if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"Sorry,您的设备不支持该功能!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:nil];
    }else if (actionSheet.tag == 101){//设置性别
        
        if (buttonIndex == 1 || buttonIndex == 2) {
            NSMutableDictionary * setting = [NSMutableDictionary dictionary];
            
            setting[@"token"] = appDelegate.configureList[APP_USER_TOKEN];
            NSInteger sexNum = 0;
            if (buttonIndex == 1) {
                sexNum = 0;
            } else {
                sexNum = 1;
            }
            setting[@"sex"] = @(sexNum);
//            [MobClick event:@"ag-xingbie"];
            [[HTTPRequestManager sharedInstance]saveMemberInfo:setting completionSuc:^(id resultObj) {
                
                if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                    [SVProgressHUD showSuccessWithStatus:@"设置性别成功" duration:DURATION_SHORT];
                    [self loadData];
                    
                }else if ([resultObj[@"result"] isEqualToString:@"FAIL"]){
                    if ([resultObj[@"msg"] isEqualToString:@"1"]) {
                        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:ALERT_MESSAGE delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        alertView.tag = 999;
                        alertView.delegate = self;
                        [alertView show];
                        return;
                    }else{
                        [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:DURATION_SHORT];
                    }
                }
            } failure:^(id failMsg) {
                NSLog(@"%@",failMsg);
            }];
            
            
            
            
        }
    }else if (actionSheet.tag == 102){
        if (buttonIndex == 0) {
//            [MobClick event:@"ags-xgsjh"];
            ChangePhoneNumberViewController * changeNumber = [[ChangePhoneNumberViewController alloc] initWithNibName:@"ChangePhoneNumberViewController" bundle:nil];
            changeNumber.delegate = self;
            changeNumber.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:changeNumber animated:YES];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        return;
    }
    
   
        if (buttonIndex == 0) {
            //取消
            return;
        }else if (buttonIndex == 1){
            
            //确定
            NSString *strUserName = self.customAlertView.textField.text;
            if (strUserName.length <= 10) {
//                [MobClick event:@"ag-nicheng"];
                [[HTTPRequestManager sharedInstance]saveMemberInfo:@{@"token":appDelegate.configureList[APP_USER_TOKEN],@"nickName":strUserName} completionSuc:^(id resultObj)
                 {
                     
                     if ([resultObj[@"result"] isEqualToString:@"OK"]){
                         [SVProgressHUD showSuccessWithStatus:@"设置昵称成功" duration:DURATION_SHORT];
                         
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateUserNickNameSuccess" object:nil userInfo:nil];
                         
                         
                         app.configureList[@"nickName"] = strUserName;
                         [self loadData];
                     } else if ([resultObj[@"result"] isEqualToString:@"FAIL"])//token失效
                     {
                         if ([resultObj[@"msg"] isEqualToString:@"1"])
                         {
                             UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:ALERT_MESSAGE delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                             alertView.tag = 999;
                             alertView.delegate = self;
                             [alertView show];
                             return;
                         }else{
                             [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:DURATION_SHORT];
                         }
                     }
                     
                 } failure:^(id failMsg) {
                     [SVProgressHUD showSuccessWithStatus:@"网络请求失败" duration:DURATION_SHORT];
                     NSLog(@"%@",failMsg);
                 }];
                return;
            }else{
                if (strUserName.length > 10) {
                    [SVProgressHUD showErrorWithStatus:@"设置昵称失败,昵称长度不能超过十个字符" duration:DURATION_SHORT];
                }
                
                return;
            }

            
        }
   
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    /**
     *1.通过相册和相机获取的图片都在此代理中
     *
     *2.图片选择已完成,在此处选择传送至服务器
     */
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        [picker dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    CGRect bounds = CGRectMake(0, 0, APP_W, APP_W);
    UIGraphicsBeginImageContext(bounds.size);
    [image drawInRect:bounds];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView * imageView = (UIImageView *)[self.view viewWithTag:9999];
    //imageView.image = image;
    if (image) {
        //self.personInfoDict[@"headImageUrl"] = image;
        
        //传到服务器
        NSData * imageData = UIImageJPEGRepresentation(image, 0.5);
        ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:NW_uploadFile]];
        [request addPostValue:@"1" forKey:@"type"];
        [request addPostValue:appDelegate.configureList[APP_USER_TOKEN] forKey:@"token"];
        NSDictionary *dict = @{@"type":@"1"};
        dict = [[HTTPRequestManager sharedInstance] secretBuild:dict];
        [request addPostValue:dict[@"sign"] forKey:@"sign"];
        [request addPostValue:APP_VERSION forKey:@"version"];
        request.timeOutSeconds = 10;
        
        [request addData:imageData forKey:@"file"];
        [request buildPostBody];
        [request setDelegate:self];
        [request setDidFailSelector:@selector(requestDidFailed:)];
        [request setDidFinishSelector:@selector(requestDidSuccess:)];
//        [request start];
        [request startAsynchronous];
        
    }
//    [MobClick event:@"ag-touxiang"];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)requestDidSuccess:(ASIFormDataRequest *)request
{
    NSDictionary *dict = [[request responseString] JSONValue];
    
    NSMutableDictionary * setting = [NSMutableDictionary dictionary];
    setting[@"token"] = appDelegate.configureList[APP_USER_TOKEN];
    setting[@"headImageUrl"] = dict[@"url"];
    
    [[HTTPRequestManager sharedInstance] saveMemberInfo:setting completionSuc:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"OK"])
        {
            [SVProgressHUD showSuccessWithStatus:@"头像上传成功" duration:DURATION_SHORT];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateUserIconSuccess" object:nil userInfo:nil];
            
            app.configureList[APP_AVATAR_KEY] = dict[@"url"];
            //刷新tableView
            
            [self.tableView reloadData];
            [self loadData];
            
        }else if ([resultObj[@"result"] isEqualToString:@"FAIL"]){
            if ([resultObj[@"msg"] isEqualToString:@"1"]) {
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:ALERT_MESSAGE delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alertView.tag = 999;
                alertView.delegate = self;
                [alertView show];
                return;
            }else{
                [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:DURATION_SHORT];
            }
        }
    } failure:^(id failMsg) {
        NSLog(@"%@",failMsg);
    }];
    
    
}

- (void)requestDidFailed:(ASIFormDataRequest *)request{
    [SVProgressHUD showSuccessWithStatus:@"头像上传失败" duration:DURATION_SHORT];
}

-(void)returnNumber:(NSString *)number{
    app.configureList[@"phoneNumber"] = number;
    NSIndexPath * indexP = [NSIndexPath indexPathForRow:3 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexP] withRowAnimation:UITableViewRowAnimationNone];
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
