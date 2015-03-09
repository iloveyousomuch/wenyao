//
//  ActivityDetailTableViewCell.h
//  wenyao
//
//  Created by xiezhenghong on 14-10-15.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityDetailTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel        *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel        *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel        *contentLabel;

@end
