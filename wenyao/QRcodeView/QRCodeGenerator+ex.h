//
//  QRCodeGenerator+ex.h
//  wenyao
//
//  Created by carret on 15/1/22.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "QRCodeGenerator.h"
typedef enum {
    QRPointRect = 0,
    QRPointRound
}QRPointType;

typedef enum {
    QRPositionNormal = 0,
    QRPositionRound
}QRPositionType;
@interface QRCodeGenerator (ex)
+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)size Topimg:(UIImage *)topimg;
+(UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)size withPointType:(QRPointType)pointType withPositionType:(QRPositionType)positionType withColor:(UIColor *)color;
@end
