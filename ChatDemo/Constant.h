//
//  Constant.h
//  quanzhi
//
//  Created by xiezhenghong on 14-5-30.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//
//  https://www.flinto.com/p/65f3c28f  //产品Web原型图
//  m.myquanwei.com/                   //web版本的参考app
//测试账号  手机号18675535684，密码：123456  9a960552303f3306800aa95ee6bf0a19
//uta环境测试账号13861318715   840319
//sit环境下           13915531876  111111
//jira

/*
 xmppserver   im.qw.com
 webapi  http://m.api.qw.com
 */
#ifndef quanzhi_Constant_h
#define quanzhi_Constant_h


/*
 SIT内网 IM地址 im.qw.com   端口5222
 SIT内网 WEBAPI地址  http://m.api.qw.com
 SIT外网 IM地址 im.sit.qwysfw.cn 端口5222
 SIT外网 WEBA
 P·I地址    http://m.api.sit.qwysfw.cn
 UAT内网 IM地址 im.qwysfw.cn 端口5222
 UAT内网 WEBAPI地址 http://api-m.qwysfw.cn
 UAT外网 IM地址 im.qwysfw.cn 端口6222
 UAT外网 WEBAPI地址 http://api-m.qwysfw.cn
 */



/**************************************************************************************
 *                             打包前注意切换环境和端口                                   *
 *************************************************************************************/

/*
 SIT外网 IM地址  im.sit.qwysfw.cn 端口5222
 SIT外网 WEBAPI地址    http://m.api.sit.qwysfw.cn
 */


//WEBAPI：http://api-m.myquanwei.com
//IM：    im.myquanwei.com   端口：5222（注意）


//#define OPEN_FIRE_URL                     @"im.myquanwei.com" //生产环境
//#define BASE_URL_V2                       @"http://api-m.myquanwei.com/app/"   //生产环境
//#define IMAGE_PRFIX                       @"http://img.myquanwei.com/product/"

//uat-2.0环境  端口 5222
//#define OPEN_FIRE_URL                     @"im.qwysfw.cn" //uat-2.0环境
//#define BASE_URL_V2                       @"http://api-m.qwysfw.cn/app/"   //uat-2.0环境
//#define IMAGE_PRFIX                       @"http://img.qwysfw.cn/product/"


//sit外网环境  端口 5222;
#define OPEN_FIRE_URL                     @"im.sit.qwysfw.cn" //sit环境
#define BASE_URL_V2                       @"http://m.api.sit.qwysfw.cn/app/"   //sit环境
#define IMAGE_PRFIX                       @"http://img.qwysfw.cn/product/"

//dev环境
//#define OPEN_FIRE_URL                       @"im.pre.qw.com"   //dev
//#define BASE_URL_V2                         @"http://api-m.pre.qw.com/app/"
//#define IMAGE_PRFIX                         @"http://img.qwysfw.cn/product/"


////sit内网环境
//#define OPEN_FIRE_URL                     @"58.210.18.38" //sit+外网
//#define BASE_URL_V2                       @"http://m.api.sit.qwysfw.cn/app/"   //sit+外网
//
//#define OPEN_FIRE_URL                      @"192.168.5.104"
//#define BASE_URL_V2                        @"http://192.168.5.104:11011/api/app/"



/**************************************************************************************
 *                                打包前注意切换环境                                     *
 *************************************************************************************/

//#define BASE_URL_V2                        @"http://192.168.5.104:11011/api/app/"

//sit环境
//#define OPEN_FIRE_URL                     @"im.qw.com" //sit
//#define BASE_URL_V2                       @"http://m.api.qw.com/app/"   //sit



//#define OPEN_FIRE_URL                      @"im.qwysfw.cn"
//#define BASE_URL_V2                        @"http://m.api.qwysfw.cn/api/app/"

//#define SHARE_URL                       @"http://api-m.myquanwei.com/"

//#define SHARE_URL                       @"http://api-0-m.qwysfw.cn/"
//#define SHARE_URL                       @"http://api-0-m.myquanwei.com/"
//#define SHARE_URL                       @"http://m.sit.qwysfw.cn/"

#define SHARE_URL                         BASE_URL_V2
#define BASE_URL                           [NSString stringWithFormat:@"%@app/",SHARE_URL]

#define THEME_URL(APPEND)                  [NSString stringWithFormat:@"%@/healthinfo/share?adviceId=%@",SHARE_URL,APPEND]

//#define BASE_URL_V2                        @"http://192.168.5.104:11011/api/app/"

#define API_APPEND_V2(APPEND)              [NSString stringWithFormat:@"%@%@",BASE_URL_V2,APPEND]

#define WELCOME_MESSAGE                    @"欢迎注册问药APP！目前“问药”已在江苏、山东、湖北区域，开启“免费送药上门”活动，只要选择含有“免费送药”标签的药店即可享受，还有惊喜礼品免费赠送，赶紧体验吧！"
#define GREENTCOLOR                     UICOLOR(58, 185, 0)
//#define GREENTCOLOR                     UICOLOR(9, 173, 0)
#define APP_VERSION                          @"2.1.0"
//#define APP_VERSION                          @"1.1.0"
#define APP_VERSION_1_3                      @"1.3"
#define APP_VERSION_1_4_0                    @"1.4.0"
#define iOS_V               [[[UIDevice currentDevice] systemVersion] floatValue]
#define iOSv7               (iOS_V >= 7)
#define UMENG_KEY           @"5355fc9256240b418f014450"
#define NETWORK_DISCONNECT     @"networkDisconnect"
#define NETWORK_RESTART     @"networkRestart"
#define UICOLOR(r,g,b)              [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define checkNull(origin)           ((origin == nil)? @"":origin);

#define DURATION_SHORT                0.8f
#define DURATION_LONG                 1.5f

#define HIGH_RESOLUTION             ([UIScreen mainScreen].bounds.size.height > 480)

#define APP_W               [UIScreen mainScreen].applicationFrame.size.width
#define APP_H               [UIScreen mainScreen].applicationFrame.size.height
#define SCREEN_W            [UIScreen mainScreen].bounds.size.width
#define SCREEN_H            [UIScreen mainScreen].bounds.size.height
#define STATUS_H            [UIApplication sharedApplication].statusBarFrame.size.height
#define TAG_BASE            100000
#define iOSv8               (iOS_V >= 8.0)

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define PORID_IMAGE(proId) (((NSString *)proId).length == 6)? [NSString stringWithFormat:@"%@middle/%@/%@/%@/1.JPG",IMAGE_PRFIX,[proId substringWithRange:NSMakeRange(0, 2)],[proId substringWithRange:NSMakeRange(2, 2)],[proId substringWithRange:NSMakeRange(4, 2)]] : @""

//#define PORID_IMAGE(proId) [NSString stringWithFormat:@"%@middle/%@1.JPG",IMAGE_PRFIX,proId];

typedef enum messageType
{
    TextMessage = 1,
    ImageMessage,
    AudioMessage,
    VideoMessage,
    LocationMessage,
    FileMessage,
    SystemMessage = 1000
}MessageType;

#define APP_COLOR_STYLE             UICOLOR(69, 192, 26)
#define APP_SEPARATE_COLOR          UICOLOR(219, 219, 219)
#define APP_BACKGROUND_COLOR        UICOLOR(236, 240, 241)

#define PAGE_ROW_NUM                10
#define BTN_HIGHLIGHTED             UIColorFromRGB(0xf2f2f2)

//add by xiezhenghong
#define API_APPEND(x)               [NSString stringWithFormat:@"%@%@",BASE_URL_V2,x]

#define ALERT_MESSAGE               @"当前身份已失效,请重新登录"
#define APP_BEST_NAME               @"nickName"//@"APP_BEST_NAME"

#define THEMEList                   API_APPEND_V2(@"other/themeList")

#define QueryRecommendClass         API_APPEND_V2(@"drug/queryRecommendClass")
#define DeleteIM                    API_APPEND_V2(@"im/delete")
#define SelectIM                    API_APPEND_V2(@"im/select")
#define AddQWIM                     API_APPEND_V2(@"im/add/qw")

#define SelectQWIM                  API_APPEND_V2(@"im/select/qw")
#define CheckReviewStatus           API_APPEND_V2(@"store/search/audit")
#define PharmacyNearList            API_APPEND_V2(@"store/search/offer")
#define PharmacyNearListWithName    API_APPEND_V2(@"store/search/offer/name")
#define SelectQW                    API_APPEND_V2(@"im/select/qw")
#define TokenValid                  API_APPEND_V2(@"mbr/tokenValid")
#define AppraiseExist               API_APPEND_V2(@"appraise/appraiseExist")
#define QueryBranhGroupByStoreAcc   API_APPEND_V2(@"store/queryBranhGroupByStoreAcc")
#define PushSet                     API_APPEND_V2(@"system/pushSet")
#define CheckCert                   API_APPEND_V2(@"im/cert/check")
#define HealthyKnowledge            API_APPEND_V2(@"drug/queryRecommendKnowledge")
#define CouponList                  API_APPEND_V2(@"promotion/query?v=2.1")
#define CouponScan                  API_APPEND_V2(@"promotion/scan")
#define CouponScanFromDetail        API_APPEND_V2(@"promotion/2qrcode")

#define CouponBranch                API_APPEND_V2(@"promotion/query/pro")
#define CouponStores                API_APPEND_V2(@"promotion/query/branch")
#define CheckPriceAndCount          API_APPEND_V2(@"promotion/account")


#define QueryRecommendProductByClass         API_APPEND_V2(@"drug/queryRecommendProductByClass")
#define Nationwide                  API_APPEND_V2(@"store/search/nationwide")
#define QueryBranchActivity         API_APPEND_V2(@"activity/queryActivity")
#define AddAppraise                 API_APPEND_V2(@"appraise/addAppraise")
#define SystemBackSet               API_APPEND_V2(@"system/backSet")
#define OpencityCheck               API_APPEND_V2(@"store/search/opencity/check")
#define GetActivity                 API_APPEND_V2(@"activity/getActivity")
#define QueryAppraise               API_APPEND_V2(@"appraise/queryStoreAppraise")
#define Regionwide                  API_APPEND_V2(@"store/search/region")
#define OpenCity                    API_APPEND_V2(@"store/search/opencity/query")
#define StoreSearch                 API_APPEND_V2(@"store/search")
#define StoreTag                    API_APPEND_V2(@"store/search/tag/query")
#define StoreComplaint              API_APPEND_V2(@"store/complaint")
#define StoreQueryComplaintType     API_APPEND_V2(@"store/complaint/type/query")
#define QueryComplaintofficial      API_APPEND_V2(@"store/complaint/official/query")



#define QueryGuideSubjectList         API_APPEND_V2(@"dguide/queryGuideSubjectList")
#define QueryHealthProgram         API_APPEND_V2(@"health/queryHealthProgram")

#define DeleteConsume               API_APPEND_V2(@"mbr/deleteConsume")
#define QuerySpmBody                API_APPEND_V2(@"spm/querySpmBody")
#define QuerySpmByKeyword           API_APPEND_V2(@"spm/querySpmByKeyword")

#define FetchDBoxProductRecord      API_APPEND_V2(@"dbox/fetchDBoxProductRecord")
#define CollectFunction             API_APPEND_V2(@"mbr/collect")
#define GetLikeNumber               API_APPEND_V2(@"mbr/getLikeNumber")
#define GetHealthLikeNum            API_APPEND_V2(@"theme/getHealthLikeNum")
#define CheckHealthLike            API_APPEND_V2(@"theme/checkHealthLike")

#define LikeHealthCountsPlus         API_APPEND_V2(@"theme/likeHealthCountsPlus")
#define LikeHealthCountsDecrease     API_APPEND_V2(@"theme/likeHealthCountsDecrease")

#define SaveDrugRecord              API_APPEND_V2(@"record/saveDrugRecord")
#define DeleteDrugRecord            API_APPEND_V2(@"record/deleteDrugRecord")
#define GetDrugRecordDetail         API_APPEND_V2(@"record/getDrugRecordDetail")
#define GetDrugRecordHistory        API_APPEND_V2(@"record/getDrugRecordHistory")
#define GetHealthAdviceTypeList     API_APPEND_V2(@"theme/getHealthAdviceTypeList")


#define QueryHealthAdviceList       API_APPEND_V2(@"healthinfo/queryHealthAdviceList")
#define QueryHealthAdviceInfo       API_APPEND_V2(@"healthinfo/getHealthAdvice")
#define QueryHealthAdviceContent    API_APPEND_V2(@"healthinfo/getAdviceContent")
#define QueryChannelList            API_APPEND_V2(@"healthinfo/queryChannelList")
#define QueryChannelBanner          API_APPEND_V2(@"healthinfo/queryChannelBanner")
#define ReadAdvice                  API_APPEND_V2(@"healthinfo/readAdvice")
#define PraiseAdvice                API_APPEND_V2(@"healthinfo/praiseAdvice")
#define CancelPraiseAdvice          API_APPEND_V2(@"healthinfo/cancelPraiseAdvice")

#define QueryAttentionList          API_APPEND_V2(@"healthinfo/queryAttentionList")
#define SaveDrugGuideItem           API_APPEND_V2(@"healthinfo/saveDrugGuideItem")
#define DeleteMsgDrugGuide           API_APPEND_V2(@"healthinfo/deleteMsgDrugGuide")

#define GetChronicDiseaseItemList   API_APPEND_V2(@"healthinfo/getChronicDiseaseItemList")
#define GetDrugGuideList            API_APPEND_V2(@"healthinfo/getDrugGuideList")
#define CheckPraiseAdvice            API_APPEND_V2(@"healthinfo/checkPraiseAdvice")
#define QueryMsgLogList             API_APPEND_V2(@"healthinfo/queryMsgLogList")

#define QueryFamiliarQuestionChannel    API_APPEND_V2(@"problem/moduleClass")
#define QueryFamiliarQuestionList       API_APPEND_V2(@"problem/list")
#define QueryFamiliarQuestionDetail     API_APPEND_V2(@"problem/detail")

#define QueryCommendPersonPhone     API_APPEND_V2(@"mbr/inviter/check")
#define QueryCimmitPersonPhone     API_APPEND_V2(@"mbr/inviter")

#define HelpInstructWebView            API_APPEND_V2(@"helpClass/yhhelp")



#define UploadFile                      API_APPEND_V2(@"other/uploadFile")

#define FetchMsgLogDetail               API_APPEND_V2(@"dguide/fetchMsgLogDetail")

#define CheckLike                       API_APPEND_V2(@"favorite/checkLike")
#define LikeCountsPlus                  API_APPEND_V2(@"favorite/likeCountsPlus")
#define LikeCountsDecrease              API_APPEND_V2(@"favorite/likeCountsDecrease")
#define SaveRecordDoser                 API_APPEND_V2(@"record/saveRecordDoser")
#define DeleteRecordDoser               API_APPEND_V2(@"record/deleteRecordDoser")
#define FetchRecordDoserList            API_APPEND_V2(@"record/fetchRecordDoserList")


#define GetSearchKeywords               API_APPEND_V2(@"drug/getSearchKeywords")
#define QueryProductByKeyword           API_APPEND_V2(@"drug/queryProductByKeyword")
#define QueryDiseaseKeyword             API_APPEND_V2(@"drug/queryDiseaseKeyword")
#define QueryAllTags                    API_APPEND_V2(@"box/queryAllTags")
#define DeleteI                         API_APPEND_V2(@"im/delete/i")

#define DelAllMessage               API_APPEND_V2(@"im/delete/all")
#define QueryMyBox                  API_APPEND_V2(@"box/queryMyBox")
#define QueryBoxByKeyword           API_APPEND_V2(@"box/queryBoxByKeyword")
#define QueryBoxByTag               API_APPEND_V2(@"box/queryBoxByTag")
#define SaveOrUpdateMyBox           API_APPEND_V2(@"box/saveOrUpdateMyBox")
#define AlternativeIMSelect         API_APPEND_V2(@"alternative/im/select")

#define HeartBeat                   API_APPEND_V2(@"system/heartbeat")

#define IMSetReceived               API_APPEND_V2(@"im/setReceived")
#define GetBoxProductDetail         API_APPEND_V2(@"box/getBoxProductDetail")
#define UpdateBoxProductTag         API_APPEND_V2(@"box/updateBoxProductTag")
#define DeleteBoxProduct            API_APPEND_V2(@"box/deleteBoxProduct")
#define SimilarDrug                 API_APPEND_V2(@"box/similarDrug")

#define QueryDrugBoxList                API_APPEND_V2(@"dbox/queryDrugBoxList")
#define QueryDBoxProductList            API_APPEND_V2(@"dbox/queryDBoxProductListByStatus")
#define QueryProductByBarCode           API_APPEND_V2(@"drug/queryProductByBarCode")


#define QUERYDiseaseClass               API_APPEND_V2(@"disease/queryDiseaseClass")
#define QUERYDiseaseByClass             API_APPEND_V2(@"disease/queryDiseaseByClass")
#define QUERYDiseaseDetail              API_APPEND_V2(@"disease/queryDiseaseDetail")
#define QUERYDiseaseFormulaDetail       API_APPEND_V2(@"disease/queryDiseaseFormulaDetail")
#define QUERYDiseaseFormulaProductList  API_APPEND_V2(@"disease/queryDiseaseFormulaProductList")
#define QUERYDiseaseProductList         API_APPEND_V2(@"drug/queryDiseaseProductList")
#define GetUnitList                     API_APPEND_V2(@"other/getUnitList")

#define SaveDBoxProduct                 API_APPEND_V2(@"dbox/saveDBoxProductAlias")
#define SaveSearchLog                   API_APPEND_V2(@"other/saveSearchLog")
#define GoodAppList                     API_APPEND_V2(@"goodApp/goodAppList")

#define SaveDBox                        API_APPEND_V2(@"dbox/saveDrugBox")
#define DeleteDBox                      API_APPEND_V2(@"dbox/deleteDrugBox")
#define DeleteDBoxProduct               API_APPEND_V2(@"dbox/deleteDBoxProduct")
#define QueryConsumeList                API_APPEND_V2(@"mbr/queryConsumeList")
#define QueryConsumeStoreList           API_APPEND_V2(@"mbr/queryConsumeStoreList")
#define QueryConsumeList                API_APPEND_V2(@"mbr/queryConsumeList")
#define QueryConsumeDetail              API_APPEND_V2(@"mbr/queryConsumeDetail")

#define AddIosDevice                    API_APPEND_V2(@"mbr/addIosDevice")
#define DeleteIosDevice                 API_APPEND_V2(@"mbr/deleteIosDevice")

#define QueryProductDetail              API_APPEND_V2(@"drug/queryProductDetail")
#define FetchAppraiseDetail             API_APPEND_V2(@"dbox/fetchAppraiseDetail")
#define FetchRecentMsgLog               API_APPEND_V2(@"dguide/fetchRecentMsgLog")

#define SaveDBoxAppraise                API_APPEND_V2(@"dbox/saveDBoxAppraise")
#define ProblemModule                   API_APPEND_V2(@"problem/module")
#define SearchRegionSize                API_APPEND_V2(@"store/search/offer/name")
#define PromotionBanner                 API_APPEND_V2(@"promotion/banner")
#define QueryProductExtInfo             API_APPEND_V2(@"drug/queryProductExtInfo")
#define ValidVerifyCode                 API_APPEND_V2(@"mbr/verifyAndChangePassword")
#define CancelRelatedMbrCard            API_APPEND_V2(@"mbr/cancelRelatedMbrCard")
#define QueryProductCollectList         API_APPEND_V2(@"favorite/queryProductCollectList")
#define GetMonthlyCount                 API_APPEND_V2(@"record/getMonthlyCount")


#define APP_EMPTY_STRING            @""
#define APP_MESSAGE_MUSIC           @"appmessagemusic"
#define APP_USERNAME_KEY            @"appusernamekey"
#define APP_LOGIN_STATUS            @"apploginloginstatus"
#define APP_PASSWORD_KEY            @"apppasswordkey"
#define APP_USER_TOKEN              @"token"
#define APP_PASSPORTID_KEY          @"apppassportkey"
#define APP_AVATAR_KEY              @"appavatarkey"
#define APP_NICKNAME_KEY            @"appnicknamekey"
#define VERSION_CHECK_DATE          @"versionNoticeDate"
#define APP_DOMAIN_KEY              @"appdomainkey"
#define AMAP_KEY                    @"dc272bb9feb04d7ecea183ace4eac7a3"
//#define AMAP_KEY                   @"1804bfb4a0330525d65a5e99201ba206"
#define APP_DOWNLOAD                @"https://itunes.apple.com/cn/app/wen-yao/id901262090?mt=8"
#define APP_GESTURE_ENABLE          @"kgestureenable"
#define UPDATE_GUIDE_Notification   @"update_guide_notification"
#define CHANGED_GUIDE_Notification  @"CHANGED_GUIDE_Notification"
#define NEED_UPDATE_AVATAR          @"NEED_UPDATE_AVATAR"
#define PHARMACY_NEED_UPDATE        @"PHARMACY_NEED_UPDATE"
#define OFFICIAL_MESSAGE            @"OFFICIAL_MESSAGE"
#define NEED_RELOCATION             @"NEED_RELOCATION"
#define LOCATION_UPDATE             @"LOCATION_UPDATE"
#define LOCATION_UPDATE_SUB         @"LOCATION_UPDATE_SUB"

#define LOCATION_UPDATE_ADDRESS     @"LOCATION_UPDATE_ADDRESS"

#define LAST_LOCATION_CITY          @"LAST_LOCATION_CITY"
#define LAST_LOCATION_PROVINCE      @"LAST_LOCATION_PROVINCE"
#define LAST_LOCATION_LONGITUDE      @"LAST_LOCATION_LONGITUDE"
#define LAST_LOCATION_LATITUDE      @"LAST_LOCATION_LATITUDE"
#define LAST_FORMAT_ADDRESS         @"LAST_FORMAT_ADDRESS"

#define APP_UPDATE_AFTER_THREE_DAYS @"App_update_three_days"
#define APP_LAST_TIMESTAMP          @"App_last_timestamp"
#define APP_LAST_SYSTEM_VERSION     @"App_last_systemVersion"
#define APP_CHECK_VERSION           @"App_check_version"
#define APP_HAS_NEW_DISEASE          @"App_has_new_disease"

//add by zhangpan
/*****************************************************************************************************/


#define myFormat(f, ...)      [NSString stringWithFormat:f, ## __VA_ARGS__]
#define BG_COLOR            [UIColor colorWithRed:231/255.0 green:236/255.0 blue:238/255.0 alpha:1.0]
#define COLOR(r,g,b)        [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define APP_COLOR           COLOR(146, 112, 224)
#define FrameColor          [UIColor colorWithWhite:0.8 alpha:1.0f]
#define iOS_V               [[[UIDevice currentDevice] systemVersion] floatValue]
#define iOSv7               (iOS_V >= 7)
#define Font(s)             [UIFont fontWithName:@"STHeitiSC-Light" size:s]
#define FontB(s)            [UIFont fontWithName:@"STHeitiSC-Medium" size:s]

#define FontSystem(s)       [UIFont systemFontOfSize:s]
#define RECT(x,y,w,h)       CGRectMake(x,y,w,h)
#define NAV_H               44
#define TAB_H               49
#define APP_W               [UIScreen mainScreen].applicationFrame.size.width
#define APP_H               [UIScreen mainScreen].applicationFrame.size.height
#define SCREEN_W            [UIScreen mainScreen].bounds.size.width
#define SCREEN_H            [UIScreen mainScreen].bounds.size.height
#define STATUS_H            [UIApplication sharedApplication].statusBarFrame.size.height

//URL add by pan
#define SERVER_ADDR                 "http://m.qwysfw.cn"
#define NW_updateLoginPassword      API_APPEND_V2(@"mbr/updateLoginPassword")
#define NW_login                    API_APPEND_V2(@"mbr/login")
#define NW_queryMemberDetail        API_APPEND_V2(@"mbr/queryMemberDetail")
#define NW_registerValid            API_APPEND_V2(@"mbr/registerValid")
#define NW_register                 API_APPEND_V2(@"mbr/register")
#define NW_sendVerifyCode           API_APPEND_V2(@"mbr/sendVerifyCode")
#define NW_validVerifyCode          API_APPEND_V2(@"mbr/validVerifyCode")
#define NW_changeMobile             API_APPEND_V2(@"mbr/changeMobile")
#define NW_resetPassword            API_APPEND_V2(@"mbr/resetPassword")
#define NW_updatePassword           API_APPEND_V2(@"mbr/updatePassword")
#define NW_validFindPwdVerifyCode   API_APPEND_V2(@"mbr/validVerifyCode")//查看验证码是否正确
#define NW_sendFindPwdVerifyCode    API_APPEND_V2(@"mbr/sendFindPwdVerifyCode")
#define NW_saveMemberInfo           API_APPEND_V2(@"mbr/saveMemberInfo")
#define NW_submitFeedback           API_APPEND_V2(@"feedback/submitFeedback")
#define NW_updatePublishSetting     API_APPEND_V2(@"other/updatePublishSetting")
#define NW_queryProductCollectList  API_APPEND_V2(@"favorite/queryProductCollectList")
#define NW_queryInfoCollectList     API_APPEND_V2(@"favorite/queryInfoCollectList")
#define NW_queryDiseaseCollectList  API_APPEND_V2(@"favorite/queryDiseaseCollectList")
#define NW_queryAdviceCollectList  API_APPEND_V2(@"favorite/queryAdviceCollectList")

#define NW_FavoriteCollect          API_APPEND_V2(@"favorite/collect")
#define NW_likeCountsPlus           API_APPEND_V2(@"mbr/likeCountsPlus")
#define NW_likeCountsDecrease       API_APPEND_V2(@"mbr/likeCountsDecrease")
#define NW_queryAttentionList       API_APPEND_V2(@"mbr/queryAttentionList")
//已调试
#define NW_getSearchKeywords            API_APPEND_V2(@"drug/getSearchKeywords")
#define NW_queryProductByKeywordCount   API_APPEND_V2(@"drug/queryProductByKeywordCount")
#define NW_querySpmByKeywordCount       API_APPEND_V2(@"spm/querySpmByKeywordCount")

#define NW_uploadFile               API_APPEND_V2(@"common/uploadFile")

#define NW_checkNewVersion              API_APPEND_V2(@"other/getLastVersion")
#define NW_heartBeat                API_APPEND_V2(@"system/heartbeat")

#define NW_queryProductByKeyword        API_APPEND_V2(@"drug/queryProductByKeyword")
//已调试
#define NW_queryDiseaseKeyword          API_APPEND_V2(@"disease/queryDiseaseKeyword")
#define NW_queryProductDetail           API_APPEND_V2(@"drug/queryProductDetail")
#define NW_queryDiseaseDetail           API_APPEND_V2(@"disease/queryDiseaseDetail")
#define NW_queryDiseaseFormulaList      API_APPEND_V2(@"disease/queryDiseaseFormulaList")
#define NW_queryDiseaseFormulaDetail    API_APPEND_V2(@"disease/queryDiseaseFormulaDetail")
#define NW_queryDiseaseFormulaProductList   API_APPEND(@"drug/queryDiseaseFormulaProductList")
#define NW_queryDiseaseDetailIos         API_APPEND_V2(@"disease/queryDiseaseDetailIos")

#define NW_queryDiseaseProductList          API_APPEND(@"drug/queryDiseaseProductList")

#define NW_fetchProFactoryByClass           API_APPEND_V2(@"drug/fetchProFactoryByClass")

#define NW_queryProductClass                API_APPEND_V2(@"drug/queryProductClass")
#define NW_querySecondProductClass          API_APPEND_V2(@"drug/querySecondProductClass")
#define NW_queryProductByClass              API_APPEND_V2(@"drug/queryProductByClass")

#define NW_queryDiseaseClass                API_APPEND_V2(@"disease/queryDiseaseClass")
#define NW_queryDiseaseByClass              API_APPEND_V2(@"disease/queryDiseaseByClass")
#define NW_queryMbrCardByPassport           API_APPEND_V2(@"mbr/queryMbrCardByPassport")

#define GetLastVersion                      API_APPEND_V2(@"other/getLastVersion")
#define CheckToken                          API_APPEND_V2(@"mbr/tokenValid")
#define IMReadNum                           API_APPEND_V2(@"im/read")
#define GetProductUsage                     API_APPEND_V2(@"drug/getProductUsage")
#define NW_queryFactoryList                 API_APPEND_V2(@"factory/queryFactoryList")
#define NW_queryFactoryDetail               API_APPEND_V2(@"factory/queryFactoryDetail")
#define NW_queryFactoryProductList          API_APPEND_V2(@"factory/queryFactoryProductList")

#define NW_queryDrugRemindList          API_APPEND_V2(@"dbox/queryDrugRemindList")
#define NW_saveDrugRemind               API_APPEND_V2(@"dbox/saveDrugRemind")
#define NW_deleteDrugRemind             API_APPEND_V2(@"dbox/deleteDrugRemind")
#define NW_queryDBoxProductListByPid    API_APPEND_V2(@"dbox/queryDBoxProductListByPid")

#define NW_getDrugGuideTypeList         API_APPEND_V2(@"dguide/getDrugGuideTypeList")
#define NW_getDrugGuideList             API_APPEND_V2(@"dguide/getDrugGuideList")
#define NW_deleteMsgDrugGuide           API_APPEND_V2(@"dguide/deleteMsgDrugGuide")
#define NW_queryMsgLogList              API_APPEND_V2(@"dguide/queryMsgLogList")
#define NW_getDrugGuideItemList         API_APPEND_V2(@"dguide/getDrugGuideItemList")
#define NW_deteleDrugGuideItem          API_APPEND_V2(@"dguide/deteleDrugGuideItem")
#define NW_queryStoreCollectList        API_APPEND_V2(@"favorite/queryStoreCollectList")
#define NW_checkOrdrBranchInfo        API_APPEND_V2(@"promotion/order/branch/check/info")
#define NW_checkOrdrBranch        API_APPEND_V2(@"promotion/order/branch/check")
#define NW_fetchRecommendPharmacy       API_APPEND_V2(@"pharmacy/fetchRecommendPharmacy")
#define NW_fetchNearPharmacy            API_APPEND_V2(@"pharmacy/fetchNearPharmacy")
#define NW_fetchPharmacyDetail          API_APPEND_V2(@"pharmacy/fetchPharmacyDetail")
#define NW_fetchSellWellProducts        API_APPEND_V2(@"pharmacy/fetchSellWellProducts")
#define NW_drugSellList                 API_APPEND_V2(@"store/search/sellWellProducts")
#define sellWellProducts            API_APPEND_V2(@"pharmacy/fetchSellWellProducts")

#define NW_pharmacyFeedback             API_APPEND_V2(@"pharmacy/pharmacyFeedback")
#define NW_searchPharmacy               API_APPEND_V2(@"pharmacy/searchPharmacy")
#define NW_getDefaultGeogInfo           API_APPEND_V2(@"pharmacy/getDefaultGeogInfo")
#define NW_fetchDefaultPharmacy         API_APPEND_V2(@"pharmacy/fetchDefaultPharmacy")
//getAllSymptomList  querySpmInfoListByBody  

#define NW_querySpmInfoList             API_APPEND_V2(@"spm/querySpmInfoList")
#define NW_queryAssociationDisease      API_APPEND_V2(@"spm/queryAssociationDisease")
#define NW_spmInfoDetail                API_APPEND_V2(@"spm/spmInfoDetail")
#define NW_SpmCollect                   API_APPEND_V2(@"mbr/collect")
#define NW_querySpmCollectList          API_APPEND_V2(@"favorite/querySpmCollectList")
#define NW_querySpmInfoListByBody       API_APPEND_V2(@"spm/querySpmInfoListByBody")
#define NW_locationEncode               API_APPEND_V2(@"pharmacy/getAreaCode")
#define NW_queryAllDisease              API_APPEND_V2(@"disease/queryAllDisease")
#define NW_shareAdvice                  API_APPEND_V2(@"healthinfo/shareAdvice")
//drug/queryProductByKwId       根据关键字id搜索商品
//drug/queryProductByKwIdCount  根据关键字id搜索商品记录数量
//disease/queryDiseaseKwId      根据关键字Id查询疾病
//disease/queryDiseaseKwIdCount 根据关键字id查询疾病记录数量
//spm/querySpmByKwId            根据关键字id查询症状
//spm/querySpmByKwIdCount       根据关键字id查询症状记录数量
#define NW_queryProductByKwId           API_APPEND_V2(@"drug/queryProductByKwId")
#define NW_queryProductByKwIdCount      API_APPEND_V2(@"drug/queryProductByKwIdCount")
#define NW_queryDiseaseKwId             API_APPEND_V2(@"disease/queryDiseaseKwId")
#define NW_queryDiseaseKwIdCount        API_APPEND_V2(@"disease/queryDiseaseKwIdCount")
#define NW_querySpmByKwId               API_APPEND_V2(@"spm/querySpmByKwId")
#define NW_querySpmByKwIdCount          API_APPEND_V2(@"spm/querySpmByKwIdCount")
#define NW_promotionOrder               API_APPEND_V2(@"promotion/order/query/customer")









#define APP_VOICE_NOTIFICATION      @"APP_VOICE_NOTIFICATION"
#define APP_VIBRATION_NOTIFICATION  @"APP_VIBRATION_NOTIFICATION"
#define APP_RECEIVE_INBACKGROUND    @"APP_RECEIVE_INBACKGROUND"
#define ALARM_VOICE_NOTIFICATION    @"ALARM_VOICE_NOTIFICATION"
#define ALARM_VIBRATION_NOTIFICATION    @"ALARM_VIBRATION_NOTIFICATION"
#define APP_ALARM_NATIONWIDE        @"APP_ALARM_NATIONWIDE"


#define NW_favoriteProductCollectList   API_APPEND_V2(@"favorite/queryProductCollectList")

#define NW_logout                       API_APPEND_V2(@"mbr/logout")


#define DATE_FORMAT            @"yyyy-MM-dd"
#define TIME_FORMAT            @"HH:mm:ss"
#define DATE_TIME_FORMAT       @"yyyy-MM-dd HH:mm:ss"
//Method
#define NoNullStr(x)        (  ( x && (![x isEqual:[NSNull null]]) ) ? x : @"" )
//panadd end
/*****************************************************************************************************/


/*****************************************************************************/
//notification
/*****************************************************************************/
#define PRO_CLASS_SELECTED      @"PRO_CLASS_SELECTED"
#define DRUG_GRIDE_EDIT         @"DRUG_GRIDE_EDIT"
#define STORE_CHANGED_PHONE     @"STORE_CHANGED_PHONE"
#define STORE_CHANGED_ADDRESS   @"STORE_CHANGED_ADDRESS"
#define LOGIN_SUCCESS           @"LOGIN_SUCCESS"
#define MESSAGE_NEED_UPDATE     @"MESSAGE_NEED_UPDATE"
#define QUIT_OUT                @"QUIT_OUT"
#define KICK_OFF                @"KICK_OFF"

#define APP_SELECT_INDEX_DISEASE    @"APP_SELECT_INDEX_DISEASE"


#define DRUG_GUIDE_1_UPDATE     @"DRUG_GUIDE_1_UPDATE"
#define DRUG_GUIDE_2_UPDATE     @"DRUG_GUIDE_2_UPDATE"
#define IMG_VIEW(x)         [[UIImageView alloc] initWithImage:[UIImage imageNamed:x]]

#define BTN_NEW     512
#define BTN_EDIT    1024

#define AttributedImageNameKey      @"ImageName"
#define EmotionItemPattern          @"\\[\\w{2}\\]"
#define PlaceHolder                 @"[0|]"
#define kHyperlinkKey               @"khyperlinkkey"

typedef enum PeopleKind{
    CHILD_KIND,
    MAN_KIND,
    WOMAN_KIND
} PeopleKind;



#endif
