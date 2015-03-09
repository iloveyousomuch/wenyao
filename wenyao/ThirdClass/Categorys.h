//
//  Categorys.h
//  quanzhi
//
//  Created by Meng on 14-1-9.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Postion)
@property(nonatomic,assign)CGFloat FX;
@property(nonatomic,assign)CGFloat FY;
@property(nonatomic,assign)CGFloat FW;
@property(nonatomic,assign)CGFloat FH;
@property(nonatomic,assign)CGFloat BX;
@property(nonatomic,assign)CGFloat BY;
@property(nonatomic,assign)CGFloat BW;
@property(nonatomic,assign)CGFloat BH;

@property(nonatomic,assign, readonly)CGFloat EX;
@property(nonatomic,assign, readonly)CGFloat EY;
@end

@interface NSDictionary (MutableDeepCopy)
-(NSMutableDictionary *)mutableDeepCopy;
@end

@interface NSString (NoNullString)
@property(nonatomic, readonly)NSString* noNull;
@end

typedef void(^UIAlertViewButtonClick) (NSInteger btnIndex);
@interface UIAlertView (Block)<UIAlertViewDelegate>
- (void)showWithBlock:(UIAlertViewButtonClick)block;
@end

