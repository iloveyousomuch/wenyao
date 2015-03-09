//
//  ActivityTableViewCell.h
//  wenyao
//
//  Created by xiezhenghong on 14-9-18.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet  UILabel     *titleLabel;
@property (nonatomic, strong) IBOutlet  UILabel     *contentLabel;
@property (nonatomic, strong) IBOutlet  UILabel     *timeStampLabel;

@end
