//
//  DiseaseClassViewTableViewCell.h
//  quanzhi
//
//  Created by xiezhenghong on 14-8-15.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiseaseClassViewTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet  UILabel     *nameLabel;
@property (nonatomic, strong) IBOutlet  UIImageView *avatar;
@property (nonatomic, strong) IBOutlet  UIImageView *accessAvatar;
@property (nonatomic, strong) IBOutlet  UILabel     *subCateLabel;

@end
