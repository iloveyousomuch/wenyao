//
//  ScanFailViewController.m
//  quanzhi
//
//  Created by Meng on 14-9-9.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "ScanFailViewController.h"
#import "Constant.h"
@interface ScanFailViewController ()

@end

@implementation ScanFailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];//239
    self.title = @"药品搜索";
    [self.view setBackgroundColor:COLOR(239, 239, 239)];
    
    [self setupBackBarButtonItem];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, 320, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"条码没有匹配的药品";
    [self.view addSubview:label];

}

- (void)setupBackBarButtonItem
{
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_btn_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backToPreviousController:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (void)backToPreviousController:(id)sender
{
    NSUInteger count = self.navigationController.viewControllers.count - 1;
    UIViewController *viewController = self.navigationController.viewControllers[count - 2];
    [self.navigationController popToViewController:viewController animated:YES];
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
