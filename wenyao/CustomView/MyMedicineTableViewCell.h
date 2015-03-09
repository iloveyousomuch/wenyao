//
//  MyMedicineTableViewCell.h
//  wenyao
//
//  Created by Meng on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyMedicineTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *medicineTitle;
@property (weak, nonatomic) IBOutlet UILabel *medicineDosage;

@property (weak, nonatomic) IBOutlet UILabel *createTime;
@property (weak, nonatomic) IBOutlet UIImageView *imperfectImageView;

@property (weak, nonatomic) IBOutlet UIButton *labelButtonClick;
@property (weak, nonatomic) IBOutlet UIButton *alarmClockClick;




@end
