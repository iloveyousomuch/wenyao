//
//  ScanDrugTableViewCell.h
//  quanzhi
//
//  Created by xiezhenghong on 14-6-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScanDrugTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *avatar;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *sepcLabel;
@property (nonatomic, strong) IBOutlet UILabel *factoryLabel;
@property (nonatomic, strong) IBOutlet UILabel *addLabel;

@end
