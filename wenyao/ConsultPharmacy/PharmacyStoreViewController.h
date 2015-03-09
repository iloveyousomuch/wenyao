//
//  PharmacyStoreViewController.h
//  wenyao
//
//  Created by xiezhenghong on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "RatingView.h"

@interface PharmacyStoreViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *phoneImage;
@property (weak, nonatomic) IBOutlet UIImageView *addressImage;
@property (nonatomic, strong) UITableView  *tableView;
@property (nonatomic, strong) IBOutlet UIView       *headerView;
@property (nonatomic, strong) IBOutlet UIImageView  *verifyLogo;
@property (nonatomic, strong) IBOutlet UILabel      *pharmacyName;
@property (nonatomic, strong) IBOutlet UILabel      *consultCount;
@property (nonatomic, strong) IBOutlet UIButton     *consultButton;

@property (nonatomic, strong) IBOutlet RatingView   *ratingView;

@property (nonatomic, strong) IBOutlet UILabel      *location;
@property (nonatomic, strong) IBOutlet UILabel      *contactPhone;
@property (nonatomic, strong) NSMutableDictionary   *infoDict;

@property (nonatomic, strong) IBOutlet UIImageView *key1Image;
@property (nonatomic, strong) IBOutlet UILabel     *key1Label;
@property (nonatomic, strong) IBOutlet UIImageView *key2Image;
@property (nonatomic, strong) IBOutlet UILabel     *key2Label;
@property (nonatomic, strong) IBOutlet UIImageView *key3Image;
@property (nonatomic, strong) IBOutlet UILabel     *key3Label;

@property (nonatomic, strong) IBOutlet UIImageView *key4Image;
@property (nonatomic, strong) IBOutlet UILabel     *key4Label;
//0是列表进入    1是通过id获取
@property (nonatomic, assign) NSUInteger              useType;
- (IBAction)pushIntoFreeConsult:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *greenBtn;
@property (weak, nonatomic) IBOutlet UIView *redBtn;
@property (strong, nonatomic) IBOutlet UIView *footView;
@property (weak, nonatomic) IBOutlet UILabel *greenBtnLabel;
@property (weak, nonatomic) IBOutlet UIImageView *greenImage;

@property (nonatomic ,strong) NSMutableArray *detail;

@end
