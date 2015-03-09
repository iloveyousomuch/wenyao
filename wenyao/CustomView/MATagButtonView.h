//
//  MATagButtonView.h
//  wenyao
//
//  Created by Meng on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MATagButtonView : UIView

- (instancetype)initWithFrame:(CGRect)frame TagArray:(NSArray *)tagArray;

@end


/*调用方法:例如
 //    NSArray *arr = @[@"免费送药",@"医保定点",@"24小时"];
 //
 //    MATagButtonView *v = [[MATagButtonView alloc] initWithFrame:CGRectMake(0, NAV_H + STATUS_H, APP_W, 0) TagArray:arr];
 //    [self.view addSubview:v];
 
 */



@interface MATagButton : UIButton


@property (nonatomic ,strong) NSString *buttonName;

@property (nonatomic ,assign) BOOL isSelected;

@end