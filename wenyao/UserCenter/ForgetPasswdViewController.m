
#import "ForgetPasswdViewController.h"
#import "SVProgressHUD.h"
#import "ZhPMethod.h"
#import "AppDelegate.h"

@interface ForgetPasswdViewController ()
{
    NSTimer *_reGetVerifyTimer;
    int reSendControl;
}
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeField;
@property (weak, nonatomic) IBOutlet UITextField *passwdField;
@property (weak, nonatomic) IBOutlet UIButton *verificationCodeButton;
@property (weak, nonatomic) IBOutlet UILabel *verificationCodeLabel;


@property (nonatomic,strong)NSTimer *reGetVerifyTimer;

- (IBAction)verificationCodeButtonClick:(id)sender;
- (IBAction)commitButtonClick:(id)sender;

@end

@implementation ForgetPasswdViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"重置密码";
        if (iOSv7 && self.view.frame.origin.y==0) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = NO;
        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    reSendControl = 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    self.verificationCodeButton.layer.masksToBounds =YES;
    self.verificationCodeButton.layer.cornerRadius = 3.0f;
    self.passwdField.secureTextEntry = YES;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

/*小提示:
 ChangePasswordViewController 代表忘记密码
 
 ForgetPasswordViewController 代表修改密码
 */

//当获取验证码按钮被点击时
- (IBAction)verificationCodeButtonClick:(id)sender {
    
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        return;
    }
    
    if (self.phoneNumberField.text.length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"手机号不能为空" duration:1];
    }else if ((self.phoneNumberField.text.length > 0 && self.phoneNumberField.text.length < 11)||self.phoneNumberField.text.length > 11)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号" duration:1];
    }else if (self.phoneNumberField.text.length == 11)
    {
        if (isPhoneNumber(self.phoneNumberField.text))//如果是手机号
        {
            //校验手机号是否注册过
            [[HTTPRequestManager sharedInstance] registerValid:@{@"mobile":self.phoneNumberField.text} completionSuc:^(id resultObj) {
                //***************如果手机号码不存在,那么就开始注册检验***************
                if ([resultObj[@"result"] isEqualToString:@"FAIL"])
                {
                    self.reGetVerifyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(reGetVerifyCodeControl:) userInfo:nil repeats:YES];
                    [self.reGetVerifyTimer setFireDate:[NSDate distantPast]];
                    
                    //如果手机号可以注册,则发送验证码
                    [[HTTPRequestManager sharedInstance] sendVerifyCode:@{@"mobile":self.phoneNumberField.text,@"type":@"2"} completion:^(id resultObj) {
                        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                            [SVProgressHUD showSuccessWithStatus:@"获取验证码成功" duration:DURATION_SHORT];
                        }else if ([resultObj[@"result"] isEqualToString:@"FAIL"]){
                            [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:DURATION_SHORT];
                        }
                    } failure:^(NSError *error) {
                        NSLog(@"%@",error);
                    }];
                    
                    //否则提示手机号已经被注册
                }else if([resultObj[@"result"] isEqualToString:@"OK"])
                {
                    [SVProgressHUD showErrorWithStatus:@"手机号未注册" duration:DURATION_SHORT];
                }
            } failure:^(id failMsg) {
                NSLog(@"%@",failMsg);
            }];
        }else
        {
            [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号" duration:1];
        }
    }

    
}
//计时器执行方法
- (void)reGetVerifyCodeControl:(id)sender{
    if (reSendControl == 60) {
        self.verificationCodeButton.userInteractionEnabled = YES;
        [self.verificationCodeButton setBackgroundImage:[UIImage imageNamed:@"获取验证码_绿.png"] forState:UIControlStateNormal];
        self.verificationCodeLabel.text = @"获取验证码";
        [sender setFireDate:[NSDate distantFuture]];
        reSendControl = 0;
    }else{
        self.verificationCodeButton.userInteractionEnabled = NO;
        [self.verificationCodeButton setBackgroundImage:[UIImage imageNamed:@"获取验证码_灰.png"] forState:UIControlStateNormal];
        self.verificationCodeLabel.text = [NSString stringWithFormat:@"%d秒后重试",60-reSendControl];
        reSendControl++;
    }
}

- (IBAction)commitButtonClick:(id)sender
{
    
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        return;
    }
    
    if (self.phoneNumberField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号" duration:DURATION_SHORT];
    }else{
        if (self.verificationCodeField.text.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"请输入验证码" duration:DURATION_SHORT];
        }else{
                if (self.passwdField.text.length >= 6 && self.passwdField.text.length < 16){
                    //开始重置密码
//                   校验密码是否含有特殊字符
                    NSCharacterSet *nameCharacters = [[NSCharacterSet
                                                       characterSetWithCharactersInString:@"_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"] invertedSet];
                    NSRange userNameRange = [self.passwdField.text rangeOfCharacterFromSet:nameCharacters];
                    if (userNameRange.length == 1) {
                        [SVProgressHUD showErrorWithStatus:@"请设置新密码，6~16位数字或字母" duration:DURATION_SHORT];
                        return;
                    }else{
                    [[HTTPRequestManager sharedInstance] resetPassword:@{@"mobile":self.phoneNumberField.text,@"code":self.verificationCodeField.text,@"newPwd":self.passwdField.text} completionSuc:^(id resultObj) {
                        if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                            [SVProgressHUD showSuccessWithStatus:@"密码修改成功" duration:DURATION_SHORT];
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        }else if ([resultObj[@"result"] isEqualToString:@"FAIL"]){
                            [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:DURATION_SHORT];
                        }
                    } failure:^(id failMsg) {
                        NSLog(@"%@",failMsg);
                    }];
                    }
                }else if (self.passwdField.text.length == 0)
                {
                    [SVProgressHUD showErrorWithStatus:@"请输入新密码" duration:DURATION_SHORT];
                }else if (self.passwdField.text.length > 0 && self.passwdField.text.length < 6)
                {
                    [SVProgressHUD showErrorWithStatus:@"密码长度应大于六位" duration:DURATION_SHORT];
                }else if (self.passwdField.text.length > 16){
                    [SVProgressHUD showErrorWithStatus:@"密码长度应小于十六位" duration:DURATION_SHORT];
                }
        }
    }
    
    
    
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.phoneNumberField resignFirstResponder];
    [self.verificationCodeField resignFirstResponder];
    [self.passwdField resignFirstResponder];
}
@end
