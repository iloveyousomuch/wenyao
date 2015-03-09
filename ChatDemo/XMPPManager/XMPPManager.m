//
//  XMPPManager.m
//  iPhoneXMPP
//
//  Created by xiezhenghong on 14-3-9.
//
//

#import "XMPPManager.h"
#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"

#import "XMPPRoomCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"

#import "DDLog.h"
#import "DDTTYLogger.h"

#import "NSData+XMPP.h"
#import <CFNetwork/CFNetwork.h>
#include "Constant.h"
#import "XMPPMessage+XEP0045.h"
#import "AppDelegate.h"
#import "XHMessage.h"
#import "HTTPRequestManager.h"
#import "NSString+MD5HexDigest.h"
#import "XHAudioPlayerHelper.h"
#import "SBJson.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface XMPPManager()




@end


@implementation XMPPManager
@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;

@synthesize rooms;

static XMPPManager      *shareXMPPManager = nil;

+ (XMPPManager*)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        shareXMPPManager = [[XMPPManager alloc] init];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
    });
    return shareXMPPManager;
}

-(id)init
{
    self = [super init];
    if(self)
    {

    }
    return self;
}

//初始化xmpp流
- (void)setupStream
{
	NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
	xmppStream = [[XMPPStream alloc] init];
	
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		//
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	xmppReconnect = [[XMPPReconnect alloc] init];
	
	//xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
	
	//xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
	
	//xmppRoster.autoFetchRoster = YES;
	//xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
	
	// Setup vCard support
	//
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
	//xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	//xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
	
	//xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    //xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    //xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    //xmppCapabilities.autoFetchHashedCapabilities = YES;
    //xmppCapabilities.autoFetchNonHashedCapabilities = NO;

	// Activate xmpp modules
    
//	[xmppReconnect         activate:xmppStream];
//	[xmppRoster            activate:xmppStream];
//	[xmppvCardTempModule   activate:xmppStream];
//	[xmppvCardAvatarModule activate:xmppStream];
//	[xmppCapabilities      activate:xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
    
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
//	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    [xmppvCardAvatarModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    rooms = [NSMutableArray arrayWithCapacity:15];
    _UUIDList = [NSMutableArray arrayWithCapacity:15];
    _taskLock = [[NSCondition alloc] init];
	// You may need to alter these settings depending on the server you're connecting to
	allowSelfSignedCertificates = NO;
	allowSSLHostNameMismatch = NO;
}



//关闭xmpp流
- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];
	
	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
	[xmppCapabilities      deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
    xmppRoster = nil;
	xmppRosterStorage = nil;
	xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
	xmppCapabilities = nil;
	xmppCapabilitiesStorage = nil;
}

- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
	return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

//上线
- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    NSString *domain = [xmppStream.myJID domain];
    
    //Google set their presence priority to 24, so we do the same to be compatible.
    
    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }
	
	[[self xmppStream] sendElement:presence];
}

//下线
- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[[self xmppStream] sendElement:presence];
}

//利用用户名以及密码登陆,用户名需要携带@domain,示例 ceshi1@221.224.87.98
- (BOOL)connectWithUserName:(NSString *)myJID Password:(NSString *)myPassword
{
	if (![xmppStream isDisconnected]) {
		return YES;
	}

	if (myJID == nil || myPassword == nil) {
		return NO;
	}
    
	[xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
	password = myPassword;
    
	NSError *error = nil;
	if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView show];
		DDLogError(@"Error connecting: %@", error);
		return NO;
	}
    
	return YES;
}

//退出登陆
- (void)disconnect
{
	[self goOffline];
	[xmppStream disconnect];
}

- (void)dealloc
{
	[self teardownStream];
}

#pragma mark - XMPPStream Delegate
//xmpp流 连上服务器
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		NSString *expectedCertName = [xmppStream.myJID domain];
        
		if (expectedCertName)
		{
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
		}
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (NSString *)encryptPassword:(NSString *)passwd
{
    NSString *encryPasswd = [NSString stringWithFormat:@"quanwei%@quanwei",passwd];
    return [encryPasswd md5HexDigest];
}

//连接成功后,开始注册账号
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    [[HTTPRequestManager sharedInstance] tokenValid:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]) {
            NSString *passportId = app.configureList[APP_PASSPORTID_KEY];
            passportId = [self encryptPassword:passportId];
            
            [xmppStream registerWithPassword:passportId error:nil];
        }else{
            //当前token已失效
            [app clearAccountInformation];
        }
    } failure:NULL];
}

//注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    //使用注册的jid登录
    NSString *passportId = app.configureList[APP_PASSPORTID_KEY];
    passportId = [self encryptPassword:passportId];
    [xmppStream authenticateWithPassword:passportId error:nil];
}

//用户名密码验证成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	[self goOnline];
}

//用户名密码验证不成功
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    //收到消息,插入数据库
    NSXMLElement *notification = [iq elementForName:@"notification"];
    if(notification && [[notification xmlns] isEqualToString:@"androidpn:iq:notification"])
    {
        //接受消息成功
        //播放声音
        NSString *UUID = [[notification elementForName:@"id"] stringValue];
        NSString *text = [[notification elementForName:@"message"] stringValue];
        NSString *from = [[notification elementForName:@"fromUser"] stringValue];
        double timeStamp = [[notification elementForName:@"timestamp"] stringValueAsDouble] / 1000;
        NSLog(@"%@",[[notification elementForName:@"timestamp"] stringValue]);
        NSString *avatorUrl = [[notification elementForName:@"uri"] stringValue];
        NSString *title = [[notification elementForName:@"title"] stringValue];
        NSString *richBody = [[notification elementForName:@"richBody"] stringValue];
        if(!richBody) {
            richBody = @"";
        }
        XMPPJID *sendJid = [iq to];
        NSString *sendName = [sendJid user];
        NSUInteger messageType = [[notification elementForName:@"msType"] stringValueAsInt32];
        if(!from || [from isEqualToString:@""])
            return YES;
        if(messageType == XHBubbleMessageMediaTypeQuitout)
        {
            [xmppReconnect deactivate];
            [[NSNotificationCenter defaultCenter] postNotificationName:KICK_OFF object:nil];
            return YES;
        }
        if(messageType == XHBubbleMessageMediaTypeStarStore) {
            title = @"5";
        }
        if(messageType == XHBubbleMessageMediaTypeStarClient) {
            CGFloat starMark = [title floatValue] / 2.0f;
            title = [NSString stringWithFormat:@"%.1f",starMark];
        }
        [app.dataBase insertMessages:[NSNumber numberWithInt:XHBubbleMessageTypeReceiving] timestamp:[NSString stringWithFormat:@"%.0f",timeStamp] UUID:UUID star:title avatorUrl:avatorUrl sendName:from recvName:sendName issend:[NSNumber numberWithInt:Sended] messagetype:[NSNumber numberWithInt:messageType] unread:[NSNumber numberWithInt:1] richbody:richBody body:text];
        if(messageType == XHBubbleMessageMediaTypeActivity)
        {
            text = title;
        }
        [app.dataBase insertHistorys:from timestamp:[NSString stringWithFormat:@"%.0f",timeStamp] body:text direction:[NSNumber numberWithInt:XHBubbleMessageTypeReceiving] messagetype:[NSNumber numberWithInt:messageType] UUID:UUID issend:[NSNumber numberWithInt:Sended] avatarUrl:@""];
        
        [_taskLock lock];
        [self.UUIDList addObject:UUID];
        [_taskLock unlock];
        [self performSelector:@selector(setIMReceived) withObject:nil afterDelay:2.0f];
    }else{
        double timeStamp = [[[iq attributeForName:@"time"] stringValue] doubleValue] / 1000;
        NSString *UUID = [[iq attributeForName:@"id"] stringValue];
        [app.dataBase updateMessageStatus:[NSNumber numberWithInt:Sended] timeStamp:[NSString stringWithFormat:@"%.0f",timeStamp] With:UUID];
    }
    return YES;
}

- (void)setIMReceived
{
    [_taskLock lock];
    if (self.UUIDList.count == 0)
    {
        [_taskLock unlock];
        return;
    }
    NSMutableArray *jsonArrays = [NSMutableArray arrayWithCapacity:10];
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    for(NSString *UUID in self.UUIDList)
    {
        NSDictionary *dict = @{@"id":UUID};
        [jsonArrays addObject:dict];
    }
    setting[@"ids"] = jsonArrays;
    [app updateUnreadCountBadge];
    [XHAudioPlayerHelper playMessageReceivedSound];
    [self.UUIDList removeAllObjects];
    [_taskLock unlock];
//    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//    localNotification.fireDate = [NSDate date];
//    localNotification.alertBody = @"你收到一条会话信息";
//    localNotification.soundName = UILocalNotificationDefaultSoundName;
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [[HTTPRequestManager sharedInstance] imSetReceived:setting completion:^(id resultObj) {
        
    } failure:NULL];
}



- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq
{
    NSXMLElement *notification = [iq elementForName:@"notification"];
    if(notification && [[notification xmlns] isEqualToString:@"androidpn:iq:notification"])
    {
        //发送消息成功
        NSString *UUID = [[notification elementForName:@"id"] stringValue];
        //更新本地数据库
        double timeStamp = [[notification elementForName:@"timestamp"] stringValueAsDouble] / 1000;
        [app.dataBase updateMessageStatus:[NSNumber numberWithInt:Sended] timeStamp:[NSString stringWithFormat:@"%.0f",timeStamp] With:UUID];
        [XHAudioPlayerHelper playMessageSentSound];
        
    }
}

//发送消息失败
- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{
    NSXMLElement *notification = [iq elementForName:@"notification"];
    if(notification && [[notification xmlns] isEqualToString:@"androidpn:iq:notification"])
    {
        //发送消息失败
        NSString *UUID = [[notification elementForName:@"id"] stringValue];
        //更新本地数据库
        double timeStamp = [[notification elementForName:@"timestamp"] stringValueAsDouble] / 1000;
        
        [app.dataBase updateMessageStatus:[NSNumber numberWithInt:SendFailure] timeStamp:[NSString stringWithFormat:@"%.0f",timeStamp] With:UUID];
        
    }
}

- (void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence
{
    if([[presence type] isEqualToString:@"subscribed"])
    {
        [xmppRoster fetchRoster];
    }
}

//发送消息成功
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{

}

//发送消息失败
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{

}

//收到消息处理
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    
}

//成功收到消息后,解析此消息,根据我们自定义的xmpp流消息进行解析,分为语音,地理位置,图片,文本信息
- (void)handleReceiveMessage:(XMPPMessage *)message isGroupChat:(BOOL)isGroupChat
{
    
}


//收到好友请求后,插入到好友请求列表
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{

}

- (XMPPPresence *)xmppStream:(XMPPStream *)sender willReceivePresence:(XMPPPresence *)presence
{

    return presence;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (!isXmppConnected)
	{
		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
	}
}

#pragma mark XMPPRosterDelegate
//获取联系人列表,并插入数据库中
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(NSXMLElement *)item
{
    
    
}

- (XMPPIQ *)xmppStream:(XMPPStream *)sender willReceiveIQ:(XMPPIQ *)iq
{
    return iq;
}


@end
