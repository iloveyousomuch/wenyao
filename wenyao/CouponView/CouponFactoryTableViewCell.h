//
//  CouponFactoryTableViewCell.h
//  wenyao
//
//  Created by 李坚 on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CouponFactoryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *factoryImage;
@property (weak, nonatomic) IBOutlet UILabel *factoryNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end
