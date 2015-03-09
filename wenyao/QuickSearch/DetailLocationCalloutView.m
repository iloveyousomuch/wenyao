//
//  DetailLocationCalloutView.m
//  wenyao
//
//  Created by garfield on 15/3/4.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "DetailLocationCalloutView.h"
#import "Constant.h"

#define POPOVER_ARROW_HEIGHT 20.0
#define POPOVER_ARROW_BASE 20.0
#define POPOVER_RADIUS 6.0

@implementation DetailLocationCalloutView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.addressLabel = [[UILabel alloc] init];
        
        self.addressLabel.numberOfLines = 999;
        self.addressLabel.font = [UIFont systemFontOfSize:14.0f];
        self.addressLabel.textColor = [UIColor whiteColor];

        [self addSubview:self.addressLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.addressLabel.text = self.addressDescription;
    CGSize size = [self.addressDescription sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(APP_W *  0.8, 999)];
    self.frame = CGRectMake(-(size.width + 25) / 2.0f + 12, -(size.height + 35) , size.width + 25, size.height + 35);

    CGRect rect = self.addressLabel.frame;
    rect.size = size;
    rect.origin.x = 12.5;
    rect.origin.y = 11.25;
    self.addressLabel.frame = rect;
}


- (void)drawRect:(CGRect)rect
{
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    height -= 12.5;
    // 简便起见，这里把圆角半径设置为长和宽平均值的1/10
    CGFloat radius = POPOVER_RADIUS;
    
    // 获取CGContext，注意UIKit里用的是一个专门的函数
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 移动到初始点
    CGContextMoveToPoint(context, radius, 0);
    
    // 绘制第1条线和第1个1/4圆弧
    CGContextAddLineToPoint(context, width - radius, 0);
    CGContextAddArc(context, width - radius, radius, radius, -0.5 * M_PI, 0.0, 0);
    
    // 绘制第2条线和第2个1/4圆弧
    CGContextAddLineToPoint(context, width, height - radius);
    CGContextAddArc(context, width - radius, height - radius, radius, 0.0, 0.5 * M_PI, 0);
    
    // 绘制第3条线和第3个1/4圆弧
    CGContextAddLineToPoint(context, radius, height);
    CGContextAddArc(context, radius, height - radius, radius, 0.5 * M_PI, M_PI, 0);
    
    // 绘制第4条线和第4个1/4圆弧
    CGContextAddLineToPoint(context, 0, radius);
    CGContextAddArc(context, radius, radius, radius, M_PI, 1.5 * M_PI, 0);
    
    // 闭合路径
    CGContextClosePath(context);
    // 填充半透明
    CGContextSetRGBFillColor(context, 0.24, 0.24, 0.24, 0.8);
    CGContextDrawPath(context, kCGPathFill);
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(width / 2.0 - 6 + 2, height - 0.2)];
    [path addLineToPoint:CGPointMake(width / 2.0 + 2, height + 12.5)];
    [path addLineToPoint:CGPointMake(width / 2.0 + 6 + 2, height - 0.2)];
    [[UIColor colorWithRed:0.24 green:0.24 blue:0.24 alpha:0.8] setFill];
    [path fill];

}

@end
