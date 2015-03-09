//
//  ShowQRViewController.m
//  wenyao
//
//  Created by carret on 15/1/22.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//
#import "AppDelegate.h"
#import "ShowQRViewController.h"
#import "QRCodeGenerator+ex.h"
#import "HTTPRequestManager.h"
#import "LoginViewController.h"
#import "NewHomePageViewController.h"
#import "CouponDeatilViewController.h"
#import "DrugDetailViewController.h"
#import "ReturnIndexView.h"

@interface ShowQRViewController ()<ReturnIndexViewDelegate>
{
    NSInteger countAlert;
}
@property (nonatomic, copy)   dispatch_source_t     messageTimer;
@property (nonatomic ,strong)UIAlertView *showMessage;
@property (strong, nonatomic) ReturnIndexView *indexView;
@end

@implementation ShowQRViewController
@synthesize messageTimer,showMessage;
- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self checkViews:self.views];
   
    self.title = @"二维码";
    

    
    if(!self.phoneNumber){
        
        self.recommderPhoneNumberLabel.hidden = YES;
    }
    else{
        self.recommderPhoneNumberLabel.hidden = NO;
        self.recommderPhoneNumberLabel.text = [NSString stringWithFormat:@"推荐人手机号：%@",self.phoneNumber];
    }
    
    
    countAlert = 0;
    
    showMessage = [[UIAlertView alloc]initWithTitle:@"提示" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] ;
    
    UIImage *imgs=[UIImage imageNamed:@"QRicon.png"];
    
    
    
    self.QRView.image = [QRCodeGenerator qrImageForString:self.QRstring imageSize:self.QRView.bounds.size.width Topimg:imgs];
    
    messageTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    
    dispatch_source_set_timer(messageTimer, dispatch_time(DISPATCH_TIME_NOW, 3ull*NSEC_PER_SEC), 3ull*NSEC_PER_SEC , DISPATCH_TIME_FOREVER);
    
    dispatch_source_set_event_handler(messageTimer, ^{
        [self check];
    });
    
    dispatch_source_set_cancel_handler(messageTimer, ^{
        
    });
    
    dispatch_resume(messageTimer);
    
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
-(void )checkViews:(NSInteger)viewsCount
{
    if ( _views < 0 ) {
        _showCount.hidden = YES;
    }else
    {
        _showCount.text = [NSString stringWithFormat:@"您可享受%ld次优惠",(long)(viewsCount?viewsCount:0)];
        _showCount.hidden = NO;
    }
}
-(void)check
{
    [[HTTPRequestManager sharedInstance] CheckCouponDetail:@{@"token":app.configureList[APP_USER_TOKEN],@"code":self.QRcode}  completionSuc:^(id resultObj) {
    
        if ( [resultObj[@"result"] isEqualToString:@"OK"]) {
               if(resultObj[@"body"] && [resultObj[@"body"][@"status"] intValue] == 1){
        
            if (countAlert == 0) {
            
//                [self checkViews: [resultObj[@"body"][@"views"] intValue]];
                countAlert ++;
                dispatch_source_cancel(messageTimer);
                
                showMessage.message = @"您已享受该优惠";
                //            showMessage.message = resultObj[@"msg"];
                
                [showMessage show];
                
            }
               }
            
        }
       
    } failure:^(id failMsg) {
        
    }];

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    if ([alertView.message isEqualToString:@"请求失败"]||[alertView.message isEqualToString:@"失败"]) {
//        
////        countAlert =0;
//    }else
//    {
//          dispatch_source_cancel(messageTimer);
//    }
    [[HTTPRequestManager sharedInstance] cancelAllHTTPRequest];
    
    switch (self.useType) {
        //为1则返回优惠详情
        case 1:
            for (UIViewController *temp in self.navigationController.viewControllers) {
                
                if ([temp isKindOfClass:[CouponDeatilViewController class]]) {
                    [self.navigationController popToViewController:temp animated:YES];
                    return;
                }
                
            }

            break;
        //为3则返回药品详情
        case 3:
            for (UIViewController *temp in self.navigationController.viewControllers) {
                
                if ([temp isKindOfClass:[DrugDetailViewController class]]) {
                    [self.navigationController popToViewController:temp animated:YES];
                    return;
                }
            }
            break;
        
        //否则返回首页
        default:
            for (UIViewController *temp in self.navigationController.viewControllers) {
                
                if ([temp isKindOfClass:[NewHomePageViewController class]]) {
                    [self.navigationController popToViewController:temp animated:YES];
                    return;
                }
            }
            break;
    }
    

}
- (void)backToPreviousController:(id)sender
{
    if (messageTimer) {
        dispatch_source_cancel(messageTimer);
    }
    
    
   [self.navigationController popViewControllerAnimated:YES];
    
}
+ (UIColor *)colorFromHexRGB:(NSString *)inColorString
{
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode); // masks off high bits
    result = [UIColor
              colorWithRed: (float)redByte / 0xff
              green: (float)greenByte/ 0xff
              blue: (float)blueByte / 0xff
              alpha:1.0];
    return result;
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
