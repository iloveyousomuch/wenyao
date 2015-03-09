//
//  HealthIndicatorDetailViewController.h
//  quanzhi
//
//  Created by xiezhenghong on 14-7-3.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"
#import "InformationListViewController.h"

@interface HealthIndicatorDetailViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIImageView *eyeImageView;

@property (nonatomic, strong) NSString                  *htmlUrl;
@property (nonatomic, strong) NSMutableDictionary       *infoDict;

@property (nonatomic, strong) IBOutlet UIScrollView     *scrollView;
@property (nonatomic, strong) IBOutlet UIImageView      *imageView;
@property (nonatomic, strong) IBOutlet UILabel          *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel          *sourceLabel;
@property (nonatomic, strong) IBOutlet UILabel          *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel          *readLabel;
@property (nonatomic, strong) IBOutlet UIWebView        *webView;
@property (nonatomic, strong) IBOutlet UILabel          *praiseLabel;
@property (nonatomic, strong) IBOutlet UILabel          *collectLabel;
@property (nonatomic, strong) IBOutlet UIView           *footerView;

@property (nonatomic, strong) IBOutlet UIImageView      *praiseImage;
@property (nonatomic, strong) IBOutlet UIImageView      *collectImage;
@property (nonatomic, assign) InformationListViewController *infoList;

@property (nonatomic, assign) NSInteger intFromBanner;
@property (nonatomic, strong) NSString *guideId;

- (IBAction)prasieOnce:(id)sender;
- (IBAction)collectClick:(id)sender;

@end
