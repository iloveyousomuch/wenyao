//
//  CustomDatePicker.m
//  wenyao
//
//  Created by xiezhenghong on 14-10-27.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "CustomDatePicker.h"
#import "Constant.h"


@implementation CustomDatePicker

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.6]];
        self.container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 240)];
        [self.container setBackgroundColor:[UIColor whiteColor]];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"取消" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15.0];
        button.frame =CGRectMake(20, 10, 80, 40);
        [button addTarget:self action:@selector(cancelDatePicker:) forControlEvents:UIControlEventTouchDown];
        [self.container addSubview:button];
        
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
        [button1 setTitle:@"确认" forState:UIControlStateNormal];
        button1.titleLabel.font = [UIFont systemFontOfSize:15.0];
        button1.frame =CGRectMake(220, 10, 80, 40);
        [button1 addTarget:self action:@selector(selectDatePicker:) forControlEvents:UIControlEventTouchDown];
        [self.container addSubview:button1];
        
        self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 50, APP_W, 190)];
        self.datePicker.userInteractionEnabled = YES;
        [self.container addSubview:self.datePicker];
    }
    return self;
}

- (void)setDatePickerMode:(UIDatePickerMode)datePickerMode
{
    _datePickerMode = datePickerMode;
    self.datePicker.datePickerMode = datePickerMode;
}

- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self];
    [self addSubview:self.container];
    CGPoint center = self.center;
    center.y -= 80;
    self.container.center = center;
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.35;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5f, 0.5f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2f, 1.2f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95f, 0.95f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.4f,@0.5f, @0.7f, @0.9f,@1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.container.layer addAnimation:popAnimation forKey:nil];
}

- (void)dismissView
{
    CAKeyframeAnimation *hideAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    hideAnimation.duration = 0.35;
    hideAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                             [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3f, 1.3f, 1.0f)],
                             [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)],
                             [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5f, 0.5f, 1.0f)],
                             [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.00f, 0.00f, 0.00f)]];
    hideAnimation.keyTimes = @[@0.2f, @0.4f,@0.6f, @0.8f, @1.0f];
    hideAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    hideAnimation.delegate = self;
    [self.container.layer addAnimation:hideAnimation forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.container removeFromSuperview];
    [self removeFromSuperview];
}

#pragma mark - TouchTouchTouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismissView];
}

- (IBAction)cancelDatePicker:(id)sender
{
    [self dismissView];
}

- (IBAction)selectDatePicker:(id)sender
{
    if([self.delegate respondsToSelector:@selector(didSelectDatePicker:date:)]){
        [self.delegate didSelectDatePicker:self date:self.datePicker.date];
    }
    [self dismissView];
}

@end
