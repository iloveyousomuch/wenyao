//
//  HTTPRequestManager+ConsultPharmacy.h
//  wenyao
//
//  Created by chenzhipeng on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "HTTPRequestManager.h"

typedef void (^GetNearPharmacyListSuccessBlock)(id objResponse);
typedef void (^GetNearPharmacyListFailBlock)(NSInteger errorCode, NSString *strResponse);

typedef void (^GetMyFavPharmacyListSuccessBlock)(id objResponse);
typedef void (^GetMyFavPharmacyListFailBlock)(NSInteger errorCode, NSString *strResponse);

@interface HTTPRequestManager (ConsultPharmacy)

- (void)getConsultPharmacyNearListWithDic:(NSMutableDictionary *)dic count:(NSInteger)count success:(GetNearPharmacyListSuccessBlock)successBlock fail:(GetNearPharmacyListFailBlock)failBlock;

- (void)getConsultPharmacMyFavListWithDic:(NSMutableDictionary *)dic success:(GetMyFavPharmacyListSuccessBlock)successBlock fail:(GetMyFavPharmacyListFailBlock)failBlock;

@end
