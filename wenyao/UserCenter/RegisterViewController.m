//
//  RegisterViewController.m
//  wenyao
//
//  Created by Meng on 14-9-30.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "RegisterViewController.h"
#import "AppDelegate.h"
#import "JGProgressHUD.h"
#import "ZhPMethod.h"
#import "SVProgressHUD.h"
#import "ServeInfoViewController.h"
#import "CheckPhoneNumberViewController.h"

@interface RegisterViewController ()
{
    JGProgressHUD * HUD;
}

@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@property (weak, nonatomic) IBOutlet UITextField *numberField;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIButton *commitButton;

- (IBAction)selectButtonClick:(id)sender;

- (IBAction)serveInformationClick:(id)sender;

- (IBAction)commitButtonClick:(id)sender;


@end

@implementation RegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"注册";
        HUD = [[JGProgressHUD alloc] init];
        HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleExtraLight];
        HUD.userInteractionEnabled = YES;
        
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectButton.selected = YES;
    self.commitButton.layer.masksToBounds = YES;
    self.commitButton.layer.cornerRadius = 3;
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
}


- (IBAction)selectButtonClick:(id)sender {
    if (self.selectButton.selected) {
        [self.selectButton setSelected:NO];
        [self.selectButton setImage:[UIImage imageNamed:@"注册_选框_未选中.png"] forState:UIControlStateNormal];
    }else{
        [self.selectButton setSelected:YES];
        [self.selectButton setImage:[UIImage imageNamed:@"注册_选框_选中.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)serveInformationClick:(id)sender{
    
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        return;
    }
    ServeInfoViewController * serverInfo = [[ServeInfoViewController alloc] init];
    serverInfo.webRequestType = WebRequestTypeServeClauses;
    [self.navigationController pushViewController:serverInfo animated:YES];
}

- (IBAction)commitButtonClick:(id)sender{
    
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        return;
    }
    
    [self.numberField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    
    if (self.numberField.text.length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号" duration:1];
    }else if ((self.numberField.text.length > 0 && self.numberField.text.length < 11)||self.numberField.text.length > 11)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号" duration:1];
    }else if (self.numberField.text.length == 11)
    {
        if (isPhoneNumber(self.numberField.text))//如果是手机号
        {
            if (self.passwordField.text.length >= 6 && self.passwordField.text.length < 16)
            {
                NSCharacterSet *nameCharacters = [[NSCharacterSet
                                                   characterSetWithCharactersInString:@"_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"] invertedSet];
                NSRange userNameRange = [self.passwordField.text rangeOfCharacterFromSet:nameCharacters];
                if (userNameRange.length >= 1) {
                    [SVProgressHUD showErrorWithStatus:@"新密码中不能包含特殊字符" duration:DURATION_SHORT];
                    return;
                }
                if (![self.selectButton isSelected]){
                    [SVProgressHUD showErrorWithStatus:@"请同意服务条款" duration:DURATION_SHORT];
                    return;
                }
                //验证手机号码是否存在
                [[HTTPRequestManager sharedInstance] registerValid:@{@"mobile":self.numberField.text} completionSuc:^(id resultObj) {
                    //***************如果手机号码不存在,那么就开始注册***************
                    if ([resultObj[@"result"] isEqualToString:@"OK"])
                    {
                        //如果手机号可以注册,则跳转到下一页
                        CheckPhoneNumberViewController * check = [[CheckPhoneNumberViewController alloc] initWithNibName:@"CheckPhoneNumberViewController" bundle:nil];
                        check.phoneNumber = self.numberField.text;
                        check.password = self.passwordField.text;
                        [self.navigationController pushViewController:check animated:YES];
                        //否则提示手机号已经被注册
                    }else if([resultObj[@"result"] isEqualToString:@"FAIL"])
                    {
                        [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:1.5];
                    }
                    //************************注册完毕**************************
                } failure:^(id failMsg) {
                    NSLog(@"%@",failMsg);
                }];
            }else if (self.passwordField.text.length == 0)
            {
                [SVProgressHUD showErrorWithStatus:@"请输入密码" duration:DURATION_SHORT];
            }else if (self.passwordField.text.length > 0 && self.passwordField.text.length < 6)
            {
                [SVProgressHUD showErrorWithStatus:@"密码至少6位" duration:DURATION_SHORT];
            }else if (self.passwordField.text.length > 16){
                [SVProgressHUD showErrorWithStatus:@"密码长度不超过16位" duration:DURATION_SHORT];
            }
        }else
        {
            [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号" duration:DURATION_SHORT];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.numberField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
