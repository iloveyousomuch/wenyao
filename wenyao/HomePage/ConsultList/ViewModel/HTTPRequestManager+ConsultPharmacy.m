//
//  HTTPRequestManager+ConsultPharmacy.m
//  wenyao
//
//  Created by chenzhipeng on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "HTTPRequestManager+ConsultPharmacy.h"
#import "AFNetworking.h"
#import "Constant.h"

@implementation HTTPRequestManager (ConsultPharmacy)

- (void)getConsultPharmacyNearListWithDic:(NSMutableDictionary *)dic count:(NSInteger)count success:(GetNearPharmacyListSuccessBlock)successBlock fail:(GetNearPharmacyListFailBlock)failBlock
{
    dic[@"size"] = [NSString stringWithFormat:@"%ld",count];
    NSDictionary *condition = (NSDictionary *)dic;
    condition = [self secretBuild:condition];
    NSLog(@"the url is %@, the condition is %@", PharmacyNearListWithName, condition);
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:PharmacyNearListWithName parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(successBlock)
            successBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failBlock)
            failBlock(error.code, error.localizedDescription);
    }];
}

- (void)getConsultPharmacMyFavListWithDic:(NSMutableDictionary *)dic success:(GetMyFavPharmacyListSuccessBlock)successBlock fail:(GetMyFavPharmacyListFailBlock)failBlock
{
    NSDictionary *condition = (NSDictionary *)dic;
    condition = [self secretBuild:condition];
    NSLog(@"the url is %@, the condition is %@", NW_queryStoreCollectList, condition);
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryStoreCollectList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(successBlock)
            successBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failBlock)
            failBlock(error.code, error.localizedDescription);
    }];
}

@end
