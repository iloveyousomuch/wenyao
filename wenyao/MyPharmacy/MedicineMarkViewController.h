//
//  MedicineMarkViewController.h
//  quanzhi
//
//  Created by xiezhenghong on 14-6-13.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@interface MedicineMarkViewController : BaseViewController<UITextViewDelegate>

@property (nonatomic, strong)           NSString    *appraiseId;
@property (nonatomic, strong)           NSString    *boxProductId;
@property (nonatomic, strong) IBOutlet  UILabel     *drugName;
@property (nonatomic, strong) IBOutlet  UITextView  *textView;
@property (nonatomic, strong) IBOutlet  UILabel     *showWordNum;
@property (nonatomic, strong) IBOutlet  UIImageView *textViewBackGround;
@property (nonatomic, assign) NSUInteger  selectedIndex;
@property (nonatomic, strong) IBOutlet  UILabel     *effectLabel;
@property (nonatomic, strong) NSMutableDictionary   *appraiseInfo;

- (IBAction)showEffectPicker:(id)sender;


@end
