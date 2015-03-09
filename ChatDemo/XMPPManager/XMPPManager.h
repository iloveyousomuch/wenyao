//
//  XMPPManager.h
//  iPhoneXMPP
//
//  Created by xiezhenghong on 14-3-9.
//
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "XMPPFramework.h"


@interface XMPPManager : NSObject<XMPPRosterDelegate>
{
    XMPPStream *xmppStream;
	XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
	XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
	NSString *password;
	BOOL allowSelfSignedCertificates;
	BOOL allowSSLHostNameMismatch;
	
	BOOL isXmppConnected;
}

@property (nonatomic, strong) NSMutableArray       *rooms;
@property (nonatomic, strong) NSMutableArray       *UUIDList;
@property (nonatomic, strong) NSCondition          *taskLock;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;


- (XMPPRoom *)setupRoom:(XMPPJID *)roomJid;
- (XMPPRoom *)searchRoomWith:(XMPPJID *)roomJid;
- (void)suspendRoom;
- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

+ (XMPPManager*)sharedInstance;
- (void)reJoinAllRooms;
- (void)setupStream;
- (void)teardownStream;
- (void)goOnline;
- (void)goOffline;

- (BOOL)connectWithUserName:(NSString *)myJID Password:(NSString *)myPassword;
- (void)disconnect;

@end
