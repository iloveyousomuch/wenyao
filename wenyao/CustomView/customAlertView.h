//
//  customAlertView.h
//  TestAlertView
//
//  Created by chenzhipeng on 14/11/4.
//  Copyright (c) 2014年 perry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface customAlertView : UIView
@property (nonatomic, assign) BOOL isClick;
@property (strong, nonatomic) IBOutlet UITextView *tvViewMessage;
@property (strong, nonatomic) IBOutlet UIButton *btnClick;

- (IBAction)btnClick:(id)sender;

@end
