//
//  MarkPharmacyViewController.m
//  wenyao
//
//  Created by xiezhenghong on 14-10-14.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "MarkPharmacyViewController.h"
#import "HTTPRequestManager.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

@interface MarkPharmacyViewController ()<UITextViewDelegate>

@end

@implementation MarkPharmacyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *submitBarButton = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(submitAction:)];
    self.navigationItem.rightBarButtonItem = submitBarButton;
    self.title = @"评价药房";
    [self.ratingView setImagesDeselected:@"star_none_big.png" partlySelected:@"star_half_big.png" fullSelected:@"star_full_big.png" andDelegate:nil];
    [self.ratingView displayRating:0.0];
    self.textView.delegate = self;
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(255, 196, 60, 15)];
    self.countLabel.textColor = [UIColor lightGrayColor];
    self.countLabel.font = [UIFont systemFontOfSize:13.5f];
    self.countLabel.text = @"0/100";
    [self.view addSubview:self.countLabel];
    
    self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 66, 120, 15)];
    self.hintLabel.textColor = [UIColor lightGrayColor];
    self.hintLabel.font = [UIFont systemFontOfSize:13.5f];
    self.hintLabel.text = @"您的评价很重要哦~";
    [self.view addSubview:self.hintLabel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.textView resignFirstResponder];
}

- (void)submitAction:(id)sener
{
    if(self.ratingView.rating == 0.0) {
        [SVProgressHUD showErrorWithStatus:@"提交失败" duration:0.0f];
        return;
    }
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    if(self.infoDict[@"groupId"]){
        setting[@"groupId"] = self.infoDict[@"groupId"];
    }else if(self.infoDict[@"id"]){
        setting[@"groupId"] = self.infoDict[@"id"];
    }else{
        [SVProgressHUD showErrorWithStatus:@"该药店数据不全,无法进行评价!" duration:0.8f];
        return;
    }
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"star"] = [NSNumber numberWithInt:(MIN(5.0,self.ratingView.rating) * 2)];
    setting[@"remark"] = self.textView.text;
    if(self.UUID)
        setting[@"imId"] = self.UUID;
    [[HTTPRequestManager sharedInstance] addAppraise:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]) {
            [SVProgressHUD showSuccessWithStatus:@"评价成功!" duration:0.8];
            if(self.InsertNewEvaluate)
            {
                NSUInteger star = (NSUInteger)([setting[@"star"] integerValue]);
                
                NSDictionary *dict = @{@"remark":self.textView.text,
                                       @"rating":[NSNumber numberWithFloat:star / 2.0]};
                self.InsertNewEvaluate(dict);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [SVProgressHUD showErrorWithStatus:@"评价失败!" duration:0.8];
        }
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"评价失败!" duration:0.8];
    }];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if(textView.text.length >= 100)
    {
        textView.text = [textView.text substringToIndex:100];
    }
    self.countLabel.text = [NSString stringWithFormat:@"%d/100",textView.text.length];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(textView.text.length <= 1 && [text isEqualToString:@""]){
        self.hintLabel.hidden = NO;
    }else{
        self.hintLabel.hidden = YES;
    }
    
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
