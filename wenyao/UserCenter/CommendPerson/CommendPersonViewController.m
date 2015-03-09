//
//  CommendPersonViewController.m
//  wenyao
//
//  Created by qwyf0006 on 15/2/12.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "CommendPersonViewController.h"
#import "CimmitPersonSuccessViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "LoginViewController.h"
#import "ZhPMethod.h"
#import "HTTPRequestManager.h"

@interface CommendPersonViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UILabel *commendLabel;
@property (weak, nonatomic) IBOutlet UILabel *boderLabel;

@end

@implementation CommendPersonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    [self setUpRightBarButton];
    self.phoneTextField.delegate = self;
    self.commendLabel.textColor = UIColorFromRGB(0x333333);
    self.tipsLabel.text = @"1. 请填写给您推荐问药app人员的手机号码，只可添加一次，方便我们进行统计，谢谢合作。\n2. 将问药app推荐给您身边的朋友，年终有机会拿到我们的小礼品哦！";
    self.tipsLabel.textColor = UIColorFromRGB(0x45c01a);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:13],NSParagraphStyleAttributeName:paragraphStyle};
    self.tipsLabel.attributedText = [[NSAttributedString alloc] initWithString:self.tipsLabel.text attributes:attributes];
    
    
    self.phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.boderLabel.layer.borderColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1].CGColor;
    self.boderLabel.layer.borderWidth = 0.5;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(textField == self.phoneTextField){
        
        if(![string isEqualToString:@""]){
            if(textField.text.length == 11){
                return NO;
            }
            else{
                return YES;
            }
        }
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.phoneTextField resignFirstResponder];
}

- (void)setUpRightBarButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 50, 40);
    [button setTitle:@"提交" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cimmitAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

//提交手机号码
- (void)cimmitAction
{
    if(!app.logStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
        return;
    }
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8];
        return;
    }
    
    NSString *myPhone = app.configureList[@"mobile"];
   
    [self.phoneTextField resignFirstResponder];
    
    if (self.phoneTextField.text.length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入推荐人手机号" duration:1];
        
    }else if ((self.phoneTextField.text.length > 0 && self.phoneTextField.text.length < 11)||self.phoneTextField.text.length > 11)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号" duration:1];
        
    }else if (self.phoneTextField.text.length == 11)
    {
        if (isPhoneNumber(self.phoneTextField.text))//如果是手机号
        {
            if ([self.phoneTextField.text isEqualToString:myPhone])
            {
                [SVProgressHUD showErrorWithStatus:@"输入手机号不能与登录账号一致" duration:0.8];
            }else
            {
                //提交服务器
                NSMutableDictionary *setting = [NSMutableDictionary dictionary];
                setting[@"token"] = app.configureList[APP_USER_TOKEN];
                setting[@"inviter"] = self.phoneTextField.text;
                [[HTTPRequestManager sharedInstance] QueryCimmitPersonPhoneNumber:setting completion:^(id resultObj) {
                    if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                        
                        CimmitPersonSuccessViewController *cimmitVC = [[UIStoryboard storyboardWithName:@"CommendPerson" bundle:nil] instantiateViewControllerWithIdentifier:@"CimmitPersonSuccessViewController"];
                        [self.navigationController pushViewController:cimmitVC animated:YES];
                    }else if ([resultObj[@"result"] isEqualToString:@"fail"]){
                        
                        [SVProgressHUD showErrorWithStatus:@"提交失败" duration:0.8];
                        
                    }
                } failure:^(NSError *error) {
                    [SVProgressHUD showErrorWithStatus:@"提交失败" duration:0.8];
                }];
                
            }
        }else
        {
            [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号" duration:0.8];
        }
    }
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
