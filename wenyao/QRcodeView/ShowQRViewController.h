//
//  ShowQRViewController.h
//  wenyao
//
//  Created by carret on 15/1/22.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"

@interface ShowQRViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIImageView *QRView;
@property (weak, nonatomic) IBOutlet UILabel *showCount;
@property (nonatomic ,copy)NSString * QRstring;
@property (nonatomic ,assign)NSInteger  views;
@property (nonatomic ,copy)NSString *QRcode;

@property (weak, nonatomic) IBOutlet UILabel *recommderPhoneNumberLabel;

@property NSInteger useType;

@property (nonatomic, copy) NSString *phoneNumber;

@end
