//
//  ProductOrderCell.m
//  wenyao
//
//  Created by Meng on 15/1/22.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "ProductOrderCell.h"

@implementation ProductOrderCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    CGRect rect = self.line.frame;
    rect.size.height = 0.5f;
    self.line.frame = rect;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
