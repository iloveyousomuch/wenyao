//
//  DataBase.m
//  iPhoneXMPP
//
//  Created by xiezhenghong on 14-3-10.
//
//

#import "DataBase.h"
#import "FMDatabase.h"
#import "XHMessageBubbleFactory.h"
#import "Constant.h"
@interface DataBase()
{
    FMDatabase *_db;
}
@end

@implementation DataBase
-(id)initWithPath:(NSString *)path
{
    
    path = [path stringByAppendingString:@"/MyDataBase.sqlite"];
    _db = [[FMDatabase alloc] initWithPath:path];
    NSLog(@"path is %@",path);
    if (![_db open])
    {
        
    }

    return self;
}

- (void)createCacheTable
{
//    id	药店ID
//    province	省（字典key）
//    provinceName	省名称
//    city	市（字典key）
//    cityName	市名称
//    open	是否开通(0:未开通,1:已开通)
//    remark	备注
//    code	城市名称首字母
//    current  1当前选择    0未选择

    BOOL result = [_db executeUpdate:@"create table if not exists CityList (id text,province text,provinceName text,city text,cityName text,open text,remark text,code text,current text default '0',unique(id))"];
    
    /*
     ### 健康资讯栏目列表 ###
     id  健康咨询列表channel id
     channelName 健康资讯channel name
     sort 健康咨询channel 排序
     */
    
    result = [_db executeUpdate:@"create table if not exists HealthInfoChannelList (id text,channelName text,sort int,unique(id))"];
    
    /*
     ### 健康资讯列表 ###
     adviceId  健康咨询 id
     channelId 外键，对应健康咨询列表id
     iconUrl 健康资讯iconUrl
     imgUrl 健康资讯imgUrl
     introduction 健康资讯介绍
     likeNumber 喜爱的个数
     pariseNum  点赞个数
     publishTime  发布时间
     readNum   阅读数
     title      标题
     publiser   发布者
     source     来源
     */
    result = [_db executeUpdate:@"create table if not exists HealthAdviceList (adviceId text, channelId text,iconUrl text, imgUrl text,introduction text,likeNumber integer,pariseNum integer,publishTime text,readNum integer,title text,publisher text,source text,unique(adviceId))"];
    
    /*
     ### 健康资讯banner列表 ###
     adviceId  健康咨询 id
     channelId 外键，对应健康咨询列表id
     bannerImgUrl bannerUrl
     */
    result = [_db executeUpdate:@"create table if not exists HealthBannerList (adviceId text, channelId text,bannerImgUrl text,unique(adviceId))"];
    
    /*
     ### 健康方案list列表 ### HealthPlanList
     id  健康方案 id
     desc 描述
     elementId
     imgPath 图片地址
     name 名字
     */
    result = [_db executeUpdate:@"create table if not exists HealthPlanList (id text, desc text,elementId text,imgPath text,name text ,unique(id))"];
    
    /*
     *  @brief 所有快速自查药品列表 QuickMedicineList
     *  @paras classId id
     *         name 药品名称
     *         classDesc 药品描述
     *         imgName  药品图片名称
     */
    result = [_db executeUpdate:@"create table if not exists QuickMedicineList(classId text,classDesc text,name text, imgName text,unique(classId))"];
    
    /*
     *  @brief 所有快速自查药品分类列表 QuickMedicineTypeList
     *  @paras classId id
     *         name 药品名称
     *         classDesc 药品描述
     *         size  个数
     *         parentId 与药品列表关联的外键
     */
    result = [_db executeUpdate:@"create table if not exists QuickMedicineTypeList(classId text,classDesc text,name text, size text, parentId text,unique(classId))"];
    
    /*
     *  @brief 所有快速自查药品二级分类列表 QuickMedicineSubTypeList
     *  @paras classId id
     *         name 药品名称
     *         classDesc 药品描述
     *         isFinalNode  最后一个Node
     *         parentId 与快速自查药品分类列表关联的外键
     */
    result = [_db executeUpdate:@"create table if not exists QuickMedicineSubTypeList(classId text,classDesc text,name text, isFinalNode text,parentId,unique(classId))"];
    
    /*
     *  @brief 所有快速自查疾病列表 QuickDiseaseList
     *  @paras classId id
     *         name 药品名称
     */
    result = [_db executeUpdate:@"create table if not exists QuickDiseaseList(classId text,name text, unique(classId))"];

    
    /*
     *  @brief 所有快速自查疾病二级列表 QuickDiseaseSubList
     *  @paras diseaseId id
     *         name 药品名称
     *         classDesc 药品描述
     *         parentId 外键，对应疾病列表classID
     */
    result = [_db executeUpdate:@"create table if not exists QuickDiseaseSubList(diseaseId text, classDesc text,name text,parentId text, unique(diseaseId))"];
    
    /*
     *  @brief 所有快速自查疾病百科列表 QuickDiseaseWikiList
     *  @paras diseaseId id
     *         name 药品名称
     *         liter
     *         sortNo 
     *         type
     */
    result = [_db executeUpdate:@"create table if not exists QuickDiseaseWikiList(diseaseId text, liter text,name text,sortNo text,type text ,unique(diseaseId))"];
    
    /*
     *  @brief 所有快速自查健康指标列表 QuickHealthIndicatorList
     *  @paras healthId id
     *         name 药品名称
     *         url 药品描述
     */
    result = [_db executeUpdate:@"create table if not exists QuickHealthIndicatorList(healthId text,name text,url text, unique(healthId))"];
    
    /*
     *  @brief 所有快速自查品牌展示列表 QuickFactoryList
     *  @paras code 标示
     *         address 地址
     *         auth 药品描述
     *         imgUrl  描述
     *         desc  描述
     *         name  描述
     */
    result = [_db executeUpdate:@"create table if not exists QuickFactoryList(code text,address text default '',auth text,imgUrl text,name text,desc text default '', unique(code))"];
    
    result = [_db executeUpdate:@"create table if not exists StoreList (id text,name text,star text,avgStar text,consult text,accType text,tel text,province text,city text,county text,addr text,distance text,imgUrl text,accountId text,tags text,shortName text,unique(id))"];
    
    result = [_db executeUpdate:@"create table if not exists RecommendStoreList (id text,name text,star text,avgStar text,consult text,accType text,tel text,province text,city text,county text,addr text,distance text,imgUrl text,accountId text,tags text,unique(id))"];
    
    result = [_db executeUpdate:@"create table if not exists SearchHistoryStoreList (id text,name text,star text,avgStar text,consult text,accType text,tel text,province text,city text,county text,addr text,distance text,imgUrl text,accountId text,tags text,unique(id))"];
    /*
     ### 常见问题栏目列表 ###
     classId  常见问题列表channel id
     channelName channel name
     
     */
    
    result = [_db executeUpdate:@"create table if not exists FamiliarQuestionChannelList (classId text,name text,moduleId text,unique(classId))"];
    
    /*
     ### 常见问题列表 ###
     classId  常见问题列表classId
     answer
     
     */
    //teamId,classId,answer,question,moduleId
    result = [_db executeUpdate:@"create table if not exists FamiliarQuestionList (teamId text,classId text,answer text,question text,moduleId text,imgUrl text,unique(teamId))"];
    
    
    //常见问题详情页
    result = [_db executeUpdate:@"create table if not exists FamiliarQuestionDetail (teamId text,classId text,content text,role text,imgUrl text)"];

    //大家都在问 首页缓存
    result = [_db executeUpdate:@"create table if not exists ProblemModule (imgUrl text,moduleId text,name text)"];

    
    result = [_db executeUpdate:@"create table if not exists ConsultNearPharmacyList (id text, distance text, addr text, accType text, accountId text, avgStar text, city text, code text, consult text, imgUrl text, latitude text, longitude text, name text, star text, tel text, unique(id))"];
    
    
    
    //健康方案（常备必知）
    result = [_db executeUpdate:@"create table if not exists usallyKnowledge (question text,answer text,klgId text,classId text,unique(klgId))"];
    
    //健康方案(常备药品)
    result = [_db executeUpdate:@"create table if not exists usallyDrug (name text,desc text,imgPath text,classId text,unique(name))"];
    
    
    if(result)
        NSLog(@"success");
}

- (void)deleteAllProblemModule
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from ProblemModule"]];
    if(result)
        NSLog(@"success");
}

- (NSMutableArray *)selectAllProblemModule
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from ProblemModule"]];
    return [rs resultArray];
}

#pragma mark - 获取常备必知道
- (NSMutableArray *)selectUsallyKnowledge:(NSString *)classId
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from usallyKnowledge where classId='%@'",classId]];
    return [rs resultArray];
}

- (void)removeAllUsallyKnowledge:(NSString *)classId{
    
    BOOL result = [_db executeUpdate:@"delete from usallyKnowledge where classId='%@'",classId];
    if(result)
        NSLog(@"success");
}

#pragma mark - 常备药品
- (void)insertIntoUsallyDrug:(NSMutableArray *)array classId:(NSString *)classId{
    BOOL result = YES;
    for (int i = 0; i < array.count ; i ++){
        
        BOOL res = [_db executeUpdate:@"insert into usallyDrug values (?,?,?,?)", array[i][@"name"], array[i][@"desc"], array[i][@"imgPath"],classId];
        if(!res){
            result = NO;
        }
    }
    if(result)
        NSLog(@"success");
}

- (NSMutableArray *)selectUsallyDrug:(NSString *)classId{
    
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from usallyDrug where classId='%@'",classId]];
    return [rs resultArray];
}

- (void)removeAllUsallyDrug:(NSString *)classId{
    
    BOOL result = [_db executeUpdate:@"delete from usallyDrug where classId='%@'",classId];
    if(result)
        NSLog(@"success");
}


- (void)insertIntoProblemModule:(NSString *)imgUrl
                       moduleId:(NSString *)moduleId
                           name:(NSString *)name
{
    BOOL result = [_db executeUpdate:@"insert or replace into ProblemModule(imgUrl,moduleId,name) values (?,?,?)",imgUrl,moduleId,name];
    if(result)
        NSLog(@"success");
}

- (BOOL)checkCityInOpen:(NSString *)cityName
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from CityList where cityName = '%@'",cityName]];
    while ([rs next])
    {
        if([rs resultDictionary]){
            return YES;
        }
    }
    return NO;
}

- (NSString *)selectCurrentCityName
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from CityList where current = '%@'",@"1"]];
    if([rs next])
    {
        NSDictionary *message = [rs resultDictionary];
        return message[@"cityName"];
    }
    return nil;
}


- (void)updateCitySelectedStatus:(NSString *)cityName
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update CityList set current = '%@'",@"0"]];
    result = [_db executeUpdate:[NSString stringWithFormat:@"update CityList set current = '%@' where cityName = '%@'",@"1",cityName]];
    if(result)
        NSLog(@"success");
}

- (void)deleteAllStoreList
{
    BOOL result = [_db executeUpdate:@"delete from StoreList"];
    if(result)
        NSLog(@"success");
}

- (void)deleteRecommendAllStoreList
{
    BOOL result = [_db executeUpdate:@"delete from RecommendStoreList"];
    if(result)
        NSLog(@"success");
}

- (void)insertIntoRecommendStoreList:(NSString *)storeId
                                name:(NSString *)name
                                star:(NSString *)star
                             avgStar:(NSString *)avgStar
                             consult:(NSString *)consult
                             accType:(NSString *)accType
                                 tel:(NSString *)tel
                            province:(NSString *)province
                                city:(NSString *)city
                              county:(NSString *)county
                                addr:(NSString *)addr
                            distance:(NSString *)distance
                              imgUrl:(NSString *)imgUrl
                           accountId:(NSString *)accountId
                                tags:(NSString *)tags
{
    BOOL result = [_db executeUpdate:@"insert or replace into RecommendStoreList(id,name,star,avgStar,consult,accType,tel,province,city,county,addr,distance,imgUrl,accountId,tags) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",storeId,name,star,avgStar,consult,accType,tel,province,city,county,addr,distance,imgUrl,accountId,tags];
    if(result)
        NSLog(@"success");
}

- (NSMutableArray *)selectALLRecommendStoreList
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from RecommendStoreList"]];
    return [rs resultArray];
}


- (void)insertIntoStoreList:(NSString *)storeId
                       name:(NSString *)name
                       star:(NSString *)star
                    avgStar:(NSString *)avgStar
                    consult:(NSString *)consult
                    accType:(NSString *)accType
                        tel:(NSString *)tel
                   province:(NSString *)province
                       city:(NSString *)city
                     county:(NSString *)county
                       addr:(NSString *)addr
                   distance:(NSString *)distance
                     imgUrl:(NSString *)imgUrl
                  accountId:(NSString *)accountId
                       tags:(NSString *)tags
                  shortName:(NSString *)shortName
{
    BOOL result = [_db executeUpdate:@"insert or replace into StoreList(id,name,star,avgStar,consult,accType,tel,province,city,county,addr,distance,imgUrl,accountId,tags,shortName) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",storeId,name,star,avgStar,consult,accType,tel,province,city,county,addr,distance,imgUrl,accountId,tags,shortName];
    if(result)
        NSLog(@"success");
}//SearchHistoryStoreList

- (void)insertSearchHistoryStoreList:(NSString *)storeId
                          name:(NSString *)name
                          star:(NSString *)star
                       avgStar:(NSString *)avgStar
                       consult:(NSString *)consult
                       accType:(NSString *)accType
                           tel:(NSString *)tel
                      province:(NSString *)province
                          city:(NSString *)city
                        county:(NSString *)county
                          addr:(NSString *)addr
                      distance:(NSString *)distance
                        imgUrl:(NSString *)imgUrl
                     accountId:(NSString *)accountId
                          tags:(NSString *)tags
{
    BOOL result = [_db executeUpdate:@"insert or replace into SearchHistoryStoreList(id,name,star,avgStar,consult,accType,tel,province,city,county,addr,distance,imgUrl,accountId,tags) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",storeId,name,star,avgStar,consult,accType,tel,province,city,county,addr,distance,imgUrl,accountId,tags];
    if(result)
        NSLog(@"插入success");
}

- (void)removeAllSearchStoreHistory
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from SearchHistoryStoreList"]];
    if(result)
        NSLog(@"delete success");
}
- (NSMutableArray *)queryAllSearchStoreHistory
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from SearchHistoryStoreList"]];
    return [rs resultArray];
}

- (void)updateLastMessageTimestamp:(NSString *)timeStamp
{
    FMResultSet *rs = [_db executeQuery:@"select * from Messages order by timestamp desc"];
    if([rs next])
    {
        NSDictionary *message = [rs resultDictionary];
        
        BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update Messages set timestamp = '%@' where UUID = '%@'",timeStamp,message[@"UUID"]]];
        if(result)
            NSLog(@"success");
    }
}

- (NSMutableArray *)selectAllStoreList
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from StoreList"]];
    return [rs resultArray];
}


- (NSMutableArray *)selectAllCityList
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from CityList"]];
    return [rs resultArray];
}

- (void)deleteCityList
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from CityList"]];
    if(result)
        NSLog(@"success");
}

- (void)insertIntoCityList:(NSString *)cityId
                  province:(NSString *)province
              provinceName:(NSString *)provinceName
                      city:(NSString *)city
                  cityName:(NSString *)cityName
                      open:(NSString *)open
                    remark:(NSString *)remark
                      code:(NSString *)code
{
    BOOL result = [_db executeUpdate:@"insert into CityList(id,province,provinceName,city,cityName,open,remark,code) values (?,?,?,?,?,?,?,?)",cityId,province,provinceName,city,cityName,open,remark,code];
    if(result)
        NSLog(@"success");
}

//插入常备必知
- (void)insertIntoUsallyKnowledge:(NSMutableArray *)array classId:(NSString *)classId{
    
    BOOL result = YES;
    for (int i = 0; i < array.count ; i ++){
        
        BOOL res = [_db executeUpdate:@"insert into usallyKnowledge values (?,?,?,?)", array[i][@"question"], array[i][@"answer"], array[i][@"klgId"],classId];
        if(!res){
            result = NO;
        }
    }
    if(result)
        NSLog(@"success");
}


// 插入channel
- (void)insertIntoHealthChannel:(NSString *)channelId
                    channelName:(NSString *)channelName
                           sort:(NSInteger)sort
{
    BOOL result = [_db executeUpdate:@"insert or replace into HealthInfoChannelList(id,channelName,sort) values (?,?,?)",channelId,channelName,[NSNumber numberWithInt:sort]];
    if(result)
        NSLog(@"success");
}
/*
 adviceId  健康咨询 id
 channelId 外键，对应健康咨询列表id
 iconUrl 健康资讯iconUrl
 imgUrl 健康资讯imgUrl
 introduction 健康资讯介绍
 likeNumber 喜爱的个数
 pariseNum  点赞个数
 publishTime  发布时间
 readNum   阅读数
 title      标题
 publiser   发布者
 source     来源
 */
- (void)insertIntoHealthAdviceList:(NSString *)channelID
                          adviceId:(NSString *)adviceId
                           iconUrl:(NSString *)iconUrl
                            imgUrl:(NSString *)imgUrl
                      introduction:(NSString *)intro
                        likeNumber:(NSInteger)likeNum
                         pariseNum:(NSInteger)pariseNum
                       publishTime:(NSString *)publishTime
                         publisher:(NSString *)publiser
                           readNum:(NSInteger)readNum
                            source:(NSString *)source
                             title:(NSString *)title
{
    BOOL result = [_db executeUpdate:@"insert or replace into HealthAdviceList(adviceId,channelId,iconUrl,imgUrl,introduction,likeNumber,pariseNum,publishTime,readNum,title,publisher,source) values (?,?,?,?,?,?,?,?,?,?,?,?)",adviceId,channelID,iconUrl,imgUrl,intro,[NSNumber numberWithInteger:likeNum],[NSNumber numberWithInteger:pariseNum],publishTime,[NSNumber numberWithInteger:readNum],title,publiser,source];
    
    if(result)
        NSLog(@"success");
    else
        NSLog(@"error message is %@",[NSString stringWithUTF8String:sqlite3_errmsg((__bridge sqlite3 *)(_db))]);
}

- (NSArray *)queryAllHealthAdviceListWithChannelId:(NSString *)channelID
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from HealthAdviceList where channelId = '%@'",channelID]];
    return [rs resultArray];
}

- (void)updareHealthAdvicePariseNum:(NSInteger)pariseNum AdviceId:(NSString *)adviceId
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update HealthAdviceList set pariseNum = %d where adviceId = '%@'",pariseNum,adviceId]];
    if(result)
        NSLog(@"success");
}

- (void)removeHealthAdviceListWithChannelId:(NSString *)channelID
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from HealthAdviceList where channelId = '%@'",channelID]];
    if(result)
        NSLog(@"success");
}

- (NSArray *)queryCachedHealthChannelList
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from HealthInfoChannelList"]];
    NSMutableArray *arrChannel = [@[] mutableCopy];
    for (NSDictionary *dicChannel in [rs resultArray]) {
        NSDictionary *dicC = @{@"channelId": dicChannel[@"id"]
                               ,@"channelName": dicChannel[@"channelName"]
                               ,@"sort":dicChannel[@"sort"]};
        [arrChannel addObject:dicC];
    }
    return arrChannel;
}

- (void)removeAllChannel
{
    NSArray *arrAllChannel = [self queryCachedHealthChannelList];
    for (NSDictionary *dicChannel in arrAllChannel) {
        [self removeHealthAdviceListWithChannelId:dicChannel[@"channelId"]];
        [self removeAllBannerListWithChannelId:dicChannel[@"channelId"]];
    }
    BOOL result = [_db executeUpdate:@"delete from HealthInfoChannelList"];
    if(result)
        NSLog(@"success");
}

/*
 ### 健康资讯banner列表 ###
 adviceId  健康咨询 id
 channelId 外键，对应健康咨询列表id
 bannerImgUrl bannerUrl
 */
- (void)insertIntoHealthBannerList:(NSString *)channelID
                          adviceId:(NSString *)adviceId
                      bannerImgUrl:(NSString *)bannerImgUrl
{
    BOOL result = [_db executeUpdate:@"insert or replace into HealthBannerList(adviceId,channelId,bannerImgUrl) values (?,?,?)",adviceId,channelID,bannerImgUrl];
    
    if(result)
        NSLog(@"success");
    else
        NSLog(@"error message is %@",[NSString stringWithUTF8String:sqlite3_errmsg((__bridge sqlite3 *)(_db))]);
}
- (NSArray *)queryAllBannerListWithChannelId:(NSString *)channelId
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from HealthBannerList where channelId = '%@'",channelId]];
    return [rs resultArray];

}
- (void)removeAllBannerListWithChannelId:(NSString *)channelId
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from HealthBannerList where channelId = '%@'",channelId]];
    if(result)
        NSLog(@"success");
}

-(void)createAllTable
{
    //创建联系人表
    //昵称：nick
	//头像：avatar
	//年龄：age="18"
	//性别：sex 1男，2女
	//个性签名：signature
    BOOL result = [_db executeUpdate:@"create table if not exists Contacts (id integer primary key,jid text,name text not null default 'unkonw',nickname text not null default '',subscription text,groups text,status text default 'unavailable',avatar text default '' ,resource text not null default '',age integer default 0,sex integer default 0,signature text default '',videoimg text default '',unique(jid))"];
    //direction 1是incoming  0是outgoing
    //timestamp     是当前发出消息的格林日志时间秒数
    //UUID      每条消息的唯一标示符
    //star      评价等级
    //avatorUrl 头像地址
    //sendname   对方的name
    //recvname  本人名字
    //issend    1是正在发送   2是发送成功   3发送失败
    //messagetype   1文本信息    2图片信息    3语音信息   4位置信息  5评价信息
    //unread        0已看    1未读  2语音信息已听
    //richbody      存放的是富文本下载路径
    //body          中存放的是消息的文本字段,如纯文本或者地址位置中描述信息
    
    result = [_db executeUpdate:@"create table if not exists Messages(id integer primary key,direction integer,timestamp text,UUID text,star text,avatorUrl text,sendname text not null,recvname text not null default '',issend integer,messagetype integer,unread integer,richbody text,body text,unique(UUID))"];
    
    //relatedid     消息关联的对方jid
    //timestamp     时间戳
    //body          平文本
    //direction     0是incoming  1是outgoing
    //messagetype   0文本信息    1图片信息    2语音信息   3位置信息  4评价信息
    //UUID          每条消息的唯一标示符
    //issend    1是正在发送   2是发送成功   3发送失败
    //avatarurl 机构的logo
    //groupName 机构名称
    //groupType 机构类型
    result = [_db executeUpdate:@"create table if not exists HistoryMessages(relatedid text,timestamp text,body text,direction integer,messagetype integer,UUID text,issend integer,avatarurl text default '',groupName text default '',groupType integer default 0,stick integer default 0,groupId text default '',unique(relatedid))"];
    
    result = [_db executeUpdate:@"create table if not exists officialMessages(fromId text default '',toId text default '',timestamp text,body text,direction integer,messagetype integer,UUID text,issend integer,relatedid text,unique(UUID))"];
    
    result = [_db executeUpdate:@"create table if not exists TagList(UUID text default '',start integer,length integer,tagType integer,title text,tagId text default '',unique(UUID,tagId))"];
    
    result = [_db executeUpdate:@"create table if not exists Mybox(boxId text,productName text,productId text,source text,useName text,createtime text,effect text,useMethod text,perCount text,unit text,intervalDay text,drugTime text,drugTag text,productEffect text,unique(boxId))"];
    
    result = [_db executeUpdate:@"create table if not exists AlarmClock(boxId text default '',timesList text,startTime text,endTime text,remark text,productName text,useName text,useMethod text,perCount text,drugTime text,intervalDay text,unique(boxId))"];
    
    result = [_db executeUpdate:@"create table if not exists AlarmCallTime(boxId text default '',callTime text)"];
    
    result = [_db executeUpdate:@"create table if not exists DiseaseSubList(guideId text default '',content text,displayTime text, title text, unReadCount integer default 0, hasRead boolean default 0,unique(guideId))"];
    
    /*
     *  @brief 所有慢病订阅列表
     *  @paras attentionId 慢病id
     *         name 慢病名称
     *         selected 是否被用户添加 bool型
     */
    result = [_db executeUpdate:@"create table if not exists DiseaseAllList(attentionId text,name text,selected text,unique(attentionId))"];
    
    /*
     *  @brief 所有我的收藏药品列表   MyFavMedicineList
     *  @paras factory 工厂
     *         id 药品id
     *         proId 
     *         proName
     *         spec
     */
    result = [_db executeUpdate:@"create table if not exists MyFavMedicineList(id text,factory text,proId text, proName text, spec text,unique(id))"];
    
    
    
    /**
     *  缓存我的订单      MyOrderList
     *
     *  @param text proName         商品名称
     *  @param text type            优惠券类型
     *  @param text date            订单日期
     *  @param discount             优惠价格
     *  @param totalLargess         赠送商品数量
     *
     *  @return 如果创建成功,返回seccess
     */
    result = [_db executeUpdate:@"create table if not exists MyOrderList(id text,proName text,type text,date text,discount text,totalLargess text,unique(id))"];
    
    /**
     *  我的关注的药房缓存列表
     *  @return 创建成功返回seccess
     */
    result = [_db executeUpdate:@"create table if not exists myFavStoreList (id text,name text,star text,avgStar text,consult text,accType text,tel text,province text,city text,county text,addr text,distance text,imgUrl text,accountId text,tags text, shortName text,unique(id))"];
    
    
    /*
     *  @brief 所有我的收藏症状列表   MyFavSymptonList
     *  @paras desc 描述
     *         name
     *         population
     *         sex
     *         spmCode
     */
    result = [_db executeUpdate:@"create table if not exists MyFavSymptonList(spmCode text,desc text,name text, population text, sex text,unique(spmCode))"];
    
    /*
     *  @brief 所有我的收藏疾病列表   MyFavDiseaseList
     *  @paras cname 描述
     *         desc
     *         diseaseId    疾病id
     *         ename
     *         type
     */
    result = [_db executeUpdate:@"create table if not exists MyFavDiseaseList(diseaseId text,desc text,cname text, ename text, type text,unique(diseaseId))"];
    
    /*
     *  @brief 所有我的收藏资讯列表   MyFavMessageList
     *  @paras adviceId 资讯id
     *         iconUrl
     *         imgUrl
     *         introduction
     *         likeNumber
     *         pariseNum
     *         publishTime
     *         publisher
     *         readNum
     *         title
     */
    result = [_db executeUpdate:@"create table if not exists MyFavMessageList(adviceId text,iconUrl text,imgUrl text, introduction text, likeNumber text,pariseNum text,publishTime text,publisher text,readNum text,title text,unique(adviceId))"];
    
    if(result)
        NSLog(@"success");
}

- (void)insertIntoAlarmCallTime:(NSString *)boxId
                      timeStamp:(NSString *)timeStamp
{
    BOOL result = [_db executeUpdate:@"insert into AlarmCallTime(boxId,callTime) values (?,?)",boxId,timeStamp];
    if(result)
        NSLog(@"success");
}

- (NSDictionary *)checkExistedTime:(NSString *)timeStamp
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from AlarmCallTime where callTime = '%@'",timeStamp]];
    while ([rs next])
    {
        return [rs resultDictionary];
    }
    return nil;
}

- (BOOL)checkValidMedicine
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from Mybox where useMethod = '%@' or perCount = '%@' or unit = '%@' or drugTime = '%@' or useName = '%@'",@"",@"",@"",@"",@""]];
    while ([rs next])
    {
        if([rs resultDictionary]){
            return YES;
        }
    }
    return NO;
}

- (NSMutableArray *)selectAllBoxMedicine
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from Mybox"]];
    return [rs resultArray];
}

- (void)insertIntoMybox:(NSString *)boxId
            productName:(NSString *)productName
              productId:(NSString *)productId
                 source:(NSString *)source
                useName:(NSString *)useName
             createtime:(NSString *)createtime
                 effect:(NSString *)effect
              useMethod:(NSString *)useMethod
               perCount:(NSString *)perCount
                   unit:(NSString *)unit
            intervalDay:(NSString *)intervalDay
               drugTime:(NSString *)drugTime
                drugTag:(NSString *)drugTag
          productEffect:(NSString *)productEffect
{
    BOOL result = [_db executeUpdate:@"insert or replace into Mybox(boxId,productName,productId,source,useName,createtime,effect,useMethod,perCount,unit,intervalDay,drugTime,drugTag,productEffect) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)",boxId,productName,productId,source,useName,createtime,effect,useMethod,perCount,unit,intervalDay,drugTime,drugTag,productEffect];
    if(result)
        NSLog(@"success");
}

- (NSUInteger)selectUnreadCountOfficialMessage
{
    FMResultSet *rs;
    int retValue = 0;
    rs = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from officialMessages where issend = '%@'",[NSNumber numberWithInteger:0]]];
    while ([rs next]) {
        retValue = [rs intForColumn:@"count(*)"];
    }
    return retValue;
}

- (NSUInteger)selectUnreadCountMessage
{
    FMResultSet *rs;
    int retValue = 0;
    rs = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from Messages where unread = '%@'",[NSNumber numberWithInteger:1]]];
    while ([rs next]) {
        retValue = [rs intForColumn:@"count(*)"];
    }
    return retValue;
}

- (NSUInteger)selectTotalUnreadCountMessage
{
    return [self selectUnreadCountOfficialMessage] + [self selectUnreadCountMessage];
}

- (void)deleteFromofficialMessages
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from officialMessages"]];
    if(result)
        NSLog(@"success");
}

- (void)setOfficialMessagesRead
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update officialMessages set issend = '%@'",[NSNumber numberWithInt:1]]];
    if(result)
        NSLog(@"success");
}

- (void)insertIntoTagList:(NSString *)UUID
                    start:(NSNumber *)start
                   length:(NSNumber *)length
                  tagType:(NSNumber *)tagType
                    title:(NSString *)title
                    tagId:(NSString *)tagId
{
    BOOL result = [_db executeUpdate:@"insert into TagList(UUID,start,length,tagType,title,tagId) values (?,?,?,?,?,?)",UUID,start,length,tagType,title,tagId];
    if(result)
        NSLog(@"success");
}

- (NSMutableArray *)selectTagList:(NSString *)UUID
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from TagList where UUID = '%@'",UUID]];
    return [rs resultArray];
}

- (BOOL)insertIntoofficialMessages:(NSString *)formId
                              toId:(NSString *)toId
                         timestamp:(NSString *)timestamp
                              body:(NSString *)body
                         direction:(NSNumber *)direction
                       messagetype:(NSNumber *)messagetype
                              UUID:(NSString *)UUID
                            issend:(NSNumber *)issend
                         relatedid:(NSString *)relatedid
{
    BOOL result = [_db executeUpdate:@"insert into officialMessages(fromId,toId,timestamp,body,direction,messagetype,UUID,issend,relatedid) values (?,?,?,?,?,?,?,?,?)",formId,toId,timestamp,body,direction,messagetype,UUID,issend,relatedid];
    return result;
}

- (void)updateLastHistoryMessage:(NSString *)relatedid
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from Messages order by timestamp desc"]];
    NSMutableArray *retArray = [rs resultArray];
    if(retArray) {
        //如果有值,将最后一条记录更新至历史
        NSDictionary *message = retArray[0];
        NSString *timeStamp = message[@"timestamp"];
        NSString *body = message[@"body"];
        NSNumber *direction = [NSNumber numberWithInteger:[message[@"direction"] integerValue]];
        NSNumber *messagetype = [NSNumber numberWithInteger:[message[@"messagetype"] integerValue]];
        if([messagetype integerValue] == XHBubbleMessageMediaTypeActivity){
            body = message[@"star"];
        }
        NSString *UUID = message[@"UUID"];
        NSNumber *issend = [NSNumber numberWithInteger:[message[@"issend"] integerValue]];

        [self forceInsertHistorys:relatedid timestamp:timeStamp body:body direction:direction messagetype:messagetype UUID:UUID issend:issend avatarUrl:@""];
    }else{
        //没有则 删除改会话列表
        [self deleteHistoryMessages:relatedid];
        [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_NEED_UPDATE object:nil];
    }
}

- (void)deleteHistoryMessages:(NSString *)relatedid
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from HistoryMessages where relatedid = '%@'",relatedid]];
    if(result)
        NSLog(@"success");
}

- (void)deleteFromOfficialMessages
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from officialMessages"]];
    if(result)
        NSLog(@"success");
}


- (NSMutableArray *)selectOfficialMessages
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from officialMessages order by timestamp asc"]];
    return [rs resultArray];
}

- (NSDictionary *)selectLastOneUpdateOfficialMessage
{
    FMResultSet *rs = [_db executeQuery:@"select * from officialMessages order by timestamp desc"];
    while ([rs next])
        return [rs resultDictionary];
    return nil;
}

- (void)setHistoryStick:(NSString *)relatedid
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update HistoryMessages set stick = '%@'",[NSNumber numberWithInt:0]]];
    result = [_db executeUpdate:[NSString stringWithFormat:@"update HistoryMessages set stick = '%@' where relatedid = '%@'",[NSNumber numberWithInt:1],relatedid]];
    if(result)
        NSLog(@"success");
}

- (void)cancelHistoryStick:(NSString *)relatedid
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update HistoryMessages set stick = '%@' where relatedid = '%@'",[NSNumber numberWithInt:0],relatedid]];
    if(result)
        NSLog(@"success");
}

- (void)insertAlarmClock:(NSString *)boxId
               timesList:(NSString *)timesList
               startTime:(NSString *)startTime
                 endTime:(NSString *)endTime
                  remark:(NSString *)remark
             productName:(NSString *)productName
                 useName:(NSString *)useName
               useMethod:(NSString *)useMethod
                perCount:(NSString *)perCount
                drugTime:(NSString *)drugTime
             intervalDay:(NSString *)intervalDay
{
    BOOL result = [_db executeUpdate:@"insert or replace into AlarmClock(boxId,timesList,startTime,endTime,remark,productName,useName,useMethod,perCount,drugTime,intervalDay) values (?,?,?,?,?,?,?,?,?,?,?)",boxId,timesList,startTime,endTime,remark,productName,useName,useMethod,perCount,drugTime,intervalDay];
    if(result)
        NSLog(@"success");
}

- (BOOL)checkAlarmClock:(NSString *)boxId
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from AlarmClock where boxId = '%@'",boxId]];
    while ([rs next])
    {
        if([rs resultDictionary]){
            return YES;
        }
    }
    return NO;
}

- (NSMutableDictionary *)selectAlarmClock:(NSString *)boxId
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from AlarmClock where boxId = '%@'",boxId]];
    while ([rs next])
        return [rs resultDictionary];
    return nil;
}

- (void)deleteAlarmClock:(NSString *)boxId
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from AlarmClock where boxId = '%@'",boxId]];
    result = [_db executeUpdate:[NSString stringWithFormat:@"delete from AlarmCallTime where boxId = '%@'",boxId]];
    if(result)
        NSLog(@"success");
}


- (void)updateOfficial:(NSString *)UUID
            sendStatus:(NSNumber *)sendStatus
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update officialMessages set issend = '%@' where UUID = '%@'",sendStatus,UUID]];
    if(result)
        NSLog(@"success");
}


- (void)updateHistory:(NSString *)relatedid
            avatarurl:(NSString *)avatarurl
            groupName:(NSString *)groupName
            groupType:(NSNumber *)groupType
              groupId:(NSString *)groupId
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update HistoryMessages set avatarurl = '%@' ,groupName = '%@' ,groupType = '%@',groupId = '%@' where relatedid = '%@'",avatarurl,groupName,groupType,groupId,relatedid]];
    if(result)
        NSLog(@"success");
}

- (NSMutableArray *)selectHistoryWith:(NSString *)relatedid
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from HistoryMessages where relatedid = '%@'",relatedid]];
    return [rs resultArray];
}

- (void)forceInsertHistorys:(NSString *)relatedid
                  timestamp:(NSString *)timestamp
                       body:(NSString *)body
                  direction:(NSNumber *)direction
                messagetype:(NSNumber *)messagetype
                       UUID:(NSString *)UUID
                     issend:(NSNumber *)issend
                  avatarUrl:(NSString *)avatarUrl
{
    BOOL result;
    result = [_db executeUpdate:@"insert or replace into HistoryMessages(relatedid,timestamp,body,direction,messagetype,UUID,issend,avatarurl) values (?,?,?,?,?,?,?,?)",relatedid,timestamp,body,direction,messagetype,UUID,issend,avatarUrl];
    if(result)
        NSLog(@"success");
}


- (void)insertHistorys:(NSString *)relatedid
             timestamp:(NSString *)timestamp
                  body:(NSString *)body
             direction:(NSNumber *)direction
           messagetype:(NSNumber *)messagetype
                  UUID:(NSString *)UUID
                issend:(NSNumber *)issend
             avatarUrl:(NSString *)avatarUrl
{
    NSMutableArray *array = [self selectHistoryWith:relatedid];
    BOOL result;
    if(array.count > 0) {
//        NSDictionary *lastInfo = array[0];
//        double lastMessageTime = [lastInfo[@"timestamp"] doubleValue];
//        if([timestamp doubleValue] > lastMessageTime) {
        result = [_db executeUpdate:[NSString stringWithFormat:@"update HistoryMessages set timestamp = '%@',body = '%@',direction = '%@',messagetype = '%@',UUID = '%@',issend = '%@' where relatedid = '%@'",timestamp,body,direction,messagetype,UUID,issend,relatedid]];
//        }
    }else{
        result = [_db executeUpdate:@"insert or replace into HistoryMessages(relatedid,timestamp,body,direction,messagetype,UUID,issend,avatarurl) values (?,?,?,?,?,?,?,?)",relatedid,timestamp,body,direction,messagetype,UUID,issend,avatarUrl];
    }
    if(result)
        NSLog(@"success");
}



- (NSMutableArray *)selectAllHistroy
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from HistoryMessages order by timestamp desc"]];
    NSMutableArray *retArray = [rs resultArray];
    NSUInteger index = 0;
    for(; index < retArray.count ; ++index)
    {
        NSDictionary *dict = retArray[index];
        if([dict[@"stick"] integerValue] == 1) {
            break;
        }
    }
    if(index < retArray.count) {
        [retArray exchangeObjectAtIndex:0 withObjectAtIndex:index];
    }
    return retArray;
}

- (NSMutableArray *)selectRelatedidWithoutGroupname
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select relatedid from HistoryMessages where groupName == ''"]];
    return [rs resultArray];
}

- (NSMutableArray *)selectAllRelatedid
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select relatedid from HistoryMessages order by timestamp desc"]];
    return [rs resultArray];
}

- (void)deleteFromHistoryWithUUID:(NSString *)relatedid
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from HistoryMessages where relatedid UUID = '%@'",relatedid]];
    if(result)
        NSLog(@"success");
}

- (void)setMessagesReadWithRelatedId:(NSString *)relatedid
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update Messages set unread = '%@' where sendname = '%@' or recvname = '%@'",[NSNumber numberWithInt:0],relatedid,relatedid]];
    if(result)
        NSLog(@"success");
}

- (void)setAllMessageReaded
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update Messages set unread = '%@'",[NSNumber numberWithInt:0]]];
    result = [_db executeUpdate:[NSString stringWithFormat:@"update officialMessages set issend = '%@'",[NSNumber numberWithInt:1]]];
    if(result)
        NSLog(@"success");

}

- (NSUInteger)selectUnreadCountMessage:(NSString *)relatedid
{
    FMResultSet *rs;
    int retValue = 0;
    rs = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from Messages where (sendname = '%@' or recvname = '%@') and unread = '%@'",relatedid,relatedid,[NSNumber numberWithInt:1]]];
    while ([rs next]) {
        retValue = [rs intForColumn:@"count(*)"];
    }
    return retValue;
}

- (NSUInteger)selectAllUnreadCountMessage
{
    FMResultSet *rs;
    int retValue = 0;
    rs = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from Messages where unread = '%@'",[NSNumber numberWithInt:1]]];
    while ([rs next]) {
        retValue = [rs intForColumn:@"count(*)"];
    }
    return retValue;
}


- (BOOL)insertMessages:(NSNumber *)direction
             timestamp:(NSString *)timestamp
                  UUID:(NSString *)UUID
                  star:(NSString *)star
             avatorUrl:(NSString *)avatorUrl
               sendName:(NSString *)sendname
              recvName:(NSString *)recvname
                issend:(NSNumber *)issend
           messagetype:(NSNumber *)messagetype
                unread:(NSNumber *)unread
              richbody:(NSString *)richbody
                  body:(NSString *)body
{
    BOOL result = [_db executeUpdate:@"insert into Messages(direction,timestamp,UUID,star,avatorUrl,sendname,recvname,issend,messagetype,unread,richbody,body) values (?,?,?,?,?,?,?,?,?,?,?,?)",direction,timestamp,UUID,star,avatorUrl,sendname,recvname,issend,messagetype,unread,richbody,body];
    if(result)
        NSLog(@"success");
    return result;
}



- (void)updateMessageEvaluate:(NSString *)status With:(NSString *)UUID
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update Messages set star = '%@' where UUID = '%@'",status,UUID]];
    if(result)
        NSLog(@"success");
}

- (void)updateMessageStatus:(NSNumber *)status
                  timeStamp:(NSString *)timeStamp
                       With:(NSString *)UUID
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update Messages set issend = '%@',timestamp = '%@' where UUID = '%@'",status,timeStamp,UUID]];
    if(result)
        NSLog(@"success");
}

- (void)deleteFromMessagesWithUUID:(NSString *)UUID
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from Messages where UUID = '%@'",UUID]];
    if(result)
        NSLog(@"success");
}

- (void)deleteFromMessagesWithName:(NSString *)sendname
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from Messages where sendname = '%@' or recvname = '%@'",sendname,sendname]];
    if(result)
        NSLog(@"success");
}

- (void)deleteFromHistoryWithRelatedId:(NSString *)relatedid
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from HistoryMessages where relatedid = '%@'",relatedid]];
    if(result)
        NSLog(@"success");
}

- (NSMutableArray *)selectAllMessagesWithSendName:(NSString *)sendname
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from Messages where sendname = '%@' or recvname = '%@' order by timestamp asc",sendname,sendname]];
    return [rs resultArray];
}

- (void)insertNewGroup:(NSString *)name
                roomId:(NSString *)roomid
           description:(NSString *)description
             maxnumber:(NSString *)maxnumber
                avatar:(NSString *)avatar
                  area:(NSString *)area
                  city:(NSString *)city
              category:(NSString *)category
            createTime:(NSNumber *)timestamp
{
    BOOL result = [_db executeUpdate:@"insert or replace into room (name,roomid,description,maxnumber,avatar,area,city,category) values (?,?,?,?,?,?,?,?)",name,roomid,description,maxnumber,avatar,area,city,category];
    if(result)
        NSLog(@"success");
}

- (void)updateGroupHostId:(NSString *)hostId withRoomId:(NSString *)roomId
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update room set hostid = '%@' where roomid = '%@'",hostId,roomId]];
    if(result)
        NSLog(@"success");
}

- (void)deleteFromRoom:(NSString *)groupId
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from room where roomid = '%@'",groupId]];
    if(result)
        NSLog(@"success");
    
}
- (void)deleteFromgroupMemberList:(NSString *)jid groupJid:(NSString *)groupjid
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from groupMemberList where jid = '%@' and groupjid = '%@'",jid,groupjid]];
    if(result)
        NSLog(@"success");
}

- (void)deleteFromAllGroupMemberList:(NSString *)groupid
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from groupMemberList where groupjid = '%@'",groupid]];
    if(result)
        NSLog(@"success");
}

- (NSMutableArray *)selectMemberListFromGroups:(NSString *)groupjid
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from groupMemberList where groupjid = '%@'",groupjid]];
    return [rs resultArray];
}

- (NSMutableArray *)selectAllGroupsJid
{
    FMResultSet *rs = [_db executeQuery:@"select distinct groupjid from groupMemberList"];
    return [rs resultArray];
}

- (void)insertgroupMemberList:(NSString *)jid
                     groupJid:(NSString *)groupjid
                     nickname:(NSString *)nickname
                    moderator:(NSUInteger)moderator
               lastUpdateTime:(NSUInteger)lastUpdateTime
{
    BOOL result = [_db executeUpdate:@"insert or replace into groupMemberList (jid,groupjid,nickname,lastupdatetime,moderator) values (?,?,?,?,?)",jid,groupjid,nickname,[NSNumber numberWithInteger:lastUpdateTime],[NSNumber numberWithInt:moderator]];
    if(result)
        NSLog(@"success");
}

- (void)updateMessagesSendSuccessWithJid:(NSString *)toJid timeStamp:(NSUInteger)timestamp
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update Messages set issend = 1 where timestamp = %@ and recvjid = '%@'",[NSNumber numberWithInt:timestamp],toJid]];
    if(result)
        NSLog(@"success");
}

- (void)insertHistoryMessageWithRelatedid:(NSString *)relatedid
                                timestamp:(NSUInteger)timestamp
                                     body:(NSString *)body
                                direction:(NSUInteger)direction
                              messagetype:(NSUInteger)messagetype
                              messagekind:(NSUInteger)messagekind
{
    BOOL result = [_db executeUpdate:@"insert into HistoryMessages (relatedid,timestamp,body,direction,messagetype,messagekind) values (?,?,?,?,?,?)",relatedid,[NSNumber numberWithInt:timestamp],body,[NSNumber numberWithInt:direction],[NSNumber numberWithInt:messagetype],[NSNumber numberWithInt:messagekind]];
    if(result)
        NSLog(@"success");
}


- (void)updateHistoryMessageWithRelatedid:(NSString *)relatedid
                                timestamp:(NSUInteger)timestamp
                                     body:(NSString *)body
                                direction:(NSUInteger)direction
                              messagetype:(NSUInteger)messagetype
                              messagekind:(NSUInteger)messagekind
{
    BOOL result = [_db executeUpdate:@"insert or replace into HistoryMessages (relatedid,timestamp,body,direction,messagetype,messagekind) values (?,?,?,?,?,?)",relatedid,[NSNumber numberWithInt:timestamp],body,[NSNumber numberWithInt:direction],[NSNumber numberWithInt:messagetype],[NSNumber numberWithInt:messagekind]];
    if(result)
        NSLog(@"success");
}

#pragma mark - 慢病
//guideId text default '',content text,displayTime text, title text, unReadCount integer, hasRead boolean,unique(guideId)
- (void)updateDiseaseSubWithGuideid:(NSString *)guideId
                            content:(NSString *)content
                        displayTime:(NSString *)displayTime
                              title:(NSString *)title
                        unReadCount:(NSInteger)unreadCount
{
    
    BOOL result = [_db executeUpdate:@"insert or ignore into DiseaseSubList (guideId,content,displayTime,title) values (?,?,?,?)",guideId,content,displayTime,title];
    if(result)
        NSLog(@"up up success,%ld,guide id is %@",(long)unreadCount, guideId);
    result = [_db executeUpdate:[NSString stringWithFormat:@"update DiseaseSubList set unReadCount = '%@' where guideId = '%@'",[NSNumber numberWithInt:unreadCount],guideId]];
    if(result){
        NSLog(@"####pepe success");
    }
}

- (void)updateDiseaseSubWithArr:(NSArray *)arrDisease
{
    for (int i = 0; i < arrDisease.count; i++) {
        NSDictionary *dict = arrDisease[i];
        NSInteger intUnReadCount = 0;
        if (![dict[@"unReadCount"] isEqual:[NSNull null]]) {
            intUnReadCount = [dict[@"unReadCount"] intValue];
        }
        [self updateDiseaseSubWithGuideid:dict[@"guideId"] content:dict[@"content"] displayTime:dict[@"displayTime"] title:dict[@"title"] unReadCount:intUnReadCount];
    }
}

- (BOOL)getMessageSendStatus:(NSString *)UUID
{
    FMResultSet *rs;
    rs = [_db executeQuery:[NSString stringWithFormat:@"select issend from Messages where UUID = '%@'",UUID]];
    while ([rs next])
    {
        int status = [rs intForColumn:@"issend"];
        return !(status == 3);
    }
    return NO;
}

- (void)updateSendingMessageToFailure
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update Messages set issend = '%@' where issend = '%@'",[NSNumber numberWithInt:3],[NSNumber numberWithInt:1]]];
    if(result){
        
    }
}

- (BOOL)getHasReadFromDiseaseSubWithGuideId:(NSString *)guideId
{
    FMResultSet *rs;
    rs = [_db executeQuery:[NSString stringWithFormat:@"select * from DiseaseSubList where guideId = '%@'",guideId]];
    while ([rs next]) {
        return [rs boolForColumn:@"hasRead"];
    }
    return NO;
}

- (BOOL)getDiseaseFromDiseaseSubWithGuideId:(NSString *)guideId
{
    FMResultSet *rs;
    rs = [_db executeQuery:[NSString stringWithFormat:@"select * from DiseaseSubList where guideId = '%@'",guideId]];
    if ([rs next]) {
        return YES;
    }
    return NO;
}

- (void)updateHasReadFromDiseaseWithId:(NSString *)guideId hasRead:(BOOL)hasRead
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update DiseaseSubList set hasRead = %d where guideId = '%@'",hasRead,guideId]];
    if(result)
        NSLog(@"success");
}

- (BOOL)checkAddNewDiseaseSubscribe:(NSArray *)newList
{
    __block BOOL result = NO;
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select guideId,unReadCount from DiseaseSubList"]];
    NSMutableArray *cacheGuideId = [NSMutableArray arrayWithCapacity:15];
    while ([rs next]) {
        NSString *guideId = [rs stringForColumn:@"guideId"];
        [cacheGuideId addObject:guideId];
    }
    [newList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *newGuideId = obj[@"guideId"];
        BOOL compareResult = NO;
        for(NSString *originGuide in cacheGuideId)
        {
            if([originGuide isEqualToString:newGuideId]) {
                compareResult = YES;
                break;
            }
        }
        if(!compareResult)
        {
            *stop = YES;
            result = YES;
        }
    }];
    return result;
}

- (BOOL)checkAnyNewDiseaseSubscribe:(NSArray *)newList needUpdateHasRead:(BOOL)update
{
    //guideId
    __block BOOL result = NO;
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select guideId,unReadCount from DiseaseSubList"]];
    NSMutableArray *cacheGuideId = [NSMutableArray arrayWithCapacity:15];
    while ([rs next]) {
        NSString *guideId = [rs stringForColumn:@"guideId"];
        [cacheGuideId addObject:guideId];
    }
    [newList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *newGuideId = obj[@"guideId"];
        BOOL compareResult = NO;
        for(NSString *originGuide in cacheGuideId)
        {
            if([originGuide isEqualToString:newGuideId]) {
                compareResult = YES;
                break;
            }
        }
        if(!compareResult)
        {
            *stop = YES;
            result = YES;
        }
    }];
    if(!result)
    {
        rs = [_db executeQuery:[NSString stringWithFormat:@"select guideId,unReadCount from DiseaseSubList"]];
        __block NSMutableArray *cacheunArray = [rs resultArray];
        [newList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *newDict = (NSDictionary *)obj;
            BOOL compareResult = NO;
            for(NSDictionary *original in cacheunArray)
            {
                if([original[@"unReadCount"] isEqual:[NSNull null]])
                    continue;

                if([original[@"guideId"] isEqualToString:newDict[@"guideId"]]) {
                    if([original[@"unReadCount"] integerValue] != [newDict[@"unReadCount"] integerValue])
                    {
                        compareResult = YES;
                        break;
                    }
                }
            }
            if(compareResult)
            {
                result = YES;
                if (update) {
                    [self updateHasReadFromDiseaseWithId:newDict[@"guideId"] hasRead:NO];
                }
            }
//            else{
//                [self updateHasReadFromDiseaseWithId:newDict[@"guideId"] hasRead:NO];
//            }
        }];
    }

    return result;
}


- (BOOL)checkAllDiseaseReaded
{
    FMResultSet *rs;
    BOOL allHasRead = YES;
    rs = [_db executeQuery:[NSString stringWithFormat:@"select hasRead from DiseaseSubList"]];
    while ([rs next]) {
        BOOL hasRead = [rs boolForColumn:@"hasRead"];
        if (!hasRead) {
            allHasRead = NO;
            return allHasRead;
        }
    }
    return allHasRead;
}

- (NSMutableArray *)queryAllDiseaseSub
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from DiseaseSubList"]];

    NSMutableArray *arrDisease = [@[] mutableCopy];
    for (NSDictionary *dicDisease in [rs resultArray]) {
        NSString *strContent = @"";
        if ([dicDisease[@"content"] isKindOfClass:[NSString class]]) {
            strContent = dicDisease[@"content"];
        } else {
            strContent = @"";
        }
        
        NSString *strDisplayTime = @"";
        if ([dicDisease[@"displayTime"] isKindOfClass:[NSString class]]) {
            strDisplayTime = dicDisease[@"displayTime"];
        } else {
            strDisplayTime = @"";
        }
        
        NSDictionary *dicC = @{@"guideId": dicDisease[@"guideId"]
                               ,@"content": strContent
                               ,@"displayTime":strDisplayTime
                               ,@"title":dicDisease[@"title"]
                               ,@"unReadCount":dicDisease[@"unReadCount"]
                               ,@"hasRead":dicDisease[@"hasRead"]};
        [arrDisease addObject:dicC];
    }
    return arrDisease;
//    return [rs resultArray];
}

// 删除全部慢病资讯
- (void)deleteAllDiseaseSubList
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from DiseaseSubList"]];
    if(result)
        NSLog(@"success");
}

// 根据id删除慢病资讯
- (void)deleteDiseaseSubWithGuideId:(NSString *)strGuide
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from DiseaseSubList where guideId = '%@'",strGuide]];
    if(result)
        NSLog(@"success");
}

/*
 *  @brief 所有慢病订阅列表
 *  @paras attentionId 慢病id
 *         name 慢病名称
 *         selected 是否被用户添加 bool型
 */
- (void)updateDiseaseListWithAttentionId:(NSString *)attentionId
                                    name:(NSString *)name
                                selected:(NSInteger)selected;
{
    BOOL result = [_db executeUpdate:@"insert or replace into DiseaseAllList (attentionId,name,selected) values (?,?,?)",attentionId,name,[NSNumber numberWithInteger:selected]];
    if(result)
        NSLog(@"success");
}

- (void)updateDiseaseItemWithAttentionId:(NSString *)attentionId isSelected:(NSInteger)isSelected
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update DiseaseAllList set selected = '%@' where attentionId = '%@'",[NSString stringWithFormat:@"%d",isSelected],attentionId]];
    if(result)
        NSLog(@"success");
}

- (NSMutableArray *)queryDiseaseList
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from DiseaseAllList"]];
    return [rs resultArray];
}

// 删除慢病订阅列表
- (void)deleteAllDiseaseList
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete * from DiseaseAllList"]];
    if(result)
        NSLog(@"success");
}

#pragma mark - end 慢病

- (void)updateMessagesSendFailureWithJid:(NSString *)toJid timeStamp:(NSUInteger)timestamp
{
    BOOL result = [_db executeUpdate:@"update Messages set issend = 2 where timestamp = %@ and recvjid = '%@'",[NSNumber numberWithInt:timestamp],toJid];
    if(result)
        NSLog(@"success");
}

- (void)updateMessagesSendFailureWithJid:(NSString *)toJid
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update Messages set issend = 2 where issend = 0 and recvjid = '%@'",toJid]];
    if(result)
        NSLog(@"success");
}

- (NSMutableArray *)selectLastUpdateMessage
{
    FMResultSet *rs = [_db executeQuery:@"select * from HistoryMessages where messagekind = 1 group by relatedid union all select * from HistoryMessages where messagekind = 2 group by relatedid order by timestamp desc"];
    return [rs resultArray];
}


- (void)deleteHistoryMessages:(NSString *)relatedid isGroup:(NSUInteger)isGroup
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from HistoryMessages where relatedid = '%@' and messagekind = %@",relatedid,[NSNumber numberWithInt:isGroup]]];
    [self deleteMessagesWithJid:relatedid];
    if(result)
        NSLog(@"success");
}

- (void)deleteFromHistory
{
    BOOL result = [_db executeUpdate:@"delete from HistoryMessages"];
    if(result)
        NSLog(@"success");
}




- (void)deleteFromMessages
{
    BOOL result = [_db executeUpdate:@"delete from Messages"];
    if(result)
        NSLog(@"success");
}





- (NSMutableArray *)selectAllContacts
{
    FMResultSet *rs;
    rs = [_db executeQuery:@"select * from Contacts where subscription = 'both' order by jid"];
    return [rs resultArray];
}

- (NSMutableArray *)selectContactsWithoutJids:(NSArray *)jids
{
    NSMutableString *jidString = [NSMutableString string];
    for (NSString *jid in jids)
    {
        [jidString appendFormat:@"%@,",jid];
    }
    if([jidString length])
    jidString = [jidString substringToIndex:jidString.length - 1];
    
    FMResultSet *rs;
    rs = [_db executeQuery:@"select * from Contacts order by jid where jid not in (%@)",jidString];
    return [rs resultArray];
}

- (void)insertaddFirendList:(NSString *)jid
{
    BOOL result = [_db executeUpdate:@"insert or replace into addFirendList (addjid) values (?)",jid];
    if(result)
        NSLog(@"success");
}

- (NSUInteger)selectUnAddFriends
{
    FMResultSet *rs;
    rs = [_db executeQuery:@"select count(*) from addFirendList where status = '待添加'"];
    while ([rs next]) {
        return [rs intForColumn:@"count(*)"];
    }
    return 0;
}

- (void)updateAddFriendWithReaded
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update addFirendList set status = '%@' where status = '%@'",@"已查看",@"待添加"]];
    if(result)
        NSLog(@"success");
}

- (void)updateAddFriendHandle:(NSString *)jid WithStatus:(NSString *)status
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"update addFirendList set status = '%@' where addjid = '%@'",status,jid]];
    if(result)
        NSLog(@"success");
}

- (void)deleteJidFromAddFriend:(NSString *)jid
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from addFirendList where addjid = '%@'",jid]];
    if(result)
        NSLog(@"success");
}

- (NSString *)selectSubsciptionFromContacts:(NSString *)jid
{
    FMResultSet *rs;
    rs = [_db executeQuery:[NSString stringWithFormat:@"select subscription from Contacts where jid = '%@'",jid]];
    while ([rs next]) {
        return [rs stringForColumn:@"subscription"];
    }
    return nil;
}

- (NSString *)selectGroupIdFromHistroy:(NSString *)relatedid
{
    FMResultSet *rs;
    rs = [_db executeQuery:[NSString stringWithFormat:@"select groupId from HistoryMessages where relatedid = '%@'",relatedid]];
    while ([rs next]) {
        return [rs stringForColumn:@"groupId"];
    }
    return @"";
}

- (NSString *)selectAvatarUrlFromContacts:(NSString *)jid
{
    FMResultSet *rs;
    rs = [_db executeQuery:[NSString stringWithFormat:@"select avatar from Contacts where jid = '%@'",jid]];
    while ([rs next]) {
        return [rs stringForColumn:@"avatar"];
    }
    return nil;
}

- (NSMutableArray *)selectAddFriendList
{
    FMResultSet *rs;
    rs = [_db executeQuery:@"select * from addFirendList order by id desc"];
    return [rs resultArray];
}

- (void)insertContacts:(NSString *)jid
                  name:(NSString *)name
              nickname:(NSString *)nickname
          subscription:(NSString *)subscription
                 group:(NSString *)group
                   age:(NSNumber *)age
                   sex:(NSNumber *)sex
             signature:(NSString *)signature
                avatar:(NSString *)avatar
              videoImg:(NSString *)videoImg
{
    BOOL result = [_db executeUpdate:@"insert or replace into Contacts (jid,name,nickname,subscription,groups,age,sex,signature,avatar,videoimg) values (?,?,?,?,?,?,?,?,?,?)",jid,name,nickname,subscription,group,age,sex,signature,avatar,videoImg];
    if(result)
        NSLog(@"success");
}

- (void)deleteFromContacts
{
    BOOL result = [_db executeUpdate:@"delete from Contacts"];
    if(result)
        NSLog(@"success");
}

- (void)updateContacts:(NSString *)jid subscription:(NSString *)subscription
{
    BOOL result = [_db executeUpdate:@"update Contacts set subscription = '%@' where jid = '%@'",subscription,jid];
    if(result)
        NSLog(@"success");
}

- (void)deleteJidFromAddContacts:(NSString *)jid
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from Contacts where jid = '%@'",jid]];
    if(result)
        NSLog(@"success");

}

#pragma mark 健康方案列表缓存
/*
 ### 健康方案list列表 ### HealthPlanList
 id  健康方案 id
 desc 描述
 elementId
 imgPath 图片地址
 name 名字
 */
// 健康方案列表缓存
- (void)insertHealthPlanListWithPlanId:(NSString *)planId
                                  desc:(NSString *)desc
                             elementId:(NSString *)elementId
                               imgPath:(NSString *)imgPath
                                  name:(NSString *)name
{
    BOOL result = [_db executeUpdate:@"insert or replace into HealthPlanList (id,desc,elementId,imgPath,name) values (?,?,?,?,?)",planId,desc,elementId,imgPath,name];
    if(result)
        NSLog(@"success");
}
- (void)removeAllHealthPlan
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from HealthPlanList"]];
    if(result)
        NSLog(@"success");
}
- (NSMutableArray *)queryAllHealthPlan
{
    FMResultSet *rs = [_db executeQuery:@"select * from HealthPlanList"];
    return [rs resultArray];
}

#pragma mark - 快速自查列表
/*
 *  @brief 所有快速自查药品列表 QuickMedicineList
 *  @paras classId id
 *         name 药品名称
 *         classDesc 药品描述
 *         imgName  药品图片名称
 */
- (void)insertQucikSearchMedicinWithClassId:(NSString *)classId
                                description:(NSString *)classDesc
                                       name:(NSString *)name
                                    imgName:(NSString *)imgName
{
    BOOL result = [_db executeUpdate:@"insert or replace into QuickMedicineList (classId,name,classDesc,imgName) values (?,?,?,?)",classId,name,classDesc,imgName];
    if(result)
        NSLog(@"success");
}
- (void)removeAllQuickSearchMedicine
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete * from QuickMedicineList"]];
    if(result)
        NSLog(@"success");
}
- (NSMutableArray *)queryAllQuickSearchMedicineList
{
    FMResultSet *rs = [_db executeQuery:@"select * from QuickMedicineList order by classId asc"];
    return [rs resultArray];
}

/*
 *  @brief 所有快速自查药品分类列表 QuickMedicineTypeList
 *  @paras classId id
 *         name 药品名称
 *         classDesc 药品描述
 *         size  个数
 *         parentId 与药品列表关联的外键
 */
/*
 classDesc = "\U7279\U6b8a\U6cbb\U7597\U529f\U80fd\U7684\U836f\U7269\Uff0c\U6ca1\U6709\U660e\U786e\U7684\U7c7b\U522b\U5f52\U5c5e\U3002";
 classId = 0118;
 name = "\U5176\U4ed6\U836f";
 size = 1;
 */
- (void)insertQucikSearchMedicineTypeListWithClassId:(NSString *)classId
                                         description:(NSString *)classDesc
                                                name:(NSString *)name
                                                size:(NSString *)size
                                        childrenList:(NSArray *)arrChildrens
                                            parentID:(NSString *)parentId
{
    BOOL result = [_db executeUpdate:@"insert or replace into QuickMedicineTypeList (classId,name,classDesc,size,parentId) values (?,?,?,?,?)",classId,name,classDesc,size,parentId];
    for (int i = 0; i < arrChildrens.count; i++) {
        NSDictionary *dicSubList = arrChildrens[i];
        [self insertQucikSearchMedicineSubTypeListWithClassId:dicSubList[@"classId"]
                                                  description:dicSubList[@"classDesc"]
                                                         name:dicSubList[@"name"]
                                                  isFinalNode:dicSubList[@"isFinalNode"]
                                                     parentID:classId];
    }
    if(result)
        NSLog(@"success");
}
- (void)removeAllQuickSearchMedicineTypeList:(NSString *)classId
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete * from QuickMedicineTypeList"]];
    if(result)
        NSLog(@"success");
}
- (NSMutableArray *)queryAllQuickSearchMedicineTypeList:(NSString *)classId
{// @"select * from QuickMedicineTypeList"
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from QuickMedicineTypeList where parentId = '%@'",classId]];
    NSArray *arrAllDiseaseList = [rs resultArray];
    NSMutableArray *arrAll = [[NSMutableArray alloc] init];
    for (NSDictionary *dicDis in arrAllDiseaseList) {
        NSArray *arrSubList = [self queryAllQuickSearchMedicineSubTypeList:dicDis[@"classId"]];
        if (!arrSubList) {
            arrSubList = @[];
        }
        NSMutableDictionary *dicAllSub = [dicDis mutableCopy];
        [dicAllSub setObject:arrSubList forKey:@"childrens"];
        [arrAll addObject:dicAllSub];
    }
    return arrAll;
}

/*
 *  @brief 所有快速自查药品二级分类列表 QuickMedicineSubTypeList
 *  @paras classId id
 *         name 药品名称
 *         classDesc 药品描述
 *         isFinalNode  最后一个Node
 *         parentId 与快速自查药品分类列表关联的外键
 */
/*
 classDesc = "\U7279\U6b8a\U6cbb\U7597\U529f\U80fd\U7684\U836f\U7269\Uff0c\U6ca1\U6709\U660e\U786e\U7684\U7c7b\U522b\U5f52\U5c5e\U3002";
 classId = 011801;
 isFinalNode = Y;
 name = "\U5176\U4ed6\U836f";
 */
- (void)insertQucikSearchMedicineSubTypeListWithClassId:(NSString *)classId
                                            description:(NSString *)classDesc
                                                   name:(NSString *)name
                                            isFinalNode:(NSString *)isFinalNode
                                               parentID:(NSString *)parentId
{
    BOOL result = [_db executeUpdate:@"insert or replace into QuickMedicineSubTypeList (classId,name,classDesc,isFinalNode,parentId) values (?,?,?,?,?)",classId,name,classDesc,isFinalNode,parentId];
    if(result)
        NSLog(@"success");
}

- (void)removeAllQuickSearchMedicineSubTypeList:(NSString *)parentId
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from QuickMedicineSubTypeList"]];
    if(result)
        NSLog(@"success");
}

- (NSArray *)queryAllQuickSearchMedicineSubTypeList:(NSString *)parentId
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from QuickMedicineSubTypeList where parentId = '%@'",parentId]];
    return [rs resultArray];
}

/*
 *  @brief 所有快速自查疾病列表 QuickDiseaseList
 *  @paras classId id
 *         name 药品名称
 */

/*
 *  疾病
 */
- (void)insertQuickSearchDiseaseListWithClassId:(NSString *)classId
                                           name:(NSString *)name
                                       SubClass:(NSArray *)arrSubClass
{
    BOOL result = [_db executeUpdate:@"insert or replace into QuickDiseaseList (classId,name) values (?,?)",classId,name];
    for (int i = 0; i < arrSubClass.count; i++) {
        NSDictionary *dicSubList = arrSubClass[i];
        [self insertQuickSearchDiseaseSubListWithDiseaseId:dicSubList[@"diseaseId"]
                                                 classDesc:dicSubList[@"classDesc"]
                                                      name:dicSubList[@"name"]
                                                  parentId:classId];
    }
    
    if(result){}
}
- (void)removeAllQuickSearchDiseaseList
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete * from QuickDiseaseList"]];
    result = [_db executeUpdate:[NSString stringWithFormat:@"delete * from QuickDiseaseSubList"]];
    if(result){}
}

- (NSMutableArray *)queryAllQuickSearchDiseaseList
{
    FMResultSet *rs = [_db executeQuery:@"select * from QuickDiseaseList"];
    NSArray *arrAllDiseaseList = [rs resultArray];
    NSMutableArray *arrAll = [[NSMutableArray alloc] init];
    for (NSDictionary *dicDis in arrAllDiseaseList) {
        NSArray *arrSubList = [self queryAllQuickSearchDiseaseSubList:dicDis[@"classId"]];
        if (!arrSubList) {
            arrSubList = @[];
        }
        NSMutableDictionary *dicAllSub = [dicDis mutableCopy];
        [dicAllSub setObject:arrSubList forKey:@"subClass"];
        [arrAll addObject:dicAllSub];
    }
    return arrAll;
}

/*
 *  @brief 所有快速自查疾病二级列表 QuickDiseaseSubList
 *  @paras diseaseId id
 *         name 药品名称
 *         classDesc 药品描述
 *         parentId 外键，对应疾病列表classID
 */
- (void)insertQuickSearchDiseaseSubListWithDiseaseId:(NSString *)diseaseId
                                           classDesc:(NSString *)classDesc
                                                name:(NSString *)name
                                            parentId:(NSString *)parentId
{
    BOOL result = [_db executeUpdate:@"insert or replace into QuickDiseaseSubList (diseaseId,name,classDesc,parentId) values (?,?,?,?)",diseaseId,name,classDesc,parentId];
    if(result){}
}

- (NSArray *)queryAllQuickSearchDiseaseSubList:(NSString *)classId
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from QuickDiseaseSubList where parentId = '%@'",classId]];
    return [rs resultArray];
}

/*
 *  疾病百科
 */
/*
 *  @brief 所有快速自查疾病百科列表 QuickDiseaseWikiList
 *  @paras diseaseId id
 *         name 药品名称
 *         liter
 *         sortNo
 *         type
 */
- (void)insertQuickSearchDiseaseWikiListWithDiseaseId:(NSString *)diseaseId
                                                liter:(NSString *)liter
                                                 name:(NSString *)name
                                               sortNo:(NSString *)sortNo
                                                 type:(NSString *)type
{
    BOOL result = [_db executeUpdate:@"insert or replace into QuickDiseaseWikiList (diseaseId,liter,name,sortNo,type) values (?,?,?,?,?)",diseaseId,liter,name,sortNo,type];
    if(result){}
}
- (void)removeAllQuickSearchDiseaseWikiList
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete * from QuickDiseaseWikiList"]];
    if(result){}
}
- (NSArray *)queryAllQuickSearchDiseaseWikiList
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from QuickDiseaseWikiList"]];
    return [rs resultArray];
}

/*
 *  健康指标
 
 */
/*
 *  @brief 所有快速自查健康指标列表 QuickHealthIndicatorList
 *  @paras healthId id
 *         name 药品名称
 *         url 药品描述
 */
- (void)insertQuickSearchHealIndicatorListWithHealthId:(NSString *)healthId
                                                  name:(NSString *)name
                                                   url:(NSString *)url
{
    BOOL result = [_db executeUpdate:@"insert or replace into QuickHealthIndicatorList (healthId,name,url) values (?,?,?)",healthId,name,url];
    if(result)
        NSLog(@"success");
}
- (void)removeAllQuickSearchHealIndicatorList
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from QuickHealthIndicatorList"]];
    if(result)
        NSLog(@"success");
}
- (NSMutableArray *)queryAllQuickSearchHealthIndicatorList
{
    FMResultSet *rs = [_db executeQuery:@"select * from QuickHealthIndicatorList"];
    return [rs resultArray];
}

/*
 *  品牌展示
 */
/*
 *  @brief 所有快速自查品牌展示列表 QuickFactoryList
 *  @paras code 标示
 *         address 地址
 *         auth 药品描述
 *         imgUrl  描述
 *         desc
 *         name  描述
 */
- (void)insertQuickSearchFactoryDisplayListWithCode:(NSString *)code
                                            address:(NSString *)address
                                               auth:(NSString *)auth
                                               desc:(NSString *)desc
                                             imgUrl:(NSString *)imgUrl
                                               name:(NSString *)name
{
    if (desc == nil) {
        desc = @"";
    }
    if (address == nil) {
        address = @"";
    }
    BOOL result = [_db executeUpdate:@"insert or replace into QuickFactoryList (code,address,auth,imgUrl,desc,name) values (?,?,?,?,?,?)",code,address,auth,imgUrl,desc,name];
    if(result)
        NSLog(@"success");
}
- (void)removeAllQuickSearchFactoryDisplayList
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete * from QuickFactoryList"]];
    if(result)
        NSLog(@"success");
}
- (NSMutableArray *)queryAllQuickSearchFactoryList
{
    FMResultSet *rs = [_db executeQuery:@"select * from QuickFactoryList"];
    return [rs resultArray];
}

#pragma mark - 我的收藏
/*
 *  @brief 所有我的收藏药品列表   MyFavMedicineList
 *  @paras factory 工厂
 *         id 药品id
 *         proId
 *         proName
 *         spec
 */
- (void)insertMyFavMedicineListWithFactory:(NSString *)factory
                                        Id:(NSString *)factoryId
                                     proId:(NSString *)proId
                                   proName:(NSString *)proName
                                      spec:(NSString *)spec
{
    BOOL result = [_db executeUpdate:@"insert or replace into MyFavMedicineList (factory,id,proId,proName,spec) values (?,?,?,?,?)",factory,factoryId,proId,proName,spec];
    if(result)
        NSLog(@"success");
}
- (void)removeAllMyFavMedicineList
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete * from MyFavMedicineList"]];
    if(result)
        NSLog(@"success");
}
- (NSArray *)queryAllMyFavMedicineList
{
    FMResultSet *rs = [_db executeQuery:@"select * from MyFavMedicineList"];
    return [rs resultArray];
}

/**
 *  缓存我的订单列表
 *
 *  @param orderId  订单id
 *  @param branch   药店名称
 *  @param price    价格
 *  @param proName  商品名称
 *  @param quantity 数量
 *  @param type     优惠券类型
 *  @param date     日期
 */

- (void)insertMyOrderListWithOrderId:(NSString *)orderId
                            proName:(NSString *)proName
                            type:(NSString *)type
                            date:(NSString *)date
                            discount:(NSString *)discount
                            totalLargess:(NSString *)totalLargess
{
    BOOL result = [_db executeUpdate:@"insert or replace into MyOrderList(id,proName,type,date,discount,totalLargess) values (?,?,?,?,?,?)",orderId,proName,type,date,discount,totalLargess];
    if (result) {
        NSLog(@"success");
    }
}

/**
 *  删除我的订单列表缓存
 */
- (void)removeAllMyOrderList
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from MyOrderList"]];
    if (result) {
        NSLog(@"success");
    }
}
/**
 *  查询我的订单列表缓存
 *
 *  @return 订单缓存数组
 */
- (NSArray *)queryAllMyOrderList
{
    FMResultSet *re = [_db executeQuery:@"select * from MyOrderList"];
    return [re resultArray];
}


- (void)myFavStoreList:(NSString *)storeId
                  name:(NSString *)name
                  star:(NSString *)star
               avgStar:(NSString *)avgStar
               consult:(NSString *)consult
               accType:(NSString *)accType
                   tel:(NSString *)tel
              province:(NSString *)province
                  city:(NSString *)city
                county:(NSString *)county
                  addr:(NSString *)addr
              distance:(NSString *)distance
                imgUrl:(NSString *)imgUrl
             accountId:(NSString *)accountId
                  tags:(NSString *)tags
             shortName:(NSString *)shortName
{
    BOOL result = [_db executeUpdate:@"insert or replace into myFavStoreList(id,name,star,avgStar,consult,accType,tel,province,city,county,addr,distance,imgUrl,accountId,tags,shortName) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",storeId,name,star,avgStar,consult,accType,tel,province,city,county,addr,distance,imgUrl,accountId,tags,shortName];
    if(result)
        NSLog(@"success");
}

- (void)removeAllMyFavStoreList
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from myFavStoreList"]];
    if (result) {
        NSLog(@"success");
    }
}
- (NSMutableArray *)queryAllMyFavStoreList
{
    FMResultSet *re = [_db executeQuery:@"select * from myFavStoreList"];
    return [re resultArray];
}



/*
 *  @brief 所有我的收藏症状列表   MyFavSymptonList
 *  @paras desc 描述
 *         name
 *         population
 *         sex
 *         spmCode
 */

- (void)insertMyFavSymptonListWithDesc:(NSString *)desc
                                  name:(NSString *)name
                            population:(NSString *)population
                                   sex:(NSString *)sex
                               spmCode:(NSString *)spmCode
{
    BOOL result = [_db executeUpdate:@"insert or replace into MyFavSymptonList (desc,name,population,sex,spmCode) values (?,?,?,?,?)",desc,name,population,sex,spmCode];
    if(result)
        NSLog(@"success");
}
- (void)removeAllMyFavSymptonList
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from MyFavSymptonList"]];
    if(result)
        NSLog(@"success");
}
- (NSArray *)queryAllMyFavSymptonList
{
    FMResultSet *rs = [_db executeQuery:@"select * from MyFavSymptonList"];
    return [rs resultArray];
}

/*
 *  @brief 所有我的收藏疾病列表   MyFavDiseaseList
 *  @paras cname 描述
 *         desc
 *         diseaseId    疾病id
 *         ename
 *         type
 */

- (void)insertMyFavDiseaseListWithDiseaseId:(NSString *)diseaseId
                                      cname:(NSString *)cname
                                       desc:(NSString *)desc
                                      ename:(NSString *)ename
                                       type:(NSString *)type
{
    BOOL result = [_db executeUpdate:@"insert or replace into MyFavDiseaseList (diseaseId,cname,desc,ename,type) values (?,?,?,?,?)",diseaseId,cname,desc,ename,type];
    if(result)
        NSLog(@"success");
}
- (void)removeAllMyFavDiseaseList
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from MyFavDiseaseList"]];
    if(result)
        NSLog(@"success");
}
- (NSArray *)queryAllMyFavDiseaseList
{
    FMResultSet *rs = [_db executeQuery:@"select * from MyFavDiseaseList"];
    return [rs resultArray];
}

/*
 *  @brief 所有我的收藏资讯列表   MyFavMessageList
 *  @paras adviceId 资讯id
 *         iconUrl
 *         imgUrl
 *         introduction
 *         likeNumber
 *         pariseNum
 *         publishTime
 *         publisher
 *         readNum
 *         title
 */

- (void)insertMyFavMessageListWithAdviceId:(NSString *)adviceId
                                   iconUrl:(NSString *)iconUrl
                                    imgUrl:(NSString *)imgUrl
                              introduction:(NSString *)introduction
                                likeNumber:(NSString *)likeNumber
                                 pariseNum:(NSString *)pariseNum
                               publishTime:(NSString *)publishTime
                                 publisher:(NSString *)publisher
                                   readNum:(NSString *)readNum
                                     title:(NSString *)title
{
    BOOL result = [_db executeUpdate:@"insert or replace into MyFavMessageList (adviceId,iconUrl,imgUrl,introduction,likeNumber,pariseNum,publishTime,publisher,readNum,title) values (?,?,?,?,?,?,?,?,?,?)",adviceId,iconUrl,imgUrl,introduction,likeNumber,pariseNum,publishTime,publisher,readNum,title];
    if(result)
        NSLog(@"success");
}
- (void)removeAllMyFavMessageList
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from MyFavMessageList"]];
    if(result)
        NSLog(@"success");
}

- (NSArray *)queryAllMyFavMessageList
{
    FMResultSet *rs = [_db executeQuery:@"select * from MyFavMessageList"];
    return [rs resultArray];
}


//插入常见问题Channel
- (void)insertIntoFamiliarQuestionChannel:(NSString *)classId
                              channelName:(NSString *)name
                                 moduleId:(NSString *)moduleId
{
    BOOL result = [_db executeUpdate:@"insert or replace into FamiliarQuestionChannelList (classId,name,moduleId) values (?,?,?)",classId,name,moduleId];
    if(result)
        NSLog(@"success");
}
//删除所有的channel
- (void)removeAllFamiliarQuestionChannelWithModuleId:(NSString *)moduleId
{
    NSArray *arrAllChannel = [self queryCachedFamiliarQuestionChannelListWithModuleId:moduleId];
    for (NSDictionary *dicChannel in arrAllChannel) {
        [self removeFamiliarQuestionListWithClassId:dicChannel[@"classID"] moduleId:moduleId];
    }
    BOOL result = [_db executeUpdate:@"delete from FamiliarQuestionChannelList where moduleId = '%@'",moduleId];
    if(result)
        NSLog(@"success");
}

//查询channel列表
- (NSArray *)queryCachedFamiliarQuestionChannelListWithModuleId:(NSString *)moduleId
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from FamiliarQuestionChannelList where moduleId = '%@'",moduleId]];
    NSMutableArray *arrChannel = [@[] mutableCopy];
    for (NSDictionary *dicChannel in [rs resultArray]) {
        NSDictionary *dicC = @{@"classId": dicChannel[@"classId"]
                               ,@"name": dicChannel[@"name"]
                               ,@"moduleId":dicChannel[@"moduleId"]
                               };
        [arrChannel addObject:dicC];
    }
    return arrChannel;
}



//插入常见问题列表
- (void)insertIntoFamiliarQuestionListWithTeamId:(NSString *)teamId
                                           answer:(NSString *)answer
                                         question:(NSString *)question
                                          classId:(NSString *)classId
                                         moduleId:(NSString *)moduleId
                                           imgUrl:(NSString *)imgUrl
{
    BOOL result = [_db executeUpdate:@"insert or replace into FamiliarQuestionList(teamId,classId,answer,question,moduleId,imgUrl) values (?,?,?,?,?,?)",teamId,classId,answer,question,moduleId,imgUrl];
    if(result)
        NSLog(@"success");
}

//查询常见问题的列表
- (NSArray *)queryAllFamiliarQuestionListWithClassId:(NSString *)classId moduleId:(NSString *)moduleId
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from FamiliarQuestionList where classId = '%@' and moduleId = '%@'",classId,moduleId]];
    return [rs resultArray];
}

//删除常见问题的列表
- (void)removeFamiliarQuestionListWithClassId:(NSString *)classID moduleId:(NSString *)moduleId
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from FamiliarQuestionList where classId = '%@' and moduleId = '%@'",classID,moduleId]];
    if(result)
        NSLog(@"success");
}


//插入问题详情列表
- (void)insertIntoFamiliarQuestionDetailWithTeamId:(NSString *)teamId
                                           classId:(NSString *)classId
                                           content:(NSString *)content
                                              role:(NSString *)role
                                            imgUrl:(NSString *)imgUrl
{
    BOOL result = [_db executeUpdate:@"insert into FamiliarQuestionDetail(teamId,classId,content,role,imgUrl) values (?,?,?,?,?)",teamId,classId,content,role,imgUrl];
    if(result)
        NSLog(@"success");

}

//查询问题详情列表
- (NSArray *)queryAllFamiliarQuestionDetailWithClassId:(NSString *)classId teamId:(NSString *)teamId
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from FamiliarQuestionDetail where classId = '%@' and teamId = '%@'",classId,teamId]];
    return [rs resultArray];
}

//删除问题详情列表
- (void)removeFamiliarQuestionDetailWithClassId:(NSString *)classID teamId:(NSString *)teamId
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from FamiliarQuestionDetail where classId = '%@' and teamId = '%@'",classID,teamId]];
    if(result)
        NSLog(@"success");
}

/**
 *  免费问药附近药店列表
 @"create table if not exists ConsultNearPharmacyList (id text, distance text, addr text, accType text, addr text, accountId text, avgStar text, city text, code text, consult text, distance text, imgUrl text, latitude text, longitude text, name text, star text, tel texxt)"
 */
- (void)insertIntoConsultNearPharmacyWithDic:(NSDictionary *)dicPharmacy
{
    BOOL result = [_db executeUpdate:@"insert into ConsultNearPharmacyList(id,distance,addr,accType,accountId,avgStar,city,code,consult,distance,imgUrl,latitude,longitude,name,star,tel) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", dicPharmacy[@"id"],dicPharmacy[@"distance"],dicPharmacy[@"addr"],dicPharmacy[@"accType"],dicPharmacy[@"accountId"],dicPharmacy[@"avgStar"],dicPharmacy[@"city"],dicPharmacy[@"code"],dicPharmacy[@"consult"],dicPharmacy[@"distance"],dicPharmacy[@"imgUrl"],dicPharmacy[@"latitude"],dicPharmacy[@"longitude"],dicPharmacy[@"name"],dicPharmacy[@"star"],dicPharmacy[@"tel"]];
    if(result)
        NSLog(@"success");
}
- (NSArray *)quearAllConsultNearPharmacy
{
    FMResultSet *rs = [_db executeQuery:[NSString stringWithFormat:@"select * from ConsultNearPharmacyList"]];
    return [rs resultArray];
}
- (void)removeAllNearPharmacyList
{
    BOOL result = [_db executeUpdate:[NSString stringWithFormat:@"delete from ConsultNearPharmacyList"]];
    if(result)
        NSLog(@"success");
}


@end
