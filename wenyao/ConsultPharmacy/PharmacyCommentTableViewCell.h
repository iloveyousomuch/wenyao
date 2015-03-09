//
//  PharmacyCommentTableViewCell.h
//  wenyao
//
//  Created by xiezhenghong on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"

@interface PharmacyCommentTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet RatingView  *ratingView;
@property (nonatomic, strong) IBOutlet UILabel     *userName;
@property (nonatomic, strong) IBOutlet UILabel     *commentContent;
@property (strong, nonatomic) IBOutlet UILabel *lblNoComment;

@end
