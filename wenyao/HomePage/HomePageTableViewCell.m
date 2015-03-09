//
//  HomePageTableViewCell.m
//  wenyao
//
//  Created by Pan@QW on 14-9-25.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "HomePageTableViewCell.h"
#import "UIView+Extension.h"


@implementation HomePageTableViewCell

- (void)awakeFromNib
{
    [self.avatarImage convertIntoCircular];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize size = [self.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(156, 21)];
    CGRect rect = self.titleLabel.frame;
    rect.size = size;
    rect.size.width += 1.0f;
    self.titleLabel.frame = rect;
    rect = self.nameIcon.frame;
    rect.origin.x = self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width + 11;
    rect.size = self.nameIcon.image.size;
    self.nameIcon.frame = rect;
}

@end
