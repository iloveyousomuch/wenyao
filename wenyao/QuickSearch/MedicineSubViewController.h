//
//  MedicineSubViewController.h
//  wenyao
//
//  Created by Meng on 14-9-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseTableViewController.h"

typedef enum {
    RequestTypeMedicine = 0,
    RequestTypeDisease,
}RequestType;

@interface MedicineSubViewController : BaseTableViewController

@property (nonatomic ,assign) RequestType requestType;
@property (nonatomic ,copy) NSString * classId;
@end
