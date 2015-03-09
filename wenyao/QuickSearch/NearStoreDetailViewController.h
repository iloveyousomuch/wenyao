//
//  NearStoreDetailViewController.h
//  wenyao
//
//  Created by Meng on 14-10-8.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"

@interface NearStoreDetailViewController : BaseViewController

@property(nonatomic, retain)NSDictionary* store;
@property(nonatomic, retain)NSMutableArray* storeList;
@property (nonatomic ,strong) NSDictionary * cityDict;
@property (nonatomic ,copy) NSString * drugStoreCode;

@end


