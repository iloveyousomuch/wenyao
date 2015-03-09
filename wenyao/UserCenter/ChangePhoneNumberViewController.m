//
//  ChangePhoneNumberViewController.m
//  wenyao
//
//  Created by Meng on 14-9-30.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "ChangePhoneNumberViewController.h"
#import "SVProgressHUD.h"
#import "ZhPMethod.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "ReturnIndexView.h"

@interface ChangePhoneNumberViewController ()<UIAlertViewDelegate,ReturnIndexViewDelegate>
{
    NSTimer *_reGetVerifyTimer;
    int reSendControl;
}
@property (nonatomic,strong)NSTimer *reGetVerifyTimer;
@property (weak, nonatomic) IBOutlet UITextField *numberField;
@property (strong, nonatomic) ReturnIndexView *indexView;
@property (weak, nonatomic) IBOutlet UITextField *checkField;

- (IBAction)getCheckCodeClick:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *checkLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;

- (IBAction)commitButtonClick:(id)sender;





@end

@implementation ChangePhoneNumberViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"修改手机号";
        if (iOSv7 && self.view.frame.origin.y==0) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = NO;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpRightItem];
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getCheckCodeClick:(id)sender {
    
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
            [self performSelectorOnMainThread:@selector(registerUser) withObject:nil waitUntilDone:YES];
        }else
        {
            [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号" duration:1];
        }
    }
}

- (void)registerUser
{
    //校验手机号是否注册过
    [[HTTPRequestManager sharedInstance] registerValid:@{@"mobile":self.numberField.text} completionSuc:^(id resultObj) {
        //***************如果手机号码不存在,那么就开始注册检验***************
        if ([resultObj[@"result"] isEqualToString:@"OK"])
        {
            self.reGetVerifyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(reGetVerifyCodeControl:) userInfo:nil repeats:YES];
            [self.reGetVerifyTimer setFireDate:[NSDate distantPast]];

            //如果手机号可以注册,则发送验证码
            [[HTTPRequestManager sharedInstance] sendVerifyCode:@{@"mobile":self.numberField.text,@"type":@"3"} completion:^(id resultObj) {
                NSLog(@"发送验证码 = %@",resultObj);
                if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                    [SVProgressHUD showSuccessWithStatus:@"获取验证码成功" duration:DURATION_SHORT];
                }else if ([resultObj[@"result"] isEqualToString:@"FAIL"]){
                    [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:DURATION_SHORT];
                }
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
            }];
            
            //否则提示手机号已经被注册
        }else if([resultObj[@"result"] isEqualToString:@"FAIL"])
        {
            [SVProgressHUD showErrorWithStatus:@"手机号已经被注册" duration:DURATION_SHORT];
        }
    } failure:^(id failMsg) {
        NSLog(@"%@",failMsg);
    }];
}

//计时器执行方法
- (void)reGetVerifyCodeControl:(id)sender{
    if (reSendControl == 60) {
        self.checkButton.userInteractionEnabled = YES;
        self.checkLabel.text = @"获取验证码";
        [self.checkButton setBackgroundImage:[UIImage imageNamed:@"获取验证码_绿.png"] forState:UIControlStateNormal];
        [sender setFireDate:[NSDate distantFuture]];
        reSendControl = 0;
    }else{
        self.checkButton.userInteractionEnabled = NO;
        [self.checkButton setBackgroundImage:[UIImage imageNamed:@"获取验证码_灰.png"] forState:UIControlStateNormal];
        self.checkLabel.text = [NSString stringWithFormat:@"%d秒后重试",60-reSendControl];
        reSendControl++;
    }
}
- (IBAction)commitButtonClick:(id)sender {
    
    if (self.numberField.text.length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号" duration:1];
        return;
    }else if ((self.numberField.text.length > 0 && self.numberField.text.length < 11)||self.numberField.text.length > 11)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号" duration:1];
        return;
    }
    
    if (!isPhoneNumber(self.numberField.text))//如果不是手机号
    {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号" duration:DURATION_SHORT];
        return;
    }
    
    if (self.checkField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入验证码" duration:DURATION_SHORT];
        return;
    }
    
    [self updateInfomation];
    
}

- (void)updateInfomation
{
    __block AppDelegate *qwDelegate = [[UIApplication sharedApplication] delegate];
    NSLog(@"登录请求参数 = %@",@{@"token":qwDelegate.configureList[APP_USER_TOKEN],@"newMobile":self.numberField.text,@"code":self.checkField.text,@"type":@"3"});
    [[HTTPRequestManager sharedInstance] changeMobile:@{@"token":qwDelegate.configureList[APP_USER_TOKEN],@"newMobile":self.numberField.text,@"code":self.checkField.text,@"type":@"3"} completionSuc:^(id resultObj) {
        NSLog(@"提交 = %@",resultObj);
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            [SVProgressHUD showSuccessWithStatus:@"手机号修改成功" duration:DURATION_SHORT];
            [app clearAccountInformation];
            [self.navigationController popToRootViewControllerAnimated:YES];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:APP_USERNAME_KEY];
            [userDefaults removeObjectForKey:APP_PASSWORD_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:APP_LOGIN_STATUS];
            [userDefaults synchronize];
            LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            UINavigationController *navgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
            loginViewController.isPresentType = YES;
            [app.tabBarController presentViewController:navgationController animated:YES completion:NULL];
            
        }else if ([resultObj[@"result"] isEqualToString:@"FAIL"]){
            if ([resultObj[@"msg"] isEqualToString:@"1"]) {
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:ALERT_MESSAGE delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        LoginViewController * login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        login.isPresentType = YES;
        login.parentNavgationController = self.navigationController;
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:login];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.numberField resignFirstResponder];
    [self.checkField resignFirstResponder];
}

@end
