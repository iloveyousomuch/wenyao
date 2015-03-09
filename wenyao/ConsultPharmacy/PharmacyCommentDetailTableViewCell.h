//
//  PharmacyCommentTableViewCell.h
//  wenyao
//
//  Created by xiezhenghong on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"

@interface PharmacyCommentDetailTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet RatingView  *ratingView;
@property (nonatomic, strong) IBOutlet UILabel     *userName;
@property (nonatomic, strong) IBOutlet UILabel     *commentContent;
@property (strong, nonatomic) IBOutlet UILabel *lblNoComment;
@property (strong, nonatomic) IBOutlet UIView *viewExpand;
@property (strong, nonatomic) IBOutlet UIButton *btnExpand;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewExpand;

@property (strong, nonatomic) IBOutlet UIView *viewSeperator;

@end
