//
//  ScanReaderViewController.h
//  quanzhi
//
//  Created by xiezhenghong on 14-6-4.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

#import <ZXingObjC/ZXingObjC.h>
typedef void(^chooseMedicineBlock)(NSMutableDictionary *);

@interface ScanReaderViewController : BaseViewController<ZXCaptureDelegate>

@property (nonatomic, weak) IBOutlet UIView *scanRectView;

//1代表普通扫码界面     2代表添加到用药     3代表扫码搜索优惠信息
@property (nonatomic, assign) NSUInteger                useType;
@property (nonatomic, copy)   chooseMedicineBlock       completionBolck;

@property(nonatomic, copy)void(^scanBlock)(NSString* scanCode);

@property (nonatomic) NSInteger pageType;



@property (nonatomic, strong) ZXCapture *capture;
@end
