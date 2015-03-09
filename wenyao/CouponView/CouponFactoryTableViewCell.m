//
//  CouponFactoryTableViewCell.m
//  wenyao
//
//  Created by 李坚 on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "CouponFactoryTableViewCell.h"

@implementation CouponFactoryTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.factoryImage.layer.masksToBounds = YES;
    self.factoryImage.layer.cornerRadius = 23.5f;
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
