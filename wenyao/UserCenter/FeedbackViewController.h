//
//  FeedbackViewController.h
//  wenyao
//
//  Created by Meng on 14-10-2.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"

@interface FeedbackViewController : BaseViewController<UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView     *scrollView;


@end
