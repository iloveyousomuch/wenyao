//
//  CouponGenerateViewController.m
//  wenyao
//
//  Created by 李坚 on 15/1/21.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "CouponGenerateViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "ShowQRViewController.h"
#import "DrugDetailViewController.h"
#import "LoginViewController.h"
#import "CouponDeatilViewController.h"
#import "NewHomePageViewController.h"
#import "SearchSliderViewController.h"

@interface CouponGenerateViewController ()<UITextFieldDelegate>
{
    CGRect beforeViewRect;
    UITextField *shouldBegainTextField;
}
@end

@implementation CouponGenerateViewController

- (id)init{
    if (self = [super init]) {
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"温馨提示：用户扫描出优惠药品，根据优惠说明输入数量，药品零售价，输入完成点击“生成优惠二维码”，会生成一个优惠二维码，药店扫描该二维码之后用户根据优惠条件享受优惠！"];
    [str addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x999999) range:NSMakeRange(0,5)];
    self.promptLabel.attributedText = str;
    
    CGRect rect = self.line.frame;
    rect.size.height = 0.5f;
    self.line.frame = rect;
    
    self.couponScrollView.frame = CGRectMake(0, 0, self.couponScrollView.frame.size.width, SCREEN_H - 64);
    
    [self.view addSubview:self.couponScrollView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView:)];
    [self.view addGestureRecognizer:tap];
    
    self.countTextField.keyboardType =  UIKeyboardTypeNumberPad;
    self.priceTextField.keyboardType =  UIKeyboardTypeNumbersAndPunctuation;
    self.phoneNumberField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.countTextField.delegate = self;
    self.priceTextField.delegate = self;
    self.phoneNumberField.delegate = self;
    
    self.btn = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, SCREEN_W - 20, 75)];
    self.btn.backgroundColor = [UIColor clearColor];
    [self.btn addTarget:self action:@selector(pushToDrugDetail:) forControlEvents:UIControlEventTouchUpInside];
    [self.couponScrollView addSubview:self.btn];
    
    self.generateBtn.layer.masksToBounds = YES;
    self.generateBtn.layer.borderWidth = 1.0f;
    self.generateBtn.layer.cornerRadius = 2.0f;
    self.generateBtn.layer.borderColor = UIColorFromRGB(0x45c01a).CGColor;
    
    [self fillInformation];
    beforeViewRect = self.view.frame;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, self.footView.frame.size.height - 0.5, APP_W, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [self.footView addSubview:line];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    shouldBegainTextField = textField;
    return YES;
}

-(void)keyboardWillShow:(NSNotification*)notification{
    
    NSDictionary*info=[notification userInfo];
    CGSize kbSize=[[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSLog(@"keyboard changed, keyboard width = %f, height = %f",
          kbSize.width,kbSize.height);
    //在这里调整UI位置
    CGFloat maxY = CGRectGetMaxY(shouldBegainTextField.frame);
    int offset = APP_H - 64 - kbSize.height - (maxY + self.footView.frame.origin.y);
    NSLog(@"%@",NSStringFromCGRect(self.couponScrollView.frame));
    
    
    if(offset < 0){
        [UIView animateWithDuration:animationDuration animations:^{
            
            
            self.couponScrollView.frame = CGRectMake(0.0f, offset, self.couponScrollView.frame.size.width, self.couponScrollView.frame.size.height);
        }];
    }
}

- (void)keyboardWillHide:(NSNotification*)notification{
    
    NSDictionary*info=[notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.couponScrollView setFrame:CGRectMake(0, 0, self.couponScrollView.frame.size.width, self.couponScrollView.frame.size.height)];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = self.infoDic[@"proName"];
}

- (void)fillInformation{
    
    self.titleLabel.text = self.infoDic[@"proName"];
    self.styleLabel.text = self.infoDic[@"spec"];
    self.factoryLabel.text = self.infoDic[@"factory"];
    self.descriptionLabel.text = self.infoDic[@"desc"];
    
    CGSize size = [self.infoDic[@"desc"] sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(self.view.frame.size.width - 100, 2000)];
    self.descriptionLabel.frame = CGRectMake(90, 127, self.view.frame.size.width - 100, size.height);
    self.footView.frame = CGRectMake(0, self.footView.frame.origin.y + size.height, self.footView.frame.size.width, self.footView.frame.size.height);
    
    
    
//    if([self.infoDic[@"status"] intValue] != 0){
//        
//        self.noneView.hidden = NO;
//    }else{
//        self.noneView.hidden = YES;
//    }
    
    int times = [self.infoDic[@"limitPersonTimes"] intValue];
    if(times == 0){
        [self.couponTim removeFromSuperview];
        [self.couponTimes removeFromSuperview];
        self.footView.frame = CGRectMake(0, self.footView.frame.origin.y - 21, self.footView.frame.size.width, self.footView.frame.size.height);
        for (UIView *view in self.footView.subviews){
            
            CGRect rect = view.frame;
            rect.origin.y -= 21;
            view.frame = rect;
        }
    }
    else{
        self.couponTimes.text = [NSString stringWithFormat:@"每人享受%d次优惠",times];
    
    }
    
    
    if(self.type == 0){
        
        self.sorryView.hidden = YES;
    }else{

        if(self.sorryText && [self.sorryText isKindOfClass:[NSString class]]){
            [self showSorryView:self.sorryText];
        }
        else{
            [self showSorryView:@"错误!"];
        }
    }
    
    
    if([self.infoDic[@"type"] intValue] == 3){
        if ([self.infoDic[@"over"] intValue] > 999) {
            self.countTextField.text = @"999";
        } else {
            self.countTextField.text = [NSString stringWithFormat:@"%d",[self.infoDic[@"over"] intValue]];
        }
    }
    
    self.countTextField.layer.masksToBounds = YES;
    self.countTextField.layer.borderWidth = 1.0f;
    self.countTextField.layer.borderColor = UIColorFromRGB(0xdbdbdb).CGColor;
    
    self.priceTextField.layer.masksToBounds = YES;
    self.priceTextField.layer.borderWidth = 1.0f;
    self.priceTextField.layer.borderColor = UIColorFromRGB(0xdbdbdb).CGColor;
    
    self.phoneNumberField.layer.masksToBounds = YES;
    self.phoneNumberField.layer.borderWidth = 1.0f;
    self.phoneNumberField.layer.borderColor = UIColorFromRGB(0xdbdbdb).CGColor;

    [self.generateBtn addTarget:self action:@selector(generateAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.couponScrollView.contentSize = CGSizeMake(self.couponScrollView.frame.size.width, self.footView.frame.origin.y + self.footView.frame.size.height + 20);
    
    CGRect rect = self.bkView.frame;
    rect.origin.y = self.footView.frame.origin.y + self.footView.frame.size.height;
    self.bkView.frame = rect;
//    if([self.infoDic[@"status"] intValue]== 11){
//        self.warningLabel.textColor = UIColorFromRGB(0x999999);
//        [SVProgressHUD showErrorWithStatus:@"商品不支持" duration:0.8f];
//    }
//    if([self.infoDic[@"status"] intValue]== 1){
//        self.warningLabel.textColor = UIColorFromRGB(0x999999);
//        [SVProgressHUD showErrorWithStatus:@"活动已过期" duration:0.8f];
//    }
//    if([self.infoDic[@"status"] intValue]== 2){
//        self.warningLabel.textColor = UIColorFromRGB(0x999999);
//        [SVProgressHUD showErrorWithStatus:@"活动还未开始" duration:0.8f];
//    }
//    if([self.infoDic[@"status"] intValue]== 14){
//        self.warningLabel.textColor = UIColorFromRGB(0x999999);
//        [SVProgressHUD showErrorWithStatus:@"商品不存在" duration:0.8f];
//    }
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_btn_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(popPage:)];
    
    [self.navigationItem setLeftBarButtonItem:leftButton];

}



- (void)popPage:(id)sender{
    

        for (UIViewController *temp in self.navigationController.viewControllers) {
            
            if ([temp isKindOfClass:[CouponDeatilViewController class]]) {
                [self.navigationController popToViewController:temp animated:YES];
                return;
            }
        }
    
    
    for (UIViewController *temp in self.navigationController.viewControllers) {
        
        if ([temp isKindOfClass:[SearchSliderViewController class]]) {
            [self.navigationController popToViewController:temp animated:YES];
            return;
        }
    }
    
        for (UIViewController *temp in self.navigationController.viewControllers) {
            
            if ([temp isKindOfClass:[NewHomePageViewController class]]) {
                [self.navigationController popToViewController:temp animated:YES];
                return;
            }
        }

}

- (void)showSorryView:(NSString *)str{
    
    self.sorryLabel.text = str;
    self.sorryLabel.textColor = UIColorFromRGB(0xf06d5b);
    self.sorryView.hidden = NO;
    self.colorLabel.textColor = UIColorFromRGB(0x999999);
}

- (void)tapView:(UITapGestureRecognizer *)tap{
    
    [self.countTextField resignFirstResponder];
    [self.priceTextField resignFirstResponder];
    [self.phoneNumberField resignFirstResponder];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if(textField == self.countTextField){
        if ([string isEqualToString:@""]) {
            return YES;
        }
        NSString *strWillChange = [self.countTextField.text stringByAppendingString:string];
        if (strWillChange.intValue > 999 || strWillChange.intValue == 0) {
            return NO;
        }
    }
    
    if(textField == self.priceTextField){
        
        if([self stringNumber:string] || [string isEqualToString:@""]){
            NSMutableString * futureString = [NSMutableString stringWithString:textField.text];
            [futureString  insertString:string atIndex:range.location];
            NSInteger flag=0;
            const NSInteger limited = 2;
            for (int i = futureString.length - 1; i>=0; i--) {
                if ([futureString characterAtIndex:i] == '.') {
                    if (flag > limited) {
                        return NO;
                    }
                    break;
                }
                flag++;
            }
            return YES;
        }
        else{
            return NO;
        }    }
 
    
    if(textField == self.phoneNumberField){
        
        if(![string isEqualToString:@""]){
            if(textField.text.length == 11){
                return NO;
            }
            else{
                return YES;
            }
        }
    }
    
    return YES;
}

- (BOOL)stringNumber:(NSString *)str{
    
    NSString *c = @"^[0-9.]+$";
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",c];
    return [pre evaluateWithObject:str];
    
}

//加号事件
- (IBAction)addCount:(id)sender {
  
    NSString *str = self.countTextField.text;
    int count = [str intValue];
    if(count >= 999){
        str = @"999";
    }
    else{
        count ++;
        str = [NSString stringWithFormat:@"%d",count];
    }
    self.countTextField.text = str;
}
//减号时间
- (IBAction)reduceCount:(id)sender {

    NSString *str = self.countTextField.text;
    int count = [str intValue];
    if(count > 1){
        count --;
    }
    str = [NSString stringWithFormat:@"%d",count];
    self.countTextField.text = str;
}

- (BOOL)isMobilePhoneNumber:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
//    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
//    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
//    return [phoneTest evaluateWithObject:mobile];
    
    int a = [[mobile substringWithRange:NSMakeRange(0,1)] intValue];
    if(a == 1 && mobile.length == 11){
        return YES;
    }else{
        return NO;
    }
}

//点击生成二维码按钮事件
- (void)generateAction:(id)sender {
    
    self.generateBtn.userInteractionEnabled = NO;
    [self.countTextField resignFirstResponder];
    [self.priceTextField resignFirstResponder];
    
    if([self.countTextField.text isEqualToString:@""]){
        
        [SVProgressHUD showErrorWithStatus:@"请输入数量！" duration:1.5f];
        self.generateBtn.userInteractionEnabled = YES;
        return;
    }
    if([self.priceTextField.text isEqualToString:@""]){
        
        [SVProgressHUD showErrorWithStatus:@"请输入价格！" duration:1.5f];
        self.generateBtn.userInteractionEnabled = YES;
        return;
    }
    
    if(![self.phoneNumberField.text isEqualToString:@""]){
        
        if(![self isMobilePhoneNumber:self.phoneNumberField.text]){
            [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号！" duration:1.5f];
            self.generateBtn.userInteractionEnabled = YES;
            return;
        }
    }

    
    if(!app.logStatus) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        UINavigationController *navgationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPresentType = YES;
        [self presentViewController:navgationController animated:YES completion:NULL];
        self.generateBtn.userInteractionEnabled = YES;
        return;
    }
    
    if([self.phoneNumberField.text isEqualToString:app.configureList[@"mobile"]]){
        
        [SVProgressHUD showErrorWithStatus:@"输入手机号不能与登录账号一致 ！" duration:1.5f];
        self.generateBtn.userInteractionEnabled = YES;
        return;
    }
    
    
    //数量
    int count = [self.countTextField.text intValue];
    //价格
    float price = [self.priceTextField.text floatValue];
    
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"token"] = app.configureList[APP_USER_TOKEN];
    setting[@"proId"] = self.proId;
    setting[@"price"] = @(price);
    setting[@"quantity"] = @(count);
    setting[@"promotionId"] = self.infoDic[@"id"];
    
    [[HTTPRequestManager sharedInstance] checkPriceAndCount:setting completionSuc:^(id resultObj){
        
        if([resultObj[@"result"] isEqualToString:@"OK"]){
            //dic字段status: 0正常，1次数不足，2价格高，3价格低，4数量低，5数量超
            if(resultObj[@"body"] && [resultObj[@"body"][@"status"] intValue] == 0){
            //等于0则表示正常，页面跳转
                if(resultObj[@"body"][@"code"]){
                    
                    ShowQRViewController *showQRView = [[ShowQRViewController alloc]init];
                    showQRView.useType = self.useType;
                    showQRView.views = [resultObj[@"body"][@"views"] integerValue];
                    
                    if(![self.phoneNumberField.text isEqualToString:@""]){
                        //有推荐人:
                        showQRView.QRstring = [NSString stringWithFormat:@"%@#%@#%@#%@#%d#%.2f#%@",resultObj[@"body"][@"code"],self.infoDic[@"id"],app.configureList[APP_PASSPORTID_KEY],self.proId,count,price,self.phoneNumberField.text];
                        showQRView.phoneNumber = self.phoneNumberField.text;
                        
                    }else{
                        //无推荐人
                        showQRView.QRstring = [NSString stringWithFormat:@"%@#%@#%@#%@#%d#%.2f#",resultObj[@"body"][@"code"],self.infoDic[@"id"],app.configureList[APP_PASSPORTID_KEY],self.proId,count,price];
                        self.phoneNumberField.text = nil;
                    }
                    
                    showQRView.QRcode = resultObj[@"body"][@"code"];
                    
                    [self.navigationController pushViewController:showQRView animated:YES];
                    self.generateBtn.userInteractionEnabled = YES;
                }
                else{
                    self.generateBtn.userInteractionEnabled = YES;
                }
            }
            else if(resultObj[@"msg"] && [resultObj[@"msg"] isKindOfClass:[NSString class]]){
                //不等于0则有异常
                [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:1.5f];
                self.generateBtn.userInteractionEnabled = YES;
            }
        }
       
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        [SVProgressHUD showErrorWithStatus:@"加载失败!" duration:1.5f];
         self.generateBtn.userInteractionEnabled = YES;
    }];
}


- (void)pushToDrugDetail:(id)sender{
    
    DrugDetailViewController *drugDeatilView = [[DrugDetailViewController alloc]init];
    drugDeatilView.useType = 1;
    drugDeatilView.proId = self.proId;
    [self.navigationController pushViewController:drugDeatilView animated:YES];
}

@end

