//
//  CouponDeatilViewController.h
//  wenyao
//
//  Created by 李坚 on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"

@interface CouponDeatilViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *line101;
@property (weak, nonatomic) IBOutlet UILabel *line102;
@property (weak, nonatomic) IBOutlet UIButton *pushBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line101Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footLineHeiht;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line102Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lin103Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line104Height;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line105Height;

@property (weak, nonatomic) IBOutlet UILabel *startTime;
@property (weak, nonatomic) IBOutlet UILabel *endTime;
@property (weak, nonatomic) IBOutlet UILabel *tickets;
@property (weak, nonatomic) IBOutlet UILabel *consulteLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineHeight;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIView *pushGenerateView;

@property (weak, nonatomic) IBOutlet UILabel *couponTimes;
@property (weak, nonatomic) IBOutlet UILabel *couponTimesLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftChanges;
@property (weak, nonatomic) IBOutlet UIView *sectionView;
- (IBAction)pushToGenerateView:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downSpace;

@property (nonatomic, strong) NSMutableDictionary *infoDic;
@property (nonatomic) NSString *promotionId;
@end
