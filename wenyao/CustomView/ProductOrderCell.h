//
//  ProductOrderCell.h
//  wenyao
//
//  Created by Meng on 15/1/22.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductOrderCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *proName;

@property (weak, nonatomic) IBOutlet UILabel *date;

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponLabel;

@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet UIView *seperatorView;

@end
