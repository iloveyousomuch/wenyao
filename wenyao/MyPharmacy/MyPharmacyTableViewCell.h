//
//  MyPharmacyTableViewCell.h
//  wenyao
//
//  Created by Pan@QW on 14-9-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
@interface MyPharmacyTableViewCell : MGSwipeTableCell

@property (nonatomic, strong) IBOutlet  UIImageView     *avatar;
@property (nonatomic, strong) IBOutlet  UIImageView     *uncompleteImage;
@property (nonatomic, strong) IBOutlet  UILabel         *medicineName;
@property (nonatomic, strong) IBOutlet  UILabel         *medicineUsage;
@property (nonatomic, strong) IBOutlet  UILabel         *dateLabel;
@property (nonatomic, strong) IBOutlet  UIButton        *alarmClockImage;

@end
