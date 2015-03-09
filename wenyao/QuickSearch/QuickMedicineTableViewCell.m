//
//  QuickMedicineTableViewCell.m
//  wenyao
//
//  Created by Meng on 14-9-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "QuickMedicineTableViewCell.h"

@implementation QuickMedicineTableViewCell

- (void)awakeFromNib
{
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.cornerRadius = 10;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
