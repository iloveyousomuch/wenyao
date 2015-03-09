//
//  BoutiqueApplicationTableViewCell.h
//  quanzhi
//
//  Created by xiezhenghong on 14-9-14.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoutiqueApplicationTableViewCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UIImageView   *avatar;
@property (nonatomic,strong) IBOutlet UIImageView   *backGroundImage;
@property (nonatomic,strong) IBOutlet UILabel       *applicationName;
@property (nonatomic,strong) IBOutlet UILabel       *applicationDescription;
@property (nonatomic,strong) IBOutlet UIButton     *expandButton;


@end
