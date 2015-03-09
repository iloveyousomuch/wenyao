//
//  ReachabilityMonitor.h
//  SMEDemo
//
//  Created by xzh on 12-12-6.
//  Copyright (c) 2012年 xzh. All rights reserved.
//
#import "Reachability.h"
@protocol ReachabilityDelegate
@optional
-(void)networkDisconnectFrom:(NetworkStatus)netStatus;
-(void)networkRestartFrom:(NetworkStatus)oldStatus toStatus:(NetworkStatus)newStatus;
-(void)networkStartAtApplicationDidFinishLaunching:(NetworkStatus)netStatus;
-(void)networKCannotStartupWhenFinishLaunching;

@end

@interface ReachabilityMonitor : NSObject
{
    Reachability            *hostReach;
    NetworkStatus           netStatus;
    Reachability            *wifiReach;
    id                      delegate;
}

-(id)initWithDelegate:(id)_delegate;
- (void)startMonitoring;
-(void)stopMonitoring;

@end
