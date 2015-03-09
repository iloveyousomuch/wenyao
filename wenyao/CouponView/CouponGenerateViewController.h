//
//  CouponGenerateViewController.h
//  wenyao
//
//  Created by 李坚 on 15/1/21.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"

@interface CouponGenerateViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIView *bkView;
@property (weak, nonatomic) IBOutlet UILabel *line;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;

@property (strong, nonatomic) IBOutlet UIScrollView *couponScrollView;

@property (strong, nonatomic) UIButton *btn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *styleLabel;
@property (weak, nonatomic) IBOutlet UILabel *factoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
- (IBAction)addCount:(id)sender;
- (IBAction)reduceCount:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *countTextField;
@property (weak, nonatomic) IBOutlet UITextField *priceTextField;

@property (weak, nonatomic) IBOutlet UIButton *generateBtn;
@property (weak, nonatomic) IBOutlet UILabel *sorryLabel;

@property (weak, nonatomic) IBOutlet UIView *noneView;

@property (weak, nonatomic) IBOutlet UIView *footView;
@property (weak, nonatomic) IBOutlet UILabel *couponTimes;
@property (weak, nonatomic) IBOutlet UIView *sorryView;

@property (weak, nonatomic) IBOutlet UILabel *couponTim;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;

@property (weak, nonatomic) IBOutlet UILabel *colorLabel;

@property (nonatomic ,strong) NSMutableDictionary *infoDic;//活动详情
@property (nonatomic ,copy) NSString *proId;//商品编码

@property (nonatomic) NSInteger type;
@property (nonatomic, copy) NSString *sorryText;

@property (nonatomic) NSInteger useType;

@end
