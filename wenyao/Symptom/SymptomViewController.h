//
//  SymptomViewController.h
//  quanzhi
//
//  Created by Meng on 14-8-6.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseViewController.h"
#import "BATableView.h"
/*!  枚举
 @brief 页面来源
 */
typedef enum {
    wikiSym, //来自百科
    bodySym, //来自人体图
    searchSym //来自搜索
}type;

@interface SymptomViewController : BaseViewController<BATableViewDelegate>

@property (nonatomic ,assign) type requestType;

@property (nonatomic, strong) UIViewController  *containerViewController;
@property (nonatomic ,strong) NSString *spmCode;
@property (nonatomic, strong) NSDictionary  *requsetDic;
@property (nonatomic ,copy) __block void(^scrollBlock)(void);


@end
