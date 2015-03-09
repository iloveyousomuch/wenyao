//
//  PharmacyDetailViewController.h
//  wenyao
//
//  Created by xiezhenghong on 14-10-24.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface PharmacyDetailViewController : BaseViewController

@property (nonatomic, strong) IBOutlet  UILabel     *titleLabel;
@property (nonatomic, strong) IBOutlet  UILabel     *sourceLabel;

@property (nonatomic, strong) IBOutlet  UIImageView *OTCImage;
@property (nonatomic, strong) IBOutlet  UILabel     *OTCLabel;
@property (nonatomic, strong) IBOutlet  UILabel     *sourceTitleLabel;
@property (nonatomic, strong) IBOutlet  UIView      *headerView;

@property (nonatomic, strong) IBOutlet  UILabel         *recipeLabel;
@property (nonatomic, strong) IBOutlet  UIImageView     *recipeImage;

@property (nonatomic, strong) IBOutlet  UILabel     *useNameLabel;
@property (nonatomic, strong) IBOutlet  UILabel     *useageLabel;


@property (nonatomic, strong) IBOutlet  UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet  UIView      *effectView;
@property (nonatomic, strong) IBOutlet  UILabel     *effectLabel;
@property (nonatomic, strong) IBOutlet  UIButton    *expandButton;

@property (nonatomic, strong) IBOutlet  UIView      *footerView;
@property (nonatomic, strong) NSMutableDictionary   *infoDict;
@property (nonatomic, copy) void(^changeMedicineInformation)(NSDictionary *dict);

- (IBAction)expandEffect:(UIButton *)sender;
- (IBAction)pushIntoMedicineDetail:(id)sender;

@end
