//
//  RightAccessButton.h
//  quanzhi
//
//  Created by xiezhenghong on 14-6-9.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RightAccessButton : UIButton

@property (strong, nonatomic) UIFont    *customFont;
@property (strong, nonatomic) UIImageView  *accessIndicate;
@property (strong, nonatomic) UIColor   *customColor;
@property (strong ,nonatomic) NSString  *buttonTitle;
@property (assign, nonatomic) BOOL      isToggle;

- (void)setCustomImage:(UIImage *)image;
- (void)setButtonTitle:(NSString *)_title;
- (void)toggleButtonWithAccessView;
- (void)changeArrowDirectionUp:(BOOL)up;

@end
