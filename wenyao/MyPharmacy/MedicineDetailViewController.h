//
//  MedicineDetailViewController.h
//  quanzhi
//
//  Created by xiezhenghong on 14-6-11.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface MedicineDetailViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>



@property (nonatomic, strong) UITableView   *tableView;

@property (nonatomic, strong) NSString      *boxProductId;
@property (nonatomic, assign) BOOL          showRightBarButton;
@property (nonatomic, assign) BOOL          showInStoryBoard;

@property (nonatomic, strong) NSString     *proId;
@property (nonatomic, strong) IBOutlet UILabel   *drugName;
@property (nonatomic, strong) IBOutlet UILabel   *drugSpec;
@property (nonatomic, strong) IBOutlet UILabel   *drugType;
@property (nonatomic, strong) IBOutlet UILabel   *drugFactory;
@property (nonatomic, strong) IBOutlet UIImageView  *firstImage;
@property (nonatomic, strong) IBOutlet UIView       *footView;

@property (nonatomic, strong) IBOutlet UILabel      *ephedrineLabel;
@property (nonatomic, strong) IBOutlet UIImageView  *ephedrineImage;

@property (nonatomic, strong) IBOutlet UIImageView *drugOtcLogo;
@property (nonatomic, strong) IBOutlet UIImageView *drugEffect;
@property (nonatomic, strong) IBOutlet UILabel   *drugKnowledge;
@property (nonatomic, strong) IBOutlet UILabel   *drugMark;
@property (nonatomic, strong) IBOutlet UIView    *digestView;
@property (nonatomic, strong) IBOutlet UIView    *adaptationView;
@property (nonatomic, strong) IBOutlet UIView    *usageView;

@property (nonatomic, strong) IBOutlet UIView    *attentionView;

@property (nonatomic, strong) IBOutlet UIView    *markView;
@property (nonatomic, strong) IBOutlet UIView    *knowLedgeView;
@property (nonatomic, strong) IBOutlet UIView    *guideCellView;
@property (nonatomic, strong) IBOutlet UISwitch  *guideSwitch;
@property (nonatomic, strong) IBOutlet UIView    *guideView;
@property (nonatomic, strong) IBOutlet UILabel   *collectLabel;
@property (nonatomic, strong) IBOutlet UIButton  *collectImage;
@property (nonatomic, strong) IBOutlet UIButton  *backCover;
@property (nonatomic, strong) NSDictionary       *extendInfo;

- (IBAction)pushIntoMark:(id)sender;
- (IBAction)setLike:(id)sender;
- (IBAction)showGuide:(id)sender;

- (IBAction)dismissAdjustFontView:(id)sender;
- (IBAction)showAdjustFont:(id)sender;
- (IBAction)ZoominFont:(id)sender;
- (IBAction)ZoomoutFont:(id)sender;


@end
