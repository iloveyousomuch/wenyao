//
//  introductionViewController.m
//  wenyao
//
//  Created by 李坚 on 15/2/10.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "introductionViewController.h"
#import "ReturnIndexView.h"
#import "AppDelegate.h"

@interface introductionViewController ()<ReturnIndexViewDelegate>
{
    UIScrollView *m_scrollView;
}
@property (strong, nonatomic) ReturnIndexView *indexView;
@end

@implementation introductionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"功能介绍";

    UIImage *m_image = [[UIImage alloc]init];
    
    m_image = [UIImage imageNamed:@"功能介绍.jpg"];
    
    m_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H - 64)];
    UIImageView *m_imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, m_image.size.height)];
    m_imageView.backgroundColor = UIColorFromRGB(0xf5f5f5);
    
    m_imageView.image = m_image;
    m_scrollView.contentSize = CGSizeMake(m_image.size.width, m_image.size.height);
    [m_scrollView addSubview:m_imageView];
    self.view.backgroundColor = UIColorFromRGB(0xf5f5f5);
    [self.view addSubview:m_scrollView];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
