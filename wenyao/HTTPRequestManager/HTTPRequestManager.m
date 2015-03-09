//
//  HTTPRequestManager.m
//  quanzhi
//
//  Created by xiezhenghong on 14-5-31.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "HTTPRequestManager.h"
#import "Constant.h"
#import "AFNetworking.h"
#import "NSString+MD5HexDigest.h"
#import "SBJson.h"

@implementation HTTPRequestManager

static HTTPRequestManager* shareHttpRequestManager = nil;

+ (HTTPRequestManager *)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        shareHttpRequestManager = [[HTTPRequestManager alloc] init];
    });
    return shareHttpRequestManager;
}

- (NSDictionary *)secretBuild:(NSDictionary *)dataSource
{
    NSMutableDictionary *build = [dataSource mutableCopy];
    build[@"version"] = APP_VERSION;
    NSArray *keys = [build allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableString *sign = [NSMutableString string];
    for(NSString *key in sortedArray)
    {
        [sign appendString:key];
        if([build[key] isKindOfClass:[NSArray class]] || [build[key] isKindOfClass:[NSMutableArray class]])
        {
            NSArray *array = build[key];
            [sign appendString:[array JSONRepresentation]];
        }else{
            [sign appendString:[NSString stringWithFormat:@"%@",build[key]]];
        }
    }
    sign = [NSMutableString stringWithFormat:@"%@%@%@",@"quanwei",sign,@"quanwei"];
    build[@"sign"] = [sign md5HexDigest];
    return build;
}

- (NSDictionary *)secretBuild:(NSDictionary *)dataSource withVersion:(NSString *)version{
    NSMutableDictionary *build = [dataSource mutableCopy];
    build[@"version"] = version;
    NSArray *keys = [build allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableString *sign = [NSMutableString string];
    for(NSString *key in sortedArray)
    {
        [sign appendString:key];
        if([build[key] isKindOfClass:[NSArray class]] || [build[key] isKindOfClass:[NSMutableArray class]])
        {
            NSArray *array = build[key];
            [sign appendString:[array JSONRepresentation]];
        }else{
            [sign appendString:[NSString stringWithFormat:@"%@",build[key]]];
        }
    }
    sign = [NSMutableString stringWithFormat:@"%@%@%@",@"quanwei",sign,@"quanwei"];
    build[@"sign"] = [sign md5HexDigest];
    return build;
}

//3.5.32	根据药店账号获取机构信息
-(void)queryBranhGroupByStoreAcc:(NSDictionary *)condition
                      completion:(SuccessBlock)success
                         failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryBranhGroupByStoreAcc parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.7.4	检查会话是否评价过
-(void)appraiseExist:(NSDictionary *)condition
          completion:(SuccessBlock)success
             failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:AppraiseExist parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


//3.9.3 健康知识 (2.1接口)  Create By Lijian

-(void)findKnowledge:(NSDictionary *)condition
       completionSuc:(SuccessBlock)success
             failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:HealthyKnowledge parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success){
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure){
            failure(error);
        }
    }];
}

//3.15.7 查询当前可用优惠券 (2.1接口)  Create By Lijian
-(void)couponList:(NSDictionary *)condition
       completionSuc:(SuccessBlock)success
             failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:CouponList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
    
}

//3.15.2 查询优惠活动从扫码页面进入 (2.1接口)  Create By Lijian
-(void)couponScan:(NSDictionary *)condition
    completionSuc:(SuccessBlock)success
          failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:CouponScan parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
    
}

// 3.15.3查询优惠活动从优惠详情页面跳入 (2.1接口)  Create By Lijian
-(void)couponScanFromDetail:(NSDictionary *)condition
    completionSuc:(SuccessBlock)success
          failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:CouponScanFromDetail parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
    
}

//(3.15.6) 查询指定优惠券关联商品列表 (2.1接口)  Create By Lijian
-(void)couponDrugs:(NSDictionary *)condition
     completionSuc:(SuccessBlock)success
           failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:CouponBranch parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

-(void)checkPriceAndCount:(NSDictionary *)condition
            completionSuc:(SuccessBlock)success
                  failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:CheckPriceAndCount parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
    
}

//  查询指定优惠活动关联的药店列表
-(void)CouponStoreCollectList:(NSDictionary *)condition
               completionSuc:(SuccessBlock)success
                     failure:(ResultFialBlock)failure{
    
        condition = [self secretBuild:condition];
        __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        [manager POST:CouponStores parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if(success)
                success(responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(failure)
                failure(error);
        }];
    
}
//3.13.7	推送设置
-(void)pushSet:(NSDictionary *)condition
    completion:(SuccessBlock)success
       failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:PushSet parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

-(void)checkCert:(NSDictionary *)condition
      completion:(SuccessBlock)success
         failure:(ResultFialBlock)failure
{
      NSLog(@"%@",condition);
    condition = [self secretBuild:condition];
  
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:CheckCert parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}




//3.10.3	删除IM聊天记录
-(void)deleteIM:(NSDictionary *)condition
     completion:(SuccessBlock)success
        failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:DeleteIM parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.10.2	添加会话记录（全维官方-客户）
-(void)addQWIM:(NSDictionary *)condition
    completion:(SuccessBlock)success
       failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:AddQWIM parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.11.3	获取ios审核状态
-(void)checkReviewStatus:(NSDictionary *)condition
              completion:(SuccessBlock)success
                 failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:SelectQWIM parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}



//3.10.5	查询全维药事聊天记录
-(void)selectQWIM:(NSDictionary *)condition
       completion:(SuccessBlock)success
          failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:SelectQWIM parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


//3.10.4	查询IM聊天记录
-(void)selectIM:(NSDictionary *)condition
     completion:(SuccessBlock)success
        failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:SelectIM parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.5.7	校验TOKEN是否有效
- (void)tokenValid:(NSDictionary *)condition
        completion:(SuccessBlock)success
           failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:TokenValid parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.10.5	查询全维药事聊天记录
-(void)selectqw:(NSDictionary *)condition
     completion:(SuccessBlock)success
        failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:SelectQW parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


//3.9.1	健康方案列表
- (void)queryRecommendClass:(NSDictionary *)condition
                 completion:(SuccessBlock)success
                    failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryRecommendClass parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.6.1	营销活动列表
- (void)queryBranchActivity:(NSDictionary *)condition
                 completion:(SuccessBlock)success
                    failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryBranchActivity parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.13.8 App是否后台状态设置
- (void)systemBackSet:(NSDictionary *)condition
           completion:(SuccessBlock)success
              failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:SystemBackSet parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


//3.7.1	添加药店评价
- (void)addAppraise:(NSDictionary *)condition
         completion:(SuccessBlock)success
            failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:AddAppraise parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.11.4	开通城市检查
-(void)checkOpenCity:(NSDictionary *)condition
          completion:(SuccessBlock)success
             failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:OpencityCheck parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.6.7GetActivity
-(void)getActivity:(NSDictionary *)condition
        completion:(SuccessBlock)success
           failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:GetActivity parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
        
    }];
}


//3.11.4	搜索附近药店
-(void)searchRegionPharmacy:(NSDictionary *)condition
         completion:(SuccessBlock)success
            failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:Regionwide parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.7.2	药店评价列表
- (void)queryAppraise:(NSDictionary *)condition
           completion:(SuccessBlock)success
              failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryAppraise parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.11.1 全国范围内查询药店列表     (已经更换2.0版本 by解)
- (void)nationwide:(NSDictionary *)condition
        completion:(SuccessBlock)success
           failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:Nationwide parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.11.2	区域范围内搜索药店    (已经更换2.0版本 by解)
- (void)regionwide:(NSDictionary *)condition
        completion:(SuccessBlock)success
           failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:Regionwide parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.11.3    药店开通城市    (已经更换2.0版本 by解)
- (void)queryOpenCity:(NSDictionary *)condition
           completion:(SuccessBlock)success
              failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:OpenCity parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.11.4	查询药店简要信息    (已经更换2.0版本 by解)
- (void)storeSearch:(NSDictionary *)condition
         completion:(SuccessBlock)success
            failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:StoreSearch parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.11.5	药店标签    (已经更换2.0版本 by解)
- (void)storeTag:(NSDictionary *)condition
      completion:(SuccessBlock)success
         failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:StoreTag parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.12.1	举报药店    (已经更换2.0版本 by解)
- (void)storeComplaint:(NSDictionary *)condition
            completion:(SuccessBlock)success
               failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:StoreComplaint parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.12.2	查询举报类型  (已经更换2.0版本 by解)
- (void)queryComplaintType:(NSDictionary *)condition
                completion:(SuccessBlock)success
                   failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:StoreQueryComplaintType parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.12.3	查询举报反馈结果  (已经更换2.0版本 by解)
- (void)queryComplaintOfficial:(NSDictionary *)condition
                    completion:(SuccessBlock)success
                       failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryComplaintofficial parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}











//健康项查询
- (void)queryHealthProgram:(NSDictionary *)condition
                completion:(SuccessBlock)success
                   failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryHealthProgram parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//加载主页上的滚动视图
- (void)loadRollingImageDataSource:(NSDictionary *)condition
                        completion:(SuccessBlock)success
                           failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:THEMEList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//获取家庭药箱列表
- (void)queryDrugBoxList:(NSDictionary *)condition
              completion:(SuccessBlock)success
                 failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryDrugBoxList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//添加健康记录人
- (void)saveRecordDoser:(NSDictionary *)condition
              completion:(SuccessBlock)success
                 failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:SaveRecordDoser parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//健康记录人删除
- (void)deleteRecordDoser:(NSDictionary *)condition
             completion:(SuccessBlock)success
                failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:DeleteRecordDoser parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//获取健康人列表
- (void)fetchRecordDoserList:(NSDictionary *)condition
               completion:(SuccessBlock)success
                  failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:FetchRecordDoserList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//搜索药品关键字联想     (已经更换2.0版本 by解)
- (void)getSearchKeywords:(NSDictionary *)condition
                  completion:(SuccessBlock)success
                     failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:GetSearchKeywords parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}



//搜索药品关键字联想     (已经更换2.0版本 by解)
- (void)queryDiseaseKeyword:(NSDictionary *)condition
               completion:(SuccessBlock)success
                  failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition withVersion:APP_VERSION_1_4_0];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryDiseaseKeyword parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


//根据id获取每一个药箱的详细信息
- (void)queryDBoxProductList:(NSDictionary *)condition
              completion:(SuccessBlock)success
                 failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryDBoxProductList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.1.1	查询我的用药列表       (已经更换2.0版本 by解)
- (void)queryMyBox:(NSDictionary *)condition
        completion:(SuccessBlock)success
           failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryMyBox parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.1.2	根据关键字查询我的用药      (已经更换2.0版本 by解)
- (void)queryBoxByKeyword:(NSDictionary *)condition
               completion:(SuccessBlock)success
                  failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryBoxByKeyword parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.1.3	根据标签查询我的用药      (已经更换2.0版本 by解)
- (void)queryBoxByTag:(NSDictionary *)condition
           completion:(SuccessBlock)success
              failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryBoxByTag parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.1.4	添加更新我的用药      (已经更换2.0版本 by解)
- (void)saveOrUpdateMyBox:(NSDictionary *)condition
               completion:(SuccessBlock)success
                  failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:SaveOrUpdateMyBox parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.10.3	获取所有未接收的会话记录
-(void)heartBeat:(NSDictionary *)condition
      completion:(SuccessBlock)success
         failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:HeartBeat parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.10.3	获取所有未接收的会话记录
-(void)alternativeIMSelect:(NSDictionary *)condition
                completion:(SuccessBlock)success
                   failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:AlternativeIMSelect parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


//3.10.25	设置IM消息状态已接受
-(void)imSetReceived:(NSDictionary *)condition
          completion:(SuccessBlock)success
             failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:IMSetReceived parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}



//3.10.10	删除指定药店/客户的IM聊天记录
-(void)delAllMessages:(NSDictionary *)condition
           completion:(SuccessBlock)success
              failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:DelAllMessage parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}



//3.1.5	用药详情      (已经更换2.0版本 by解)
- (void)getBoxProductDetail:(NSDictionary *)condition
                 completion:(SuccessBlock)success
                    failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:GetBoxProductDetail parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.1.6	删除我的用药      (已经更换2.0版本 by解)
- (void)deleteBoxProduct:(NSDictionary *)condition
              completion:(SuccessBlock)success
                 failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:DeleteBoxProduct parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.1.7	更新用药的药效的标签      (已经更换2.0版本 by解)
- (void)updateBoxProductTag:(NSDictionary *)condition
              completion:(SuccessBlock)success
                 failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:UpdateBoxProductTag parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.1.8	同效药品列表      (已经更换2.0版本 by解)
- (void)similarDrug:(NSDictionary *)condition
         completion:(SuccessBlock)success
            failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:SimilarDrug parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.1.9	我的用药所有标签
- (void)queryAllTags:(NSDictionary *)condition
          completion:(SuccessBlock)success
             failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryAllTags parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.10.4	删除IM聊天记录
- (void)deleteI:(NSDictionary *)condition
     completion:(SuccessBlock)success
        failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:DeleteI parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//根据关键字搜索药品名称   (已经更换2.0版本 by解)
- (void)queryProductByKeyword:(NSDictionary *)condition
                  completion:(SuccessBlock)success
                     failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryProductByKeyword parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//app最新版本查询
- (void)getLastVersion:(NSDictionary *)condition
            completion:(SuccessBlock)success
               failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:GetLastVersion parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


//会员卡查询
- (void)queryMbrCardByPassport:(NSDictionary *)condition
                   completion:(SuccessBlock)success
                      failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryMbrCardByPassport parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//会员卡取消关联
- (void)cancelRelatedMbrCard:(NSDictionary *)condition
                    completion:(SuccessBlock)success
                       failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:CancelRelatedMbrCard parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//扫码获取商品信息
- (void)queryProductByBarCode:(NSDictionary *)condition
                   completion:(SuccessBlock)success
                      failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryProductByBarCode parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//消费记录删除
- (void)deleteConsume:(NSDictionary *)condition
                 completion:(SuccessBlock)success
                    failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:DeleteConsume parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//部位查询
- (void)querySpmBody:(NSDictionary *)condition
          completion:(SuccessBlock)success
             failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QuerySpmBody parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//根据关键字搜索症状
- (void)querySpmByKeyword:(NSDictionary *)condition
               completion:(SuccessBlock)success
                  failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QuerySpmByKeyword parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//药箱商品用药记录
- (void)fetchDBoxProductRecord:(NSDictionary *)condition
           completion:(SuccessBlock)success
              failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:FetchDBoxProductRecord parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//收藏功能
- (void)collectFunction:(NSDictionary *)condition
                    completion:(SuccessBlock)success
                       failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:CollectFunction parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//查询喜欢的数量
- (void)getLikeNumber:(NSDictionary *)condition
             completion:(SuccessBlock)success
                failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:GetLikeNumber parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//查询喜欢资讯的数量
- (void)getHealthLikeNum:(NSDictionary *)condition
           completion:(SuccessBlock)success
              failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:GetHealthLikeNum parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//资讯喜欢+1
- (void)likeHealthCountsPlus:(NSDictionary *)condition
              completion:(SuccessBlock)success
                 failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:LikeHealthCountsPlus parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//资讯喜欢-1
- (void)likeHealthCountsDecrease:(NSDictionary *)condition
              completion:(SuccessBlock)success
                 failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:LikeHealthCountsDecrease parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//检查资讯是否已喜欢
- (void)checkHealthLike:(NSDictionary *)condition
              completion:(SuccessBlock)success
                 failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:CheckHealthLike parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
    
}

//记一笔保存
- (void)saveDrugRecord:(NSDictionary *)condition
           completion:(SuccessBlock)success
              failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:SaveDrugRecord parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


//获取某一天记一笔记录
- (void)getDrugRecordDetail:(NSDictionary *)condition
              completion:(SuccessBlock)success
                 failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:GetDrugRecordDetail parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//获取用药历史信息
- (void)getDrugRecordHistory:(NSDictionary *)condition
                 completion:(SuccessBlock)success
                    failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:GetDrugRecordHistory parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//健康资讯分类查询
- (void)getHealthAdviceTypeList:(NSDictionary *)condition
                  completion:(SuccessBlock)success
                     failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:GetHealthAdviceTypeList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.2.2 健康咨询列表查询 (已经更换2.0版本 by解)
- (void)queryHealthAdviceList:(NSDictionary *)condition
                   completion:(SuccessBlock)success
                      failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryHealthAdviceList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//健康资讯详情
- (void)getHealthAdviceInfo:(NSDictionary *)condition
                 completion:(SuccessBlock)success
                    failure:(FailureBlock)failure
{
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryHealthAdviceInfo parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//健康资讯内容
- (void)getHealthAdviceContent:(NSDictionary *)condition
                    completion:(SuccessBlock)success
                       failure:(FailureBlock)failure
{
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *strUrl = @"http://m.api.sit.qwysfw.cn/app/healthinfo/getAdviceContent?adviceId=e1ce9f77833d4665976df34ca764b434";//[NSString stringWithFormat:@"%@%@",QueryHealthAdviceContent,condition];
    NSLog(@"the str url is %@",QueryHealthAdviceContent);
    
    [manager GET:strUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            NSLog(@"response object %@",responseObject);
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.2.1	健康资讯栏目列表 (已经更换2.0版本 by解)
- (void)queryChannelList:(NSDictionary *)condition
              completion:(SuccessBlock)success
                 failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryChannelList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.14.2 常见问题类型
- (void)queryFamiliarQuestionChannelList:(NSDictionary *)condition
                              completion:(SuccessBlock)success
                                 failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryFamiliarQuestionChannel parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

//3.14.3 常见用药问题列表
- (void)QueryFamiliarQuestionlist:(NSDictionary *)condition
                       completion:(SuccessBlock)success
                          failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryFamiliarQuestionList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

//3.14.4 问题详情
- (void)QueryFamiliarQuestiondetail:(NSDictionary *)condition
                         completion:(SuccessBlock)success
                            failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryFamiliarQuestionDetail parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

//3.5.50 获取推荐人手机号

- (void)QueryCommendPersonPhoneNumber:(NSDictionary *)condition
                           completion:(SuccessBlock)success
                              failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryCommendPersonPhone parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

//3.5.51 更新推荐人手机号

- (void)QueryCimmitPersonPhoneNumber:(NSDictionary *)condition
                          completion:(SuccessBlock)success
                             failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryCimmitPersonPhone parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}



//3.2.3	根据栏目获取Banner (已经更换2.0版本 by解)
- (void)queryChannelBanner:(NSDictionary *)condition
                completion:(SuccessBlock)success
                   failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryChannelBanner parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];

}

//3.5.14	添加,取消收藏
- (void)favoriteCollect:(NSDictionary *)condition
             completion:(SuccessBlock)success
                failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_FavoriteCollect parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
    
}


//3.2.4	阅读数+1          (已经更换2.0版本 by解)
- (void)readAdvice:(NSDictionary *)condition
        completion:(SuccessBlock)success
           failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:ReadAdvice parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//点赞数 - 1
- (void)cancelPraiseAdvice:(NSDictionary *)condition
                completion:(SuccessBlock)success
                   failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:CancelPraiseAdvice parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.2.5	点赞数+1          (已经更换2.0版本 by解)
- (void)praiseAdvice:(NSDictionary *)condition
        completion:(SuccessBlock)success
           failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:PraiseAdvice parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.2.6	获取慢病指导项列表信息    (已经更换2.0版本 by解)
- (void)queryAttentionList:(NSDictionary *)condition
          completion:(SuccessBlock)success
             failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryAttentionList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.2.7	添加慢病指导      (已经更换2.0版本 by解)
- (void)saveDrugGuideItem:(NSDictionary *)condition
                completion:(SuccessBlock)success
                   failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:SaveDrugGuideItem parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error is %@",[error description]);
        if(failure)
            failure(error);
    }];
}

//3.2.11	删除慢病指导
- (void)deleteMsgDrugGuide:(NSDictionary *)condition
                completion:(SuccessBlock)success
                   failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:DeleteMsgDrugGuide parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.2.8	查询已添加的慢病指导项    (已经更换2.0版本 by解)
- (void)getChronicDiseaseItemList:(NSDictionary *)condition
               completion:(SuccessBlock)success
                  failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:GetChronicDiseaseItemList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.2.9	查询慢病指导列表    (已经更换2.0版本 by解)
- (void)getDrugGuideList:(NSDictionary *)condition
              completion:(SuccessBlock)success
                 failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:GetDrugGuideList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.2.7	检查是否已经点赞
- (void)checkPraiseAdvice:(NSDictionary *)condition
               completion:(SuccessBlock)success
                  failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:CheckPraiseAdvice parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


//3.2.10  慢病指导跟踪服务分页列表   (已经更换2.0版本 by解)
- (void)queryMsgLogList:(NSDictionary *)condition
              completion:(SuccessBlock)success
                 failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryMsgLogList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.9.2	健康方案内容商品列表        (已经更换2.0版本 by解)
- (void)queryRecommendProductByClass:(NSDictionary *)condition
                          completion:(SuccessBlock)success
                             failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryRecommendProductByClass parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}










//查询喜欢的数量
- (void)checkLike:(NSDictionary *)condition
           completion:(SuccessBlock)success
              failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:CheckLike parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//跟踪服务明细查询
- (void)fetchMsgLogDetail:(NSDictionary *)condition
               completion:(SuccessBlock)success
                  failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:FetchMsgLogDetail parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}



//喜欢的数量加1
- (void)likeCountsPlus:(NSDictionary *)condition
       completion:(SuccessBlock)success
          failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:LikeCountsPlus parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//喜欢的数量-1
- (void)likeCountsDecrease:(NSDictionary *)condition
            completion:(SuccessBlock)success
               failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:LikeCountsDecrease parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}



//获取疾病分类
- (void)quertDiseaseClass:(NSDictionary *)condition
               completion:(SuccessBlock)success
                  failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QUERYDiseaseClass parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//获取药箱商品的单位列表
- (void)getUnitList:(NSDictionary *)condition
               completion:(SuccessBlock)success
                  failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:GetUnitList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//添加一个新的药箱商品
- (void)saveDBoxProduct:(NSDictionary *)condition
             completion:(SuccessBlock)success
                failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:SaveDBoxProduct parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//精品应用列表
- (void)goodAppList:(NSDictionary *)condition
         completion:(SuccessBlock)success
            failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition withVersion:APP_VERSION];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:GoodAppList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


//记录关键词搜索日志
- (void)saveSearchLog:(NSDictionary *)condition
           completion:(SuccessBlock)success
              failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition withVersion:APP_VERSION_1_4_0];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:SaveSearchLog parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//记一笔的删除
- (void)deleteDrugRecord:(NSDictionary *)condition
             completion:(SuccessBlock)success
                failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:DeleteDrugRecord parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


//drug/queryProductByKwId       根据关键字id搜索商品
//drug/queryProductByKwIdCount  根据关键字id搜索商品记录数量
//disease/queryDiseaseKwId      根据关键字Id查询疾病
//disease/queryDiseaseKwIdCount 根据关键字id查询疾病记录数量
//spm/querySpmByKwId            根据关键字id查询症状
//spm/querySpmByKwIdCount       根据关键字id查询症状记录数量

- (void)queryProductByKwId:(NSDictionary *)condition
                completion:(SuccessBlock)success
                   failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryProductByKwId parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

- (void)queryProductByKwIdCount:(NSDictionary *)condition
                     completion:(SuccessBlock)success
                        failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryProductByKwIdCount parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

- (void)queryDiseaseKwId:(NSDictionary *)condition
              completion:(SuccessBlock)success
                 failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryDiseaseKwId parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

- (void)queryDiseaseKwIdCount:(NSDictionary *)condition
                   completion:(SuccessBlock)success
                      failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryDiseaseKwIdCount parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

- (void)querySpmByKwId:(NSDictionary *)condition
            completion:(SuccessBlock)success
               failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_querySpmByKwId parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

- (void)querySpmByKwIdCount:(NSDictionary *)condition
                 completion:(SuccessBlock)success
                    failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_querySpmByKwIdCount parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

- (void)queryDiseaseDetailIos:(NSDictionary *)condition
                   completion:(SuccessBlock)success
                      failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryDiseaseDetailIos parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


//添加一个新的药箱
- (void)saveDBox:(NSDictionary *)condition
         completion:(SuccessBlock)success
            failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:SaveDBox parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//删除一个药箱商品
- (void)deleteDBoxProduct:(NSDictionary *)condition
        completion:(SuccessBlock)success
           failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:DeleteDBoxProduct parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//删除一个药箱
- (void)deleteDBox:(NSDictionary *)condition
      completion:(SuccessBlock)success
         failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:DeleteDBox parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


//消费药店列表查询
- (void)queryConsumeStoreList:(NSDictionary *)condition
              completion:(SuccessBlock)success
                 failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryConsumeStoreList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//消费历史查询
- (void)queryConsumeList:(NSDictionary *)condition
            completion:(SuccessBlock)success
                      failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryConsumeList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//消费明细查询
- (void)queryConsumeDetail:(NSDictionary *)condition
              completion:(SuccessBlock)success
                 failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryConsumeDetail parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}



//获取最近两天的跟踪服务消息
- (void)fetchRecentMsgLog:(NSDictionary *)condition
                 completion:(SuccessBlock)success
                    failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:FetchRecentMsgLog parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


//查询商品使用效果
- (void)fetchAppraiseDetail:(NSDictionary *)condition
                completion:(SuccessBlock)success
                   failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:FetchAppraiseDetail parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//保存商品评价
- (void)saveDBoxAppraise:(NSDictionary *)condition
              completion:(SuccessBlock)success
                 failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:SaveDBoxAppraise parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//查询商品明细,带index
- (void)queryProductDetail:(NSDictionary *)condition
                completion:(SuccessBlockIndex)success
                   failure:(FailureBlockIndex)failure
                     index:(NSUInteger)index
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryProductDetail parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject,index);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error,index);
    }];
}

//查询商品明细
- (void)queryProductDetail:(NSDictionary *)condition
              completion:(SuccessBlock)success
                 failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryProductDetail parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//添加IOS设备
- (void)addIosDevice:(NSDictionary *)condition
                completion:(SuccessBlock)success
                   failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:AddIosDevice parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//取消IOS设备
- (void)deleteIosDevice:(NSDictionary *)condition
          completion:(SuccessBlock)success
             failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:DeleteIosDevice parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//查询商品扩展信息
- (void)queryProductExtInfo:(NSDictionary *)condition
                completion:(SuccessBlock)success
                   failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryProductExtInfo parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//通过短信码设置新密码
- (void)validVerifyCode:(NSDictionary *)condition
                 completion:(SuccessBlock)success
                    failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:ValidVerifyCode parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//我的商品收藏
- (void)queryProductCollectList:(NSDictionary *)condition
                     completion:(SuccessBlock)success
                        failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QueryProductCollectList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//当月健康记录数统计
- (void)getMonthlyCount:(NSDictionary *)condition
             completion:(SuccessBlock)success
                failure:(FailureBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:GetMonthlyCount parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


//zhangpanADD 
-(void)httpPostRequsetWithURL:(NSString *)URL
                        Param:(NSDictionary *)condition
                completionSuc:(SuccessBlock)success
                   reusltFail:(ResultFialBlock)resultFail
                      failure:(FailureBlock)failure

{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:URL parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            if ([((NSString *)responseObject[@"result"]) isEqualToString:@"OK"]) {
                success(responseObject[@"body"]);
            }else
            {
                resultFail(responseObject[@"msg"]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}
//ADD By Meng
-(void)httpPostRequsetWithURL:(NSString *)URL
                        Param:(NSDictionary *)condition
                completionSuc:(SuccessBlock)success
                   reusltFail:(ResultFialBlock)resultFail
                      failure:(FailureBlock)failure
                  withVersion:(NSString *)version{
    condition = [self secretBuild:condition withVersion:APP_VERSION_1_4_0];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:URL parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            if ([((NSString *)responseObject[@"result"]) isEqualToString:@"OK"]) {
                success(responseObject[@"body"]);
            }else
            {
                resultFail(responseObject[@"msg"]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


//修改密码
-(void)modifyPassWordWithParam:(NSDictionary *)condition
                 completionSuc:(SuccessBlock)success
                       failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_updateLoginPassword parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            if ([((NSString *)responseObject[@"result"]) isEqualToString:@"OK"]) {
                success(responseObject[@"body"]);
            }else
            {
                failure(responseObject[@"msg"]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//注册校验手机号码是否已存在
-(void)checkPhoneNumWithParam:(NSDictionary *)condition
                completionSuc:(SuccessBlock)success
                      failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_registerValid parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief (3.5.4) 校验注册用户是否已存在 (2.0接口)  Create By Meng
 */
-(void)registerValid:(NSDictionary *)condition
       completionSuc:(SuccessBlock)success
             failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_registerValid parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.15.15	首页banner
-(void)promotionBanner:(NSDictionary *)condition
            completion:(SuccessBlock)success
               failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:PromotionBanner parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.11.3	查询附近药店
-(void)searchStoreOffer:(NSDictionary *)condition
             completion:(SuccessBlock)success
                failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:SearchRegionSize parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}



//3.14.1	问题模块列表
-(void)problemModule:(NSDictionary *)condition
          completion:(SuccessBlock)success
             failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:ProblemModule parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//发送验证码
-(void)sendVerifyCodeNumWithParam:(NSDictionary *)condition
                    completionSuc:(SuccessBlock)success
                          failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_sendVerifyCode parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            if ([((NSString *)responseObject[@"result"]) isEqualToString:@"OK"]) {
                success(responseObject[@"body"]);
            }else
            {
                failure(responseObject[@"msg"]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}
//验证验证码是否正确
-(void)checkVerifyCodeNumWithParam:(NSDictionary *)condition
                     completionSuc:(SuccessBlock)success
                           failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_validVerifyCode parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            if ([((NSString *)responseObject[@"result"]) isEqualToString:@"OK"]) {
                success(responseObject[@"body"]);
            }else
            {
                failure(responseObject[@"msg"]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//	图片上传接口




//注册会员
-(void)registUserWithParam:(NSDictionary *)condition
             completionSuc:(SuccessBlock)success
                   failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_register parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
        {
            if ([((NSString *)responseObject[@"result"]) isEqualToString:@"OK"]) {
                success(responseObject[@"body"]);
            }else
            {
                failure(responseObject[@"msg"]);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}
//end

//症状列表
-(void)getAllSymptomListWithParam:(NSDictionary *)condition
                    completionSuc:(SuccessBlock)success
                          failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_querySpmInfoList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}
//症状详细
-(void)symptomDetailWithParam:(NSDictionary *)condition
                completionSuc:(SuccessBlock)success
                      failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_spmInfoDetail parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}
//症状关联的疾病
-(void)associationDiseaseWithParam:(NSDictionary *)condition
                     completionSuc:(SuccessBlock)success
                           failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition withVersion:APP_VERSION_1_4_0];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryAssociationDisease parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/*!
 @brief 部位下关联症状
 */
-(void)querySpmInfoListByBodyWithParam:(NSDictionary *)condition
                         completionSuc:(SuccessBlock)success
                               failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_querySpmInfoListByBody parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


//症状收藏
-(void)spmCollectListWithParam:(NSDictionary *)condition
                 completionSuc:(SuccessBlock)success
                       failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_SpmCollect parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//疾病百科
- (void)queryAllDisease:(NSDictionary *)condition
             completion:(SuccessBlock)success
                failure:(FailureBlock)failure{
    condition = [self secretBuild:condition withVersion:APP_VERSION_1_4_0];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryAllDisease parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//通过关键字搜索药品
- (void)searchByKeyword:(NSDictionary *)condition
                     completion:(SuccessBlock)success
                        failure:(FailureBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_getSearchKeywords parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//通过关键字搜索疾病     (已经更换2.0版本 by解)
- (void)diseaseSearchByKeyword:(NSDictionary *)condition
                    completion:(SuccessBlock)success
                       failure:(FailureBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryDiseaseKeyword parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}
//通过关键字搜索症状
- (void)symptomSearchByKeyword:(NSDictionary *)condition
                    completion:(SuccessBlock)success
                       failure:(FailureBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:QuerySpmByKeyword parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//获取疾病的一级类别
- (void)queryProductClass:(NSDictionary *)condition
               completion:(SuccessBlock)success
                  failure:(FailureBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryProductClass parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}
//根据classId获取药品列表
- (void)queryProductByClass:(NSDictionary *)condition
                 completion:(SuccessBlock)success
                    failure:(FailureBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryProductByClass parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//获取生产厂家列表
- (void)queryFactoryList:(NSDictionary *)condition
              completion:(SuccessBlock)success
                 failure:(FailureBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_fetchProFactoryByClass parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}
//获取疾病分类列表
- (void)queryDiseaseClass:(NSDictionary *)condition
               completion:(SuccessBlock)success
                  failure:(FailureBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryDiseaseClass parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//获取疾病二级分类列表
- (void)queryDiseaseByClass:(NSDictionary *)condition
                 completion:(SuccessBlock)success
                    failure:(FailureBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryDiseaseByClass parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

- (void)readIMNum:(NSDictionary *)condition
       completion:(SuccessBlock)success
          failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:IMReadNum parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.1.10获取药品的用法用量信息
- (void)getProductUsage:(NSDictionary *)condition
             completion:(SuccessBlock)success
                failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:GetProductUsage parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

//3.13.9	药店端账号检测
-(void)checkToken:(NSDictionary *)condition
       completion:(SuccessBlock)success
          failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:CheckToken parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief (3.5.1) 登录 (2.0接口)  Create By Meng
 */
- (void)login:(NSDictionary *)condition completion:(SuccessBlock)success failure:(FailureBlock)failure{
    condition = [self secretBuild:condition];
    [MobClick event:@"d-denglu"];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_login parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief (3.5.1) 登录 (2.0接口)  Create By Meng
 */
-(void)login:(NSDictionary *)condition completionSuc:(SuccessBlock)success reusltFail:(ResultFialBlock)resultFail
     failure:(FailureBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_login parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}
/**
 *  @brief (3.5.6) 发送手机验证码 (2.0接口)  Create By Meng
 */
- (void)sendVerifyCode:(NSDictionary *)condition
            completion:(SuccessBlock)success
               failure:(FailureBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_sendVerifyCode parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}
/**
 *  @brief (3.5.5) 注册用户 (2.0接口)  Create By Meng
 */
-(void)registUser:(NSDictionary *)condition
             completionSuc:(SuccessBlock)success
                   failure:(ResultFialBlock)failure{
    [MobClick event:@"d-zhuce"];
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_register parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}
/**
 *  @brief (3.5.7) 校验手机验证码 (2.0接口)  Create By Meng
 */
-(void)validVerifyCode:(NSDictionary *)condition
         completionSuc:(SuccessBlock)success
               failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_validVerifyCode parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief (3.5.3) 重置密码 (2.0接口)  Create By Meng
 */
-(void)resetPassword:(NSDictionary *)condition
       completionSuc:(SuccessBlock)success
             failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_resetPassword parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief (3.5.10) 更改手机 (2.0接口)  Create By Meng
 */
-(void)changeMobile:(NSDictionary *)condition
      completionSuc:(SuccessBlock)success
            failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_changeMobile parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief (3.5.8) 获取账号用户资料 (2.0接口)  Create By Meng
 */
-(void)queryMemberDetail:(NSDictionary *)condition
           completionSuc:(SuccessBlock)success
                 failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryMemberDetail parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief (3.5.2) 修改密码 (2.0接口)  Create By Meng
 */
-(void)updatePassword:(NSDictionary *)condition
        completionSuc:(SuccessBlock)success
              failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_updatePassword parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief (3.5.14) 药品收藏 (2.0接口)  Create By Meng
 */
-(void)favoriteProductCollectList:(NSDictionary *)condition
                    completionSuc:(SuccessBlock)success
                          failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_favoriteProductCollectList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}
/**
 *  @brief (3.4.1) 添加反馈 (2.0接口)  Create By Meng
 */
-(void)submitFeedback:(NSDictionary *)condition
        completionSuc:(SuccessBlock)success
              failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_submitFeedback parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief (3.8.1) 附近药店列表 (2.0接口)  Create By Meng
 */
-(void)fetchDefaultPharmacy:(NSDictionary *)condition
              completionSuc:(SuccessBlock)success
                    failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_fetchDefaultPharmacy parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}
/**
 *  @brief (3.8.2) 获取省市区的编码 (2.0接口)  Create By Meng
 */
-(void)locationEncodeWithParam:(NSDictionary *)condition
                 completionSuc:(SuccessBlock)success
                       failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_locationEncode parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief (3.8.4) 通过药店编码获取药店详情 (2.0接口)  Create By Meng
 */
-(void)fetchPharmacyDetail:(NSDictionary *)condition
             completionSuc:(SuccessBlock)success
                   failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_fetchPharmacyDetail parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief (3.8.3) 获取药店区域畅销商品 (2.0接口)  Create By Meng
 */
-(void)fetchSellWellProducts:(NSDictionary *)condition
               completionSuc:(SuccessBlock)success
                     failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_drugSellList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief (3.5.9) 获取药店区域畅销商品 (2.0接口)  Create By Meng
 */
-(void)saveMemberInfo:(NSDictionary *)condition
        completionSuc:(SuccessBlock)success
              failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_saveMemberInfo parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief (3.3.17) 查询二级商品分类 (2.0接口)  Create By Meng
 */
-(void)querySecondProductClass:(NSDictionary *)condition
                 completionSuc:(SuccessBlock)success
                       failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_querySecondProductClass parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief (3.13.2) 公共的图片上传 (2.0接口)  Create By Meng
 */
-(void)uploadFile:(NSDictionary *)condition
    completionSuc:(SuccessBlock)success
          failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_uploadFile parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief (3.5.6) 用户登出 (2.0接口)  Create By Meng
 */
-(void)logout:(NSDictionary *)condition
completionSuc:(SuccessBlock)success
      failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_logout parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief (3.5.13) 获取症状收藏列表 (2.0接口)  Create By Meng
 */
-(void)querySpmCollectList:(NSDictionary *)condition
             completionSuc:(SuccessBlock)success
                   failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_querySpmCollectList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief (3.5.14) 获取疾病收藏列表 (2.0接口)  Create By Meng
 */
-(void)queryDiseaseCollectList:(NSDictionary *)condition
                 completionSuc:(SuccessBlock)success
                       failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryDiseaseCollectList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief (3.5.15) 获取信息收藏列表 (2.0接口)  Create By Meng
 */
-(void)queryAdviceCollectList:(NSDictionary *)condition
                completionSuc:(SuccessBlock)success
                      failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryAdviceCollectList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief 获取厂家详情 (2.0接口)  Create By Meng
 */
-(void)queryFactoryDetail:(NSDictionary *)condition
            completionSuc:(SuccessBlock)success
                  failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryFactoryDetail parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  @brief 获取药品列表详情 (2.0接口)  Create By Meng
 */
-(void)queryFactoryProductList:(NSDictionary *)condition
                 completionSuc:(SuccessBlock)success
                       failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryFactoryProductList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 * 最新版本查询 3.13.4
 */
-(void)queryLastVersion:(NSDictionary *)condition
                 completionSuc:(SuccessBlock)success
                       failure:(ResultFialBlock)failure{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_checkNewVersion parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  心跳接口 3.13.3
 */
- (void)queryHeartBeat:(NSDictionary *)condition
        completeionSuc:(SuccessBlock)success
               failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_heartBeat parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

/**
 *  健康资讯分享+1 3.2.20
 */
- (void)shareAdvice:(NSDictionary *)condition
     completeionSuc:(SuccessBlock)success
            failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_shareAdvice parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

- (void)queryDiseaseDetail:(NSDictionary *)condition
            completeionSuc:(SuccessBlock)success
                   failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryDiseaseDetail parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


- (void)queryDiseaseFormulaList:(NSDictionary *)condition
                 completeionSuc:(SuccessBlock)success
                        failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryDiseaseFormulaList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

- (void)queryDiseaseFormulaDetail:(NSDictionary *)condition
                   completeionSuc:(SuccessBlock)success
                          failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryDiseaseFormulaDetail parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

- (void)queryDiseaseFormulaProductList:(NSDictionary *)condition
                        completeionSuc:(SuccessBlock)success
                               failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryDiseaseFormulaProductList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


-(void)queryStoreCollectList:(NSDictionary *)condition
               completionSuc:(SuccessBlock)success
                     failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryStoreCollectList parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

-(void)promotionOrder:(NSDictionary *)condition
        completionSuc:(SuccessBlock)success
              failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_promotionOrder parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}


-(void)CheckCoupon:(NSDictionary *)condition
               completionSuc:(SuccessBlock)success
                     failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_checkOrdrBranch parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

-(void)CheckCouponDetail:(NSDictionary *)condition
     completionSuc:(SuccessBlock)success
           failure:(ResultFialBlock)failure
{
    condition = [self secretBuild:condition];
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_checkOrdrBranchInfo parameters:condition success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(success)
            success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failure)
            failure(error);
    }];
}

- (void)cancelAllHTTPRequest
{
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [[manager.operationQueue operations] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        AFHTTPRequestOperation *operation = (AFHTTPRequestOperation *)obj;
        [[operation connection] cancel];
    }];
    [manager.operationQueue cancelAllOperations];
}

- (void)cancelHTTPRequestWithURL:(NSString *)url
{
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [[manager.operationQueue operations] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        AFHTTPRequestOperation *operation = (AFHTTPRequestOperation *)obj;
        NSString *originUrl  = [NSString stringWithString:[[[operation request] URL] absoluteString]];
        if([originUrl hasPrefix:url])
        {
            [[operation connection] cancel];
        }
    }];
}

- (void)dealloc
{
    
}

@end
