//
//  DiseaseSubscriptionTableViewCell.h
//  wenyao
//
//  Created by Pan@QW on 14-9-24.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiseaseSubscriptionTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet  UILabel     *titleLabel;
@property (nonatomic, strong) IBOutlet  UILabel     *contentLabel;
@property (nonatomic, strong) IBOutlet  UILabel     *dateLabel;
@property (nonatomic, strong) IBOutlet  UIImageView *indicateImage;


@end
