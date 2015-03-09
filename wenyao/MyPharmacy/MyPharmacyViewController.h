//
//  MyPharmacyViewController.h
//  wenyao
//
//  Created by Pan@QW on 14-9-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


typedef enum TagType {
    DrugTag = 1,
    UseNameTag = 2,
    EffectTag = 3,
    AddTag,
} TagType;

@interface MyPharmacyViewController : BaseViewController

@property (nonatomic, strong) NSMutableArray            *myMedicineList;

//YES的话 不需要显示searchBar以及添加标签字段
@property (nonatomic, assign) BOOL                      subType;
@property (nonatomic, assign) BOOL                      shouldScrollToUncomplete;

@end
