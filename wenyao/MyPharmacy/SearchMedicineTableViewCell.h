//
//  SearchMedicineTableViewCell.h
//  wenyao
//
//  Created by xiezhenghong on 14-10-8.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchMedicineTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet  UIImageView *backImg;
@property (nonatomic, strong) IBOutlet  UILabel     *medicineName;
@property (nonatomic, strong) IBOutlet  UILabel     *medicineNorms;
@property (nonatomic, strong) IBOutlet  UILabel     *medicineFactory;

@end
