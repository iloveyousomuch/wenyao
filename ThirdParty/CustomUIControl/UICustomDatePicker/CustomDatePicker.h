//
//  CustomDatePicker.h
//  wenyao
//
//  Created by xiezhenghong on 14-10-27.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomDatePicker;
@protocol CustomDatePickerDelegate <NSObject>

- (void)didSelectDatePicker:(CustomDatePicker *)datePicker date:(NSDate *)date;

@end


@interface CustomDatePicker : UIView

@property (nonatomic, strong) UIDatePicker      *datePicker;
@property (nonatomic, strong) UIView            *container;
@property (nonatomic, weak) id<CustomDatePickerDelegate>  delegate;

@property (nonatomic) UIDatePickerMode datePickerMode;

- (void)showInView:(UIView *)aView animated:(BOOL)animated;
- (void)dismissView;

- (IBAction)cancelDatePicker:(id)sender;
- (IBAction)selectDatePicker:(id)sender;
@end
