//
//  QuickSearchButton.h
//  wenyao
//
//  Created by Meng on 14-9-24.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QuickSearchButtonDelegate <NSObject>
@required
- (void)buttonViewClick:(NSInteger)tag;
@end

@interface QuickSearchButton : UIView
@property (nonatomic ,copy) NSString * buttonTitle;
@property (nonatomic ,assign) NSInteger viewTag;
@property (nonatomic ,weak) id<QuickSearchButtonDelegate> delegate;

@end



//@interface MyTapGestureRecognizer : UITapGestureRecognizer
//@property (nonatomic ,assign) NSInteger tag;
//@end