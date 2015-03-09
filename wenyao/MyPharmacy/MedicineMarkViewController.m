//
//  MedicineMarkViewController.m
//  quanzhi
//
//  Created by xiezhenghong on 14-6-13.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "MedicineMarkViewController.h"
#import "SVProgressHUD.h"
#import "HTTPRequestManager.h"

#import "CustomPickerTableViewCell.h"

@interface MedicineMarkViewController ()

@property (nonatomic, strong) CustomPickerView          *pickerView;
@property (nonatomic, strong) NSArray                   *effectArrays;

@end

@implementation MedicineMarkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"评价";
    UIBarButtonItem *saveBarButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction:)];
    self.navigationItem.rightBarButtonItem = saveBarButton;
    self.effectArrays = @[@"好",@"一般",@"差"];
    UIImage *image = [UIImage imageNamed:@"备注-2.png"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    [self.textViewBackGround setImage:image];
    [self setupCustomDatePicker];
    self.drugName.text = self.appraiseInfo[@"drugName"];
    self.textView.contentInset = UIEdgeInsetsMake(0, 0, 15, 0);
}

- (void)setupCustomDatePicker
{    
    self.pickerView = [[[NSBundle mainBundle] loadNibNamed:@"CustomPickerView" owner:self options:nil] objectAtIndex:0];
    self.pickerView.titleLabel.text = @"选择评价";
    self.pickerView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    if(self.appraiseInfo[@"remark"])
    {
        self.textView.text = self.appraiseInfo[@"remark"];
        self.showWordNum.text = [NSString stringWithFormat:@"%d/150",self.textView.text.length];
        NSUInteger effect = [self.appraiseInfo[@"effect"] intValue] - 1;
        self.selectedIndex = effect;
        self.effectLabel.text = self.effectArrays[effect];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.textView resignFirstResponder];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
}

#pragma mark -
#pragma mark CustomPickerViewDelegate
- (NSInteger)numberOfRowsInCustomTableView:(NSUInteger)section
{

    return [self.effectArrays count];
}

- (UITableViewCell *)CustomTableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CustomCategoryTableViewCell = @"CustomCategoryIdentifier";
    CustomPickerTableViewCell *cell = (CustomPickerTableViewCell *)[atableView dequeueReusableCellWithIdentifier:CustomCategoryTableViewCell];
    if(cell == nil){
        UINib *nib = [UINib nibWithNibName:@"CustomPickerTableViewCell" bundle:nil];
        [atableView registerNib:nib forCellReuseIdentifier:CustomCategoryTableViewCell];
        cell = (CustomPickerTableViewCell *)[atableView dequeueReusableCellWithIdentifier:CustomCategoryTableViewCell];
    }
    

    if(indexPath.row == self.selectedIndex)
    {
        cell.categoryLabel.textColor = APP_COLOR_STYLE;
        cell.selectImage.image = [UIImage imageNamed:@"选中.png"];
    }else{
        cell.categoryLabel.textColor = UIColorFromRGB(0x333333);
        cell.selectImage.image = [UIImage imageNamed:@"未选中.png"];
    }
    
    cell.categoryLabel.text = self.effectArrays[indexPath.row];
    return cell;
}

- (void)CustomTableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    self.selectedIndex = indexPath.row;
    [self.pickerView.customeTableView reloadData];
}

- (void)confirmSelected
{
    self.effectLabel.text = self.effectArrays[self.selectedIndex];
}


- (IBAction)saveAction:(id)sender
{
    if([self.effectLabel.text isEqualToString:@"使用效果"])
    {
        [SVProgressHUD showErrorWithStatus:@"请选择使用效果" duration:0.8f];
        return;
    }
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"boxProductId"] = self.boxProductId;
    setting[@"remark"] = self.textView.text;
    setting[@"effect"] = [NSString stringWithFormat:@"%d",++self.selectedIndex];
    if(self.appraiseInfo[@"id"])
        setting[@"appraiseId"] = self.appraiseInfo[@"id"];
    [[HTTPRequestManager sharedInstance] saveDBoxAppraise:setting completion:^(id resultObj) {
        if([resultObj[@"result"] isEqualToString:@"OK"]){
            self.appraiseInfo[@"remark"] = self.textView.text;
            self.appraiseInfo[@"effect"] = [NSString stringWithFormat:@"%d",self.selectedIndex];
            [SVProgressHUD showSuccessWithStatus:@"评价成功" duration:0.8f];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"评价失败,请重试" duration:0.8f];
    }];
    
}

- (IBAction)showEffectPicker:(id)sender
{
    [self.textView resignFirstResponder];
    [self.pickerView showInView:self.view];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger length = textView.text.length;
    if(![text isEqualToString:@""])
    {
        if(textView.text.length >= 150) {
            return NO;
        }
        ++length;
    }else {
        if(length > 0)
            --length;
    }
    self.showWordNum.text = [NSString stringWithFormat:@"%d/150",length];
    return YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
