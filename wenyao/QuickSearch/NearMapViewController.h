//
//  NearStoreViewController.h
//  wenyao
//
//  Created by yang_wei on 14-10-2.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>


@interface NearMapViewController : BaseViewController


@end


//@interface MyCalloutView : UIView
//
//@end


@interface MyAnnotation : MAPointAnnotation<MAAnnotation>

@property (nonatomic, retain) NSDictionary* storeDic;

@end

@interface MyAnnotationButton : UIButton

@property (nonatomic ,strong) NSMutableDictionary * store;

@end


@interface MyAnnotationView : MAAnnotationView

@property (nonatomic, retain) NSDictionary * store;
@property (nonatomic ,strong) UILabel * tagLabel;
@property (nonatomic ,strong) UIImageView * iconView;

@end




