//
//  BoutiqueApplicationTableViewCell.m
//  quanzhi
//
//  Created by xiezhenghong on 14-9-14.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BoutiqueApplicationTableViewCell.h"

@implementation BoutiqueApplicationTableViewCell

- (void)awakeFromNib
{
    self.avatar.layer.cornerRadius = 3.0f;
    self.avatar.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
