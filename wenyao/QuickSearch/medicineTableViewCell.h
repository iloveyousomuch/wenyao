//
//  medicineTableViewCell.h
//  wenyao
//
//  Created by 李坚 on 14/12/8.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface medicineTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLable;
@property (weak, nonatomic) IBOutlet UILabel *mlLable;
@property (weak, nonatomic) IBOutlet UILabel *compaleLable;
@property (weak, nonatomic) IBOutlet UIImageView *medicineImage;
@property (weak, nonatomic) IBOutlet UIImageView *numberImage;
@property (weak, nonatomic) IBOutlet UILabel *whatForLable;

@end
