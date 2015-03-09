//
//  NearStoreDetail1ViewController.h
//  wenyao
//
//  Created by 李坚 on 14/12/8.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface NearStoreDetail1ViewController : BaseViewController<UIAlertViewDelegate>
@property (strong, nonatomic) UILabel *introductionLable;
@property (strong, nonatomic) IBOutlet UILabel *yingxiaoLable;

@property (strong, nonatomic) IBOutlet UIView *footView;
@property (weak, nonatomic) IBOutlet UILabel *nameLable;

@property (strong, nonatomic) UILabel *phoneLable;
@property (strong, nonatomic) UILabel *addressLable;
@property (strong, nonatomic) UIImageView *phoneImage;
@property (strong, nonatomic) UIImageView *addressImage;

@property(nonatomic, retain)NSDictionary* store;
@property(nonatomic, retain)NSMutableArray* storeList;
@property (nonatomic ,strong) NSDictionary * cityDict;
@property (nonatomic ,copy) NSString * drugStoreCode;
@property(nonatomic, retain)NSMutableDictionary* detail;

@end
