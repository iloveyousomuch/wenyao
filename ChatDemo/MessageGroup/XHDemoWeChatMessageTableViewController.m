//
//  XHDemoWeChatMessageTableViewController.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-27.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHDemoWeChatMessageTableViewController.h"

#import "XHDisplayTextViewController.h"
#import "XHDisplayMediaViewController.h"
#import "XHDisplayLocationViewController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "XHContactDetailTableViewController.h"
#import "XHAudioPlayerHelper.h"
#import "MJRefresh.h"
#import "XMPPManager.h"
#import "XMPPIQ+XMPPMessage.h"
#import "XMPPLogging.h"
#import "ShowLocationViewController.h"
#import "SVProgressHUD.h"
#import "MarkPharmacyViewController.h"
#import "MarketDetailViewController.h"
#import "MedicineDetailViewController.h"
#import "DetailSubscriptionListViewController.h"
#import "SBJson.h"
#import "PharmacyStoreViewController.h"
#import "IntroduceQwysViewController.h"
#import "QuickSearchViewController.h"
#import "DiseaseSubscriptionViewController.h"
#import "PersonInformationViewController.h"
#import "DrugDetailViewController.h"
#import "ReturnIndexView.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface XHDemoWeChatMessageTableViewController () <XHAudioPlayerHelperDelegate,MLEmojiLabelDelegate,ReturnIndexViewDelegate>
{
    UIImageView         *hintView;
    
}


@property (nonatomic, strong) NSString *errorMsg;
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, strong) NSArray *emotionManagers;
@property (nonatomic, strong) NSMutableArray    *cacheList;
@property (nonatomic, strong) XHMessageTableViewCell *currentSelectedCell;
@property (strong, nonatomic) ReturnIndexView *indexView;

@end

@implementation XHDemoWeChatMessageTableViewController

- (XHMessage *)getTextMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType
{
    XHMessage *textMessage = [[XHMessage alloc] initWithText:@"Hgccc" sender:@"华仔" timestamp:[NSDate distantPast] UUID:[XMPPStream generateUUID]];
    textMessage.sended = Sended;
    textMessage.avator = [UIImage imageNamed:@"avator"];
    textMessage.avatorUrl = @"http://www.pailixiu.com/jack/meIcon@2x.png";
    textMessage.bubbleMessageType = bubbleMessageType;
    
    return textMessage;
}

- (XHMessage *)getPhotoMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    XHMessage *photoMessage = [[XHMessage alloc] initWithPhoto:[UIImage imageNamed:@"placeholderImage"] thumbnailUrl:@"http://d.hiphotos.baidu.com/image/pic/item/30adcbef76094b361721961da1cc7cd98c109d8b.jpg" originPhotoUrl:nil sender:@"Jack" timestamp:[NSDate date]];
    photoMessage.avator = [UIImage imageNamed:@"avator"];
    photoMessage.avatorUrl = @"http://www.pailixiu.com/jack/JieIcon@2x.png";
    photoMessage.bubbleMessageType = bubbleMessageType;
    return photoMessage;
}

- (XHMessage *)getVideoMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"IMG_1555.MOV" ofType:@""];
    XHMessage *videoMessage = [[XHMessage alloc] initWithVideoConverPhoto:[XHMessageVideoConverPhotoFactory videoConverPhotoWithVideoPath:videoPath] videoPath:videoPath videoUrl:nil sender:@"Jayson" timestamp:[NSDate date]];
    videoMessage.avator = [UIImage imageNamed:@"avator"];
    videoMessage.avatorUrl = @"http://www.pailixiu.com/jack/JieIcon@2x.png";
    videoMessage.bubbleMessageType = bubbleMessageType;
    
    return videoMessage;
}

- (XHMessage *)getVoiceMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    XHMessage *voiceMessage = [[XHMessage alloc] initWithVoicePath:nil voiceUrl:nil voiceDuration:@"1" sender:@"Jayson" timestamp:[NSDate date]];
    voiceMessage.avator = [UIImage imageNamed:@"avator"];
    voiceMessage.avatorUrl = @"http://www.pailixiu.com/jack/JieIcon@2x.png";
    voiceMessage.bubbleMessageType = bubbleMessageType;
    
    return voiceMessage;
}

- (XHMessage *)getEmotionMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    XHMessage *emotionMessage = [[XHMessage alloc] initWithEmotionPath:[[NSBundle mainBundle] pathForResource:@"Demo0.gif" ofType:nil] sender:@"Jayson" timestamp:[NSDate date]];
    emotionMessage.avator = [UIImage imageNamed:@"avator"];
    emotionMessage.avatorUrl = @"http://www.pailixiu.com/jack/JieIcon@2x.png";
    emotionMessage.bubbleMessageType = bubbleMessageType;
    
    return emotionMessage;
}

- (XHMessage *)getGeolocationsMessageWithBubbleMessageType:(XHBubbleMessageType)bubbleMessageType {
    XHMessage *localPositionMessage = [[XHMessage alloc] initWithLocalPositionPhoto:[UIImage imageNamed:@"Fav_Cell_Loc"] geolocations:@"中国广东省广州市天河区东圃二马路121号" location:[[CLLocation alloc] initWithLatitude:23.110387 longitude:113.399444] sender:@"Jack" timestamp:[NSDate date]];
    localPositionMessage.avator = [UIImage imageNamed:@"avator"];
    localPositionMessage.avatorUrl = @"http://www.pailixiu.com/jack/meIcon@2x.png";
    localPositionMessage.bubbleMessageType = bubbleMessageType;
    
    return localPositionMessage;
}

- (void)loadDemoDataSource
{
    WEAKSELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.messageTableView reloadData];
            
            [weakSelf scrollToBottomAnimated:NO];
        });
    });
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"endpoint"] = @"1";
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"viewType"] = @"-1";
    setting[@"view"] = @"15";
    if(self.accountType == OfficialType)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        if(self.messages.count == 0) {
            setting[@"point"] = [formatter stringFromDate:[NSDate date]];
        }else{
            XHMessage *message = self.messages[0];
            setting[@"point"] = [formatter stringFromDate:message.timestamp];
        }
    
        [[HTTPRequestManager sharedInstance] selectQWIM:setting completion:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                NSArray *array = resultObj[@"body"];
                if([array isKindOfClass:[NSString class]])
                {
                    [self.messageTableView headerEndRefreshing];
                    return;
                }
                for(NSDictionary *dict in array)
                {
                    NSUInteger type = [dict[@"type"] integerValue];
                    NSDictionary *info = dict[@"info"];
                    NSString *content = info[@"content"];
                    NSString *fromId = info[@"fromId"];
                    NSString *toId = info[@"toId"];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    double timeStamp = [[formatter dateFromString:info[@"time"]] timeIntervalSince1970];
                    NSDate *date = [formatter dateFromString:info[@"time"]];
                    NSString *UUID = info[@"id"];
                    NSUInteger fromTag = [info[@"fromTag"] integerValue];
                    NSArray *tags = info[@"tags"];
                    NSUInteger msgType = [info[@"source"] integerValue];
                    if(msgType == 0)
                        msgType = 1;
                    
                    for(NSDictionary *tag in info[@"tags"])
                    {
                        NSUInteger length = [tag[@"length"] integerValue];
                        NSUInteger start = [tag[@"start"] integerValue];
                        NSUInteger tagType = [tag[@"tag"] integerValue];
                        NSString *tagId = tag[@"tagId"];
                        NSString *title = tag[@"title"];
                        [app.dataBase insertIntoTagList:UUID start:[NSNumber numberWithInt:start] length:[NSNumber numberWithInt:length] tagType:[NSNumber numberWithInt:tagType] title:title tagId:tagId];
                    }
                    
                    if(fromTag == 2)
                    {
                        BOOL result = [app.dataBase insertMessages:[NSNumber numberWithInt:XHBubbleMessageTypeReceiving] timestamp:[NSString stringWithFormat:@"%.0f",timeStamp] UUID:UUID star:@"" avatorUrl:@"" sendName:fromId recvName:toId issend:[NSNumber numberWithInt:Sended] messagetype:[NSNumber numberWithInt:msgType] unread:[NSNumber numberWithInt:0] richbody:@"" body:content];
                        if(!result)
                            continue;
                        [app.dataBase insertHistorys:fromId timestamp:[NSString stringWithFormat:@"%.0f",timeStamp] body:content direction:[NSNumber numberWithInt:XHBubbleMessageTypeReceiving] messagetype:[NSNumber numberWithInt:msgType] UUID:UUID issend:[NSNumber numberWithInt:2] avatarUrl:@""];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:fromId object:nil];
                        continue;
                    }else if(fromTag == 0)
                    {
                        //全维药事的推送
                        BOOL result = [app.dataBase insertIntoofficialMessages:fromId toId:toId timestamp:[NSString stringWithFormat:@"%f",timeStamp] body:content direction:[NSNumber numberWithInt:XHBubbleMessageTypeReceiving] messagetype:[NSNumber numberWithInt:msgType] UUID:UUID issend:[NSNumber numberWithInt:1] relatedid:fromId];
                        if(!result)
                            continue;
                    }


                    NSArray *tagList = [app.dataBase selectTagList:UUID];
                    XHMessage *message = nil;
                    switch (msgType)
                    {
                        case XHBubbleMessageMediaTypeText:
                        {
                            message = [[XHMessage alloc] initWithText:content sender:fromId timestamp:date UUID:UUID];
                            break;
                        }
                        case XHBubbleMessageMediaTypeAutoSubscription:
                        {
                            message = [[XHMessage alloc] initWithAutoSubscription:content sender:fromId timestamp:date UUID:UUID tagList:tagList];
                            
                            break;
                        }
                        case XHBubbleMessageMediaTypeDrugGuide:
                        {
                            NSDictionary *tag = tagList[0];
                            message = [[XHMessage alloc] initWithDrugGuide:content title:tag[@"title"] sender:fromId timestamp:date UUID:UUID tagList:tagList];
                            break;
                        }
                        default:
                            break;
                    }
                    message.avator = [UIImage imageNamed:@"全维药事icon.png"];
                    message.bubbleMessageType = XHBubbleMessageTypeReceiving;
                    message.officialType = YES;
                    if(message)
                        [self.messages addObject:message];
                }
                if (self.messages.count >= 2)
                {
                    XHMessage *message1 = self.messages[0];
                    XHMessage *message2 = self.messages[1];
                    if([message1.text isEqualToString:WELCOME_MESSAGE] && [message2.text isEqualToString:WELCOME_MESSAGE]) {
                        [self.messages removeObjectAtIndex:0];
                    }
                }
                [self.messageTableView reloadData];
                [self.messageTableView headerEndRefreshing];
                [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_NEED_UPDATE object:nil];
            }
        } failure:^(id failMsg) {
            [self.messageTableView headerEndRefreshing];
        }];
    }else{
        if(self.messages.count == 0) {
            double timestamp = [[NSDate date] timeIntervalSince1970];
            timestamp *= 1000;
            setting[@"point"] = [NSString stringWithFormat:@"%.0f",timestamp];
        }else{
            XHMessage *message = self.messages[0];
            double timestamp = [message.timestamp timeIntervalSince1970];
            timestamp *= 1000;
            setting[@"point"] = [NSString stringWithFormat:@"%.0f",timestamp];
        }

        setting[@"to"] = self.messageSender;
        [[HTTPRequestManager sharedInstance] selectIM:setting completion:^(id resultObj) {
            if([resultObj[@"result"] isEqualToString:@"OK"]){
                NSArray *historys = resultObj[@"body"];
                if([historys isKindOfClass:[NSString class]])
                {
                    [self.messageTableView headerEndRefreshing];
                    return;
                }
                NSInteger count = historys.count - 1;
                for(; count >= 0 ; --count)
                {
                    XHMessage *message = nil;
                    NSDictionary *dict = historys[count];
                    NSString *content = dict[@"content"];
                    NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:content options:0 error:nil];
                    XMPPIQ *iq = (XMPPIQ *)[document rootElement];
                    NSXMLElement *notification = [iq elementForName:@"notification"];
                    
                    NSDictionary *testDict = [[[notification elementForName:@"message"] stringValue] JSONValue][@"info"];
                    if(!testDict) {
                        if(notification && [[notification xmlns] isEqualToString:@"androidpn:iq:notification"])
                        {
                            //接受消息成功
                            NSString *UUID = [[notification elementForName:@"id"] stringValue];
                            NSString *text = [[notification elementForName:@"message"] stringValue];
                            NSString *from = [[notification elementForName:@"fromUser"] stringValue];
                            double timeStamp = [[notification elementForName:@"timestamp"] stringValueAsDouble] / 1000;
                            NSString *avatorUrl = [[notification elementForName:@"uri"] stringValue];
                            NSString *sendName = [[notification elementForName:@"to"] stringValue];
                            NSUInteger messageType = [[notification elementForName:@"msType"] stringValueAsInt32];
                            NSString *title = [[notification elementForName:@"title"] stringValue];
                            NSString *richBody = [[notification elementForName:@"richBody"] stringValue];
                            
                            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
                            
                            NSString *fromId = dict[@"fromId"];
                            
                            switch (messageType)
                            {
                                case XHBubbleMessageMediaTypeText:
                                {
                                    message = [[XHMessage alloc] initWithText:text sender:sendName timestamp:date UUID:UUID];
                                    break;
                                }
                                case XHBubbleMessageMediaTypeStarStore:
                                {
                                    message = [[XHMessage alloc] initInviteEvaluate:text sender:sendName timestamp:date UUID:UUID];
                                    break;
                                }
                                case XHBubbleMessageMediaTypeStarClient:
                                {
                                    message = [[XHMessage alloc] initEvaluate:[title floatValue] text:[NSString stringWithFormat:@"评价内容:%@",text] sender:sendName timestamp:date UUID:UUID];
                                    break;
                                }
                                case XHBubbleMessageMediaTypeActivity:
                                {
                                    NSString *imageUrl = avatorUrl;
                                    if(imageUrl == nil)
                                        imageUrl = @"";
                                    message = [[XHMessage alloc] initMarketActivity:[app replaceSpecialStringWith:title] sender:sendName imageUrl:imageUrl content:[app replaceSpecialStringWith:text] comment:@"" richBody:richBody timestamp:date UUID:UUID];
                                    break;
                                }
                                case XHBubbleMessageMediaTypeLocation:
                                {
                                    NSString *latitude = [title componentsSeparatedByString:@","][0];
                                    NSString *longitude = [title componentsSeparatedByString:@","][1];
                                    
                                    message = [[XHMessage alloc] initWithLocation:text latitude:latitude longitude:longitude sender:sendName timestamp:date UUID:UUID];
                                    break;
                                }
                                case XHBubbleMessageMediaTypePurchaseMedicine:
                                {
                                    message = [[XHMessage alloc] initWithPurchaseMedicine:text sender:sendName timestamp:date UUID:UUID tagList:nil];
                                    break;
                                }
                                default:
                                    break;
                            }
                            
                            if([fromId isEqualToString:self.messageSender]){
                                message.bubbleMessageType = XHBubbleMessageTypeReceiving;
                            }else{
                                message.bubbleMessageType = XHBubbleMessageTypeSending;
                            }
                            if(message.bubbleMessageType == XHBubbleMessageTypeSending) {
                                message.avatorUrl = app.configureList[APP_AVATAR_KEY];
                            }else{
                                message.avatorUrl = self.avatarUrl;
                            }
                            if(messageType == XHBubbleMessageMediaTypeStarStore) {
                                if([dict[@"star"] integerValue] != -1) {
                                    title = @"0";
                                    message.isMarked = YES;
                                }else{
                                    title = @"5";
                                    message.isMarked = NO;
                                }
                            }
                            if(message){
                                BOOL result = [app.dataBase insertMessages:[NSNumber numberWithInt:message.bubbleMessageType] timestamp:[NSString stringWithFormat:@"%.0f",timeStamp] UUID:UUID star:title avatorUrl:avatorUrl sendName:from recvName:sendName issend:[NSNumber numberWithInt:Sended] messagetype:[NSNumber numberWithInt:messageType] unread:[NSNumber numberWithInt:0] richbody:avatorUrl body:text];
                                if(result)
                                    [self.messages insertObject:message atIndex:0];
                            }
                        }
                    }else{
                        if(notification && [[notification xmlns] isEqualToString:@"androidpn:iq:notification"])
                        {
                            NSString *UUID = [[notification elementForName:@"id"] stringValue];
                            NSDictionary *dict = [[[notification elementForName:@"message"] stringValue] JSONValue][@"info"];
                            
                            NSString *text = dict[@"content"];
                            NSString *from = dict[@"fromId"];
                            NSString *sendName = dict[@"toId"];
                            NSArray *tagList = dict[@"tags"];
                            NSString *title = @"";
                            NSUInteger source = [dict[@"source"] integerValue];
                            if(tagList.count)
                            {
                                title = tagList[0][@"title"];
                            }
                            double timeStamp = [[notification elementForName:@"timestamp"] stringValueAsDouble] / 1000;
                            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
                            
                            BOOL result = [app.dataBase insertMessages:[NSNumber numberWithInt:XHBubbleMessageTypeReceiving] timestamp:[NSString stringWithFormat:@"%.0f",timeStamp] UUID:UUID star:title avatorUrl:@"" sendName:from recvName:sendName issend:[NSNumber numberWithInt:Sended] messagetype:[NSNumber numberWithInt:source] unread:[NSNumber numberWithInt:0] richbody:@"" body:text];
                            if(!result)
                                continue;
                            for(NSDictionary *tag in tagList)
                            {
                                NSUInteger length = [tag[@"length"] integerValue];
                                NSUInteger start = [tag[@"start"] integerValue];
                                NSUInteger tagType = [tag[@"tag"] integerValue];
                                NSString *tagId = tag[@"tagId"];
                                NSString *title = tag[@"title"];
                                [app.dataBase insertIntoTagList:UUID start:[NSNumber numberWithInt:start] length:[NSNumber numberWithInt:length] tagType:[NSNumber numberWithInt:tagType] title:title tagId:tagId];
                            }
                            tagList = [app.dataBase selectTagList:UUID];
                            switch (source)
                            {
                                case XHBubbleMessageMediaTypeDrugGuide:
                                {
                                    NSString *title = tagList[0][@"title"];
                                    message = [[XHMessage alloc] initWithDrugGuide:text title:title sender:sendName timestamp:date UUID:UUID tagList:tagList];
                                    break;
                                }
                                case XHBubbleMessageMediaTypePurchaseMedicine:
                                {
                                    message = [[XHMessage alloc] initWithPurchaseMedicine:text sender:sendName timestamp:date UUID:UUID tagList:tagList];
                                    break;
                                }
                                default:
                                    break;
                            }
                            message.bubbleMessageType = XHBubbleMessageTypeReceiving;
                            if(self.infoDict[@"avatarurl"]) {
                                message.avatorUrl = self.infoDict[@"avatarurl"];
                            }else if(self.infoDict[@"imgUrl"]) {
                                message.avatorUrl = self.infoDict[@"imgUrl"];
                            }else{
                                message.avatorUrl = @"";
                            }
                            if(message)
                            {
                                [self.messages insertObject:message atIndex:0];
                            }
                        }
                    }
                }
                
                [self.messageTableView reloadData];
                [self.messageTableView headerEndRefreshing];
                [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_NEED_UPDATE object:nil];
            }
        } failure:^(id failMsg) {
            [self.messageTableView headerEndRefreshing];
        }];
    }
    [self.messageTableView performSelector:@selector(headerEndRefreshing) withObject:nil afterDelay:5.0f];
}

- (void)rereshingRecentMessage
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"endpoint"] = @"1";
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"viewType"] = @"-1";
    setting[@"view"] = @"100";
    if(self.accountType == OfficialType)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        setting[@"point"] = [formatter stringFromDate:[NSDate date]];
        
        [[HTTPRequestManager sharedInstance] selectQWIM:setting completion:^(id resultObj) {
            if ([resultObj[@"result"] isEqualToString:@"OK"]) {
                NSArray *array = resultObj[@"body"];
                if([array isKindOfClass:[NSString class]])
                {
                    [self.messageTableView headerEndRefreshing];
                    return;
                }
                if(self.messages.count > 0 && array.count > 0)
                {
                    XHMessage *lastMessage = [self.messages lastObject];
                    NSString *UUID = [array lastObject][@"id"];
                    if([lastMessage.UUID isEqualToString:UUID])
                        return;
                    double lastTimeStamp = [lastMessage.timestamp timeIntervalSince1970];
                    if((lastTimeStamp * 1000) >= [[array lastObject][@"time"] doubleValue]) {
                        return;
                    }
                }
                if(array.count >= 15)
                {
                    [self.messages removeAllObjects];
                    [app.dataBase deleteFromOfficialMessages];
                    
                }
                for(NSDictionary *dict in array)
                {
                    NSUInteger type = [dict[@"type"] integerValue];
                    NSDictionary *info = dict[@"info"];
                    NSString *content = info[@"content"];
                    NSString *fromId = info[@"fromId"];
                    NSString *toId = info[@"toId"];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    double timeStamp = [[formatter dateFromString:info[@"time"]] timeIntervalSince1970];
                    NSDate *date = [formatter dateFromString:info[@"time"]];
                    NSString *UUID = info[@"id"];
                    NSUInteger fromTag = [info[@"fromTag"] integerValue];
                    NSArray *tags = info[@"tags"];
                    NSUInteger msgType = [info[@"source"] integerValue];
                    if(msgType == 0)
                        msgType = 1;
                    
                    for(NSDictionary *tag in info[@"tags"])
                    {
                        NSUInteger length = [tag[@"length"] integerValue];
                        NSUInteger start = [tag[@"start"] integerValue];
                        NSUInteger tagType = [tag[@"tag"] integerValue];
                        NSString *tagId = tag[@"tagId"];
                        NSString *title = tag[@"title"];
                        [app.dataBase insertIntoTagList:UUID start:[NSNumber numberWithInt:start] length:[NSNumber numberWithInt:length] tagType:[NSNumber numberWithInt:tagType] title:title tagId:tagId];
                    }
                    
                    if(fromTag == 2)
                    {
                        [app.dataBase insertMessages:[NSNumber numberWithInt:XHBubbleMessageTypeReceiving] timestamp:[NSString stringWithFormat:@"%.0f",timeStamp] UUID:UUID star:@"" avatorUrl:@"" sendName:fromId recvName:toId issend:[NSNumber numberWithInt:Sended] messagetype:[NSNumber numberWithInt:msgType] unread:[NSNumber numberWithInt:0] richbody:@"" body:content];
                        if([fromId isEqualToString:app.configureList[APP_PASSPORTID_KEY]]) {
                            fromId = toId;
                        }
                        [app.dataBase insertHistorys:fromId timestamp:[NSString stringWithFormat:@"%.0f",timeStamp] body:content direction:[NSNumber numberWithInt:XHBubbleMessageTypeReceiving] messagetype:[NSNumber numberWithInt:msgType] UUID:UUID issend:[NSNumber numberWithInt:2] avatarUrl:@""];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:fromId object:nil];
                        continue;
                    }else if(fromTag == 0)
                    {
                        //全维药事的推送
                        [app.dataBase insertIntoofficialMessages:fromId toId:toId timestamp:[NSString stringWithFormat:@"%f",timeStamp] body:content direction:[NSNumber numberWithInt:XHBubbleMessageTypeReceiving] messagetype:[NSNumber numberWithInt:msgType] UUID:UUID issend:[NSNumber numberWithInt:1] relatedid:fromId];
                        
                    }
                }
                self.messages = [self queryOfficialDataBaseCache];
                [self.messageTableView reloadData];
                [self.messageTableView headerEndRefreshing];
                [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_NEED_UPDATE object:nil];
            }
        } failure:^(id failMsg) {
            [self.messageTableView headerEndRefreshing];
        }];
    }else{
        double timestamp = [[NSDate date] timeIntervalSince1970];
        timestamp *= 1000;
        setting[@"point"] = [NSString stringWithFormat:@"%.0f",timestamp];
        
        setting[@"to"] = self.messageSender;
        [[HTTPRequestManager sharedInstance] selectIM:setting completion:^(id resultObj) {
            if([resultObj[@"result"] isEqualToString:@"OK"]){
                NSArray *historys = resultObj[@"body"];
                if([historys isKindOfClass:[NSString class]])
                {
                    [self.messageTableView headerEndRefreshing];
                    return;
                }
                if(self.messages.count > 0 && historys.count > 0)
                {
                    NSString *UUID = [historys lastObject][@"id"];
                    XHMessage *lastMessage = [self.messages lastObject];
                    if([lastMessage.UUID isEqualToString:UUID])
                        return;
                    double lastTimeStamp = [lastMessage.timestamp timeIntervalSince1970];
                    if((lastTimeStamp * 1000) >= [[historys lastObject][@"time"] doubleValue]) {
                        return;
                    }
                }
                if(historys.count >= 15)
                {
                    [self.messages removeAllObjects];
                    [app.dataBase deleteFromMessagesWithName:self.messageSender];
                }
                NSInteger count = historys.count - 1;
                for(; count >= 0 ; --count)
                {
                    XHMessage *message = nil;
                    NSDictionary *dict = historys[count];
                    NSString *content = dict[@"content"];
                    NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:content options:0 error:nil];
                    XMPPIQ *iq = (XMPPIQ *)[document rootElement];
                    NSXMLElement *notification = [iq elementForName:@"notification"];
                    NSDictionary *testDict = [[[notification elementForName:@"message"] stringValue] JSONValue][@"info"];
                    if(!testDict) {
                        if(notification && [[notification xmlns] isEqualToString:@"androidpn:iq:notification"])
                        {
                            //接受消息成功
                            NSString *UUID = [[notification elementForName:@"id"] stringValue];
                            NSString *text = [[notification elementForName:@"message"] stringValue];
                            NSString *from = [[notification elementForName:@"fromUser"] stringValue];
                            double timeStamp = [[notification elementForName:@"timestamp"] stringValueAsDouble] / 1000;
                            NSString *avatorUrl = [[notification elementForName:@"uri"] stringValue];
                            NSString *sendName = [[notification elementForName:@"to"] stringValue];
                            NSUInteger messageType = [[notification elementForName:@"msType"] stringValueAsInt32];
                            NSString *title = [[notification elementForName:@"title"] stringValue];
                            NSString *richBody = [[notification elementForName:@"richBody"] stringValue];
                            
                            NSArray *tagList = dict[@"tags"];
                            if(tagList.count)
                            {
                                title = tagList[0][@"title"];
                            }
                            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
                            
                            NSString *fromId = dict[@"fromId"];
                            
                            switch (messageType)
                            {
                                case XHBubbleMessageMediaTypeText:
                                {
                                    message = [[XHMessage alloc] initWithText:text sender:sendName timestamp:date UUID:UUID];
                                    break;
                                }
                                case XHBubbleMessageMediaTypeStarStore:
                                {
                                    message = [[XHMessage alloc] initInviteEvaluate:text sender:sendName timestamp:date UUID:UUID];
                                    break;
                                }
                                case XHBubbleMessageMediaTypeStarClient:
                                {
                                    message = [[XHMessage alloc] initEvaluate:[title floatValue] text:[NSString stringWithFormat:@"评价内容:%@",text] sender:sendName timestamp:date UUID:UUID];
                                    break;
                                }
                                case XHBubbleMessageMediaTypeLocation:
                                {
                                    NSString *latitude = [title componentsSeparatedByString:@","][0];
                                    NSString *longitude = [title componentsSeparatedByString:@","][1];
                                    
                                    message = [[XHMessage alloc] initWithLocation:text latitude:latitude longitude:longitude sender:sendName timestamp:date UUID:UUID];
                                    break;
                                }
                                case XHBubbleMessageMediaTypeActivity:
                                {
                                    NSString *imageUrl = avatorUrl;
                                    if(imageUrl == nil)
                                        imageUrl = @"";
                                    message = [[XHMessage alloc] initMarketActivity:[app replaceSpecialStringWith:title] sender:sendName imageUrl:imageUrl content:[app replaceSpecialStringWith:text] comment:@"" richBody:richBody timestamp:date UUID:UUID];
                                    break;
                                }
                                case XHBubbleMessageMediaTypeDrugGuide:
                                {
                                    NSString *title = tagList[0][@"title"];
                                    message = [[XHMessage alloc] initWithDrugGuide:text title:title sender:sendName timestamp:date UUID:UUID tagList:tagList];
                                    break;
                                }
                                case XHBubbleMessageMediaTypePurchaseMedicine:
                                {
                                    message = [[XHMessage alloc] initWithPurchaseMedicine:text sender:sendName timestamp:date UUID:UUID tagList:nil];
                                    break;
                                }
                                default:
                                    break;
                            }
                            
                            if([fromId isEqualToString:self.messageSender]){
                                message.bubbleMessageType = XHBubbleMessageTypeReceiving;
                            }else{
                                message.bubbleMessageType = XHBubbleMessageTypeSending;
                            }
                            if(message.bubbleMessageType == XHBubbleMessageTypeSending) {
                                message.avatorUrl = app.configureList[APP_AVATAR_KEY];
                            }else{
                                message.avatorUrl = self.avatarUrl;
                            }
                            if(messageType == XHBubbleMessageMediaTypeStarStore) {
                                if([dict[@"star"] integerValue] != -1) {
                                    message.isMarked = YES;
                                    title = @"0";
                                }else{
                                    message.isMarked = NO;
                                    title = @"5";
                                }
                            }
                            
                            if(message){
                                BOOL result = [app.dataBase insertMessages:[NSNumber numberWithInt:message.bubbleMessageType] timestamp:[NSString stringWithFormat:@"%.0f",timeStamp] UUID:UUID star:title avatorUrl:avatorUrl sendName:from recvName:sendName issend:[NSNumber numberWithInt:Sended] messagetype:[NSNumber numberWithInt:messageType] unread:[NSNumber numberWithInt:0] richbody:avatorUrl body:text];
                                
                                NSString *historyTitle = @"";
                                if(messageType == 5){
                                    historyTitle = title;
                                }else{
                                    historyTitle = text;
                                }
                                if(count == (historys.count - 1))
                                    [app.dataBase insertHistorys:self.messageSender timestamp:[NSString stringWithFormat:@"%.0f",timeStamp] body:historyTitle direction:[NSNumber numberWithInt:message.bubbleMessageType] messagetype:[NSNumber numberWithInt:messageType] UUID:UUID issend:[NSNumber numberWithInt:Sended] avatarUrl:@""];
                                
                                if(result)
                                {
                                    if(![self getMessageWithUUID:UUID]){
                                        [self.messages insertObject:message atIndex:0];
                                    }
                                }
                            }
                        }
                    }else{
                        if(notification && [[notification xmlns] isEqualToString:@"androidpn:iq:notification"])
                        {
                            NSString *UUID = [[notification elementForName:@"id"] stringValue];
                            NSDictionary *dict = [[[notification elementForName:@"message"] stringValue] JSONValue][@"info"];
                            
                            NSString *text = dict[@"content"];
                            NSString *from = dict[@"fromId"];
                            NSString *sendName = dict[@"toId"];
                            NSArray *tagList = dict[@"tags"];
                            NSString *title = @"";
                            NSUInteger source = [dict[@"source"] integerValue];
                            NSString *historyTitle = @"";
                            if(source == 5){
                                historyTitle = title;
                            }else{
                                historyTitle = text;
                            }
                            if(tagList.count)
                            {
                                title = tagList[0][@"title"];
                            }
                            double timeStamp = [[notification elementForName:@"timestamp"] stringValueAsDouble] / 1000;
                            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
                            
                            [app.dataBase insertMessages:[NSNumber numberWithInt:XHBubbleMessageTypeReceiving] timestamp:[NSString stringWithFormat:@"%.0f",timeStamp] UUID:UUID star:title avatorUrl:@"" sendName:from recvName:sendName issend:[NSNumber numberWithInt:Sended] messagetype:[NSNumber numberWithInt:source] unread:[NSNumber numberWithInt:0] richbody:@"" body:text];
                            
                            if(count == (historys.count - 1))
                                [app.dataBase insertHistorys:self.messageSender timestamp:[NSString stringWithFormat:@"%.0f",timeStamp] body:historyTitle direction:[NSNumber numberWithInt:message.bubbleMessageType] messagetype:[NSNumber numberWithInt:source] UUID:UUID issend:[NSNumber numberWithInt:Sended] avatarUrl:@""];
                            for(NSDictionary *tag in tagList)
                            {
                                NSUInteger length = [tag[@"length"] integerValue];
                                NSUInteger start = [tag[@"start"] integerValue];
                                NSUInteger tagType = [tag[@"tag"] integerValue];
                                NSString *tagId = tag[@"tagId"];
                                NSString *title = tag[@"title"];
                                [app.dataBase insertIntoTagList:UUID start:[NSNumber numberWithInt:start] length:[NSNumber numberWithInt:length] tagType:[NSNumber numberWithInt:tagType] title:title tagId:tagId];
                            }
                            tagList = [app.dataBase selectTagList:UUID];
                            switch (source)
                            {
                                case XHBubbleMessageMediaTypeDrugGuide:
                                {
                                    NSString *title = tagList[0][@"title"];
                                    message = [[XHMessage alloc] initWithDrugGuide:text title:title sender:sendName timestamp:date UUID:UUID tagList:tagList];
                                    break;
                                }
                                case XHBubbleMessageMediaTypePurchaseMedicine:
                                {
                                    message = [[XHMessage alloc] initWithPurchaseMedicine:text sender:sendName timestamp:date UUID:UUID tagList:tagList];
                                    break;
                                }
                                default:
                                    break;
                            }
                            message.bubbleMessageType = XHBubbleMessageTypeReceiving;
                            if(self.infoDict[@"avatarurl"]) {
                                message.avatorUrl = self.infoDict[@"avatarurl"];
                            }else if(self.infoDict[@"imgUrl"]) {
                                message.avatorUrl = self.infoDict[@"imgUrl"];
                            }else{
                                message.avatorUrl = @"";
                            }
                            if(message)
                            {
                                [self.messages insertObject:message atIndex:0];
                            }
                        }
                    }
                }
                [self.messageTableView reloadData];
                [self.messageTableView headerEndRefreshing];
                [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_NEED_UPDATE object:nil];
                [self scrollToBottomAnimated:YES];
            }
        } failure:^(id failMsg) {
            [self.messageTableView headerEndRefreshing];
        }];
    }
}


- (void)footerRereshing
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"endpoint"] = @"1";
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    if(self.messages.count == 0) {
        double timestamp = [[NSDate date] timeIntervalSince1970];
        timestamp *= 1000;
        setting[@"point"] = [NSString stringWithFormat:@"%.0f",timestamp];
    }else{
        XHMessage *message = self.messages[0];
        double timestamp = [message.timestamp timeIntervalSince1970];
        timestamp *= 1000;
        setting[@"point"] = [NSString stringWithFormat:@"%.0f",timestamp];
    }
    setting[@"viewType"] = @"+1";
    setting[@"view"] = @"15";
    setting[@"to"] = self.messageSender;
    [[HTTPRequestManager sharedInstance] selectIM:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]){
            NSArray *historys = resultObj[@"body"];
            NSInteger count = historys.count - 1;
            for(; count >= 0 ; --count)
            {
                NSDictionary *dict = historys[count];
                NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString:dict[@"content"] options:0 error:nil];
                XMPPIQ *iq = (XMPPIQ *)[document rootElement];
                NSXMLElement *notification = [iq elementForName:@"notification"];
                if(notification && [[notification xmlns] isEqualToString:@"androidpn:iq:notification"])
                {
                    //接受消息成功
                    NSString *UUID = [[notification elementForName:@"id"] stringValue];
                    NSString *text = [[notification elementForName:@"message"] stringValue];
                    NSString *from = [[notification elementForName:@"fromUser"] stringValue];
                    double timeStamp = [[notification elementForName:@"timestamp"] stringValueAsDouble] / 1000;
                    NSString *avatorUrl = [[notification elementForName:@"uri"] stringValue];
                    NSString *sendName = [[notification elementForName:@"to"] stringValue];
                    NSUInteger messageType = [[notification elementForName:@"msType"] stringValueAsInt32];
                    NSString *title = [[notification elementForName:@"title"] stringValue];
                    NSString *richBody = [[notification elementForName:@"richBody"] stringValue];
                    
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
                    
                    NSString *fromId = dict[@"fromId"];
                    XHMessage *message = nil;
                    switch (messageType)
                    {
                        case XHBubbleMessageMediaTypeText:
                        {
                            message = [[XHMessage alloc] initWithText:text sender:sendName timestamp:date UUID:UUID];
                            break;
                        }
                        case XHBubbleMessageMediaTypeLocation:
                        {
                            NSString *latitude = [title componentsSeparatedByString:@","][0];
                            NSString *longitude = [title componentsSeparatedByString:@","][1];
                            
                            message = [[XHMessage alloc] initWithLocation:text latitude:latitude longitude:longitude sender:sendName timestamp:date UUID:UUID];
                            break;
                        }
                        case XHBubbleMessageMediaTypeStarStore:
                        {
                            message = [[XHMessage alloc] initInviteEvaluate:text sender:sendName timestamp:date UUID:UUID];
                            break;
                        }
                        case XHBubbleMessageMediaTypeStarClient:
                        {
                            message = [[XHMessage alloc] initEvaluate:[title floatValue] text:[NSString stringWithFormat:@"评价内容:%@",text] sender:sendName timestamp:date UUID:UUID];
                            break;
                        }
                        case XHBubbleMessageMediaTypeActivity:
                        {
                            NSString *imageUrl = avatorUrl;
                            if(imageUrl == nil)
                                imageUrl = @"";
                            message = [[XHMessage alloc] initMarketActivity:[app replaceSpecialStringWith:title] sender:sendName imageUrl:imageUrl content:[app replaceSpecialStringWith:text] comment:@"" richBody:richBody timestamp:date UUID:UUID];
                            break;
                        }
                        default:
                            break;
                    }
                    
                    if([fromId isEqualToString:self.messageSender]){
                        message.bubbleMessageType = XHBubbleMessageTypeReceiving;
                    }else{
                        message.bubbleMessageType = XHBubbleMessageTypeSending;
                    }
                    if(message.bubbleMessageType == XHBubbleMessageTypeSending) {
                        message.avatorUrl = app.configureList[APP_AVATAR_KEY];
                    }else{
                        message.avatorUrl = self.avatarUrl;
                    }
                    BOOL result = [app.dataBase insertMessages:[NSNumber numberWithInt:message.bubbleMessageType] timestamp:[NSString stringWithFormat:@"%.0f",timeStamp] UUID:UUID star:title avatorUrl:avatorUrl sendName:from recvName:sendName issend:[NSNumber numberWithInt:Sended] messagetype:[NSNumber numberWithInt:messageType] unread:[NSNumber numberWithInt:1] richbody:avatorUrl body:text];
                    if(result)
                        [self.messages addObject:message];
                }
                [self.messageTableView reloadData];
                
            }
            [self.messageTableView footerEndRefreshing];
        }
    } failure:^(id failMsg) {
        [self.messageTableView footerEndRefreshing];
    }];
    
    [self.messageTableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:5.0f];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.messageInputView.inputTextView resignFirstResponder];
    [[XHAudioPlayerHelper shareInstance] stopAudio];
    [app updateUnreadCountBadge];
    [app.dataBase updateSendingMessageToFailure];
    [super viewWillDisappear:animated];
}

- (XHMessage *)getMessageWithUUID:(NSString *)uuid
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"UUID == %@",uuid];
    NSArray *array = [self.messages filteredArrayUsingPredicate:predicate];
    if([array count] > 0) {
        return array[0];
    }else{
        return nil;
    }
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSXMLElement *notification = [iq elementForName:@"notification"];
    if(notification && [[notification xmlns] isEqualToString:@"androidpn:iq:notification"])
    {
        //发送消息成功
        NSString *UUID = [[notification elementForName:@"id"] stringValue];
        NSString *text = [[notification elementForName:@"message"] stringValue];
        NSString *from = [[notification elementForName:@"fromUser"] stringValue];
        NSString *title = [[notification elementForName:@"title"] stringValue];
        NSString *imagrUri = [[notification elementForName:@"uri"] stringValue];
        NSString *richBody = [[notification elementForName:@"richBody"] stringValue];
        if(![from isEqualToString:self.messageSender]){
            return YES;
        }
        NSInteger timeStamp = [[notification elementForName:@"timestamp"] stringValueAsFloat] / 1000;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
        XHBubbleMessageMediaType messageType = [[notification elementForName:@"msType"] stringValueAsInt32];
        XHMessage *message = nil;
        if(messageType == XHBubbleMessageMediaTypeQuitout)
            return NO;
        switch (messageType) {
            case XHBubbleMessageMediaTypeText:{
                message = [[XHMessage alloc] initWithText:text sender:app.configureList[APP_PASSPORTID_KEY] timestamp:date UUID:UUID];
                break;
            }
            case XHBubbleMessageMediaTypeLocation:
            {
                NSString *latitude = [title componentsSeparatedByString:@","][0];
                NSString *longitude = [title componentsSeparatedByString:@","][1];
                
                message = [[XHMessage alloc] initWithLocation:text latitude:latitude longitude:longitude sender:app.configureList[APP_PASSPORTID_KEY] timestamp:date UUID:UUID];
                break;
            }
            case XHBubbleMessageMediaTypeStarStore:{
                message = [[XHMessage alloc] initInviteEvaluate:text sender:app.configureList[APP_PASSPORTID_KEY] timestamp:date UUID:UUID];
                message.starMark = 5.0;
                message.isMarked = NO;
                break;
            }
            case XHBubbleMessageMediaTypeStarClient:
            {
                
                break;
            }
            case XHBubbleMessageMediaTypeActivity:
            {
                message = [[XHMessage alloc] initMarketActivity:[app replaceSpecialStringWith:title] sender:app.configureList[APP_PASSPORTID_KEY] imageUrl:imagrUri content:[app replaceSpecialStringWith:text] comment:@"" richBody:richBody timestamp:date UUID:UUID];
                break;
            }
            default:
                break;
        }
        message.sended = Sended;
        message.bubbleMessageType = XHBubbleMessageTypeReceiving;

        message.avatorUrl = self.avatarUrl;
        [_taskLock lock];
        if (message)
            [_cacheList addObject:message];
        [_taskLock unlock];
        [self performSelector:@selector(loadMoreMessage) withObject:nil afterDelay:1.0f];
    }
    return YES;
}

- (void)loadMoreMessage
{
    [_taskLock lock];
    if(_cacheList.count == 0)
    {
        [_taskLock unlock];
        return;
    }
    if(!self.messageTableView.tableFooterView) {
        [self setupFooterHintView];
    }
    [self addCacheMessage:_cacheList];
    [_cacheList removeAllObjects];
    [app.dataBase setMessagesReadWithRelatedId:self.messageSender];
    [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_NEED_UPDATE object:nil];
    [_taskLock unlock];
}

- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq
{
    NSXMLElement *notification = [iq elementForName:@"notification"];
    if(notification && [[notification xmlns] isEqualToString:@"androidpn:iq:notification"])
    {
        //发送消息成功
        NSString *UUID = [[notification elementForName:@"id"] stringValue];
        XHMessage *filterMessage = [self getMessageWithUUID:UUID];
        if(filterMessage) {
            filterMessage.sended = Sended;

            NSInteger index = [self.messages indexOfObject:filterMessage];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self scrollToBottomAnimated:YES];
    }
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{
    NSXMLElement *notification = [iq elementForName:@"notification"];
    if(notification && [[notification xmlns] isEqualToString:@"androidpn:iq:notification"])
    {
        //发送消息失败
        NSString *UUID = [[notification elementForName:@"id"] stringValue];
        XHMessage *filterMessage = [self getMessageWithUUID:UUID];
        if(filterMessage) {
            filterMessage.sended = SendFailure;
            //更新本地数据库

            NSInteger index = [self.messages indexOfObject:filterMessage];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        [self scrollToBottomAnimated:YES];
        [SVProgressHUD showErrorWithStatus:@"网络连接不可用，请稍后重试" duration:0.8f];
    }
}

- (NSMutableArray *)queryOfficialDataBaseCache
{
    NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:10];
    for(NSDictionary *dict in [app.dataBase selectOfficialMessages])
    {
        XHMessage *message = nil;
        double time = [dict[@"timestamp"] doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
        NSArray *tagList = [app.dataBase selectTagList:dict[@"UUID"]];
        
        switch ([dict[@"messagetype"] intValue])
        {
            case XHBubbleMessageMediaTypeAutoSubscription:
            {
                message = [[XHMessage alloc] initWithAutoSubscription:dict[@"body"] sender:@"" timestamp:date UUID:dict[@"UUID"] tagList:tagList];
                break;
            }
            case XHBubbleMessageMediaTypeDrugGuide:
            {
                NSDictionary *tag = tagList[0];
                message = [[XHMessage alloc] initWithDrugGuide:dict[@"body"] title:tag[@"title"] sender:@"" timestamp:date UUID:dict[@"UUID"] tagList:tagList];
                break;
            }
            case XHBubbleMessageMediaTypePurchaseMedicine:
            {
                message = [[XHMessage alloc] initWithPurchaseMedicine:dict[@"body"] sender:@"" timestamp:date UUID:dict[@"UUID"] tagList:tagList];
                break;
            }
            case XHBubbleMessageMediaTypeText:
            {
                message = [[XHMessage alloc] initWithText:dict[@"body"] sender:@"" timestamp:date UUID:dict[@"UUID"]];
                break;
            }
        }
        message.avator = [UIImage imageNamed:@"全维药事icon.png"];
        message.officialType = YES;
        message.bubbleMessageType = [dict[@"direction"] integerValue];
        if(message)
            [retArray addObject:message];
    }
    if(retArray.count == 0 && self.messages.count == 0)
    {
        XHMessage *welcomeMessage = [[XHMessage alloc] initWithText:WELCOME_MESSAGE sender:@"" timestamp:[NSDate date] UUID:[XMPPStream generateUUID]];
        welcomeMessage.avator = [UIImage imageNamed:@"全维药事icon.png"];
        welcomeMessage.officialType = YES;
        welcomeMessage.bubbleMessageType = XHBubbleMessageTypeReceiving;
        [retArray addObject:welcomeMessage];
    }
    return retArray;
}

- (NSMutableArray *)queryDataBaseCache
{
    BOOL shouldShowFooter = NO;
    NSMutableArray *array = [app.dataBase selectAllMessagesWithSendName:self.messageSender];
    NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:15];
    for(NSDictionary *dict in array)
    {
        XHMessage *message = nil;
        double time = [dict[@"timestamp"] doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
        switch ([dict[@"messagetype"] intValue])
        {
            case XHBubbleMessageMediaTypeText:
            {
                message = [[XHMessage alloc] initWithText:dict[@"body"] sender:dict[@"sendname"] timestamp:date UUID:dict[@"UUID"]];
                break;
            }
            case XHBubbleMessageMediaTypeLocation:
            {
                NSString *latitude = [dict[@"star"] componentsSeparatedByString:@","][0];
                NSString *longitude = [dict[@"star"] componentsSeparatedByString:@","][1];
                
                message = [[XHMessage alloc] initWithLocation:dict[@"body"] latitude:latitude longitude:longitude sender:dict[@"sendname"] timestamp:date UUID:dict[@"UUID"]];
                break;
            }
            case XHBubbleMessageMediaTypeStarStore:
            {
                message = [[XHMessage alloc] initInviteEvaluate:dict[@"body"] sender:dict[@"sendname"] timestamp:date UUID:dict[@"UUID"]];
                message.starMark = [dict[@"star"] integerValue];
                if(message.starMark > 0) {
                    message.isMarked = NO;
                }else{
                    message.isMarked = YES;
                }
                break;
            }
            case XHBubbleMessageMediaTypeStarClient:
            {
                message = [[XHMessage alloc] initEvaluate:[dict[@"star"] floatValue] text:[NSString stringWithFormat:@"评价内容:%@",dict[@"body"]] sender:dict[@"sendname"] timestamp:date UUID:dict[@"UUID"]];
                
                break;
            }
            case XHBubbleMessageMediaTypeActivity:
            {
                NSString *imageUrl = dict[@"avatorUrl"];
                if(imageUrl == nil)
                    imageUrl = @"";
                NSString *star = dict[@"star"];
                if(star == nil || [star isEqual:[NSNull null]])
                    star = @"";
                
                message = [[XHMessage alloc] initMarketActivity:[app replaceSpecialStringWith:star] sender:dict[@"sendname"] imageUrl:imageUrl content:[app replaceSpecialStringWith:dict[@"body"]] comment:@"" richBody:dict[@"richbody"] timestamp:date UUID:dict[@"UUID"]];
                break;
            }
            case XHBubbleMessageMediaTypeDrugGuide:
            {
                NSArray *tagList = [app.dataBase selectTagList:dict[@"UUID"]];
                NSDictionary *tag = tagList[0];
                message = [[XHMessage alloc] initWithDrugGuide:dict[@"body"] title:tag[@"title"] sender:@"" timestamp:date UUID:dict[@"UUID"] tagList:tagList];
                break;
            }
            case XHBubbleMessageMediaTypePurchaseMedicine:
            {
                NSArray *tagList = [app.dataBase selectTagList:dict[@"UUID"]];
                message = [[XHMessage alloc] initWithPurchaseMedicine:dict[@"body"] sender:@"" timestamp:date UUID:dict[@"UUID"] tagList:tagList];
                break;
            }
            default:
                break;
        }
        if([dict[@"direction"] intValue] == XHBubbleMessageTypeSending)
        {
            shouldShowFooter = YES;
            message.avatorUrl = app.configureList[APP_AVATAR_KEY];
        }else{
            message.avatorUrl = self.avatarUrl;
        }
        message.sended = [dict[@"issend"] intValue];
        message.bubbleMessageType = [dict[@"direction"] intValue];
        if(message)
            [retArray addObject:message];
    }
    if(shouldShowFooter)
    {
        [self setupFooterHintView];
    }
    if(retArray.count == 0)
    {
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        setting[@"source"] = @"1";
        [[HTTPRequestManager sharedInstance] heartBeat:setting completion:^(id resultObj) {
            if([resultObj[@"result"] isEqualToString:@"OK"]) {
                double timeStamp = [resultObj[@"body"][@"respTime"] doubleValue];
                timeStamp /= 1000;
                XHMessage *message = [self buildFirstHintMessage:timeStamp];
                [self.messages addObject:message];
                [self.messageTableView reloadData];
            }
        } failure:NULL];
        
    }
    return retArray;
}

- (XHMessage *)buildFirstHintMessage:(double)timeStamp
{
    NSString *hintMsg = [NSString stringWithFormat:@"您好，这里是%@，请问有什么可以帮您呢？",self.infoDict[@"name"]];
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    
    XHMessage *message = [[XHMessage alloc] initWithText:hintMsg sender:app.configureList[APP_PASSPORTID_KEY] timestamp:timeDate UUID:[XMPPStream generateUUID]];
    message.sended = Sended;
    message.bubbleMessageType = XHBubbleMessageTypeReceiving;
    message.avatorUrl = self.avatarUrl;
    
    NSString *timeString = [NSString stringWithFormat:@"%.0f",timeStamp];
    
    [app.dataBase insertMessages:[NSNumber numberWithInt:1] timestamp:timeString UUID:message.UUID star:@"" avatorUrl:@"" sendName:self.messageSender recvName:app.configureList[APP_USER_TOKEN] issend:[NSNumber numberWithInt:2] messagetype:[NSNumber numberWithInt:XHBubbleMessageMediaTypeText] unread:[NSNumber numberWithInt:0] richbody:@"" body:hintMsg];
    return message;
}

- (void)backToPreviousController:(id)sender
{
    [[[XMPPManager sharedInstance] xmppStream] removeDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadAvatar
{
    [app.dataBase setMessagesReadWithRelatedId:self.messageSender];
    self.messages = [self queryDataBaseCache];
    [self.messageTableView reloadData];
}

- (void)reloadOfficial
{
    [app.dataBase setOfficialMessagesRead];
    self.messages = [self queryOfficialDataBaseCache];
    [self.messageTableView reloadData];
}

- (void)pushIntoOfficialIntroduce:(id)sender
{
    IntroduceQwysViewController *introduceQwysViewController = [[IntroduceQwysViewController alloc] initWithNibName:@"IntroduceQwysViewController" bundle:nil];
    [self.navigationController pushViewController:introduceQwysViewController animated:YES];
}

- (void)checkCertVaild
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    if(self.infoDict[@"groupId"])
        setting[@"id"] = self.infoDict[@"groupId"];
    else
        setting[@"id"] = self.infoDict[@"id"];
    setting[@"endpoint"] = @"1";
    [[HTTPRequestManager sharedInstance] checkCert:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"FAIL"]) {
            NSInteger sendType = [resultObj[@"body"][@"send"] integerValue];
            if(sendType == 1) {
                //允许发送
                [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:3.0f];
                
            }else if(sendType == -1){
                //不允许发送
                [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:3.0f];
                self.errorMsg = resultObj[@"msg"];
                self.messageInputView.userInteractionEnabled = NO;
                self.shareMenuView.userInteractionEnabled = NO;
                self.emotionManagerView.userInteractionEnabled = NO;
            }
        }
    } failure:^(id failMsg) {
        
    }];
}

- (void)closeHintAction:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        hintView.alpha = 0.0;
    }];
}


#pragma ---跳转到首页


-(void)setRightItems{
    UIView *qwysBarItems = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 55)];
    //[customBarItems setBackgroundColor:[UIColor yellowColor]];
    UIButton *meButton = [[UIButton alloc] initWithFrame:CGRectMake(28, 0, 55, 55)];
    [meButton setImage:[UIImage imageNamed:@"IM_qwys_icon.png"]  forState:UIControlStateNormal];
    [meButton addTarget:self action:@selector(pushIntoOfficialIntroduce:) forControlEvents:UIControlEventTouchDown];
    [qwysBarItems addSubview:meButton];
    
    UIButton *indexButton = [[UIButton alloc] initWithFrame:CGRectMake(65, 0, 55, 55)];
    [indexButton setImage:[UIImage imageNamed:@"icon-unfold.PNG"] forState:UIControlStateNormal];
    [indexButton addTarget:self action:@selector(showIndex) forControlEvents:UIControlEventTouchDown];
    [qwysBarItems addSubview:indexButton];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -20;
    self.navigationItem.rightBarButtonItems = @[fixed,[[UIBarButtonItem alloc] initWithCustomView:qwysBarItems]];

}

- (void)showIndex
{
    self.indexView = [ReturnIndexView sharedManagerWithImage:@[@"首页.png"] title:@[@"首页"]];
    self.indexView.delegate = self;
    [self.indexView show];
    
}

- (void)RetunIndexView:(ReturnIndexView *)ReturnIndexView didSelectedIndex:(NSIndexPath *)indexPath
{
    [self.indexView hide];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self performSelector:@selector(delayPopToHome) withObject:nil afterDelay:0.01];
}

- (void)delayPopToHome
{
    [app.tabBarController setSelectedIndex:0];
}






- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.accountType == NormalType) {
        _cacheList = [NSMutableArray arrayWithCapacity:15];
        _taskLock = [[NSCondition alloc] init];
        [[[XMPPManager sharedInstance] xmppStream] addDelegate:self delegateQueue:dispatch_get_main_queue()];
        if(self.infoDict[@"accountId"])
        {
            self.messageSender = self.infoDict[@"accountId"];
            self.avatarUrl = self.infoDict[@"imgUrl"];
        }
        else
        {
            self.messageSender = self.infoDict[@"relatedid"];
            self.avatarUrl = self.infoDict[@"avatarurl"];
        }
        [app.dataBase setMessagesReadWithRelatedId:self.messageSender];
        self.messages = [self queryDataBaseCache];
        [self checkCertVaild];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAvatar) name:NEED_UPDATE_AVATAR object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAvatar) name:self.messageSender object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAvatar) name:@"offLineMessage" object:nil];
    }else{
        self.title = @"全维药事";
        #pragma ---按钮调整
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IM_qwys_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pushIntoOfficialIntroduce:)];
        [self setRightItems];
   
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadOfficial) name:OFFICIAL_MESSAGE object:nil];
        CGRect rect = self.messageTableView.frame;
        rect.size.height += 45;
        self.messageTableView.frame = rect;
        self.messageInputView.hidden = YES;
        [self.messageTableView removeFooter];
        self.messages = [self queryOfficialDataBaseCache];
        if(app.logStatus) {
            [app.dataBase setOfficialMessagesRead];
        }
    }
    if(!app.logStatus) {
        [self.messageTableView removeHeader];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_NEED_UPDATE object:nil];
    // 添加第三方接入数据
    NSMutableArray *shareMenuItems = [NSMutableArray array];
    NSArray *plugIcons = @[@"sharemore_pic", @"sharemore_video", @"sharemore_location", @"sharemore_friendcard", @"sharemore_myfav", @"sharemore_wxtalk", @"sharemore_videovoip", @"sharemore_voiceinput", @"sharemore_openapi", @"sharemore_openapi", @"avator"];
    NSArray *plugTitle = @[@"照片", @"拍摄", @"位置", @"名片", @"我的收藏", @"实时对讲机", @"视频聊天", @"语音输入", @"大众点评", @"应用", @"曾宪华"];
    for (NSString *plugIcon in plugIcons) {
        XHShareMenuItem *shareMenuItem = [[XHShareMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:plugIcon] title:[plugTitle objectAtIndex:[plugIcons indexOfObject:plugIcon]]];
        [shareMenuItems addObject:shareMenuItem];
    }
    
    NSString *emojiPath = [[NSBundle mainBundle] pathForResource:@"expressionImage_custom" ofType:@"plist"];
    NSMutableDictionary *emotionDict = [[NSMutableDictionary alloc] initWithContentsOfFile:emojiPath];
    NSArray *allKeys = [emotionDict allKeys];
    XHEmotionManager *emotionManager = [[XHEmotionManager alloc] init];
    //emotionManager.emotionName = @"表情";
    NSMutableArray *emotionManagers = [NSMutableArray arrayWithCapacity:100];
    
#define ROW_NUM     3
#define COLUMN_NUM  7
    for(NSUInteger index = 0; index < [allKeys count]; ++index)
    {
        NSString *key = allKeys[index];
        if(index != 0 && (index % (ROW_NUM * COLUMN_NUM - 1)) == 0){
            XHEmotionManager *subEmotion = [[XHEmotionManager alloc] init];
            subEmotion.emotionName = @"删除";
            subEmotion.imageName = @"backFaceSelect";
            [emotionManager.emotions addObject:subEmotion];
        }
        XHEmotionManager *subEmotion = [[XHEmotionManager alloc] init];
        subEmotion.emotionName = key;
        subEmotion.imageName = emotionDict[key];
        [emotionManager.emotions addObject:subEmotion];
        if (index == [allKeys count] - 1)
        {
            XHEmotionManager *subEmotion = [[XHEmotionManager alloc] init];
            subEmotion.emotionName = @"删除";
            subEmotion.imageName = @"backFaceSelect";
            [emotionManager.emotions addObject:subEmotion];
        }
    }
    [emotionManagers addObject:emotionManager];
    self.emotionManagers = emotionManagers;
    [self.emotionManagerView reloadData];
    
    self.shareMenuItems = shareMenuItems;
    [self.shareMenuView reloadData];
    if(app.logStatus)
    {
        [self rereshingRecentMessage];
        [app updateUnreadCountBadge];
        [self updateServiceReadNum];
        [self loadDemoDataSource];
    }
}

- (void)setupFooterHintView
{
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_W, 100)];
    UIImageView *bubbleImageView = [[UIImageView alloc] init];
    bubbleImageView.frame = CGRectMake(16, 10, APP_W * 0.9, 80);
    UIImage *resizeImage = [UIImage imageNamed:@"weChatBubble_Receiving_Solid_无角.png"];
    resizeImage = [resizeImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch];
    bubbleImageView.image = resizeImage;
    bubbleImageView.userInteractionEnabled = YES;
    MLEmojiLabel *emojiLabel = [[MLEmojiLabel alloc] initWithFrame:CGRectMake(10, 10, APP_W * 0.85, 60)];
    emojiLabel.numberOfLines = 4;
    emojiLabel.font = [UIFont systemFontOfSize:14.0f];
    emojiLabel.lineBreakMode = NSLineBreakByCharWrapping;
    emojiLabel.backgroundColor = [UIColor clearColor];
    emojiLabel.emojiDelegate = self;
    //emojiLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    emojiLabel.customEmojiPlistName = @"expressionImage_custom.plist";
    emojiLabel.emojiText = @"药师利用空闲时间解答用药相关问题，如未及时回复请谅解，药师的回答仅供参考。除了咨询药师，您还可以快速自查身体不适。";

    [emojiLabel addLinkToURL:[NSURL URLWithString:@""] withRange:NSMakeRange(48, 4)];
    [bubbleImageView addSubview:emojiLabel];
    [container addSubview:bubbleImageView];
    self.messageTableView.tableFooterView = container;
}

- (void)mlEmojiLabel:(MLEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(MLEmojiLabelLinkType)type
{
    if(type == MLEmojiLabelLinkTypeQuickSearch) {
        QuickSearchViewController *quickSearchViewController = [[QuickSearchViewController alloc] init];
        quickSearchViewController.showBack = 1;
        [self.navigationController pushViewController:quickSearchViewController animated:YES];
    }
}

- (void)updateServiceReadNum
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    NSUInteger unread = [app.dataBase selectTotalUnreadCountMessage];
    setting[@"num"] = [NSNumber numberWithInteger:unread];
    [[HTTPRequestManager sharedInstance] readIMNum:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"])
        {
            
        }
    } failure:NULL];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.emotionManagers = nil;
    [[XHAudioPlayerHelper shareInstance] setDelegate:nil];
    if(self.accountType == OfficialType) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:OFFICIAL_MESSAGE object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NEED_UPDATE_AVATAR object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:self.messageSender object:nil];
    }
}

/*
 [self removeMessageAtIndexPath:indexPath];
 [self insertOldMessages:self.messages];
 */

#pragma mark - XHMessageTableViewCell delegate

- (void)multiMediaMessageDidSelectedOnMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(XHMessageTableViewCell *)messageTableViewCell
{
    UIViewController *disPlayViewController;
    switch (message.messageMediaType) {
        case XHBubbleMessageMediaTypeLocation:
        {
            ShowLocationViewController *showLocationViewController = [[ShowLocationViewController alloc] init];
            showLocationViewController.coordinate = [message location].coordinate;
            showLocationViewController.address = [message text];
            [self.navigationController pushViewController:showLocationViewController animated:YES];
            break;
        }
        case XHBubbleMessageMediaTypeStarStore:
        {
            NSMutableDictionary *setting = [NSMutableDictionary dictionary];
            setting[@"imId"] = [message UUID];
            messageTableViewCell.userInteractionEnabled = NO;
            [[HTTPRequestManager sharedInstance] appraiseExist:setting completion:^(id resultObj) {
                messageTableViewCell.userInteractionEnabled = YES;
                if([resultObj[@"result"] isEqualToString:@"OK"]){
                    if([resultObj[@"body"][@"flag"] integerValue] == 1)
                        return;
                    MarkPharmacyViewController *markPharmacyViewController = [[MarkPharmacyViewController alloc] initWithNibName:@"MarkPharmacyViewController" bundle:nil];
                    markPharmacyViewController.UUID = [message UUID];
                    markPharmacyViewController.hidesBottomBarWhenPushed = YES;
                    markPharmacyViewController.infoDict = self.infoDict;
                    WEAKSELF
                    markPharmacyViewController.InsertNewEvaluate = ^(NSDictionary *dict){
                        [weakSelf didSendEvaluateStar:[dict[@"rating"] floatValue] Text:dict[@"remark"] fromSender:self.messageSender onDate:[NSDate date]];
                        XHMessage *message = self.messages[indexPath.row];
                        message.starMark = 0;
                        message.isMarked = YES;
                        [app.dataBase updateMessageEvaluate:@"0" With:message.UUID];
                        [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    };
                    [self.navigationController pushViewController:markPharmacyViewController animated:YES];
                }
            } failure:^(id failMsg) {
                messageTableViewCell.userInteractionEnabled = YES;
            }];
            break;
        }
        case XHBubbleMessageMediaTypeActivity:
        {
            //聊天进入
            
            MarketDetailViewController *marketDetailViewController = nil;
            
            if(HIGH_RESOLUTION) {
                marketDetailViewController = [[MarketDetailViewController alloc] initWithNibName:@"MarketDetailViewController" bundle:nil];
            }else{
                marketDetailViewController = [[MarketDetailViewController alloc] initWithNibName:@"MarketDetailViewController-480" bundle:nil];
            }
            NSString *richBody = [message richBody];
            NSDate *date = [message timestamp];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
            infoDict[@"activityId"] = richBody;
            if(self.infoDict[@"groupId"])
                infoDict[@"groupId"] = self.infoDict[@"groupId"];
            else if (self.infoDict[@"id"])
                infoDict[@"groupId"] = self.infoDict[@"id"];
            if(!infoDict[@"groupId"])
                return;
            marketDetailViewController.infoDict = infoDict;
            marketDetailViewController.userType = 1;
            marketDetailViewController.imStatus =2;
            if (!richBody)
            {
                marketDetailViewController.infoDict =@{@"title":[message title],
                                                                @"content":[message text],
                                                                @"imgUrl":([message activityUrl] ==nil)? @"":[message activityUrl],
                                                                @"publishTime":[formatter stringFromDate:date]                                                             };
            }
            
            
            [self.navigationController pushViewController:marketDetailViewController animated:YES];
            break;
        }
        default:
            break;
    }
    if (disPlayViewController) {
        [self.navigationController pushViewController:disPlayViewController animated:YES];
    }
}

- (void)didDoubleSelectedOnTextMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath
{
//    DLog(@"text : %@", message.text);
//    XHDisplayTextViewController *displayTextViewController = [[XHDisplayTextViewController alloc] init];
//    displayTextViewController.message = message;
//    [self.navigationController pushViewController:displayTextViewController animated:YES];
}

- (void)didSelectedAvatorOnMessage:(id<XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath
{
    //选中头像后的跳转逻辑
    if([message bubbleMessageType] == XHBubbleMessageTypeSending)
    {
        PersonInformationViewController * personInformation = [[PersonInformationViewController alloc] init];
        personInformation.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:personInformation animated:YES];
    }else{
        NSString *groupId = [app.dataBase selectGroupIdFromHistroy:self.messageSender];
        if([groupId isEqualToString:@""])
        {
            groupId = self.infoDict[@"id"];
            if(groupId == nil || [groupId isEqualToString:@""])
            {
                return;
            }
        }
        PharmacyStoreViewController *pharmacyStoreViewController = [[PharmacyStoreViewController alloc] init];
        NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];

        infoDict[@"id"] = groupId;
        pharmacyStoreViewController.infoDict = infoDict;
        pharmacyStoreViewController.useType = 1;
        [self.navigationController pushViewController:pharmacyStoreViewController animated:YES];
    }
}

- (void)menuDidSelectedAtBubbleMessageMenuSelecteType:(XHBubbleMessageMenuSelecteType)bubbleMessageMenuSelecteType
{
    
}

//删除某一条记录
- (void)deleteOneMessageAtIndexPath:(NSIndexPath *)indexPath
{
    XHMessage *message = self.messages[indexPath.row];
    
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"endpoint"] = @"1";
    setting[@"id"] = message.UUID;
    [[HTTPRequestManager sharedInstance] deleteI:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]) {
        }
    } failure:NULL];
    [app.dataBase deleteFromMessagesWithUUID:message.UUID];
    [app.dataBase updateLastHistoryMessage:self.messageSender];
    [self.messages removeObjectAtIndex:indexPath.row];
    [self.messageTableView reloadData];
}

//重新发送这条消息
- (void)resendMessageWithIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否重新发送" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    alertView.tag = indexPath.row;
}

- (void)didSelectActivityTitle:(NSIndexPath *)indexPath
{
    XHMessage *message = self.messages[indexPath.row];
    if([message messageMediaType] == XHBubbleMessageMediaTypeDrugGuide) {
        if([message tagList].count >= 1)
        {
            NSString *groupId = [message tagList][0][@"tagId"];
            NSString *title = [message tagList][0][@"title"];
            DetailSubscriptionListViewController *detailSubscriptionViewController = [[DetailSubscriptionListViewController alloc] init];
            detailSubscriptionViewController.infoDict = @{@"title":title,
                                                          @"guideId":groupId
                                                          };
            [self.navigationController pushViewController:detailSubscriptionViewController animated:YES];
        }
    }
}

- (void)didSelectLinkOnMeseage:(id <XHMessageModel>)message atIndexPath:(NSIndexPath *)indexPath LinkSting:(NSString *)link LinkType:(MLEmojiLabelLinkType)linkType
{
    if(linkType == MLEmojiLabelLinkTypeMedicineDetail)
    {
        DrugDetailViewController *vc = [[DrugDetailViewController alloc] init];
        vc.proId = link;
        [self.navigationController pushViewController:vc animated:YES];

    }else if (linkType == MLEmojiLabelLinkTypeDrugGuide)
    {
        DetailSubscriptionListViewController *detailSubscriptionViewController = [[DetailSubscriptionListViewController alloc] init];
        NSString *title = @"慢病订阅";
        if([message tagList].count > 1){
            
            DiseaseSubscriptionViewController *subscription = [[DiseaseSubscriptionViewController alloc] init];
            subscription.title = @"慢病订阅";
            subscription.subType = YES;
            subscription.navigationController = self.navigationController;
            [self.navigationController pushViewController:subscription animated:YES];
            
        }else{
            for(NSDictionary *dict in [message tagList])
            {
                if([dict[@"tagId"] isEqualToString:link]){
                    title = [[message text] substringWithRange:NSMakeRange([dict[@"start"] integerValue], [dict[@"length"] integerValue])];
                    break;
                }
            }
            detailSubscriptionViewController.infoDict = @{@"title":title,
                                                          @"guideId":link
                                                          };
            [app.dataBase updateHasReadFromDiseaseWithId:link hasRead:YES];
            [self.navigationController pushViewController:detailSubscriptionViewController animated:YES];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        if([[[XMPPManager sharedInstance] xmppStream] isConnected])
        {
            XHMessage *textMessage = self.messages[alertView.tag];
            textMessage.timestamp = [NSDate date];
            double timeDouble = [textMessage.timestamp timeIntervalSince1970] * 1000;
            XMPPIQ *messageIq = [XMPPIQ messageTypeWithText:textMessage.text withTo:self.messageSender avatarUrl:textMessage.avatorUrl from:app.configureList[APP_PASSPORTID_KEY] timestamp:timeDouble UUID:textMessage.UUID];
            [self.messages removeObject:textMessage];
            [self.messages addObject:textMessage];
            [self.messageTableView reloadData];
            [app.dataBase insertHistorys:self.messageSender timestamp:[NSString stringWithFormat:@"%0.f",[textMessage.timestamp timeIntervalSince1970]] body:textMessage.text direction:[NSNumber numberWithInt:XHBubbleMessageTypeSending] messagetype:[NSNumber numberWithInt:XHBubbleMessageMediaTypeStarClient] UUID:textMessage.UUID issend:[NSNumber numberWithInt:Sending] avatarUrl:textMessage.avatorUrl];
            [[[XMPPManager sharedInstance] xmppStream] sendIQ:messageIq withTag:0];
        }else{
            [SVProgressHUD showErrorWithStatus:@"网络连接不可用，请稍后重试" duration:0.8f];
        }
    }
}


#pragma mark - XHAudioPlayerHelper Delegate

- (void)didAudioPlayerStopPlay:(AVAudioPlayer *)audioPlayer {
    if (!_currentSelectedCell) {
        return;
    }
    [_currentSelectedCell.messageBubbleView.animationVoiceImageView stopAnimating];
    self.currentSelectedCell = nil;
}

#pragma mark - XHEmotionManagerView DataSource

- (NSInteger)numberOfEmotionManagers
{
    return self.emotionManagers.count;
}

- (XHEmotionManager *)emotionManagerForColumn:(NSInteger)column
{
    return [self.emotionManagers objectAtIndex:column];
}

- (NSArray *)emotionManagersAtManager
{
    return self.emotionManagers;
}

#pragma mark - XHMessageTableViewController Delegate

- (BOOL)shouldLoadMoreMessagesScrollToTop
{
    return YES;
}

- (void)didSendEvaluateStar:(CGFloat)star
                       Text:(NSString *)text
                 fromSender:(NSString *)sender
                     onDate:(NSDate *)date
{
    if(self.errorMsg && ![self.errorMsg isEqualToString:@""])
    {
        [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];
        [SVProgressHUD showErrorWithStatus:self.errorMsg duration:0.8f];
        return;
    }
    
    XHMessage *message = [[XHMessage alloc] initEvaluate:star text:[NSString stringWithFormat:@"评价内容:%@",text] sender:sender timestamp:date UUID:[XMPPStream generateUUID]];
    if([[[XMPPManager sharedInstance] xmppStream] isConnected]) {
        message.sended = Sending;
    }else{
        message.sended = SendFailure;
    }
    message.starMark = star;
    message.bubbleMessageType = XHBubbleMessageTypeSending;
    message.avatorUrl = app.configureList[APP_AVATAR_KEY];
    if(!self.messageTableView.tableFooterView) {
        [self setupFooterHintView];
    }
    [self addMessage:message];
    
    [app.dataBase insertMessages:[NSNumber numberWithInt:XHBubbleMessageTypeSending] timestamp:[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]] UUID:message.UUID star:[NSString stringWithFormat:@"%f",message.starMark] avatorUrl:message.avatorUrl sendName:app.configureList[APP_PASSPORTID_KEY] recvName:self.messageSender issend:[NSNumber numberWithInt:Sending] messagetype:[NSNumber numberWithInt:XHBubbleMessageMediaTypeStarClient] unread:[NSNumber numberWithInt:0] richbody:@"" body:text];
    double timeDouble = [date timeIntervalSince1970] * 1000;
    
    [app.dataBase insertHistorys:self.messageSender timestamp:[NSString stringWithFormat:@"%0.f",[date timeIntervalSince1970]] body:text direction:[NSNumber numberWithInt:XHBubbleMessageTypeSending] messagetype:[NSNumber numberWithInt:XHBubbleMessageMediaTypeStarClient] UUID:message.UUID issend:[NSNumber numberWithInt:Sending] avatarUrl:message.avatorUrl];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];
    
    if(![[[XMPPManager sharedInstance] xmppStream] isConnected])
    {
        [self.messageInputView.inputTextView resignFirstResponder];
        [self scrollToBottomAnimated:YES];
        [SVProgressHUD showErrorWithStatus:@"网络连接不可用，请稍后重试" duration:0.8f];
        
        return;
    }
    
    XMPPIQ *messageIq = [XMPPIQ messageTypeWithEvaluate:text withTo:self.messageSender star:star * 2 avatarUrl:message.avatorUrl from:app.configureList[APP_PASSPORTID_KEY] timestamp:timeDouble UUID:message.UUID];
    [[[XMPPManager sharedInstance] xmppStream] sendIQ:messageIq withTag:0];
    
}

/**
 *  发送文本消息的回调方法
 *
 *  @param text   目标文本字符串
 *  @param sender 发送者的名字
 *  @param date   发送时间
 */
- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date
{
    if([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"发送内容不得为空!" duration:0.8f];
        return;
    }
    if(self.errorMsg && ![self.errorMsg isEqualToString:@""])
    {
        [self.messageInputView.inputTextView resignFirstResponder];
        [SVProgressHUD showErrorWithStatus:self.errorMsg duration:0.8f];
        return;
    }
    
    XHMessage *textMessage = [[XHMessage alloc] initWithText:text sender:sender timestamp:date UUID:[XMPPStream generateUUID]];
    if([[[XMPPManager sharedInstance] xmppStream] isConnected]) {
        textMessage.sended = Sending;
    }else{
        textMessage.sended = SendFailure;
    }
    
    textMessage.messageMediaType = XHBubbleMessageMediaTypeText;
    textMessage.bubbleMessageType = XHBubbleMessageTypeSending;
    textMessage.avator = [UIImage imageNamed:@"avator"];
    textMessage.avatorUrl = app.configureList[APP_AVATAR_KEY];
    if(!self.messageTableView.tableFooterView) {
        [self setupFooterHintView];
    }
    [self addMessage:textMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeText];
    
    [app.dataBase insertMessages:[NSNumber numberWithInt:XHBubbleMessageTypeSending] timestamp:[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]] UUID:textMessage.UUID star:@"0" avatorUrl:textMessage.avatorUrl sendName:app.configureList[APP_PASSPORTID_KEY] recvName:self.messageSender issend:[NSNumber numberWithInt:textMessage.sended] messagetype:[NSNumber numberWithInt:XHBubbleMessageMediaTypeText] unread:[NSNumber numberWithInt:0] richbody:@"" body:text];
    
    [app.dataBase insertHistorys:self.messageSender timestamp:[NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]] body:text direction:[NSNumber numberWithInt:XHBubbleMessageTypeSending] messagetype:[NSNumber numberWithInt:XHBubbleMessageMediaTypeText] UUID:textMessage.UUID issend:[NSNumber numberWithInt:Sended] avatarUrl:@""];
    
    double timeDouble = [date timeIntervalSince1970] * 1000;
    if(![[[XMPPManager sharedInstance] xmppStream] isConnected])
    {
        [self.messageInputView.inputTextView resignFirstResponder];
        [self scrollToBottomAnimated:YES];
        [SVProgressHUD showErrorWithStatus:@"网络连接不可用，请稍后重试" duration:0.8f];
        [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_NEED_UPDATE object:nil];
        return;
    }
    XMPPIQ *messageIq = [XMPPIQ messageTypeWithText:text withTo:self.messageSender avatarUrl:textMessage.avatorUrl from:app.configureList[APP_PASSPORTID_KEY] timestamp:timeDouble UUID:textMessage.UUID];
    [[[XMPPManager sharedInstance] xmppStream] sendIQ:messageIq withTag:0];
}

/**
 *  发送图片消息的回调方法
 *
 *  @param photo  目标图片对象，后续有可能会换
 *  @param sender 发送者的名字
 *  @param date   发送时间
 */
- (void)didSendPhoto:(UIImage *)photo fromSender:(NSString *)sender onDate:(NSDate *)date {
    XHMessage *photoMessage = [[XHMessage alloc] initWithPhoto:photo thumbnailUrl:nil originPhotoUrl:nil sender:sender timestamp:date];
    photoMessage.avator = [UIImage imageNamed:@"avator"];
    photoMessage.avatorUrl = @"http://www.pailixiu.com/jack/meIcon@2x.png";
    [self addMessage:photoMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypePhoto];
}


/**
 *  发送语音消息的回调方法
 *
 *  @param voicePath        目标语音本地路径
 *  @param voiceDuration    目标语音时长
 *  @param sender           发送者的名字
 *  @param date             发送时间
 */
- (void)didSendVoice:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration fromSender:(NSString *)sender onDate:(NSDate *)date {
    XHMessage *voiceMessage = [[XHMessage alloc] initWithVoicePath:voicePath voiceUrl:nil voiceDuration:voiceDuration sender:sender timestamp:date];
    voiceMessage.avator = [UIImage imageNamed:@"avator"];
    voiceMessage.avatorUrl = @"http://www.pailixiu.com/jack/meIcon@2x.png";
    [self addMessage:voiceMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeVoice];
}

/**
 *  发送第三方表情消息的回调方法
 *
 *  @param facePath 目标第三方表情的本地路径
 *  @param sender   发送者的名字
 *  @param date     发送时间
 */
- (void)didSendEmotion:(NSString *)emotionPath fromSender:(NSString *)sender onDate:(NSDate *)date {
    XHMessage *emotionMessage = [[XHMessage alloc] initWithEmotionPath:emotionPath sender:sender timestamp:date];
    emotionMessage.avator = [UIImage imageNamed:@"avator"];
    emotionMessage.avatorUrl = @"http://www.pailixiu.com/jack/meIcon@2x.png";
    [self addMessage:emotionMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeEmotion];
}

/**
 *  有些网友说需要发送地理位置，这个我暂时放一放
 */
- (void)didSendGeoLocationsPhoto:(UIImage *)geoLocationsPhoto geolocations:(NSString *)geolocations location:(CLLocation *)location fromSender:(NSString *)sender onDate:(NSDate *)date {
    XHMessage *geoLocationsMessage = [[XHMessage alloc] initWithLocalPositionPhoto:geoLocationsPhoto geolocations:geolocations location:location sender:sender timestamp:date];
    geoLocationsMessage.avator = [UIImage imageNamed:@"avator"];
    geoLocationsMessage.avatorUrl = @"http://www.pailixiu.com/jack/meIcon@2x.png";
    [self addMessage:geoLocationsMessage];
    [self finishSendMessageWithBubbleMessageType:XHBubbleMessageMediaTypeLocalPosition];
}

/**
 *  是否显示时间轴Label的回调方法
 *
 *  @param indexPath 目标消息的位置IndexPath
 *
 *  @return 根据indexPath获取消息的Model的对象，从而判断返回YES or NO来控制是否显示时间轴Label
 */
- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath {

    XHMessage *message1 = self.messages[indexPath.row];
    if(indexPath.row == 0) {
        return YES;
    }else{
        XHMessage *message0 = self.messages[indexPath.row - 1];
        NSTimeInterval offset = [message1.timestamp timeIntervalSinceDate:message0.timestamp];
        if(offset >= 300.0)
            return YES;
    }
    return NO;
}

/**
 *  配置Cell的样式或者字体
 *
 *  @param cell      目标Cell
 *  @param indexPath 目标Cell所在位置IndexPath
 */
- (void)configureCell:(XHMessageTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{

}

/**
 *  协议回掉是否支持用户手动滚动
 *
 *  @return 返回YES or NO
 */
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

@end
