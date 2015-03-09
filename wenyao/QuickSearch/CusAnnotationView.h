//
//  CusAnnotationView.h
//  MAMapKit_static_demo
//
//  Created by songjian on 13-10-16.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>


@protocol CusAnnotationViewDelegate <NSObject>

- (void)callOutViewStore:(NSDictionary *)store;

@end



@interface CusAnnotationView : MAAnnotationView

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) UIImage *portrait;
@property (nonatomic, strong) UIView *calloutView;
@property (nonatomic ,strong) UIImageView *iconView;
@property (nonatomic ,strong) UILabel *tagLabel;
@property (nonatomic, retain) NSDictionary *storeDic;



/**
 *  标注类型
 *
 *  annType = 1 是大背景    annType = 2 是小背景
 */
@property (nonatomic ,assign) NSInteger annType;

@property (nonatomic ,weak) id<CusAnnotationViewDelegate>delegate;

@end
