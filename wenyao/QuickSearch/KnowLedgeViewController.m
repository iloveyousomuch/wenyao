//
//  KnowLedgeViewController.m
//  wenyao
//
//  Created by Meng on 14-9-29.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "KnowLedgeViewController.h"
#import "ZhPMethod.h"

@interface KnowLedgeViewController ()

@end

@implementation KnowLedgeViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
       self.title = @"用药小知识";
    [self initView];
}

- (void)initView{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, APP_W, APP_H)];
    scrollView.backgroundColor = [UIColor whiteColor];

    NSString * title = [self replaceSpecialStringWith:self.knowledgeTitle];
    CGSize titleSize = getTextSize(title, Font(15), APP_W-20);
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 19, APP_W, titleSize.height)];
    titleLabel.font = Font(18);
    titleLabel.textColor = UIColorFromRGB(0x333333);
    titleLabel.text = title;
    [scrollView addSubview:titleLabel];
    
    UIView * line1 = [[UIView alloc] initWithFrame:CGRectMake(10, titleLabel.frame.origin.y + titleLabel.frame.size.height + 8, APP_W-20, 0.5)];
    line1.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [scrollView addSubview:line1];
    
    NSString * content = [self replaceSpecialStringWith:self.knowledgeContent];
    CGSize size = getTextSize(content,  Font(14), APP_W-20);
    UILabel * contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, line1.frame.origin.y + line1.frame.size.height + 8, APP_W-20, size.height + 10)];
    contentLabel.textColor = UIColorFromRGB(0x666666);
    contentLabel.numberOfLines = 0;
    contentLabel.font = Font(14);
    contentLabel.text = content;
    [scrollView addSubview:contentLabel];
    
//    UIView * line2 = [[UIView alloc] initWithFrame:CGRectMake(10, contentLabel.frame.origin.y + contentLabel.frame.size.height + 8, APP_W-20, 0.5)];
//    line2.backgroundColor = [UIColor grayColor];
//    [scrollView addSubview:line2];
    
    
    [self.view addSubview:scrollView];
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
