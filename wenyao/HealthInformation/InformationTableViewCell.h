//
//  InformationTableViewCell.h
//  quanzhi
//
//  Created by xiezhenghong on 14-6-24.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InformationTableViewCell : UITableViewCell


@property (nonatomic, strong) IBOutlet  UIImageView     *avatar;
@property (nonatomic, strong) IBOutlet  UILabel         *titleLabel;
@property (nonatomic, strong) IBOutlet  UILabel         *dateLabel;
@property (nonatomic, strong) IBOutlet  UILabel         *contentLabel;
@property (nonatomic, strong) IBOutlet  UILabel         *readedLabel;
@property (nonatomic, strong) IBOutlet  UILabel         *praiseLabel;
@property (nonatomic, strong) IBOutlet  UIImageView     *backImage;


@end
