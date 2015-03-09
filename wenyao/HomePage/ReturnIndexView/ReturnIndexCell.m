//
//  ReturnIndexCell.m
//  wenyao
//
//  Created by qwfy0006 on 15/3/2.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "ReturnIndexCell.h"
#import "Constant.h"

@implementation ReturnIndexCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    // Configure the view for the selected state
}

//在自定义cell中实现，两种方法都可行，一个是改颜色，一个是用图片
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
        if(highlighted) {
            self.bg.backgroundColor = UIColorFromRGB(0x000000);
            self.bg.alpha = 0.85;
        } else {
            self.bg.backgroundColor = UIColorFromRGB(0x000000);
            self.bg.alpha = 0.8;
        }

        [super setHighlighted:highlighted animated:animated];

}

@end
