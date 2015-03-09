//
//  SmallTableViewCell.m
//  wenyao
//
//  Created by garfield on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "SmallTableViewCell.h"
#import "UIView+Extension.h"
@implementation SmallTableViewCell

- (void)awakeFromNib
{
    [self.avatarImage convertIntoCircular];
    self.contentView.transform = CGAffineTransformMakeRotation(M_PI / 2);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
