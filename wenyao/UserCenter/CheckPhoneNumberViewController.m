//
//  CheckPhoneNumberViewController.m
//  wenyao
//
//  Created by Meng on 14-10-1.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "CheckPhoneNumberViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "XMPPManager.h"

@interface CheckPhoneNumberViewController ()
{
    NSTimer *_reGetVerifyTimer;
    int reSendControl;
}
@property (weak, nonatomic) IBOutlet UITextField *checkCodeField;

@property (weak, nonatomic) IBOutlet UIButton *checkButton;

@property (weak, nonatomic) IBOutlet UILabel *checkLabel;

@property (weak, nonatomic) IBOutlet UIButton *commitButton;


@property (nonatomic,strong)NSTimer *reGetVerifyTimer;

- (IBAction)checkButtonClick:(id)sender;

- (IBAction)registerClick:(id)sender;

@end

@implementation CheckPhoneNumberViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"验证手机号";
        
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.checkCodeField resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.reGetVerifyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(reGetVerifyCodeControl:) userInfo:nil repeats:YES];
    [self.reGetVerifyTimer setFireDate:[NSDate distantPast]];
    [[HTTPRequestManager sharedInstance] sendVerifyCode:@{@"mobile":self.phoneNumber,@"type":@"1"} completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"FAIL"]){
            
            [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:DURATION_LONG];
        }else if ([resultObj[@"result"] isEqualToString:@"OK"]){
            [SVProgressHUD showSuccessWithStatus:@"获取验证码成功" duration:DURATION_LONG];
        }
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络数据请求失败" duration:DURATION_LONG];
        NSLog(@"%@",error);
    }];
    
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    self.commitButton.layer.masksToBounds = YES;
    self.commitButton.layer.cornerRadius = 3;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)checkButtonClick:(id)sender {
    self.reGetVerifyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(reGetVerifyCodeControl:) userInfo:nil repeats:YES];
    [self.reGetVerifyTimer setFireDate:[NSDate distantPast]];
    [[HTTPRequestManager sharedInstance] sendVerifyCode:@{@"mobile":self.phoneNumber,@"type":@"1"} completion:^(id resultObj) {
        if ([resultObj[@"result"] isEqualToString:@"FAIL"]){
            
            [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:DURATION_LONG];
        }else if ([resultObj[@"result"] isEqualToString:@"OK"]){
            [SVProgressHUD showErrorWithStatus:@"获取验证码成功" duration:DURATION_LONG];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
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

- (IBAction)registerClick:(id)sender
{
    self.commitButton.enabled = NO;
    [self.checkCodeField resignFirstResponder];
    if (self.checkCodeField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入验证码" duration:DURATION_SHORT];
        return;
    }
    //如果验证码正确,那么就开始注册
    [[HTTPRequestManager sharedInstance] registUser:@{@"mobile":self.phoneNumber,@"password":self.password,@"code":self.checkCodeField.text,@"deviceType":@"2",@"device":[[UIDevice currentDevice].identifierForVendor UUIDString]} completionSuc:^(id resultObj) {
        
        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
            [SVProgressHUD showSuccessWithStatus:@"注册成功" duration:DURATION_SHORT];
            //如果注册成功,那么就开始登录
            
            __block AppDelegate *qwDelegate = [[UIApplication sharedApplication] delegate];
            [[HTTPRequestManager sharedInstance] login:@{@"account":self.phoneNumber,@"password":self.password,@"deviceCode":app.deviceToken,@"device":@"2"} completionSuc:^(id resultObj) {
                self.commitButton.enabled = YES;
                NSLog(@" 登陆 = %@",resultObj);
                NSString * str = [NSString stringWithFormat:@"%@",resultObj[@"passportId"]];
                if (str.length > 0) {
                    [qwDelegate initDataSource:self.phoneNumber];
                    [qwDelegate.configureList setObject:resultObj[@"body"][@"token"] forKey:APP_USER_TOKEN];
                    [qwDelegate.configureList setObject:resultObj[@"body"][@"passportId"] forKey:APP_PASSPORTID_KEY];
                    [qwDelegate.configureList setObject:self.phoneNumber forKey:APP_USERNAME_KEY];
                    [qwDelegate.configureList setObject:self.password forKey:APP_PASSWORD_KEY];
                    qwDelegate.logStatus = YES;
                    [qwDelegate saveAppConfigure];
                    [[NSUserDefaults standardUserDefaults] setObject:self.phoneNumber forKey:APP_USERNAME_KEY];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_SUCCESS object:nil];
                    XMPPJID *jid = [XMPPJID jidWithUser:resultObj[@"body"][@"passportId"] domain:OPEN_FIRE_URL resource:@"AndroidpnClient"];
                    [[[XMPPManager sharedInstance] xmppStream] setMyJID:jid];
                    [[[XMPPManager sharedInstance] xmppStream] connectWithTimeout:-1 error:nil];
                    [self.navigationController popToRootViewControllerAnimated:YES];

                }
            } reusltFail:^(id failMsg) {
                self.commitButton.enabled = YES;
                [SVProgressHUD showErrorWithStatus:failMsg duration:DURATION_SHORT];
            } failure:^(NSError *error) {
                self.commitButton.enabled = YES;
                NSLog(@"%@",error);
            }];
        }else if ([resultObj[@"result"] isEqualToString:@"FAIL"]){
            self.commitButton.enabled = YES;
            [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:DURATION_SHORT];
        }
    } failure:^(id failMsg) {
        self.commitButton.enabled = YES;
        NSLog(@"%@",failMsg);
    }];

}
@end
