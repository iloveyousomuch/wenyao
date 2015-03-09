//
//  AlarmClockViewController.h
//  wenyao
//
//  Created by xiezhenghong on 14-10-18.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface AlarmClockViewController : BaseViewController

//0是添加闹钟        1是编辑闹钟
@property (nonatomic, assign) NSUInteger    useType;
@property (nonatomic, assign) BOOL          mustSave;
@property (nonatomic, strong) NSMutableDictionary    *infoDict;


@property (nonatomic, strong) IBOutlet UIView        *alertCellView;
@property (nonatomic, strong) IBOutlet UIView        *noteCellView;

@property (nonatomic, strong) IBOutlet UITextView    *textView;
@property (nonatomic, copy) void(^editClockBlock)();


@end
