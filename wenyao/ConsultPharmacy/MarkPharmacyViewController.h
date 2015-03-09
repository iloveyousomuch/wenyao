//
//  MarkPharmacyViewController.h
//  wenyao
//
//  Created by xiezhenghong on 14-10-14.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"
#import "BaseViewController.h"

@interface MarkPharmacyViewController : BaseViewController

@property (nonatomic, strong) NSDictionary       *infoDict;
@property (nonatomic, strong) NSString           *UUID;
@property (nonatomic, strong) IBOutlet  RatingView      *ratingView;
@property (nonatomic, strong) IBOutlet  UILabel         *countLabel;
@property (nonatomic, strong) IBOutlet  UILabel         *hintLabel;
@property (nonatomic, strong) IBOutlet  UITextView      *textView;

@property (nonatomic, copy) void(^InsertNewEvaluate)(NSDictionary *dict);

@end
