//
//  AddNewMedicineViewController.h
//  wenyao
//
//  Created by Pan@QW on 14-9-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "secondCustomAlertView.h"

typedef void (^PushToMyMedicineList)();

@interface AddNewMedicineViewController : BaseViewController

//0为新增模式    1为编辑模式需要填充数据
@property (nonatomic, assign) NSUInteger        editMode;

@property (nonatomic, strong) UITableView       *tableView;
@property (nonatomic, strong) IBOutlet  UIView  *footerView;
@property (nonatomic, strong) IBOutlet  UIButton  *usageButton;
@property (nonatomic, strong) IBOutlet  UIButton  *unitButton;
@property (nonatomic, strong) IBOutlet  UIButton  *quantityButton;
@property (nonatomic, strong) IBOutlet  UIButton  *periodButton;
@property (nonatomic, strong) IBOutlet  UIButton  *frequencyButton;
@property (nonatomic, strong) IBOutlet  UILabel   *usageDetailLabel;
@property (nonatomic, strong) IBOutlet  UITextField *countField;

@property (nonatomic, strong) PushToMyMedicineList blockPush;

@property (nonatomic, copy) void(^InsertNewPharmacy)(NSMutableDictionary *dict);

@property (nonatomic, strong) NSMutableDictionary *infoDict;
@property (nonatomic, strong) NSMutableDictionary *originDict;
@property (nonatomic ,strong) secondCustomAlertView *customAlertView;

- (IBAction)chooseUsage:(id)sender;
- (IBAction)chooseQuantity:(id)sender;
- (IBAction)chooseUnit:(id)sender;
- (IBAction)choosePeriod:(id)sender;
- (IBAction)chooseFrequency:(id)sender;

- (IBAction)pushIntoScanReaderView:(id)sender;

- (void)setPushToMyMedicineBlock:(PushToMyMedicineList)block;

@end
