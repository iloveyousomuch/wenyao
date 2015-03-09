//
//  ReachabilityMonitor.m
//  SMEDemo
//
//  Created by xzh on 12-12-6.
//  Copyright (c) 2012年 xzh. All rights reserved.
//

#import "ReachabilityMonitor.h"

@implementation ReachabilityMonitor

-(id)initWithDelegate:(id)_delegate
{
    if(self = [super init])
    {
        hostReach = nil;
        wifiReach = nil;
        netStatus = kDetecting;
        delegate = _delegate;
    }
    return self;
}

-(void)dealloc
{
    [hostReach release];hostReach = nil;
    
    [super dealloc];
}

- (void)updateInterfaceWithReachability:(Reachability*)curReach
{
    NetworkStatus oldStatus = netStatus;
    netStatus = [curReach currentReachabilityStatus];
    if((oldStatus == kDetecting) && netStatus != kNotReachable)
    {
        if([delegate respondsToSelector:@selector(networkStartAtApplicationDidFinishLaunching:)])
        {
            [delegate networkStartAtApplicationDidFinishLaunching:netStatus];
        }
    }else if(oldStatus == kDetecting && netStatus == kNotReachable){
        if([delegate respondsToSelector:@selector(networKCannotStartupWhenFinishLaunching)])
        {
            [delegate networKCannotStartupWhenFinishLaunching];
        }
    }else if(netStatus == kReachableViaWiFi || netStatus == kReachableViaWWAN)
    {
        if([delegate respondsToSelector:@selector(networkRestartFrom:toStatus:)])
        {
            [delegate networkRestartFrom:oldStatus toStatus:netStatus];
        }
    }else if((oldStatus != kNotReachable) && (netStatus == kNotReachable))
    {
        if([delegate respondsToSelector:@selector(networkDisconnectFrom:)])
        {
            [delegate networkDisconnectFrom:oldStatus];
        }
    }
}

//Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification*)note
{
    Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

-(void)stopMonitoring
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [hostReach stopNotifier];
    [hostReach release];
}

- (void)startMonitoring
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    netStatus = kDetecting;
    hostReach = [[Reachability reachabilityWithHostName: @"www.baidu.com"] retain];
    [hostReach startNotifier];
 //   [self updateInterfaceWithReachability:hostReach];
}
@end
