//
//  UserCenterViewCell.m
//  wenyao
//
//  Created by Meng on 15/1/27.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "UserCenterViewCell.h"
#import "UIView+Extension.h"
@implementation UserCenterViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.imageView convertIntoCircular];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
