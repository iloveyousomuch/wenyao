//
//  RegularTableViewCell.h
//  quanzhi
//
//  Created by xiezhenghong on 14-6-26.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegularTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet  UIImageView     *backImg;
@property (nonatomic, strong) IBOutlet  UIImageView     *avatarImg;
@property (nonatomic, strong) IBOutlet  UILabel         *titleLabel;
@property (nonatomic, strong) IBOutlet  UILabel         *descLabel;

@end
