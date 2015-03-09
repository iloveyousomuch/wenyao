//
//  FeedbackViewController.m
//  wenyao
//
//  Created by Meng on 14-10-2.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "FeedbackViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface FeedbackViewController ()<UITextViewDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UILabel *placeholder;


@property (weak, nonatomic) IBOutlet UILabel *limitWord;


@property (weak, nonatomic) IBOutlet UITextField *QQTextField;


@property (weak, nonatomic) IBOutlet UIButton *QQButton;

- (IBAction)QQButtonClick:(id)sender;

@end

@implementation FeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"意见反馈";
        if (iOSv7 && self.view.frame.origin.y==0) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            self.extendedLayoutIncludesOpaqueBars = NO;
            self.modalPresentationCapturesStatusBarAppearance = NO;
        }
        
        UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleBordered target:self action:@selector(rightButtonClick)];
        self.navigationItem.rightBarButtonItem = rightButton;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textView.delegate = self;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.scrollView.contentSize = CGSizeMake(APP_W, 0);
    self.scrollView.contentOffset = CGPointMake(0, 0);
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    self.scrollView.contentSize = CGSizeMake(APP_W, 0);
    self.scrollView.contentOffset = CGPointMake(0, 0);
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(!HIGH_RESOLUTION){
        self.scrollView.contentSize = CGSizeMake(APP_W, self.view.frame.size.height);
        [self.scrollView setContentOffset:CGPointMake(0, 120) animated:YES];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.scrollView.contentSize = CGSizeMake(APP_W, 0);
    self.scrollView.contentOffset = CGPointMake(0, 0);
    return YES;
}

- (void)rightButtonClick
{
    
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        return;
    }
    
    if (self.textView.text.length == 0){
        [SVProgressHUD showErrorWithStatus:@"反馈内容不能为空" duration:DURATION_SHORT];
    }else{
        if (self.textView.text.length > 300) {
            [SVProgressHUD showErrorWithStatus:@"反馈内容不能超过300字" duration:DURATION_SHORT];
            return;
        }
        if (self.QQTextField.text.length > 50) {
            [SVProgressHUD showErrorWithStatus:@"QQ号或邮箱长度不能超过50位!" duration:DURATION_SHORT];
            return;
        }
        NSMutableDictionary * setting = [NSMutableDictionary dictionary];
        setting[@"content"] = self.textView.text;
        setting[@"source"] = @"5";
        setting[@"type"] = @1;
        setting[@"contact"] = self.QQTextField.text;
        if (app.configureList[APP_USER_TOKEN]) {
            setting[@"token"] = app.configureList[APP_USER_TOKEN];
        }
        [[HTTPRequestManager sharedInstance] submitFeedback:setting completionSuc:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                [SVProgressHUD showSuccessWithStatus:@"反馈成功" duration:DURATION_SHORT];
                [self.navigationController popViewControllerAnimated:YES];
            }else if ([resultObj[@"result"] isEqualToString:@"FAIL"]){
                
            }
        } failure:^(id failMsg) {
            NSLog(@"%@",failMsg);
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        LoginViewController * login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        login.isPresentType = YES;
        login.parentNavgationController = self.navigationController;
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:login];
        [self presentViewController:nav animated:YES completion:^{
            
        }];
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length == 0) {
        self.placeholder.text = @"请提出您的宝贵意见，我们会及时进行解决~~";
    }else{
        self.placeholder.text = @"";
        CGFloat length = textView.text.length;
        int len = 300-length;
        self.limitWord.text = [NSString stringWithFormat:@"您还可以输入%d个字",len];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    NSString *temp = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (temp.length > 300) {
        textView.text = [temp substringToIndex:300];
        return NO;
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.textView resignFirstResponder];
    [self.QQTextField resignFirstResponder];
}

- (IBAction)QQButtonClick:(id)sender {
}
@end
