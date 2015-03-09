//
//  RemindAlarmViewController.m
//  wenyao
//
//  Created by xiezhenghong on 14-10-18.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "RemindAlarmViewController.h"
#import "AppDelegate.h"
#import "Constant.h"
#import "XHAudioPlayerHelper.h"


@interface RemindAlarmViewController ()
{
    NSTimer         *remindTimer;
}
@end

@implementation RemindAlarmViewController

- (void)adjustRemark:(NSString *)remark
{
    self.remarkLabel.text = remark;
    CGSize size = [remark sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240, 200)];
    CGFloat offset = size.height - 25.0f;
    if(offset > 0)
    {
        CGRect rect = self.remarkLabel.frame;
        rect.size.height += offset;
        self.remarkLabel.frame = rect;
        
        rect = self.container.frame;
        rect.size.height += offset;
        self.container.frame = rect;
        
        rect = self.containerBackImage.frame;
        rect.size.height += offset;
        self.containerBackImage.frame = rect;
    }
    UIImage *backImage = [UIImage imageNamed:@"闹钟内容背景.png"];
    backImage = [backImage resizableImageWithCapInsets:UIEdgeInsetsMake(20, 50, 20, 50) resizingMode:UIImageResizingModeStretch];
    self.containerBackImage.image = backImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    self.navigationController.navigationBar.hidden = YES;
    NSDictionary *dict = [app.dataBase selectAlarmClock:self.infoDict[@"boxId"]];
    [self.infoDict addEntriesFromDictionary:dict];
    
    self.productNameLabel.text = self.infoDict[@"productName"];
    self.useNameLabel.text = [NSString stringWithFormat:@"使用者: %@",self.infoDict[@"useName"]];
    NSUInteger intervalDay = [self.infoDict[@"intervalDay"] integerValue];
    if(intervalDay == 0) {
        self.useageLabel.text = [NSString stringWithFormat:@"%@,一次%@%@,即需即用",self.infoDict[@"useMethod"],self.infoDict[@"perCount"],self.infoDict[@"unit"]];
    }else{
        self.useageLabel.text = [NSString stringWithFormat:@"%@,一次%@%@,%@日%@次",self.infoDict[@"useMethod"],self.infoDict[@"perCount"],self.infoDict[@"unit"],self.infoDict[@"intervalDay"],self.infoDict[@"drugTime"]];
    }
    [self adjustRemark:self.infoDict[@"remark"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [XHAudioPlayerHelper playAlarmAudio];
    remindTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(remindTimeOut:) userInfo:nil repeats:NO];
}

- (void)remindTimeOut:(NSTimer *)timer
{
    [self finishClock:nil];
}

- (IBAction)deleteClock:(id)sender
{
    [remindTimer invalidate];
    remindTimer = nil;
    [XHAudioPlayerHelper stopAlarmAudio];
    [app.dataBase deleteAlarmClock:self.infoDict[@"boxId"]];
    NSArray *notificationList = [[UIApplication sharedApplication] scheduledLocalNotifications];
    [notificationList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UILocalNotification *localNotification = (UILocalNotification *)obj;
        NSDictionary *userInfo = [localNotification userInfo];
        if([userInfo[@"boxId"] isEqualToString:self.infoDict[@"boxId"]])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
        }
    }];
    notificationList = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSMutableArray *fireTimeList = [NSMutableArray arrayWithCapacity:5];
    [notificationList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UILocalNotification *localNotification = (UILocalNotification *)obj;
        NSDate *currentDate = [NSDate date];
        if([currentDate compare:localNotification.fireDate] == NSOrderedDescending) {
            [fireTimeList addObject:localNotification];
        }
    }];
    if(fireTimeList.count > 0) {
        RemindAlarmViewController *remindAlarmViewController = nil;
        if(HIGH_RESOLUTION) {
            remindAlarmViewController = [[RemindAlarmViewController alloc] initWithNibName:@"RemindAlarmViewController" bundle:nil];
        }else{
            remindAlarmViewController = [[RemindAlarmViewController alloc] initWithNibName:@"RemindAlarmViewController-480" bundle:nil];
        }
        UILocalNotification *notification = fireTimeList[0];
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[notification userInfo]];
        remindAlarmViewController.infoDict = info;
        [self.navigationController pushViewController:remindAlarmViewController animated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PHARMACY_NEED_UPDATE object:nil];
}

- (IBAction)finishClock:(id)sender
{
    NSArray *notificationList = [[UIApplication sharedApplication] scheduledLocalNotifications];
    [notificationList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UILocalNotification *localNotification = (UILocalNotification *)obj;
        NSDictionary *userInfo = [localNotification userInfo];
        
        if([userInfo[@"boxId"] isEqualToString:self.infoDict[@"boxId"]])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
            *stop = YES;
        }
    }];
    notificationList = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSMutableArray *fireTimeList = [NSMutableArray arrayWithCapacity:5];
    [notificationList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UILocalNotification *localNotification = (UILocalNotification *)obj;
        NSDate *currentDate = [NSDate date];
        if([currentDate compare:localNotification.fireDate] == NSOrderedDescending) {
            [fireTimeList addObject:localNotification];
        }
    }];
    
    [remindTimer invalidate];
    remindTimer = nil;
    [XHAudioPlayerHelper stopAlarmAudio];
    if(fireTimeList.count > 0) {
        RemindAlarmViewController *remindAlarmViewController = nil;
        if(HIGH_RESOLUTION) {
            remindAlarmViewController = [[RemindAlarmViewController alloc] initWithNibName:@"RemindAlarmViewController" bundle:nil];
        }else{
            remindAlarmViewController = [[RemindAlarmViewController alloc] initWithNibName:@"RemindAlarmViewController-480" bundle:nil];
        }
        UILocalNotification *notification = fireTimeList[0];
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[notification userInfo]];
        remindAlarmViewController.infoDict = info;
        [self.navigationController pushViewController:remindAlarmViewController animated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
