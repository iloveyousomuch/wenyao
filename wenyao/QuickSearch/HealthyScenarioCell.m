//
//  HealthyScenarioCell.m
//  wenyao
//
//  Created by Meng on 14/10/28.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "HealthyScenarioCell.h"

@implementation HealthyScenarioCell

- (void)awakeFromNib {
    self.cellImageView.layer.masksToBounds = YES;
    self.cellImageView.layer.cornerRadius = 15;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
