//
//  OrderDetailViewController.m
//  wenyao
//
//  Created by Meng on 15/2/13.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "UIViewController+isNetwork.h"
#import "ReturnIndexView.h"
#import "AppDelegate.h"


@interface OrderDetailViewController ()<ReturnIndexViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *activityName;
@property (weak, nonatomic) IBOutlet UILabel *activityType;
@property (weak, nonatomic) IBOutlet UILabel *activityContent;
@property (weak, nonatomic) IBOutlet UILabel *proQuantity;
@property (weak, nonatomic) IBOutlet UILabel *unitPrice;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;
@property (weak, nonatomic) IBOutlet UILabel *buyStore;
@property (weak, nonatomic) IBOutlet UILabel *buyTime;
@property (weak, nonatomic) IBOutlet UILabel *referPhone;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (weak, nonatomic) IBOutlet UILabel *phone;

@property (strong, nonatomic) ReturnIndexView *indexView;
@property (weak, nonatomic) IBOutlet UILabel *payMoney;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet UIView *line2;
@property (weak, nonatomic) IBOutlet UIView *line3;

@end

@implementation OrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"订单详情";
    self.view.backgroundColor = [UIColor whiteColor];
      [self setUpRightItem];
    // Do any additional setup after loading the view from its nib.
    if(self.isNetWorking){
        [self addNetView];
    }else{
        [self subViewDidLoad];
    }
    
}

- (void)BtnClick{
    
    if(!self.isNetWorking){
        [[self.view viewWithTag:999] removeFromSuperview];
        [self subViewDidLoad];
    }
}

- (void)subViewDidLoad{
    
    if (self.activityDict.count > 0) {
        self.activityName.text = [self replaceSpecialStringWith:self.activityDict[@"title"]];
        self.activityContent.text = [self replaceSpecialStringWith:self.activityDict[@"desc"]];

        NSString *type = [NSString stringWithFormat:@"%@",self.activityDict[@"type"]];
        NSString *typeStr = nil;
        NSString *couponStr = nil;
        
        //优惠券类型
        if ([type isEqualToString:@"1"]) {//1:折扣券
            typeStr = @"折扣";
            self.totalPrice.text = [NSString stringWithFormat:@"%.1f元",[self.activityDict[@"pay"] floatValue]];
            couponStr = [NSString stringWithFormat:@"本订单已优惠%.1f元",[self.activityDict[@"discount"] floatValue]];
        }
        if ([type isEqualToString:@"2"]){//2:代金券
            typeStr = @"代金";
            self.totalPrice.text = [NSString stringWithFormat:@"%.1f元",[self.activityDict[@"pay"] floatValue]];
            couponStr = [NSString stringWithFormat:@"本订单已优惠%.1f元",[self.activityDict[@"discount"] floatValue]];
        }
        if ([type isEqualToString:@"3"]){//3:买赠券
            typeStr = @"买赠";
            self.payMoney.text = @"赠送商品：";
            self.totalPrice.text = [NSString stringWithFormat:@"%d件",[self.activityDict[@"totalLargess"] intValue]];
            couponStr = [NSString stringWithFormat:@"本订单已享受%d次优惠",[self.activityDict[@"useTimes"] intValue]];
        }
        
        self.activityType.text = typeStr;
        self.proQuantity.text = [NSString stringWithFormat:@"%@",self.activityDict[@"quantity"]];
        self.unitPrice.text = [NSString stringWithFormat:@"%@元",self.activityDict[@"price"]];
        
//        NSNumber *priceNumber = self.activityDict[@"price"];
//        NSNumber *quantityNumber = self.activityDict[@"quantity"];
//        
//        int price =  [priceNumber intValue];
//        int quantity = [quantityNumber intValue];
//        self.totalPrice.text = [NSString stringWithFormat:@"%d元",price * quantity];
        
        self.buyStore.text = self.activityDict[@"branch"];
        self.buyTime.text = self.activityDict[@"date"];
        
        NSString *phoneNumber = self.activityDict[@"inviter"];
        if(phoneNumber.length > 0){
            self.phone.hidden = NO;
            self.referPhone.hidden = NO;
            self.referPhone.text = self.activityDict[@"inviter"];
        }
        else{
            self.phone.hidden = YES;
            self.referPhone.hidden = YES;
            CGRect rect = self.noticeLabel.frame;
            rect.origin.y -= 21;
            self.noticeLabel.frame = rect;
        }
        
        if(couponStr){
            self.noticeLabel.hidden = NO;
            self.noticeLabel.text = couponStr;
        }
        else{
            self.noticeLabel.hidden = YES;
        }
        
    }

    CGRect rec = self.footerView.frame;
    rec.origin.y = self.noticeLabel.frame.origin.y + self.noticeLabel.frame.size.height + 15;
    self.footerView.frame = rec;
    
    CGRect rect = self.line.frame;
    rect.size.height = 0.5f;
    self.line.frame = rect;
    
    rect = self.line2.frame;
    rect.size.height = 0.5f;
    self.line2.frame = rect;
    
    rect = self.line3.frame;
    rect.size.height = 0.5f;
    self.line3.frame = rect;
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
