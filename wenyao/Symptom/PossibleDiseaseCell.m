//
//  PossibleDiseaseCell.m
//  quanzhi
//
//  Created by Meng on 14-8-13.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "PossibleDiseaseCell.h"

@implementation PossibleDiseaseCell

- (void)awakeFromNib
{
    self.leftImageView.layer.cornerRadius = 20;
    self.leftImageView.layer.masksToBounds = YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
