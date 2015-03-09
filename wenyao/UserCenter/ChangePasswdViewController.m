
#import "ChangePasswdViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "ReturnIndexView.h"

@interface ChangePasswdViewController ()<UIAlertViewDelegate,ReturnIndexViewDelegate>

@property (strong , nonatomic) ReturnIndexView *indexView;
@property (weak, nonatomic) IBOutlet UITextField *oldField;

@property (weak, nonatomic) IBOutlet UITextField *firstPassordField;

//@property (weak, nonatomic) IBOutlet UITextField *secondPassordField;

@property (weak, nonatomic) IBOutlet UIButton *commitButton;

- (IBAction)commitButtonClick:(id)sender;

@end

@implementation ChangePasswdViewController

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.oldField resignFirstResponder];
    [self.firstPassordField resignFirstResponder];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"修改密码";
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
    self.oldField.secureTextEntry = YES;
    self.firstPassordField.secureTextEntry = YES;
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

- (IBAction)commitButtonClick:(id)sender {
    
    if (self.oldField.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入当前密码" duration:DURATION_SHORT];
    }else{
        if (self.firstPassordField.text.length >= 6 && self.firstPassordField.text.length < 16)
        {
           //===================================================================
            if(app.currentNetWork == NotReachable)
            {
                [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
                return;
            }
            //请求服务器
            NSCharacterSet *nameCharacters = [[NSCharacterSet
                                               characterSetWithCharactersInString:@"_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"] invertedSet];
            NSRange userNameRange = [self.firstPassordField.text rangeOfCharacterFromSet:nameCharacters];
            if (userNameRange.length == 1) {
                [SVProgressHUD showErrorWithStatus:@"请输入新密码" duration:DURATION_SHORT];
                return;
            }else{
            
            [[HTTPRequestManager sharedInstance] updatePassword:@{@"token":app.configureList[@"token"],@"newPwd":self.firstPassordField.text,@"oldPwd":self.oldField.text} completionSuc:^(id resultObj) {
                NSLog(@"修改密码 = %@",resultObj);
                if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                    [SVProgressHUD showSuccessWithStatus:@"修改成功" duration:DURATION_SHORT];
                    [self.navigationController popToRootViewControllerAnimated:YES];
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
          //===================================================================
        }else if (self.firstPassordField.text.length == 0)
        {
            [SVProgressHUD showErrorWithStatus:@"请输入新密码" duration:DURATION_SHORT];
        }else if (self.firstPassordField.text.length > 0 && self.firstPassordField.text.length < 6)
        {
            [SVProgressHUD showErrorWithStatus:@"密码长度应大于六位" duration:DURATION_SHORT];
        }else if (self.firstPassordField.text.length > 16){
            [SVProgressHUD showErrorWithStatus:@"密码长度应小于十六位" duration:DURATION_SHORT];
        }

    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 999) {
        if (buttonIndex == 0) {
            LoginViewController * login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            login.isPresentType = YES;
            login.parentNavgationController = self.navigationController;
            UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:login];
            [self presentViewController:nav animated:YES completion:nil];
        }
    }else if (buttonIndex == 1) {
        LoginViewController * login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        login.isPresentType = YES;
        login.parentNavgationController = self.navigationController;
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:login];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

@end
