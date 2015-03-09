//
//  LoginViewController.m
//  WenYao
//
//  Created by Meng on 14-9-2.
//  Copyright (c) 2014年 江苏苏州. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "SVProgressHUD.h"
#import "ZhPMethod.h"
#import "AppDelegate.h"
#import "ForgetPasswdViewController.h"
#import "XMPPManager.h"
#import "Constant.h"


@interface LoginViewController ()<RegisterViewControllerDelegate>
{

}
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *passwdField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

- (IBAction)loginClick:(id)sender;

- (IBAction)forgetPasswdClick:(id)sender;

- (IBAction)registerClick:(id)sender;
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"登录";
        
        self.passwdField.secureTextEntry = YES;
        //self.inputView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"登录_输入框_背景.png"]];
//        HUD = [[JGProgressHUD alloc] init];
//        HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleExtraLight];
//        HUD.userInteractionEnabled = YES;
        
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isPresentType) {
        UIBarButtonItem * leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleBordered target:self action:@selector(clockLoginView)];
        self.navigationItem.leftBarButtonItem = leftBarButton;
    }
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:APP_USERNAME_KEY];
    if(userName)
        self.nameField.text = userName;
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:APP_PASSWORD_KEY];
    if(password)
        self.passwdField.text = password;
    
}

- (void)clockLoginView{
    
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [MobClick event:@"denglu"];
    self.loginButton.layer.masksToBounds = YES;
    self.loginButton.layer.cornerRadius = 3;
    self.registerButton.layer.masksToBounds = YES;
    self.registerButton.layer.cornerRadius = 2;
    self.registerButton.layer.borderColor = UIColorFromRGB(0x45c01a).CGColor;
    self.registerButton.layer.borderWidth = 1;
    [self.registerButton setTitleColor:UIColorFromRGB(0x45c01a) forState:UIControlStateNormal];
    self.passwdField.secureTextEntry = YES;
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    [self customNavBarButton];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)customNavBarButton
{
    if(self.isPresentType)
    {
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_btn_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backToRoot:)];
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    }
}

- (void)backToRoot:(id)sender
{
    if (self.backBlocker) {
        self.backBlocker();
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        if(self.navigationController)
            [self.navigationController popViewControllerAnimated:YES];
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginClick:(id)sender {
    
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        return;
    }
    [self.nameField resignFirstResponder];
    [self.passwdField resignFirstResponder];
    
    if (self.nameField.text.length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号" duration:DURATION_SHORT];
        
    }else//registerValid
        if ((self.nameField.text.length > 0 && self.nameField.text.length < 11)||self.nameField.text.length > 11)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号" duration:DURATION_SHORT];
    }else
        if (self.nameField.text.length == 11)
    {
        if (isPhoneNumber(self.nameField.text))//如果是手机号
        {
            //判断完手机号后,再判断密码
            if (self.passwdField.text.length == 0)
            {
                [SVProgressHUD showErrorWithStatus:@"请输入密码" duration:DURATION_SHORT];
            }else
                if (self.passwdField.text.length > 0 && self.passwdField.text.length < 6)
            {
                [SVProgressHUD showErrorWithStatus:@"密码至少6位" duration:DURATION_SHORT];
            }else
                if (self.passwdField.text.length >= 6)
            {
                [SVProgressHUD showWithStatus:@"登录中..." maskType:SVProgressHUDMaskTypeNone];

                [self performSelectorOnMainThread:@selector(login) withObject:nil waitUntilDone:YES];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号" duration:DURATION_SHORT];
        }
    }
}

- (void)login
{
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        return;
    }
    //校验注册用户是否已存在
    self.loginButton.enabled = NO;
    
    [[HTTPRequestManager sharedInstance] registerValid:@{@"mobile":self.nameField.text} completionSuc:^(id resultObj) {
        //存在
        if ([resultObj[@"result"] isEqualToString:@"FAIL"]) {
            //账号和密码格式符合  开始登陆
            __block AppDelegate *qwDelegate = [[UIApplication sharedApplication] delegate];
            __weak LoginViewController *logvc = self;
            
            [[HTTPRequestManager sharedInstance] login:@{
                                                         @"account":self.nameField.text,
                                                         @"password":self.passwdField.text,
                                                         @"deviceCode":app.deviceToken,
//                                                         @"deviceType":@"2",
                                                         @"device":@"2"//[[UIDevice currentDevice].identifierForVendor UUIDString]
                                                         } completion:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                    NSString * str = resultObj[@"body"][@"token"];
                    if (str) {
                        [qwDelegate initDataSource:self.nameField.text];
                        [qwDelegate.configureList setObject:resultObj[@"body"][@"token"] forKey:APP_USER_TOKEN];
                        [qwDelegate.configureList setObject:resultObj[@"body"][@"passportId"] forKey:APP_PASSPORTID_KEY];
                        [qwDelegate.configureList setObject:self.nameField.text forKey:APP_USERNAME_KEY];
                        [qwDelegate.configureList setObject:self.passwdField.text forKey:APP_PASSWORD_KEY];
                        NSString *nickName = resultObj[@"body"][@"nickName"];
                        if(nickName && ![nickName isEqual:[NSNull null]]){
                            app.configureList[APP_NICKNAME_KEY] = nickName;
                        }else{
                            app.configureList[APP_NICKNAME_KEY] = @"";
                        }
                        NSString *avatarUrl = resultObj[@"body"][@"avatarUrl"];
                        if(avatarUrl && ![avatarUrl isEqual:[NSNull null]]){
                            app.configureList[APP_AVATAR_KEY] = avatarUrl;
                        }else{
                            app.configureList[APP_AVATAR_KEY] = @"";
                        }
                        qwDelegate.logStatus = YES;
                        [qwDelegate saveAppConfigure];
                        [[NSUserDefaults standardUserDefaults] setObject:self.nameField.text forKey:APP_USERNAME_KEY];
                        [[NSUserDefaults standardUserDefaults] setObject:self.passwdField.text forKey:APP_PASSWORD_KEY];
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:APP_LOGIN_STATUS];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                         [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESS object:nil];
                         XMPPJID *jid = [XMPPJID jidWithUser:resultObj[@"body"][@"passportId"] domain:OPEN_FIRE_URL resource:@"AndroidpnClient"];
                         [[[XMPPManager sharedInstance] xmppReconnect] activate:[[XMPPManager sharedInstance] xmppStream]];
                         [[[XMPPManager sharedInstance] xmppStream] setMyJID:jid];
                         [[[XMPPManager sharedInstance] xmppStream] connectWithTimeout:-1 error:nil];
//                       [logvc queryDrugGuideList];
                         if(logvc.isPresentType){
                            [logvc dismissViewControllerAnimated:YES completion:NULL];
                         }else{
                             [logvc.navigationController popViewControllerAnimated:YES];
                         }
                         if(self.loginSuccessBlock){
                             self.loginSuccessBlock();
                         }
                    }
                self.loginButton.enabled = YES;
                [SVProgressHUD dismiss];
                }else if ([resultObj[@"result"] isEqualToString:@"FAIL"]){
                        [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:DURATION_SHORT];
                        self.loginButton.enabled = YES;
                 }
                        } failure:^(NSError *error) {
                            //[SVProgressHUD showErrorWithStatus:@"手机号或密码错误" duration:DURATION_SHORT];
                            [SVProgressHUD showErrorWithStatus:@"请求超时，请重试！" duration:DURATION_SHORT];
                            self.loginButton.enabled = YES;
                        }];
        }else if ([resultObj[@"result"] isEqualToString:@"OK"]){
           [SVProgressHUD showErrorWithStatus:@"手机号未注册" duration:DURATION_SHORT];
            self.loginButton.enabled = YES;
        }
    } failure:^(id failMsg) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"请求超时，请重试！" duration:DURATION_SHORT];
        NSLog(@"&&&&&%@",failMsg);
        self.loginButton.enabled = YES;
    }];
}

- (void)queryDrugGuideList
{
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        setting[@"token"] = app.configureList[APP_USER_TOKEN];
        setting[@"status"] = @"3";
        setting[@"currPage"] = @"1";
        setting[@"pageSize"] = @"100";
        [[HTTPRequestManager sharedInstance] getDrugGuideList:setting completion:^(id resultObj) {
            if([resultObj[@"result"] isEqualToString:@"OK"]) {
                NSArray *array = resultObj[@"body"][@"data"];
                if([array count] > 0) {
                    [app.dataBase updateDiseaseSubWithArr:array];
                    if (![app.dataBase checkAllDiseaseReaded]) {
                        [app showDiseaseBudge:YES];
                    } else {
                        [app showDiseaseBudge:NO];
                    }
                    //                    [self.navigationController.tabBarItem]
                }
            }else{
                
            }
        } failure:^(NSError *error) {
            NSLog(@"error is %@",error);
        }];
    
}


- (IBAction)forgetPasswdClick:(id)sender
{
    
    ForgetPasswdViewController * change = [[ForgetPasswdViewController alloc] initWithNibName:@"ForgetPasswdViewController" bundle:nil];
    [self.navigationController pushViewController:change animated:YES];
}

- (IBAction)registerClick:(id)sender
{
    RegisterViewController * registerViewController = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    registerViewController.delegate = self;
    [self.navigationController pushViewController:registerViewController animated:YES];
}

-(void)returnRegisterNumber:(NSString *)number Password:(NSString *)password
{
    self.nameField.text = number;
    self.passwdField.text = password;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.nameField resignFirstResponder];
    [self.passwdField resignFirstResponder];
}
@end
