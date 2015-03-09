//
//  SubRegularTableViewCell.h
//  quanzhi
//
//  Created by xiezhenghong on 14-6-26.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubRegularTableViewCell : UITableViewCell

@property (nonatomic,strong) IBOutlet   UILabel    *titleLabel;
@property (nonatomic,strong) IBOutlet   UIImageView *avatarImage;
@property (nonatomic,strong) IBOutlet   UIImageView *backImg;
@property (nonatomic,strong) IBOutlet   UILabel    *descLabel;


@end
