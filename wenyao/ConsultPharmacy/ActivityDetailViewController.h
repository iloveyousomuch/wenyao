//
//  ActivityDetailViewController.h
//  wenyao
//
//  Created by xiezhenghong on 14-10-14.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "RatingView.h"

@interface ActivityDetailViewController : BaseViewController

@property (nonatomic, strong) NSMutableDictionary   *infoDict;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UILabel      *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel      *dateLabel;

@property (nonatomic, strong) IBOutlet UIImageView  *imageView;
@property (nonatomic, strong) IBOutlet UILabel      *contentLabel;

@end
