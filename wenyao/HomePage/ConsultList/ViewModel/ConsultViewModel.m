//
//  ConsultViewModel.m
//  wenyao
//
//  Created by chenzhipeng on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "ConsultViewModel.h"
#import "DataBase.h"
#import "AppDelegate.h"
#import "NSObject+SBJson.h"
#import "HTTPRequestManager+ConsultPharmacy.h"
@implementation ConsultViewModel

- (void)getNearPharmacyListWithCount:(NSInteger)count Latitude:(CGFloat)latitude Longitude:(CGFloat)longitude CityName:(NSString *)strCity ProvinceName:(NSString *)strProvince
{
    HTTPRequestManager *httpManager = [HTTPRequestManager sharedInstance];
    NSMutableDictionary *dicParas = [@{} mutableCopy];
    dicParas[@"longitude"] = [NSString stringWithFormat:@"%f",longitude];
    dicParas[@"latitude"] = [NSString stringWithFormat:@"%f",latitude];
    dicParas[@"city"] = strCity;
    dicParas[@"province"] = strProvince;
    NSLog(@"the dic is %@",dicParas);
    if (self.arrNearPharmacyList == nil) {
        self.arrNearPharmacyList = [@[] mutableCopy];
    }
    __weak ConsultViewModel *weakSelf = self;
    [httpManager getConsultPharmacyNearListWithDic:dicParas count:5 success:^(id objResponse) {
        if (weakSelf && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ConsultPharmacySuccessWithTag:)]) {
            NSLog(@"%@",objResponse);
            if ([objResponse[@"result"] isEqualToString:@"OK"]) {
                NSArray *arrList = objResponse[@"body"][@"list"];
                weakSelf.arrNearPharmacyList = [arrList mutableCopy];
                [app.cacheBase removeAllNearPharmacyList];
                [self cacheNearPharmacyList:arrList];
                [weakSelf.delegate ConsultPharmacySuccessWithTag:ConsultPharmacyNearList];
            } else {
                if (weakSelf && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ConsultPharmacyFailWithTag:msg:)]) {
                    [weakSelf.delegate ConsultPharmacyFailWithTag:ConsultPharmacyNearList msg:objResponse[@"result"]];
                }
            }
        }
    } fail:^(NSInteger errorCode, NSString *strResponse) {
        if (weakSelf && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ConsultPharmacyFailWithTag:msg:)]) {
            [weakSelf.delegate ConsultPharmacyFailWithTag:ConsultPharmacyNearList msg:strResponse];
        }
    }];
}

- (void)getMyFavPharmacyListWithCount:(NSInteger)count page:(NSInteger)page token:(NSString *)strToken
{
    HTTPRequestManager *httpManager = [HTTPRequestManager sharedInstance];
    NSMutableDictionary *dicParas = [@{} mutableCopy];
    dicParas[@"token"] = strToken;
    dicParas[@"currPage"] = [NSString stringWithFormat:@"%ld",(long)page];
    dicParas[@"pageSize"] = [NSString stringWithFormat:@"%ld",(long)count];
    NSLog(@"the dic is %@",dicParas);
    if (self.arrMyFavPharmacyList == nil) {
        self.arrMyFavPharmacyList = [@[] mutableCopy];
    }
//    if (self.arrMyFavPharmacyList.count > 0) {
//        return;
//    }
    __weak ConsultViewModel *weakSelf = self;
    [httpManager getConsultPharmacMyFavListWithDic:dicParas success:^(id objResponse) {
        if (weakSelf && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ConsultPharmacySuccessWithTag:)]) {
            NSLog(@"%@",objResponse);
            if ([objResponse[@"result"] isEqualToString:@"OK"]) {
                NSArray *arrList = objResponse[@"body"][@"list"];
                [weakSelf.arrMyFavPharmacyList addObjectsFromArray:arrList];
                if (page == 1) {
                    [app.dataBase removeAllMyFavStoreList];
                }
                if (arrList.count > 0) {
                    [weakSelf cacheMyPharmacyList:arrList];
                }
                [weakSelf.delegate ConsultPharmacySuccessWithTag:ConsultPharmacyMyFav];
            } else {
                if (weakSelf && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ConsultPharmacyFailWithTag:msg:)]) {
                    [weakSelf.delegate ConsultPharmacyFailWithTag:ConsultPharmacyMyFav msg:objResponse[@"result"]];
                }
            }
        }
    } fail:^(NSInteger errorCode, NSString *strResponse) {
        if (weakSelf && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(ConsultPharmacyFailWithTag:msg:)]) {
            [weakSelf.delegate ConsultPharmacyFailWithTag:ConsultPharmacyMyFav msg:strResponse];
        }
    }];
}

- (void)getCachedMyFavPharmacyList
{
    self.arrMyFavPharmacyList = [[app.dataBase queryAllMyFavStoreList] mutableCopy];
}

- (void)getCachedNearPharmacyList
{
    self.arrNearPharmacyList = [[app.cacheBase quearAllConsultNearPharmacy] mutableCopy];
}

- (void)cacheMyPharmacyList:(NSArray *)arrMyPharmacyList
{
    for(NSDictionary *dic in arrMyPharmacyList)
    {
        NSString *storeId = dic[@"id"];
        NSString *accountId = dic[@"accountId"];
        NSString *name = dic[@"name"];
        NSString *star = [NSString stringWithFormat:@"%@",dic[@"star"]];
        NSString *avgStar = [NSString stringWithFormat:@"%@",dic[@"avgStar"]];
        NSString *consult = [NSString stringWithFormat:@"%@",dic[@"consult"]];
        NSString *accType = [NSString stringWithFormat:@"%@",dic[@"accType"]];
        NSString *tel = dic[@"tel"];
        NSString *province = dic[@"province"];
        NSString *city = dic[@"city"];
        NSString *county = dic[@"county"];
        NSString *addr = dic[@"addr"];
        NSString *distance = [NSString stringWithFormat:@"%@",dic[@"distance"]];
        NSString *imgUrl = dic[@"imgUrl"];
        NSString *shortName = dic[@"shortName"];
        NSString *tags = [dic[@"tags"] JSONRepresentation];
        [app.dataBase myFavStoreList:storeId
                                name:name
                                star:star
                             avgStar:avgStar
                             consult:consult
                             accType:accType
                                 tel:tel
                            province:province
                                city:city
                              county:county
                                addr:addr
                            distance:distance
                              imgUrl:imgUrl
                           accountId:accountId
                                tags:tags
                           shortName:shortName];
    }
}

- (void)cacheNearPharmacyList:(NSArray *)arrPharmacyList
{
    for (NSDictionary *dicPharmacy in arrPharmacyList) {
        [app.cacheBase insertIntoConsultNearPharmacyWithDic:dicPharmacy];
    }
}

@end
