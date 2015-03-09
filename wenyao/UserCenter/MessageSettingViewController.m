//
//  SettingViewController.m
//  wenyao
//
//  Created by Meng on 14/11/6.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "MessageSettingViewController.h"
#import "SettingCell.h"
#import "HTTPRequestManager.h"
#import "AppDelegate.h"
#import "Constant.h"
#import "ReturnIndexView.h"


@interface MessageSettingViewController ()<ReturnIndexViewDelegate>
{
    NSArray * titleArr;
}
@property (strong , nonatomic) ReturnIndexView *indexView;
@end

@implementation MessageSettingViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.title = @"设置";
        self.tableView.scrollEnabled = NO;
        self.tableView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)swicthSetting:(UISwitch *)changeSwitch
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    switch (changeSwitch.tag) {
        case 101:
        {
            [userDefault setObject:[NSNumber numberWithBool:changeSwitch.isOn] forKey:APP_VOICE_NOTIFICATION];
            break;
        }
        case 102:
        {
            [userDefault setObject:[NSNumber numberWithBool:changeSwitch.isOn] forKey:APP_VIBRATION_NOTIFICATION];
            break;
        }
        case 103:
        {
            [userDefault setObject:[NSNumber numberWithBool:changeSwitch.isOn] forKey:APP_RECEIVE_INBACKGROUND];
            break;
        }
        case 104:
        {
            [userDefault setObject:[NSNumber numberWithBool:changeSwitch.isOn] forKey:ALARM_VOICE_NOTIFICATION];
            break;
        }
        case 105:
        {
            [userDefault setObject:[NSNumber numberWithBool:changeSwitch.isOn] forKey:ALARM_VIBRATION_NOTIFICATION];
            break;
        }
        default:
            break;
    }
    [userDefault synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    titleArr = @[@[@"声音",@"震动",@"退出后仍接收消息"],@[@"声音",@"震动"]];
    titleArr = @[@[@"声音",@"震动"],@[@"声音",@"震动"]];
    
    self.messageVoiceSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 35)];
    self.messageVoiceSwitch.tag = 101;
    [self.messageVoiceSwitch addTarget:self action:@selector(swicthSetting:) forControlEvents:UIControlEventValueChanged];
    self.messageVibrationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 35)];
    self.messageVibrationSwitch.tag = 102;
    [self.messageVibrationSwitch addTarget:self action:@selector(swicthSetting:) forControlEvents:UIControlEventValueChanged];
    self.receiveInBackGroundSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 35)];
    self.receiveInBackGroundSwitch.tag = 103;

    [self.receiveInBackGroundSwitch addTarget:self action:@selector(swicthSetting:) forControlEvents:UIControlEventValueChanged];
    self.alarmVoiceSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 35)];
    self.alarmVoiceSwitch.tag = 104;
    [self.alarmVoiceSwitch addTarget:self action:@selector(swicthSetting:) forControlEvents:UIControlEventValueChanged];
    self.alarmVibrationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 35)];
    self.alarmVibrationSwitch.tag = 105;
    [self.alarmVibrationSwitch addTarget:self action:@selector(swicthSetting:) forControlEvents:UIControlEventValueChanged];
    
    [self setUpRightItem];
}

#pragma mark---------------------------------------------跳转到首页-----------------------------------------------

- (void)setUpRightItem
{
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed.width = -6;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-unfold.PNG"] style:UIBarButtonItemStylePlain target:self action:@selector(returnIndex)];
    self.navigationItem.rightBarButtonItems = @[fixed,rightItem];
}
- (void)returnIndex
{
    self.indexView = [ReturnIndexView sharedManagerWithImage:@[@"icon home.PNG"] title:@[@"首页"]];
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
#pragma mark---------------------------------------------跳转到首页-----------------------------------------------


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    self.messageVoiceSwitch.on = [[userDefault objectForKey:APP_VOICE_NOTIFICATION] boolValue];
    self.messageVibrationSwitch.on = [[userDefault objectForKey:APP_VIBRATION_NOTIFICATION] boolValue];
    self.receiveInBackGroundSwitch.on = [[userDefault objectForKey:APP_RECEIVE_INBACKGROUND] boolValue];
    self.alarmVoiceSwitch.on = [[userDefault objectForKey:ALARM_VOICE_NOTIFICATION] boolValue];
    self.alarmVibrationSwitch.on = [[userDefault objectForKey:ALARM_VIBRATION_NOTIFICATION] boolValue];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(!app.logStatus)
        return;
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"source"] = @"1";
    if(self.receiveInBackGroundSwitch.isOn) {
        setting[@"pushStatus"] = @"0";
    }else{
        setting[@"pushStatus"] = @"1";
    }
    [[HTTPRequestManager sharedInstance] pushSet:setting completion:NULL failure:NULL];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSArray *)titleArr[section] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(10, 10, APP_W-20, 20)];
    view.backgroundColor = [UIColor clearColor];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, APP_W-20, 20)];
    label.textColor = UICOLOR(139, 139, 139);
    
    
    if (section == 0)
    {
        label.text = @"新消息提醒";
    }else if (section == 1)
    {
        label.text = @"用药闹钟提醒";
    }
    label.font = Font(14);
    [view addSubview:label];
    
    
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return titleArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"cellIdentifier";
    SettingCell * cell = (SettingCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:self options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.titleLabel.text = titleArr[indexPath.section][indexPath.row];
    if(indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                cell.accessoryView = self.messageVoiceSwitch;
                break;
            }
            case 1:
            {
                cell.accessoryView = self.messageVibrationSwitch;
                break;
            }
            case 2:
            {
                cell.accessoryView = self.receiveInBackGroundSwitch;
                break;
            }
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
            {
                cell.accessoryView = self.alarmVoiceSwitch;
                break;
            }
            case 1:
            {
                cell.accessoryView = self.alarmVibrationSwitch;
                break;
            }
            default:
                break;
        }
    }
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
