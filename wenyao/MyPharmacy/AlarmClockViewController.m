//
//  AlarmClockViewController.m
//  wenyao
//
//  Created by xiezhenghong on 14-10-18.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "AlarmClockViewController.h"
#import "RemindAlarmViewController.h"
#import "CustomDatePicker.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"


@interface AlarmClockViewController ()<UITableViewDataSource,
UITableViewDelegate,CustomDatePickerDelegate,UITextViewDelegate>

@property (nonatomic, strong) UITableView       *tableView;
@property (nonatomic, strong) NSMutableArray    *alarmList;
@property (nonatomic, strong) NSDate            *startDate;
@property (nonatomic, strong) NSDate            *endDate;



@end

@implementation AlarmClockViewController

- (void)editAction:(id)sender
{
    self.tableView.tableFooterView = nil;
    self.title = @"编辑用药闹钟";
    self.useType = 0;
    self.textView.editable = YES;
    UIBarButtonItem *savaBarItem = nil;
    savaBarItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction:)];
    self.navigationItem.rightBarButtonItem = savaBarItem;
    
}

- (void)saveAction:(id)sender
{
    if([self.startDate compare:self.endDate] == NSOrderedDescending) {
        [SVProgressHUD showErrorWithStatus:@"结束不得小于起始时间!" duration:0.8f];
        return;
    }
    if(self.textView.text.length > 50) {
        [SVProgressHUD showErrorWithStatus:@"备注信息不得超过50个字!" duration:0.8f];
        return;
    }
    NSMutableString *timesList = [NSMutableString string];
    NSUInteger drugTime = [self.infoDict[@"drugTime"] integerValue];
    if(drugTime > 5)
        drugTime = 5;
    for(NSUInteger index = 0; index < drugTime; ++index)
    {
        id object = self.alarmList[index];
        if([object isKindOfClass:[NSNull class]])
        {
            [SVProgressHUD showErrorWithStatus:@"请填写齐全提醒钟点" duration:0.8f];
            return;
        }else{
            NSDate *date = (NSDate *)object;
            NSTimeInterval notiTime = (NSTimeInterval)[date timeIntervalSince1970];
            [timesList appendFormat:@"%f\r\n",notiTime];
        }
    }
    
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
    if([timesList hasSuffix:@"\r\n"])
        [timesList deleteCharactersInRange:NSMakeRange(timesList.length - 2, 2)];
    NSString *startTime = [NSString stringWithFormat:@"%.0f",[self.startDate timeIntervalSince1970]];
    NSString *endTime = [NSString stringWithFormat:@"%.0f",[self.endDate timeIntervalSince1970]];
    [app.dataBase insertAlarmClock:self.infoDict[@"boxId"] timesList:timesList startTime:startTime endTime:endTime remark:self.textView.text productName:self.infoDict[@"productName"] useName:self.infoDict[@"useName"] useMethod:self.infoDict[@"useMethod"] perCount:self.infoDict[@"perCount"] drugTime:[NSString stringWithFormat:@"%@",self.infoDict[@"drugTime"]] intervalDay:[NSString stringWithFormat:@"%@",self.infoDict[@"intervalDay"]]];
    [[NSNotificationCenter defaultCenter] postNotificationName:PHARMACY_NEED_UPDATE object:nil];
    if(self.editClockBlock)
    {
        self.editClockBlock();
    }
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [SVProgressHUD showWithStatus:@"正在设置,请稍等" maskType:SVProgressHUDMaskTypeGradient];
        [self setupAlarmClock];
        [SVProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
//    });
}

- (void)setupAlarmClock
{
    NSUInteger drugTime = [self.infoDict[@"drugTime"] integerValue];
    if(drugTime > 5) {
        drugTime = 5;
    }
    NSUInteger intervalDay = [self.infoDict[@"intervalDay"] integerValue];
    double startTime = [self.startDate timeIntervalSince1970];
    double endTime = [self.endDate timeIntervalSince1970];
    
    for(;startTime < endTime;) {
        
        for(NSUInteger index = 0; index < drugTime; ++index)
        {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *component = [calendar components:(NSCalendarUnitYear| NSCalendarUnitMonth |NSCalendarUnitDay|NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
            
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:startTime];
            NSDateComponents *subComponent = [calendar components:(NSCalendarUnitYear| NSCalendarUnitMonth |NSCalendarUnitDay) fromDate:startDate];
            component.year = subComponent.year;
            component.month = subComponent.month;
            component.day = subComponent.day;
            
            subComponent = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:self.alarmList[index]];
            component.hour = subComponent.hour;
            component.minute = subComponent.minute;
            component.second = subComponent.second;
            
            NSDate *fireDate = [calendar dateFromComponents:component];
            fireDate = [self checkDifferentFireDate:fireDate];
            NSDate *currentDate = [NSDate date];
            if([currentDate compare:fireDate] == NSOrderedDescending) {
                continue;
            }
            notification.fireDate = fireDate;
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:self.infoDict];
            if([userInfo[@"productId"] isEqual:[NSNull null]]) {
                userInfo[@"productId"] = @"";
            }
            notification.userInfo = userInfo;
            notification.repeatInterval = NSCalendarUnitDay;
            notification.alertBody = @"闹钟提醒";
            notification.alertAction = @"查看";
            notification.soundName = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            NSString *fireTimeStamp = [NSString stringWithFormat:@"%.0f",[fireDate timeIntervalSince1970]];
            [app.dataBase insertIntoAlarmCallTime:self.infoDict[@"boxId"] timeStamp:fireTimeStamp];
        }
        startTime += intervalDay * 24 * 3600;
    }
}

- (NSDate *)checkDifferentFireDate:(NSDate *)fireDate
{
    NSDate *retDate = fireDate;
    NSString *fireTimeStamp = [NSString stringWithFormat:@"%.0f",[fireDate timeIntervalSince1970]];
    NSDictionary *existTimeDict = nil;
    existTimeDict = [app.dataBase checkExistedTime:fireTimeStamp];
    if(existTimeDict)
    {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *component = [calendar components:(NSCalendarUnitYear| NSCalendarUnitMonth |NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:fireDate];
        if (component.second <= 60)
        {
            component.second += 3;
            retDate = [calendar dateFromComponents:component];
            retDate = [self checkDifferentFireDate:retDate];
        }
    }
    return retDate;
}

- (void)backToPreviousController:(id)sender
{
    if(self.mustSave) {
        [self deleteAction:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)deleteAction:(id)sender
{
    [app.dataBase deleteAlarmClock:self.infoDict[@"boxId"]];
    NSArray *notificationList = [[UIApplication sharedApplication] scheduledLocalNotifications];
    [notificationList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UILocalNotification *localNotification = (UILocalNotification *)obj;
        NSDictionary *userInfo = [localNotification userInfo];
        if([userInfo[@"boxId"] isEqualToString:self.infoDict[@"boxId"]])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
            [[NSNotificationCenter defaultCenter] postNotificationName:PHARMACY_NEED_UPDATE object:nil];
        }
        
    }];
    if(self.editClockBlock) {
        self.editClockBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupTableView
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    self.view.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height - 64);
    bounds = self.view.frame;
    bounds.origin.x = 10;
    bounds.size.width = 300.0f;
    bounds.size.height -= 10;
    self.tableView = [[UITableView alloc] initWithFrame:bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    if(textView.text.length >= 50 && ![text isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unregisterNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.alarmList = [NSMutableArray arrayWithCapacity:5];
    if(self.useType == 1) {
        self.title = @"用药闹钟详情";
        
        NSMutableDictionary *dict = [app.dataBase selectAlarmClock:self.infoDict[@"boxId"]];
        self.textView.text = dict[@"remark"];
        self.startDate =  [NSDate dateWithTimeIntervalSince1970:[dict[@"startTime"] integerValue]];
        self.endDate = [NSDate dateWithTimeIntervalSince1970:[dict[@"endTime"] integerValue]];
        NSArray *array = [dict[@"timesList"] componentsSeparatedByString:@"\r\n"];
        for(NSString *timeString in array)
            [self.alarmList addObject:[NSDate dateWithTimeIntervalSince1970:[timeString integerValue]]];
        
        NSUInteger drugTime = [self.infoDict[@"drugTime"] integerValue];
        while (drugTime > self.alarmList.count) {
            [self.alarmList addObject:[NSNull null]];
        }
        self.textView.editable = NO;
        UIBarButtonItem *savaBarItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editAction:)];
        self.navigationItem.rightBarButtonItem = savaBarItem;
        
    }else{
        self.title = @"添加用药闹钟";
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *component = [calendar components:(NSCalendarUnitYear| NSCalendarUnitMonth |NSCalendarUnitDay|NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
        for(NSUInteger index = 0; index < 5; ++index){
            component.minute = 0;
            component.second = 0;
            switch (index) {
                case 0:
                {
                    component.hour = 8;
                    break;
                }
                case 1:
                {
                    component.hour = 12;
                    break;
                }
                case 2:
                {
                    component.hour = 18;
                    break;
                }
                case 3:
                {
                    component.hour = 20;
                    break;
                }
                case 4:
                {
                    component.hour = 22;
                    break;
                }
                default:
                    break;
            }
            [self.alarmList addObject:[calendar dateFromComponents:component]];
        }
        self.startDate = [NSDate date];
        self.endDate = [[NSDate alloc] initWithTimeInterval:7.0 * 24 * 3600 sinceDate:self.startDate];
        self.textView.text = @"";
        UIBarButtonItem *savaBarItem = nil;
        savaBarItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction:)];
        self.navigationItem.rightBarButtonItem = savaBarItem;
    }
    
    
    
    [self setupTableView];
    if(self.useType == 1) {
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 60)];
        [containerView setBackgroundColor:[UIColor clearColor]];
        UIButton *delButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [delButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [delButton setTitle:@"删除用药闹钟" forState:UIControlStateNormal];
        [delButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchDown];
        [delButton setBackgroundColor:UICOLOR(250, 74, 73)];
        delButton.frame = CGRectMake(0, 0, 282, 40);
        delButton.layer.cornerRadius = 3.0;
        delButton.layer.masksToBounds = YES;
        [containerView addSubview:delButton];
        delButton.center = containerView.center;
        self.tableView.tableFooterView = containerView;
    }
    [self registerNotification];
    if(self.mustSave) {
        [self editAction:nil];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardBounds;
    [keyboardBoundsValue getValue:&keyboardBounds];
    NSUInteger drugTime = [self.infoDict[@"drugTime"] integerValue];
    if(drugTime > 5) {
        drugTime = 5;
    }
    CGSize contentSize = CGSizeMake(300, 50 * 4 + 6 * 10 + 130 + 51 + 44 * drugTime);
    CGFloat offset = contentSize.height - self.tableView.frame.size.height;
    contentSize = CGSizeMake(contentSize.width, contentSize.height + keyboardBounds.size.height);
    self.tableView.contentSize = contentSize;
    offset = MAX(0, offset);
    offset += keyboardBounds.size.height + 50;
    [self.tableView setContentOffset:CGPointMake(0,offset) animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSUInteger drugTime = [self.infoDict[@"drugTime"] integerValue];
    if(drugTime > 5) {
        drugTime = 5;
    }
    CGSize contentSize = CGSizeMake(300, 50 * 4 + 6 * 10 + 130 + 51 + 44 * drugTime);
    self.tableView.contentSize = contentSize;
    CGFloat offset = contentSize.height - self.tableView.frame.size.height;
    offset = MAX(0, offset);
    [self.tableView setContentOffset:CGPointMake(0, offset) animated:YES];
}

- (void)dealloc
{
    [self unregisterNotification];
}


#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        case 1:
        case 2:
        case 4:
            return 50.f;
        case 3:
        {
            if(indexPath.row == 0) {
                return 51;
            }else{
                return 44.0f;
            }
        }
        case 5:
            return 130;
        default:
            break;
    }
    
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 10)];
    [header setBackgroundColor:[UIColor clearColor]];
    return header;
}

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 3)
    {
        NSUInteger drugTime = [self.infoDict[@"drugTime"] integerValue];
        if(drugTime > 5) {
            drugTime = 5;
        }
        return drugTime + 1;
    }else if(section == 4)
    {
        return 2;
    }
    
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)atableView
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableViewCellIdentifier = @"TableViewCellIdentifier";
    UITableViewCell *cell = [atableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableViewCellIdentifier];
        
    }
    cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
    cell.textLabel.textColor = UIColorFromRGB(0x666666);
    UILabel *accessTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    accessTitle.font = [UIFont systemFontOfSize:15.0f];
    accessTitle.textColor = [UIColor blackColor];
    accessTitle.textAlignment = NSTextAlignmentRight;
    cell.accessoryView = accessTitle;
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor whiteColor];
    UIView *bkView = [[UIView alloc]initWithFrame:cell.frame];
    bkView.backgroundColor = UIColorFromRGB(0xdfe4e6);
    cell.selectedBackgroundView = bkView;
    
    switch (indexPath.section) {
        case 0:{
            [[cell.contentView viewWithTag:101] removeFromSuperview];
            cell.textLabel.text = @"药品名称";
            accessTitle.text = self.infoDict[@"productName"];
            
            break;
        }
        case 1:{
            [[cell.contentView viewWithTag:101] removeFromSuperview];
            cell.textLabel.text = @"使用者";
            accessTitle.text = self.infoDict[@"useName"];
            break;
        }
        case 2:{
            [[cell.contentView viewWithTag:101] removeFromSuperview];
            cell.textLabel.text = @"用法用量";
            NSUInteger intervalDay = [self.infoDict[@"intervalDay"] integerValue];
            if(intervalDay == 0) {
                accessTitle.text = [NSString stringWithFormat:@"%@,一次%@%@,即需即用",self.infoDict[@"useMethod"],self.infoDict[@"perCount"],self.infoDict[@"unit"]];
            }else{
                accessTitle.text = [NSString stringWithFormat:@"%@,一次%@%@,%@日%@次",self.infoDict[@"useMethod"],self.infoDict[@"perCount"],self.infoDict[@"unit"],self.infoDict[@"intervalDay"],self.infoDict[@"drugTime"]];
            }
            break;
        }
        case 3:{
            [[cell.contentView viewWithTag:101] removeFromSuperview];
            cell.textLabel.text = @"";
            accessTitle.text = @"";
            if(indexPath.row == 0)
            {
                cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"提醒钟点_背景.png"]];
                cell.textLabel.text = @"提醒钟点";
                UIImageView *image = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"提醒钟点_背景.png"]];
                
                cell.selectedBackgroundView = image;
            }else{
                id object = self.alarmList[indexPath.row - 1];
                if([object isKindOfClass:[NSDate class]]){
                    NSDate *date = (NSDate *)object;
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"HH:mm"];
                    accessTitle.text = [formatter stringFromDate:date];
                }else{
                    accessTitle.text = @"";
                }
                cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"提醒钟点_背景2.png"]];
                cell.font = [UIFont systemFontOfSize:14.0f];
                cell.textLabel.textColor = UICOLOR(130, 141, 152);
                cell.textLabel.text = [NSString stringWithFormat:@"第%d次",indexPath.row];
            }
            break;
        }
        case 4:{
            [[cell.contentView viewWithTag:101] removeFromSuperview];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            if(indexPath.row == 0)
            {
                accessTitle.text = [formatter stringFromDate:self.startDate];
                cell.textLabel.text = @"开始日期";
            }else{
                accessTitle.text = [formatter stringFromDate:self.endDate];
                cell.textLabel.text = @"结束日期";
            }
            
            break;
        }
        case 5:{
            cell.textLabel.text = @"";
            accessTitle.text = @"";
            [cell.contentView addSubview:self.noteCellView];
            cell.selectedBackgroundView = [[UIView alloc] init];
            break;
        }
            
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [atableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.useType == 1)
        return;
    if (indexPath.section == 3 || indexPath.section == 4)
    {
        [self.textView resignFirstResponder];
        if(indexPath.row == 0 && indexPath.section == 3)
            return;
        CGRect rect = [[UIScreen mainScreen] bounds];
        CustomDatePicker *datePicker = [[CustomDatePicker alloc] initWithFrame:rect];
        datePicker.delegate = self;
        if(indexPath.section == 3) {
            [datePicker setDatePickerMode:UIDatePickerModeTime];
            datePicker.tag = indexPath.row - 1;
        }else if(indexPath.section == 4)
        {   datePicker.tag = indexPath.row;
            [datePicker setDatePickerMode:UIDatePickerModeDate];
        }
        [datePicker showInView:self.view animated:YES];
    }else if(indexPath.section == 5)
    {
        [self.textView becomeFirstResponder];
    }else{
        [self.textView resignFirstResponder];
    }
}

- (BOOL)checkSameDate:(NSDate *)date
{
    for(NSDate *previousDate in self.alarmList)
    {
        if([previousDate isEqual:[NSNull null]]) {
            continue;
        }else{
            if([previousDate isEqualToDate:date]){
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark -
#pragma mark CustomDatePickerDelegate
- (void)didSelectDatePicker:(CustomDatePicker *)datePicker date:(NSDate *)date
{
    if(datePicker.datePickerMode == UIDatePickerModeTime) {
        //时间选择
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *component = [calendar components:(NSCalendarUnitYear| NSCalendarUnitMonth |NSCalendarUnitDay|NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
        component.second = 0;
        date = [calendar dateFromComponents:component];
        if([self checkSameDate:date]) {
            [SVProgressHUD showErrorWithStatus:@"同一个种药品不得设置相同时间的闹钟!" duration:2.0];
            return;
        }
        [self.alarmList replaceObjectAtIndex:datePicker.tag withObject:date];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:datePicker.tag + 1 inSection:3]] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        //日期选择
        if(datePicker.tag == 0) {
            self.startDate = date;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:4]] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *startComponent = [calendar components:(NSCalendarUnitYear| NSCalendarUnitMonth |NSCalendarUnitDay|NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:self.startDate];
            startComponent.month += 3;
            NSDate *maxEndDate = [calendar dateFromComponents:startComponent];
            if([maxEndDate compare:date] == NSOrderedAscending) {
                [SVProgressHUD showErrorWithStatus:@"闹钟设置有效期不得超过3个月" duration:0.8];
                return;
            }
            self.endDate = date;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:4]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
