//
//  TagCollectionViewCell.m
//  wenyao
//
//  Created by xiezhenghong on 14-9-18.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "TagCollectionViewCell.h"
#import "Constant.h"

@implementation TagCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.backImageButton setBackgroundColor:[UIColor clearColor]];
        self.backImageButton.userInteractionEnabled = NO;
        [self.backImageButton setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
        
        self.backImageButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [self.contentView addSubview:self.backImageButton];
    }
    return self;
}

- (void)setTagName:(NSString *)tagName
{
    _tagName = tagName;
    [self.backImageButton setTitle:tagName forState:UIControlStateNormal];
    UIImage *resizeImage = nil;
    resizeImage = [UIImage imageNamed:@"标签背景.png"];
    resizeImage = [resizeImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 5, 10, 5) resizingMode:UIImageResizingModeStretch];
    CGSize size = [tagName sizeWithFont:self.backImageButton.titleLabel.font constrainedToSize:CGSizeMake(300, 20)];
    self.backImageButton.frame = CGRectMake(0, 0, size.width + 2 * 10, 25);
    [self.backImageButton setBackgroundImage:resizeImage forState:UIControlStateNormal];
}


@end
