//
//  ConsultQuizViewController.m
//  wenyao
//
//  Created by chenzhipeng on 15/1/19.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "ConsultQuizViewController.h"
#import "ConsultMedicineListViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

static NSInteger maxTextNum = 100;
static NSInteger minTextNum = 5;

@interface ConsultQuizViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblPlaceholder;
@property (weak, nonatomic) IBOutlet UITextView *tvConsult;
@property (weak, nonatomic) IBOutlet UILabel *lblConsultRemain;
@property (weak, nonatomic) IBOutlet UILabel *lblQuizOne;
@property (weak, nonatomic) IBOutlet UILabel *lblQuizTwo;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewQuizOne;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewQuizTwo;
@property (weak, nonatomic) IBOutlet UIButton *btnQuizOne;
@property (weak, nonatomic) IBOutlet UIButton *btnQuizTwo;

@property (nonatomic, assign) BOOL showPlaceholder;

- (IBAction)btnPressed_qizOne:(id)sender;
- (IBAction)btnPressed_qizTwo:(id)sender;
- (IBAction)pushToChatList:(id)sender;

@end

@implementation ConsultQuizViewController

- (void)tapOnEmptyView
{
    [self.tvConsult resignFirstResponder];
}

- (void)setNaviBar
{
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    lblTitle.text = @"免费问药";
    lblTitle.font = [UIFont systemFontOfSize:18];
    lblTitle.textColor = UIColorFromRGB(0xffffff);
    self.navigationItem.titleView = lblTitle;
    
    UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    btnNext.frame = CGRectMake(0, 0, 45, 30);
    btnNext.titleLabel.textAlignment = NSTextAlignmentRight;
    btnNext.titleLabel.font = [UIFont systemFontOfSize:15];
    [btnNext setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [btnNext setTitle:@"下一步" forState:UIControlStateNormal];
    [btnNext addTarget:self action:@selector(pushToChatList:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *nextBtnItem = [[UIBarButtonItem alloc] initWithCustomView:btnNext];
    self.navigationItem.rightBarButtonItem = nextBtnItem;
}

- (void)setTextViewPlaceholder:(BOOL)didSet
{
    if (didSet) {
        if (self.btnQuizOne.selected) {
            self.lblPlaceholder.text = @"请填写您需要咨询的内容，比如：男，20岁，咳嗽两天了吃什么药比较好？";
        } else {
            self.lblPlaceholder.text = @"请填写您需要咨询的内容，比如：女，3岁，吃999感冒灵颗粒有什么副作用吗？";
        }
        self.lblPlaceholder.hidden = NO;
//        self.tvConsult.textColor = [UIColor lightGrayColor];
        self.showPlaceholder = YES;
    } else {
        self.lblPlaceholder.hidden = YES;
//        self.tvConsult.text = @"";
//        self.tvConsult.textColor = [UIColor darkTextColor];
        self.showPlaceholder = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *gestureTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnEmptyView)];
    [self.view addGestureRecognizer:gestureTap];
    [self setNaviBar];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textViewEditChanged:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
    self.lblPlaceholder.hidden = YES;
    self.btnQuizOne.selected = YES;
    self.btnQuizTwo.selected = NO;
    self.imgViewQuizTwo.highlighted = NO;
    self.imgViewQuizOne.highlighted = YES;
    [self setRemainWord:0];
    self.tvConsult.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.tvConsult.layer.borderWidth = 0.5;
    self.tvConsult.textContainer.lineFragmentPadding = 0;
    self.tvConsult.textContainerInset = UIEdgeInsetsMake(15, 9, 9, 9);
    self.showPlaceholder = YES;
    [self setTextViewPlaceholder:YES];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextView methods
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length == 0) {
        [self setTextViewPlaceholder:YES];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (self.showPlaceholder) {
        [self setTextViewPlaceholder:NO];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.tvConsult.text.length == 0) {
        [self setTextViewPlaceholder:YES];
    } else {
        [self setTextViewPlaceholder:NO];
    }
}

- (void)setRemainWord:(NSInteger)wordInputted
{
    NSInteger intRemain = maxTextNum - wordInputted;
    self.lblConsultRemain.text = [NSString stringWithFormat:@"%ld 字",(long)intRemain];
    if (self.tvConsult.text.length == 0) {
        [self setTextViewPlaceholder:YES];
    } else {
        [self setTextViewPlaceholder:NO];
    }
}

// 监听文本改变
-(void)textViewEditChanged:(NSNotification *)obj
{
    UITextView *textView = (UITextView *)obj.object;
    NSString *toBeString = textView.text;
    NSString *lang = [[textView textInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > maxTextNum) {
                textView.text = [toBeString substringToIndex:maxTextNum];
            }
            [self setRemainWord:textView.text.length];
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > maxTextNum) {
            textView.text = [toBeString substringToIndex:maxTextNum];
        }
        [self setRemainWord:textView.text.length];
    }
}

#pragma mark - Navigation
- (void)showAlertWithMsg:(NSString *)strMsg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:strMsg delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
    [alert show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"seguePharmacyList"]) {
        NSString *strConsultContent = [self.tvConsult.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *strConsultTitle = @"";
        if (self.btnQuizOne.selected) {
            strConsultTitle = @"button one tapped";
        } else if (self.btnQuizTwo.selected) {
            strConsultTitle = @"button two tapped";
        }
        NSDictionary *dicContent = @{@"consult_title":strConsultTitle,
                                     @"consult_content":strConsultContent};
        ConsultMedicineListViewController *viewControllerList = (ConsultMedicineListViewController *)segue.destinationViewController;
        viewControllerList.dicConsult = dicContent;
    }
}

- (IBAction)btnPressed_qizOne:(id)sender {
    if (self.btnQuizOne.selected) {
        return;
    }
    self.btnQuizOne.selected = !self.btnQuizOne.selected;
    if (self.btnQuizOne.selected) {
        self.imgViewQuizTwo.highlighted = NO;
        self.btnQuizTwo.selected = NO;
    }
    self.imgViewQuizOne.highlighted = !self.imgViewQuizOne.highlighted;
    if (self.showPlaceholder) {
        [self setTextViewPlaceholder:YES];
    }
}

- (IBAction)btnPressed_qizTwo:(id)sender {
    if (self.btnQuizTwo.selected) {
        return;
    }
    self.btnQuizTwo.selected = !self.btnQuizTwo.selected;
    if (self.btnQuizTwo.selected) {
        self.imgViewQuizOne.highlighted = NO;
        self.btnQuizOne.selected = NO;
    }
    self.imgViewQuizTwo.highlighted = !self.imgViewQuizTwo.highlighted;
    if (self.showPlaceholder) {
        [self setTextViewPlaceholder:YES];
    }
}

- (IBAction)pushToChatList:(id)sender {
    if (app.currentNetWork == kNotReachable) {
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        return;
    }
    NSString *strConsultContent = [self.tvConsult.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (self.showPlaceholder) {
        [SVProgressHUD showErrorWithStatus:@"请输入您要问的问题" duration:DURATION_SHORT];
        return;
    } else {
        if (strConsultContent.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"请输入您要问的问题" duration:DURATION_SHORT];
            return;
        } else if (strConsultContent.length < minTextNum) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"至少输入%ld个字符",(long)minTextNum] duration:DURATION_SHORT];
            return;
        } else if (strConsultContent.length > maxTextNum) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"至少输入%ld个字符",(long)maxTextNum] duration:DURATION_SHORT];
            return;
        }
    }

    if (!self.btnQuizOne.selected && !self.btnQuizTwo.selected) {
        //[self showAlertWithMsg:@"请选择标题"];
        [SVProgressHUD showErrorWithStatus:@"请选择标题" duration:DURATION_SHORT];
        return;
    }
    [self performSegueWithIdentifier:@"seguePharmacyList" sender:sender];
}
@end
