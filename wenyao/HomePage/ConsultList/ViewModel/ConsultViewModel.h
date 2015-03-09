//
//  ConsultViewModel.h
//  wenyao
//
//  Created by chenzhipeng on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum TagConsultPharmacy
{
    ConsultPharmacyNearList,
    ConsultPharmacyMyFav
}TagConsultPharmacy;

@protocol ConsultPharmacyListDelegate <NSObject>

- (void)ConsultPharmacySuccessWithTag:(TagConsultPharmacy)tag;
- (void)ConsultPharmacyFailWithTag:(TagConsultPharmacy)tag msg:(NSString *)strResponse;

@end

@interface ConsultViewModel : NSObject

@property (nonatomic, weak) id<ConsultPharmacyListDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *arrNearPharmacyList;

@property (nonatomic, strong) NSMutableArray *arrMyFavPharmacyList;

- (void)getMyFavPharmacyListWithCount:(NSInteger)count page:(NSInteger)page token:(NSString *)strToken;
- (void)getNearPharmacyListWithCount:(NSInteger)count Latitude:(CGFloat)latitude Longitude:(CGFloat)longitude CityName:(NSString *)strCity ProvinceName:(NSString *)strProvince;
- (void)getCachedNearPharmacyList;
- (void)getCachedMyFavPharmacyList;
- (void)cacheNearPharmacyList:(NSArray *)arrPharmacyList;
- (void)cacheMyPharmacyList:(NSArray *)arrMyPharmacyList;
@end
