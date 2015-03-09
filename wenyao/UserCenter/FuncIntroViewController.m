//
//  FuncIntroViewController.m
//  wenyao
//
//  Created by qw on 14-11-28.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "FuncIntroViewController.h"

@interface FuncIntroViewController ()

@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewContent;

@end

@implementation FuncIntroViewController

- (void)setUpScrollViewContent
{
    NSLayoutConstraint *constraintImgTop = nil;
    NSLayoutConstraint *constraintImgBottom = nil;
    NSLayoutConstraint *constraintImgLeading = nil;
    NSLayoutConstraint *constraintImgTrailing = nil;
    NSLayoutConstraint *constraintImgWidth = nil;
    NSLayoutConstraint *constraintImgHeight = nil;
    UIImageView *previousImgView = nil;
    for (int i = 0; i < 3; i++) {
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.translatesAutoresizingMaskIntoConstraints = NO;
        if (i == 0) {
            imgView.image = [UIImage imageNamed:@"FuncIntro1"];
        } else if (i == 1) {
            imgView.image = [UIImage imageNamed:@"FuncIntro2"];
        } else if (i == 2) {
            imgView.image = [UIImage imageNamed:@"FuncIntro3"];
        }
        constraintImgWidth = [NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.scrollViewContent attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
        constraintImgHeight = [NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.scrollViewContent attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        if (!previousImgView) {
            constraintImgTop = [NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.scrollViewContent attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        } else {
            constraintImgTop = [NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:previousImgView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
        }

        constraintImgBottom = [NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.scrollViewContent attribute:NSLayoutAttributeBottom multiplier:(1.0*(i+1)) constant:0.0];
        constraintImgLeading = [NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.scrollViewContent attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0];
        constraintImgTrailing = [NSLayoutConstraint constraintWithItem:imgView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.scrollViewContent attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0];
        [self.scrollViewContent addSubview:imgView];
        [self.scrollViewContent addConstraints:@[constraintImgTop, constraintImgWidth, constraintImgLeading, constraintImgHeight]];
        previousImgView = imgView;
    }
    [self.scrollViewContent addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollViewContent attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:previousImgView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollViewContent.translatesAutoresizingMaskIntoConstraints = NO;
    [self setUpScrollViewContent];
    self.navigationItem.title = @"功能介绍";
    // Do any additional setup after loading the view from its nib.
}

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
