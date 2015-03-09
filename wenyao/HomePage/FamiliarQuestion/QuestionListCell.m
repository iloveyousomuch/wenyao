//
//  QuestionListCell.m
//  wenyao
//
//  Created by qwyf0006 on 15/1/15.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "QuestionListCell.h"
#import "Constant.h"

@implementation QuestionListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showData
{
    self.logoImage.layer.cornerRadius = 20.0;
    self.logoImage.layer.masksToBounds = YES;
    self.labelBgView.layer.cornerRadius = 5.0;
    self.labelBgView.layer.masksToBounds = YES;
    self.titleLabel.textColor = UIColorFromRGB(0x333333);
    self.contentLabel.textColor = UIColorFromRGB(0x333333);
//    self.titleLabel.backgroundColor = [UIColor redColor];
//    self.contentLabel.backgroundColor = [UIColor blueColor];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 3;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:13],NSParagraphStyleAttributeName:paragraphStyle};
    self.contentLabel.attributedText = [[NSAttributedString alloc] initWithString:self.contentLabel.text attributes:attributes];
    
    
}


@end
