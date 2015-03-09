//
//  ConsultPharmacyTableViewCell.h
//  wenyao
//
//  Created by xiezhenghong on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"
@interface ConsultPharmacyTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel     *drugStore;
@property (nonatomic, strong) IBOutlet UIImageView *drugAvatar;
@property (nonatomic, strong) IBOutlet UIImageView *verifyLogo;

@property (nonatomic, strong) IBOutlet RatingView  *ratingView;

@property (nonatomic, strong) IBOutlet UILabel     *consultPerson;
@property (nonatomic, strong) IBOutlet UILabel     *distance;
@property (nonatomic, strong) IBOutlet UILabel     *locationDesc;

@property (nonatomic, strong) IBOutlet UIButton    *consultButton;

@property (nonatomic, strong) IBOutlet UIImageView *key1Image;
@property (nonatomic, strong) IBOutlet UILabel     *key1Label;
@property (nonatomic, strong) IBOutlet UIImageView *key2Image;
@property (nonatomic, strong) IBOutlet UILabel     *key2Label;
@property (nonatomic, strong) IBOutlet UIImageView *key3Image;
@property (nonatomic, strong) IBOutlet UILabel     *key3Label;
@property (nonatomic, strong) IBOutlet UIImageView *key4Image;
@property (nonatomic, strong) IBOutlet UILabel     *key4Label;
@property (strong, nonatomic) IBOutlet UIView *viewSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *distanceIcon;

@end
