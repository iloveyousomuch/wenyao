//
//  PharmacyCommentTableViewCell.m
//  wenyao
//
//  Created by xiezhenghong on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "PharmacyCommentTableViewCell.h"

@implementation PharmacyCommentTableViewCell

- (void)awakeFromNib
{
    [self.ratingView setImagesDeselected:@"star_none.png" partlySelected:@"star_half.png" fullSelected:@"star_full" andDelegate:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
