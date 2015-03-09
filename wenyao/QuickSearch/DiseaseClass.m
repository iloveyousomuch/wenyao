//
//  DiseaseClass.m
//  quanzhi
//
//  Created by ZhongYun on 14-6-22.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "DiseaseClass.h"
#import "HTTPRequestManager.h"
#import "AFNetworking.h"

@interface DiseaseClass ()
{
    NSMutableArray* m_tree;
    NSMutableArray* m_list; //1,2级列表;
}
@end

@implementation DiseaseClass
+ (DiseaseClass*)shared
{
    static DiseaseClass* instance = nil;
    if (!instance) {
        instance = [[DiseaseClass alloc] init];
    }
    return instance;
}

- (id)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)initData
{
    if (m_tree != nil) {
        return;
    }
    
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryDiseaseClass
       parameters:@{@"currPage":@1,@"pageSize":@200}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              m_tree = [[NSMutableArray alloc] init];
              for (NSDictionary* item in responseObject[@"body"][@"data"]) {
                  [m_tree addObject:[item mutableCopy]];
              }
              
              for (NSMutableDictionary* item in m_tree) {
                  item[@"level"] = @1;
                  
                  if ([item[@"isFinalNode"] boolValue] == NO) {
                      [manager POST:NW_queryDiseaseClass
                         parameters:@{@"currClassId":item[@"classId"], @"currPage":@1, @"pageSize":@200}
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                item[@"sublist"] = [[NSMutableArray alloc] init];
                                for (NSDictionary* tmpitem in responseObject[@"body"][@"data"]) {
                                    [item[@"sublist"] addObject:[tmpitem mutableCopy]];
                                }
                                for (NSMutableDictionary* subitem in item[@"sublist"]) {
                                    subitem[@"level"]=@2;
                                }
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                            }];
                  }
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"%@", error);
          }];
}


- (NSMutableArray*)getTree:(NSMutableDictionary*)parent Resp:(void(^)(id))block
{
    if (parent == nil) {
        if (!m_tree) {
            [self loadTopLevel];
        }
        return m_tree;
    } else {
        if ([parent[@"isFinalNode"] boolValue] == YES) {
            return nil;
        }
        
        if (parent[@"sublist"] == nil) {
            [self loadNextLevel:parent Resp:block];
        }
        
        return parent[@"sublist"];
    }
    return nil;
}

- (NSMutableArray*)getList
{
    if (!m_tree) {
        [self loadTopLevel];
    }
    
    if (!m_list) {
        m_list = [[NSMutableArray alloc] init];
        for (NSMutableDictionary* item in m_tree) {
            item[@"level"] = @1;
            [m_list addObject:item];
            
            if ([item[@"isFinalNode"] boolValue] == NO) {
                //                if (item[@"sublist"] == nil) {
                //                    [self loadNextLevel:item];
                //                }
                
                for (NSMutableDictionary* subItem in item[@"sublist"]) {
                    subItem[@"level"] = @2;
                    [m_list addObject:subItem];
                }
            }
        }
    }
    return m_list;
}

- (void)loadTopLevel
{
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryDiseaseClass
       parameters:@{@"currPage":@1,@"pageSize":@200}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              m_tree = [[NSMutableArray alloc] initWithArray:responseObject[@"body"][@"data"]];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"%@", error);
          }];
}

- (void)loadNextLevel:(NSMutableDictionary*)parent Resp:(void(^)(id))block
{
    __block AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:NW_queryDiseaseClass
       parameters:@{@"currClassId":parent[@"classId"], @"currPage":@1, @"pageSize":@200}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              parent[@"sublist"] = [[NSMutableArray alloc] initWithArray:responseObject[@"body"][@"data"]];
              block(parent[@"sublist"]);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"%@", error);
          }];
}

@end
