//
//  ConsultPharmacyTableViewCell.m
//  wenyao
//
//  Created by xiezhenghong on 14-9-17.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "ConsultPharmacyTableViewCell.h"
#import "Constant.h"

@implementation ConsultPharmacyTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.ratingView setImagesDeselected:@"star_none.png" partlySelected:@"star_half.png" fullSelected:@"star_full" andDelegate:nil];
    self.ratingView.userInteractionEnabled = NO;
    self.consultButton.layer.cornerRadius = 2.0f;
    self.consultButton.layer.masksToBounds = YES;
    
    self.consultButton.layer.borderWidth = 1;
    self.consultButton.layer.borderColor = UIColorFromRGB(0xff8a00).CGColor;
    
    self.drugAvatar.layer.masksToBounds = YES;
    self.drugAvatar.layer.cornerRadius = 27.5f;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
//    self.key2Image.frame = CGRectMake(142, 61, 13, 13);
//    self.key2Label.frame = CGRectMake(158, 61, 20, 13);
//    self.key3Image.frame = CGRectMake(182, 61, 13, 13);
//    self.key3Label.frame = CGRectMake(199, 61, 40, 13);
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect imageRect = self.key1Image.frame;
    CGRect labelRect = self.key1Label.frame;
    if(self.key1Image.hidden == NO){
        self.key1Image.frame = imageRect;
        self.key1Label.frame = labelRect;
        imageRect.origin.x += self.key1Label.frame.size.width + 17;
        labelRect.origin.x += self.key1Label.frame.size.width + 17;
    }
    if(self.key3Image.hidden == NO){
        self.key3Image.frame = imageRect;
        self.key3Label.frame = labelRect;
        imageRect.origin.x += self.key3Label.frame.size.width + 17;
        labelRect.origin.x += self.key3Label.frame.size.width + 17;
    }
    if(self.key2Image.hidden == NO){
        self.key2Image.frame = imageRect;
        self.key2Label.frame = labelRect;
        imageRect.origin.x += self.key2Label.frame.size.width - 3;
        labelRect.origin.x += self.key2Label.frame.size.width - 3;
    }
    if(self.key4Image.hidden == NO){
        self.key4Image.frame = imageRect;
        self.key4Label.frame = labelRect;
        imageRect.origin.x += self.key4Label.frame.size.width + 17;
        labelRect.origin.x += self.key4Label.frame.size.width + 17;
    }
    
//    CGRect rect = self.drugStore.frame;
//    CGSize size = [self.drugStore.text sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(250, 19)];
//    rect.size.width = size.width;
//    self.drugStore.frame = rect;
//    rect = self.verifyLogo.frame;
//    rect.origin.x = self.drugStore.frame.origin.x + self.drugStore.frame.size.width + 10;
//    self.verifyLogo.frame = rect;
//    rect = CGRectZero;
//    rect.origin.y = 62;
//    rect.size.height = 13;
//    for(NSUInteger index = 0; index < 4; ++index)
//    {
//        switch (index) {
//            case 0:
//            {
//                if(self.key1Image.hidden == NO)
//                {
//                    rect = self.key1Label.frame;
//                    rect.origin.x = 137;
//                }else{
//                    rect.origin.x = 80;
//                }
//                break;
//            }
//            case 1:
//            {
//                if(self.key2Image.hidden == NO)
//                {
//                    rect.origin.x += 2;
//                    rect.size.width = 13;
//                    self.key2Image.frame = rect;
//                    rect.origin.x = rect.origin.x + rect.size.width + 2;
//                    rect.size.width = 20;
//                    self.key2Label.frame = rect;
//                    rect.origin.x = rect.origin.x + rect.size.width;
//                }
//                break;
//            }
//            case 2:
//            {
//                if(self.key3Image.hidden == NO)
//                {
//                    rect.origin.x += 2;
//                    rect.size.width = 13;
//                    self.key3Image.frame = rect;
//                    rect.origin.x = rect.origin.x + rect.size.width + 2;
//                    rect.size.width = 40;
//                    self.key3Label.frame = rect;
//                    rect.origin.x = rect.origin.x + rect.size.width;
//                }
//                break;
//            }
//            case 3:
//            {
//                if(self.key4Image.hidden == NO)
//                {
//                    rect.origin.x += 2;
//                    rect.size.width = 13;
//                    self.key4Image.frame = rect;
//                    rect.origin.x = rect.origin.x + rect.size.width + 2;
//                    rect.size.width = 40;
//                    self.key4Label.frame = rect;
//                    rect.origin.x = rect.origin.x + rect.size.width;
//                }
//                break;
//            }
//            default:
//                break;
//        }
//    }
}

@end
