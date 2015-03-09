//
//  SettingViewController.h
//  wenyao
//
//  Created by Meng on 14/11/6.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "BaseTableViewController.h"

@interface MessageSettingViewController : BaseTableViewController

@property (nonatomic, strong) UISwitch      *messageVoiceSwitch;
@property (nonatomic, strong) UISwitch      *messageVibrationSwitch;

@property (nonatomic, strong) UISwitch      *receiveInBackGroundSwitch;
@property (nonatomic, strong) UISwitch      *alarmVoiceSwitch;
@property (nonatomic, strong) UISwitch      *alarmVibrationSwitch;


@end
