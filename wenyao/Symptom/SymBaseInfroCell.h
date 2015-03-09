//
//  SymBaseInfroCell.h
//  quanzhi
//
//  Created by Meng on 14-8-11.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SymBaseInfroCell;
@protocol SymBaseInfroCellDelegate <NSObject>

- (void)clickExpandEventWithIndexPath:(SymBaseInfroCell *)indexPath;

@end

@interface SymBaseInfroCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (nonatomic ,weak) id<SymBaseInfroCellDelegate>delegate;

@property (nonatomic, strong) IBOutlet  UIButton    *ExtendButton;
@property (nonatomic, assign) BOOL      isExpand;
@property (nonatomic, strong) IBOutlet UIImageView   *arrowImageView;
- (IBAction)expandContent:(id)sender;
- (void)changeArrowWithUp:(BOOL)up;
@end
