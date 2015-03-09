//
//  DataBase.h
//  iPhoneXMPP
//
//  Created by xiezhenghong on 14-3-10.
//
//

#import <Foundation/Foundation.h>

@interface DataBase : NSObject

- (id)initWithPath:(NSString *)path;
-(void)createAllTable;
- (void)createCacheTable;

//联系人表的增删查改
- (NSMutableArray *)selectAllContacts;
- (NSMutableArray *)selectAllStoreList;
- (NSUInteger)selectTotalUnreadCountMessage;

- (BOOL)getMessageSendStatus:(NSString *)UUID;
- (void)updateSendingMessageToFailure;
- (NSMutableArray *)selectAllCityList;
- (void)insertIntoCityList:(NSString *)cityId
                  province:(NSString *)province
              provinceName:(NSString *)provinceName
                      city:(NSString *)city
                  cityName:(NSString *)cityName
                      open:(NSString *)open
                    remark:(NSString *)remark
                      code:(NSString *)code;
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
                  shortName:(NSString *)shortName;
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
                       tags:(NSString *)tags;
- (void)removeAllSearchStoreHistory;
- (NSMutableArray *)queryAllSearchStoreHistory;
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
                            shortName:(NSString *)shortName;
- (void)removeAllMyFavStoreList;
- (NSMutableArray *)queryAllMyFavStoreList;
- (BOOL)checkCityInOpen:(NSString *)cityName;
- (NSString *)selectCurrentCityName;
- (void)updateCitySelectedStatus:(NSString *)cityName;
- (void)deleteAllStoreList;
- (void)updateLastMessageTimestamp:(NSString *)timeStamp;

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
                  body:(NSString *)body;

- (void)deleteFromofficialMessages;
- (NSUInteger)selectUnreadCountOfficialMessage;
- (void)setOfficialMessagesRead;

- (void)setHistoryStick:(NSString *)relatedid;
- (void)cancelHistoryStick:(NSString *)relatedid;

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
             intervalDay:(NSString *)intervalDay;

- (BOOL)checkValidMedicine;
- (NSMutableArray *)selectAllBoxMedicine;
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
          productEffect:(NSString *)productEffect;


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
                                tags:(NSString *)tags;

- (NSMutableArray *)selectALLRecommendStoreList;
- (void)deleteRecommendAllStoreList;
- (void)forceInsertHistorys:(NSString *)relatedid
                  timestamp:(NSString *)timestamp
                       body:(NSString *)body
                  direction:(NSNumber *)direction
                messagetype:(NSNumber *)messagetype
                       UUID:(NSString *)UUID
                     issend:(NSNumber *)issend
                  avatarUrl:(NSString *)avatarUrl;

- (void)updateMessageEvaluate:(NSString *)status With:(NSString *)UUID;
- (void)setAllMessageReaded;
- (NSMutableArray *)selectTagList:(NSString *)UUID;
- (BOOL)insertIntoofficialMessages:(NSString *)formId
                              toId:(NSString *)toId
                         timestamp:(NSString *)timestamp
                              body:(NSString *)body
                         direction:(NSNumber *)direction
                       messagetype:(NSNumber *)messagetype
                              UUID:(NSString *)UUID
                            issend:(NSNumber *)issend
                         relatedid:(NSString *)relatedid;
- (NSMutableArray *)selectOfficialMessages;
- (NSDictionary *)selectLastOneUpdateOfficialMessage;

- (void)deleteAlarmClock:(NSString *)boxId;
- (BOOL)checkAlarmClock:(NSString *)boxId;

- (NSMutableDictionary *)selectAlarmClock:(NSString *)boxId;

- (void)updateMessageStatus:(NSNumber *)status timeStamp:(NSString *)timeStamp With:(NSString *)UUID;

- (void)deleteFromMessagesWithUUID:(NSString *)UUID;
- (void)deleteFromMessagesWithSendName:(NSString *)sendname;
- (NSMutableArray *)selectAllMessagesWithSendName:(NSString *)jid;

- (NSMutableArray *)selectAllHistroy;
- (NSMutableArray *)selectAllRelatedid;

- (void)insertHistorys:(NSString *)relatedid
             timestamp:(NSString *)timestamp
                  body:(NSString *)body
             direction:(NSNumber *)direction
           messagetype:(NSNumber *)messagetype
                  UUID:(NSString *)UUID
                issend:(NSNumber *)issend
             avatarUrl:(NSString *)avatarUrl;

- (void)updateHistory:(NSString *)relatedid
            avatarurl:(NSString *)avatarurl
            groupName:(NSString *)groupName
            groupType:(NSNumber *)groupType
              groupId:(NSString *)groupId;

- (NSString *)selectGroupIdFromHistroy:(NSString *)relatedid;

- (void)deleteFromHistoryWithUUID:(NSString *)UUID;


- (void)deleteFromRoom:(NSString *)groupId;

- (void)deleteFromContacts;

- (NSMutableArray *)selectAddFriendList;
- (void)insertaddFirendList:(NSString *)jid;
- (void)deleteFromHistory;
- (void)deleteFromMessages;

- (void)deleteAllProblemModule;
- (NSMutableArray *)selectAllProblemModule;
- (void)insertIntoProblemModule:(NSString *)imgUrl
                       moduleId:(NSString *)moduleId
                           name:(NSString *)name;


- (void)insertNewGroup:(NSString *)name
                roomId:(NSString *)roomid
           description:(NSString *)description
             maxnumber:(NSString *)maxnumber
                avatar:(NSString *)avatar
                  area:(NSString *)area
                  city:(NSString *)city
              category:(NSString *)category
            createTime:(NSNumber *)timestamp;

- (NSMutableArray *)selectContactsWithoutJids:(NSArray *)jids;
- (void)updateGroupHostId:(NSString *)hostId withRoomId:(NSString *)roomId;
- (NSUInteger)selectUnAddFriends;
- (void)deleteFromRoom:(NSString *)groupId;
- (void)deleteFromAllGroupMemberList:(NSString *)groupid;
- (NSString *)selectSubsciptionFromContacts:(NSString *)jid;
- (NSString *)selectAvatarUrlFromContacts:(NSString *)jid;
- (NSMutableArray *)selectLastUpdateMessage;
- (void)updateMessagesSendSuccessWithJid:(NSString *)toJid timeStamp:(NSUInteger)timestamp;
- (void)updateMessagesSendFailureWithJid:(NSString *)toJid timeStamp:(NSUInteger)timestamp;
- (void)updateMessagesSendFailureWithJid:(NSString *)toJid;
- (void)updateAddFriendHandle:(NSString *)jid WithStatus:(NSString *)status;
- (void)deleteJidFromAddFriend:(NSString *)jid;
- (void)deleteHistoryMessages:(NSString *)relatedid;
- (void)deleteJidFromAddContacts:(NSString *)jid;
- (void)updateContacts:(NSString *)jid subscription:(NSString *)subscription;
- (void)updateLastHistoryMessage:(NSString *)relatedid;

- (void)deleteFromOfficialMessages;
- (void)insertIntoAlarmCallTime:(NSString *)boxId
                      timeStamp:(NSString *)timeStamp;

- (NSDictionary *)checkExistedTime:(NSString *)timeStamp;

- (NSMutableArray *)selectMemberListFromGroups:(NSString *)groupjid;

- (void)updateHistoryMessageWithRelatedid:(NSString *)relatedid
                                timestamp:(NSUInteger)timestamp
                                     body:(NSString *)body
                                direction:(NSUInteger)direction
                              messagetype:(NSUInteger)messagetype
                              messagekind:(NSUInteger)messagekind;

- (void)updateOfficial:(NSString *)UUID
            sendStatus:(NSNumber *)sendStatus;

- (void)insertIntoTagList:(NSString *)UUID
                    start:(NSNumber *)start
                   length:(NSNumber *)length
                  tagType:(NSNumber *)tagType
                    title:(NSString *)title
                    tagId:(NSString *)tagId;


- (NSUInteger)selectUnreadCountMessage:(NSString *)relatedid;
- (NSUInteger)selectAllUnreadCountMessage;
- (void)setMessagesReadWithRelatedId:(NSString *)relatedid;

- (NSMutableArray *)selectRelatedidWithoutGroupname;
- (void)deleteFromMessagesWithName:(NSString *)sendname;
- (void)deleteFromHistoryWithRelatedId:(NSString *)relatedid;
- (NSMutableArray *)selectHistoryWith:(NSString *)relatedid;

- (void)updateGroudMessageReadedWith:(NSString *)groupJid;
- (void)insertHistoryMessageWithRelatedid:(NSString *)relatedid
                                timestamp:(NSUInteger)timestamp
                                     body:(NSString *)body
                                direction:(NSUInteger)direction
                              messagetype:(NSUInteger)messagetype
                              messagekind:(NSUInteger)messagekind;
- (NSUInteger)selectUnreadMessagesCountWithGroupJid:(NSString *)jid;
- (void)deleteFromgroupMemberList:(NSString *)jid groupJid:(NSString *)groupjid;
- (void)deleteHistoryMessages:(NSString *)relatedid isGroup:(NSUInteger)isGroup;
- (NSMutableArray *)selectAllGroupsJid;
- (void)insertgroupMemberList:(NSString *)jid
                     groupJid:(NSString *)groupjid
                     nickname:(NSString *)nickname
                    moderator:(NSUInteger)moderator
               lastUpdateTime:(NSUInteger)lastUpdateTime;
- (void)deleteGroupMessagesWithJid:(NSString *)jidString;
- (NSDictionary *)selectLastOnegroupUpdateMessages:(NSString *)fromJid;
- (NSUInteger)selectUnreadMessagesCountWithJid:(NSString *)jid;
- (NSMutableArray *)selectPersonalTotalMessages:(NSString *)fromJid;
- (NSMutableArray *)selectGroupTotalMessages:(NSString *)fromJid;
- (void)deleteMessagesWithJid:(NSString *)jidString;
- (void)updateAllMessageReadedWithJid:(NSString *)recvjid;
- (NSDictionary *)selectLastOneUpdateMessages:(NSString *)fromJid;
- (void)deleteCityList;
// 慢病订阅
- (void)updateDiseaseSubWithArr:(NSArray *)arrDisease;
- (BOOL)getHasReadFromDiseaseSubWithGuideId:(NSString *)guideId;
- (BOOL)getDiseaseFromDiseaseSubWithGuideId:(NSString *)guideId;
- (void)updateHasReadFromDiseaseWithId:(NSString *)guideId hasRead:(BOOL)hasRead;
- (NSMutableArray *)queryAllDiseaseSub;
- (BOOL)checkAllDiseaseReaded;
- (BOOL)checkAddNewDiseaseSubscribe:(NSArray *)newList;
- (BOOL)checkAnyNewDiseaseSubscribe:(NSArray *)newList needUpdateHasRead:(BOOL)update;
- (void)deleteAllDiseaseSubList;
- (void)deleteDiseaseSubWithGuideId:(NSString *)strGuide;
- (void)updateDiseaseListWithAttentionId:(NSString *)attentionId
                                    name:(NSString *)name
                                selected:(NSInteger)selected;
- (void)updateDiseaseItemWithAttentionId:(NSString *)attentionId isSelected:(NSInteger)isSelected;

- (NSMutableArray *)queryDiseaseList;
- (void)deleteAllDiseaseList;
// TODO
- (void)updateAddedDiseaseList;
- (void)queryAddedDiseaseList;
// 健康资讯列表缓存
- (void)insertIntoHealthChannel:(NSString *)channelId
                    channelName:(NSString *)channelName
                           sort:(NSInteger)sort;
- (NSArray *)queryCachedHealthChannelList;
- (void)removeAllChannel;

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
                             title:(NSString *)title;
- (NSArray *)queryAllHealthAdviceListWithChannelId:(NSString *)channelID;
- (void)removeHealthAdviceListWithChannelId:(NSString *)channelID;
- (void)updareHealthAdvicePariseNum:(NSInteger)pariseNum AdviceId:(NSString *)adviceId;

- (void)insertIntoHealthBannerList:(NSString *)channelID
                          adviceId:(NSString *)adviceId
                      bannerImgUrl:(NSString *)bannerImgUrl;
- (NSArray *)queryAllBannerListWithChannelId:(NSString *)channelId;
- (void)removeAllBannerListWithChannelId:(NSString *)channelId;

// 健康方案列表缓存
- (void)insertHealthPlanListWithPlanId:(NSString *)planId
                                  desc:(NSString *)desc
                             elementId:(NSString *)elementId
                               imgPath:(NSString *)imgPath
                                  name:(NSString *)name;
- (void)removeAllHealthPlan;
- (NSMutableArray *)queryAllHealthPlan;

// 快速自查列表缓存
/*
 *  药品列表缓存
 */
- (void)insertQucikSearchMedicinWithClassId:(NSString *)classId
                                description:(NSString *)classDesc
                                       name:(NSString *)name
                                    imgName:(NSString *)imgName;
- (void)removeAllQuickSearchMedicine;
- (NSMutableArray *)queryAllQuickSearchMedicineList;

- (void)insertQucikSearchMedicineTypeListWithClassId:(NSString *)classId
                                         description:(NSString *)classDesc
                                                name:(NSString *)name
                                                size:(NSString *)size
                                        childrenList:(NSArray *)arrChildrens
                                            parentID:(NSString *)parentId;
- (void)removeAllQuickSearchMedicineTypeList:(NSString *)classId;
- (NSMutableArray *)queryAllQuickSearchMedicineTypeList:(NSString *)classId;
/*
 *  健康指标
 */
- (void)insertQuickSearchHealIndicatorListWithHealthId:(NSString *)healthId
                                                   name:(NSString *)name
                                                    url:(NSString *)url;
- (void)removeAllQuickSearchHealIndicatorList;
- (NSMutableArray *)queryAllQuickSearchHealthIndicatorList;



/*
 *  疾病
 */
- (void)insertQuickSearchDiseaseListWithClassId:(NSString *)classId
                                           name:(NSString *)name
                                       SubClass:(NSArray *)arrSubClass;
- (void)removeAllQuickSearchDiseaseList;
- (NSMutableArray *)queryAllQuickSearchDiseaseList;


/*
 *  疾病百科
 */
- (void)insertQuickSearchDiseaseWikiListWithDiseaseId:(NSString *)diseaseId
                                                liter:(NSString *)liter
                                                 name:(NSString *)name
                                               sortNo:(NSString *)sortNo
                                                 type:(NSString *)type;
- (void)removeAllQuickSearchDiseaseWikiList;
- (NSArray *)queryAllQuickSearchDiseaseWikiList;

/*
 *  症状
 */

/*
 *  品牌展示
 */
- (void)insertQuickSearchFactoryDisplayListWithCode:(NSString *)code
                                            address:(NSString *)address
                                               auth:(NSString *)auth
                                               desc:(NSString *)desc
                                             imgUrl:(NSString *)imgUrl
                                               name:(NSString *)name;
- (void)removeAllQuickSearchFactoryDisplayList;
- (NSMutableArray *)queryAllQuickSearchFactoryList;

/*
 *  我的收藏               药品  factory = "\U6c5f\U82cf";
 id = e95a58e8196c31b19092347bea80891b;
 proId = 700116;
 proName = "\U82cd\U672f\Uff08\U9eb8\U7092\Uff09";
 spec = 1g;
 
 症状
 desc = "\U53e3\U751c\Uff0c\U53c8\U79f0\U201c\U53e3\U7518\U201d\U3002\U662f\U53e3\U4e2d\U81ea\U89c9\U6709\U751c\U5473\Uff0c\U5373\U4f7f\U559d\U767d\U5f00\U6c34\U4e5f\U89c9\U751c\Uff0c\U6216\U751c\U800c\U5e26\U9178\U3002\U591a\U89c1\U4e8e\U5e73\U7d20\U55dc\U98df\U7518\U80a5\U539a\U5473\U7684\U4eba\U3002";
 name = "\U53e3\U751c";
 population = 1;
 sex = 0;
 spmCode = 000091;
 
 疾病
 cname = "\U5931\U7720";
 desc = "\U5931\U7720\U662f\U6307\U65e0\U6cd5\U5165\U7761\U6216\U65e0\U6cd5\U4fdd\U6301\U7761\U7720\U72b6\U6001\Uff0c\U8868\U73b0\U4e3a\U5165\U7761\U56f0\U96be\U3001\U6613\U9192\U3001\U8fc7\U65e9\U82cf\U9192\Uff0c\U5bfc\U81f4\U7761\U7720\U65f6\U95f4\U51cf\U5c11\U6216\U8d28\U91cf\U4e0b\U964d\Uff0c\U4e0d\U80fd\U6ee1\U8db3\U4e2a\U4f53\U751f\U7406\U9700\U8981\U3002";
 diseaseId = 1001;
 ename = "\U5931\U7720";
 type = A;
 
 资讯
 adviceId = 121d5cc5b51040f2ae3d24d4fb576f66;
 iconUrl = "http://img.qwysfw.cn/subject/h/o/o9/l4f574q5a-85_79.png";
 imgUrl = "http://img.qwysfw.cn/subject/h/o/o9/l4f574q5a-85_79.png";
 introduction = "\U4e0a\U6d77\U5065\U8015\U533b\U836f\U79d1\U6280";
 likeNumber = 0;
 pariseNum = 1;
 publishTime = "2014-11-19 19:11";
 publisher = "\U4efb\U51a0\U79b9";
 readNum = 14;
 title = "\U4e0a\U6d77\U5065\U8015\U533b\U836f\U79d1\U6280";
 
 */
- (void)insertMyFavMedicineListWithFactory:(NSString *)factory
                                        Id:(NSString *)factoryId
                                     proId:(NSString *)proId
                                   proName:(NSString *)proName
                                      spec:(NSString *)spec;
- (void)removeAllMyFavMedicineList;
- (NSArray *)queryAllMyFavMedicineList;

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
                        totalLargess:(NSString *)totalLargess;
/**
 *  删除我的订单列表缓存
 */
- (void)removeAllMyOrderList;
/**
 *  查询我的订单列表缓存
 *
 *  @return 订单缓存数组
 */
- (NSArray *)queryAllMyOrderList;

- (void)insertMyFavSymptonListWithDesc:(NSString *)desc
                                  name:(NSString *)name
                            population:(NSString *)population
                                   sex:(NSString *)sex
                               spmCode:(NSString *)spmCode;
- (void)removeAllMyFavSymptonList;
- (NSArray *)queryAllMyFavSymptonList;

- (void)insertMyFavDiseaseListWithDiseaseId:(NSString *)diseaseId
                                      cname:(NSString *)cname
                                       desc:(NSString *)desc
                                      ename:(NSString *)ename
                                       type:(NSString *)type;
- (void)removeAllMyFavDiseaseList;
- (NSArray *)queryAllMyFavDiseaseList;

- (void)insertMyFavMessageListWithAdviceId:(NSString *)adviceId
                                   iconUrl:(NSString *)iconUrl
                                    imgUrl:(NSString *)imgUrl
                              introduction:(NSString *)introduction
                                likeNumber:(NSString *)likeNumber
                                 pariseNum:(NSString *)pariseNum
                               publishTime:(NSString *)publishTime
                                 publisher:(NSString *)publisher
                                   readNum:(NSString *)readNum
                                     title:(NSString *)title;
- (void)removeAllMyFavMessageList;
- (NSArray *)queryAllMyFavMessageList;


//插入常见问题Channel
- (void)insertIntoFamiliarQuestionChannel:(NSString *)classId
                              channelName:(NSString *)name
                                 moduleId:(NSString *)moduleId;

//删除所有的channel
- (void)removeAllFamiliarQuestionChannelWithModuleId:(NSString *)moduleId;


//查询channel列表
- (NSArray *)queryCachedFamiliarQuestionChannelListWithModuleId:(NSString *)moduleId;




//插入常见问题列表
- (void)insertIntoFamiliarQuestionListWithTeamId:(NSString *)teamId
                                          answer:(NSString *)answer
                                        question:(NSString *)question
                                         classId:(NSString *)classId
                                        moduleId:(NSString *)moduleId
                                          imgUrl:(NSString *)imgUrl;

//查询常见问题的列表
- (NSArray *)queryAllFamiliarQuestionListWithClassId:(NSString *)classId
                                            moduleId:(NSString *)moduleId;


//删除常见问题的列表
- (void)removeFamiliarQuestionListWithClassId:(NSString *)classID
                                     moduleId:(NSString *)moduleId;


//插入问题详情列表
- (void)insertIntoFamiliarQuestionDetailWithTeamId:(NSString *)teamId
                                           classId:(NSString *)classId
                                           content:(NSString *)content
                                              role:(NSString *)role
                                            imgUrl:(NSString *)imgUrl;

//查询问题详情列表
- (NSArray *)queryAllFamiliarQuestionDetailWithClassId:(NSString *)classId
                                                teamId:(NSString *)teamId;

//删除问题详情列表
- (void)removeFamiliarQuestionDetailWithClassId:(NSString *)classID
                                         teamId:(NSString *)teamId;


/**
 *  免费问药附近药店列表
 */
- (void)insertIntoConsultNearPharmacyWithDic:(NSDictionary *)dicPharmacy;
- (NSArray *)quearAllConsultNearPharmacy;
- (void)removeAllNearPharmacyList;

/**
 *  常备必知列表
 */
- (void)insertIntoUsallyKnowledge:(NSMutableArray *)array classId:(NSString *)classId;
- (NSMutableArray *)selectUsallyKnowledge:(NSString *)classId;
- (void)removeAllUsallyKnowledge:(NSString *)classId;

/**
 *  常备药品列表
 */
- (void)insertIntoUsallyDrug:(NSMutableArray *)array classId:(NSString *)classId;
- (NSMutableArray *)selectUsallyDrug:(NSString *)classId;
- (void)removeAllUsallyDrug:(NSString *)classId;

@end
