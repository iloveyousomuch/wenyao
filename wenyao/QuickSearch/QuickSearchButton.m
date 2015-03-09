//
//  QuickSearchButton.m
//  wenyao
//
//  Created by Meng on 14-9-24.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "QuickSearchButton.h"
#define imageView_X  20
#define imageView_Y  10
#define imageView_W  59
#define imageView_H  50

@implementation QuickSearchButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setDelegate:(id<QuickSearchButtonDelegate>)delegate{
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageView_X, imageView_Y, imageView_W, imageView_H)];
    imageView.backgroundColor = [UIColor orangeColor];
    [self addSubview:imageView];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(imageView_X, imageView_Y + imageView_H + 5, imageView_W, 15)];
    label.text = self.buttonTitle;
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    
//    MyTapGestureRecognizer * tap = [[MyTapGestureRecognizer alloc] init];
//    tap.tag = self.viewTag;
//    [tap addTarget:self action:@selector(viewClick:)];
//    [self addGestureRecognizer:tap];
}

- (void)viewClick:(NSInteger)tag{
    NSLog(@"代理的tag = %d",tag);
    if ([self.delegate respondsToSelector:@selector(buttonViewClick:)]) {
        [self.delegate buttonViewClick:tag];
    }
}

@end



//@implementation MyTapGestureRecognizer
//
//
//@end
