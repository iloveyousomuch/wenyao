//
//  BaseViewController.m
//  zhihu
//
//  Created by xiezhenghong on 14-8-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "MMBaseViewController.h"
#import "Constant.h"
@interface MMBaseViewController ()

@end

@implementation MMBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"界面纯色背景.png"]]];
    self.bottomToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, 320, 44)];
    self.bottomToolBar.alpha = 0.96f;
    [self.bottomToolBar setBackgroundImage:[UIImage imageNamed:@"底部导航条.png"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.view addSubview:self.bottomToolBar];
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
