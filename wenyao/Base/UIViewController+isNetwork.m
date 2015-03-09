//
//  UIViewController+isNetwork.m
//  wenyao
//
//  Created by 李坚 on 14/12/30.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "UIViewController+isNetwork.h"
#import "Constant.h"
#import "Reachability.h"

@implementation UIViewController (isNetwork)

- (void)addNetView{
    
    UIView *noInternetView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APP_W, APP_H - NAV_H)];
    noInternetView.tag = 999;
    noInternetView.backgroundColor = UIColorFromRGB(0xecf0f1);
//    view.center = self.view.center;
    UIView *v = [[UIView alloc]init];
    v.frame = CGRectMake( (SCREEN_W - 250)/2, (SCREEN_W - 150)/2, 250, 200);
    
    v.backgroundColor = UIColorFromRGB(0xecf0f1);
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 175, 250, 20)];
    lable.textAlignment= NSTextAlignmentCenter;
    lable.font = [UIFont boldSystemFontOfSize:16.0f];
    lable.text = @"您的网络不太给力，请点击重试";
    lable.textColor = [UIColor colorWithRed:107.0f/255.0f green:121.0f/255.0f blue:132.0f/255.0f alpha:1.0];
    
    UIImageView *im = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"网络信号icon.png"]];
    im.frame = CGRectMake(50, 0, 150, 150);
    im.backgroundColor = UIColorFromRGB(0xecf0f1);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(BtnClick)];
    [v addGestureRecognizer:tap];
    
    [v addSubview:lable];
    [v addSubview:im];
    
    [noInternetView addSubview:v];
    [self.view addSubview:noInternetView];
    [self.view bringSubviewToFront:noInternetView];
}

- (void)BtnClick
{
   
}

- (BOOL)isNetWorking{
    
    BOOL isNet = NO;
    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    
    switch ([r currentReachabilityStatus]) {
            
        case NotReachable:
            isNet = YES;
            break;
            
        case ReachableViaWWAN:
            isNet = NO;
            break;
            
        case ReachableViaWiFi:
            isNet = NO;
            break;
            
        default:
            break;
    }
    
    return isNet;
}
- (void)removeNetView{
    
//    Reachability *ra = [Reachability reachabilityWithHostName:@"www.baidu.com"];
//    
//    switch ([ra currentReachabilityStatus]) {
//        case NotReachable:
//            self.isNet = YES;
//            break;
//        case ReachableViaWWAN:
//            self.isNet = NO;
//            break;
//        case ReachableViaWiFi:
//            self.isNet = NO;
//            break;
//        default:
//            break;
//    }
//    if(!self.isNet){
//        [self.noInternetView removeFromSuperview];
//        [self subViewDidLoad];
//    }
}

@end
