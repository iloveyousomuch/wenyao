//
//  ScanReaderViewController.m
//  quanzhi
//
//  Created by xiezhenghong on 14-6-4.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "ScanReaderViewController.h"
#import "HTTPRequestManager.h"
#import "ScanFailViewController.h"
#import "ScanDrugViewController.h"
#import "SVProgressHUD.h"
#import "CouponGenerateViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface ScanReaderViewController ()
{
    NSMutableArray *checkArr;
    NSString *checkStr;
    BOOL torchIsOn;
}
@end

@implementation ScanReaderViewController
@synthesize scanRectView;

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
    self.title = @"条码";
    checkArr = [NSMutableArray array];
    checkStr = @"";
//    [self._scanRectView.scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE to:0];
    self.capture = [[ZXCapture alloc] init];
    self.capture.camera = self.capture.back;
    self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    [self configureReadView];
    [self setupTorchBarButton];
    [self setupDynamicScanFrame];
    
}

- (void)backToPreviousController:(id)sender
{
    if (self.capture.running ) {
        [self.capture stop];
    }
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)configureReadView
{
 
    self.capture.rotation = 90.0f;
//    self.capture.torch = YES;
    self.capture.layer.frame = self.view.bounds;
    self.capture.delegate = self;
    self.capture.layer.frame = self.view.bounds;
    
    CGAffineTransform captureSizeTransform = CGAffineTransformMakeScale(320 / self.view.frame.size.width, 480 / self.view.frame.size.height);
    self.capture.scanRect = CGRectApplyAffineTransform(self.scanRectView.frame, captureSizeTransform);
    [self.view.layer addSublayer:self.capture.layer];
    
//    [self.view bringSubviewToFront:self.scanRectView];   
    CGRect scanMaskRect = CGRectMake(60, CGRectGetMidY(scanRectView.frame) - 126, 200, 200);
    //_scanRectView.scanCrop = [self getScanCrop:scanMaskRect _scanRectViewBounds:self._scanRectView.bounds];
    UILabel *desrciption = [[UILabel alloc] initWithFrame:CGRectMake(60, 380, 200, 35)];
    desrciption.textColor = [UIColor whiteColor];
    desrciption.font = [UIFont systemFontOfSize:13];
    desrciption.text = @"将条码放到取景框内,即可自动扫描";
    [self.view addSubview:desrciption];
}

- (void)setupDynamicScanFrame
{
    CGRect scanMaskRect = CGRectMake(60, CGRectGetMidY(scanRectView.frame) - 126, 200, 200);
    UIImageView *scanImage = [[UIImageView alloc] initWithFrame:scanMaskRect];
    [scanImage setImage:[UIImage imageNamed:@"扫描框.png"]];
    [self.view addSubview:scanImage];
    
    UIImageView *scanLineImage = [[UIImageView alloc] initWithFrame:CGRectMake(60, CGRectGetMidY(scanRectView.frame) - 126, 200, 6)];
    [scanLineImage setImage:[UIImage imageNamed:@"扫描线.png"]];
    [self.view addSubview:scanLineImage];
    [self runSpinAnimationOnView:scanLineImage duration:3 positionY:200 repeat:CGFLOAT_MAX];
}

- (CGRect)getScanCrop:(CGRect)rect _scanRectViewBounds:(CGRect)_scanRectViewBounds
{
    CGFloat x,y,width,height;
    
    x = rect.origin.x / _scanRectViewBounds.size.width;
    y = rect.origin.y / _scanRectViewBounds.size.height;
    width = rect.size.width / _scanRectViewBounds.size.width;
    height = rect.size.height / _scanRectViewBounds.size.height;
    
    return CGRectMake(x, y, width, height);
}

- (void)setupTorchBarButton
{
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"闪光灯.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleTorch:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}
- (void)captureSize:(ZXCapture *)capture
              width:(NSNumber *)width
             height:(NSNumber *)height
{
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if ( !self.capture.running) {
        [checkArr removeAllObjects];
        [self configureReadView];
        [self setupTorchBarButton];
        [self setupDynamicScanFrame];
        [self.capture start];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    torchIsOn = NO;
}

- (void)captureCameraIsReady:(ZXCapture *)capture
{
    
}

- (IBAction)toggleTorch:(id)sender
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (!torchIsOn) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                torchIsOn = YES;
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                torchIsOn = NO;
            }
            [device unlockForConfiguration];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}
- (NSString *)barcodeFormatToString:(ZXBarcodeFormat)format {
    switch (format) {
        case kBarcodeFormatAztec:
            return @"Aztec";
            
        case kBarcodeFormatCodabar:
            return @"CODABAR";
            
        case kBarcodeFormatCode39:
            return @"Code 39";
            
        case kBarcodeFormatCode93:
            return @"Code 93";
            
        case kBarcodeFormatCode128:
            return @"Code 128";
            
        case kBarcodeFormatDataMatrix:
            return @"Data Matrix";
            
        case kBarcodeFormatEan8:
            return @"EAN-8";
            
        case kBarcodeFormatEan13:
            return @"EAN-13";
            
        case kBarcodeFormatITF:
            return @"ITF";
            
        case kBarcodeFormatPDF417:
            return @"PDF417";
            
        case kBarcodeFormatQRCode:
            return @"QR Code";
            
        case kBarcodeFormatRSS14:
            return @"RSS 14";
            
        case kBarcodeFormatRSSExpanded:
            return @"RSS Expanded";
            
        case kBarcodeFormatUPCA:
            return @"UPCA";
            
        case kBarcodeFormatUPCE:
            return @"UPCE";
            
        case kBarcodeFormatUPCEANExtension:
            return @"UPC/EAN extension";
            
        default:
            return @"Unknown";
    }
}
- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result {
    if (!result) return;
     if ([checkArr count]>8)
    {
        
    }else
    {
        [checkArr addObject:result.text];
    }
    
    if ([checkArr count] == 3) {
        for (int i = 0; i < checkArr.count; i ++) {
            NSString *string = checkArr[ i];
            NSMutableArray *tempArray = [@[] mutableCopy];
            [tempArray addObject:string];
            for (int j = i+1; j < checkArr.count; j ++) {
                NSString *jstring = checkArr[j];
                NSLog(@"jstring:%@",jstring);
                if([string isEqualToString:jstring]){
                    NSLog(@"jvalue = kvalue");
                    checkStr = jstring;
//                    [checkArr removeObjectAtIndex:j];
                }
            }
      
        }
        if ([checkStr isEqualToString:@""]) {
            [checkArr removeAllObjects];
        }
        NSLog(@"count == 3");
        
        if(checkStr.length){
            if(self.useType == 3) {
                //优惠码逻辑
                //______________________________________
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[@"barCode"] = checkStr;
                [[HTTPRequestManager sharedInstance] queryProductByBarCode:dic completion:^(id resultObj) {
                    
                    if([resultObj[@"result"] isEqualToString:@"OK"])
                    {
                        NSArray *array = resultObj[@"body"][@"data"];
                        if(array.count > 0){
                            //根据条形码获取商品ID,用商品ID去请求code
                            [self pushToGenerateView:array[0][@"proId"] barCode:checkStr];
                        }else{
                            self.useType = 1;
                            [self normalScan:checkStr];
                        }
                    }else{
                        self.useType = 1;
                        [self normalScan:checkStr];
                    }
                } failure:^(NSError *error) {
                    NSLog(@"%@",error);
                    [SVProgressHUD showErrorWithStatus:@"加载失败!" duration:0.8f];
                    return;
                }];
                //______________________________________
            }else{
                [self normalScan:checkStr];
            }
        }
    }
    NSString *formatString = [self barcodeFormatToString:result.barcodeFormat];
    NSString *display = [NSString stringWithFormat:@"Scanned!\n\nFormat: %@\n\nContents:\n%@", formatString, result.text];
    
}
- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear:animated];
  
//    [_scanRectView start];
}

- (void)runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration positionY:(CGFloat)positionY repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: positionY];
    rotationAnimation.duration = duration;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    rotationAnimation.autoreverses = YES;
    [view.layer addAnimation:rotationAnimation forKey:@"position"];
}

- (void)pushToGenerateView:(NSString *)proId barCode:(NSString *)barCode
{  
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    if(app.logStatus){
        setting[@"token"] = app.configureList[APP_USER_TOKEN];
    }
    setting[@"proId"] = proId;
    [[HTTPRequestManager sharedInstance]couponScan:setting completionSuc:^(id resultObj){
        //                body不会为空，首先判断status
        
        int status = [resultObj[@"body"][@"status"] intValue];
        if([resultObj[@"result"] isEqualToString:@"OK"] && (status == 0 || status == -13 || status == -14)){

            CouponGenerateViewController *generateView = [[CouponGenerateViewController alloc]initWithNibName:@"CouponGenerateViewController" bundle:nil];
            generateView.useType = self.pageType;
            generateView.type = [resultObj[@"body"][@"status"] integerValue];
            if([resultObj[@"body"][@"status"] intValue] != 0){
                generateView.sorryText = resultObj[@"msg"];
            }
            //传值：优惠活动详情
            generateView.infoDic = resultObj[@"body"];
            //传值：商品编码
            generateView.proId = proId;
            if (self.capture.running ) {
                [self.capture stop];
            }
            [self.navigationController pushViewController:generateView animated:YES];
            
        }else{
            self.useType = 1;
            [self normalScan:barCode];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        self.useType = 1;
        [self normalScan:barCode];
        return;
    }];

}

- (void)normalScan:(NSString *)proId
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    setting[@"barCode"] = proId;
    
    [[HTTPRequestManager sharedInstance] queryProductByBarCode:setting completion:^(id resultObj) {
        NSLog(@"扫码 = %@",resultObj);
        if([resultObj[@"result"] isEqualToString:@"OK"])
        {
            if(!self.scanBlock)
            {
                if(self.useType == 1) {
                    ScanDrugViewController *scanDrugViewController = [[ScanDrugViewController alloc] init];
                    scanDrugViewController.drugList = resultObj[@"body"][@"data"];
                    scanDrugViewController.userType = self.useType;
                    if(self.completionBolck){
                        scanDrugViewController.completionBolck = self.completionBolck;
                    }
                    if (self.capture.running ) {
                        [self.capture stop];
                    }
                    [self.navigationController pushViewController:scanDrugViewController animated:YES];
                }else{
                    NSArray *array = resultObj[@"body"][@"data"];
                    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
                    setting[@"productId"] = array[0][@"proId"];
                    [[HTTPRequestManager sharedInstance] getProductUsage:setting completion:^(id resultObj) {
                        if([resultObj[@"result"] isEqualToString:@"OK"]) {
                            if(self.completionBolck)
                            {
                                NSMutableDictionary *source = [NSMutableDictionary dictionaryWithDictionary:array[0]];
                                
                                [source addEntriesFromDictionary:resultObj[@"body"]];
                                if(source[@"dayPerCount"]) {
                                    source[@"drugTime"] = source[@"dayPerCount"];
                                    [source removeObjectForKey:@"dayPerCount"];
                                }
                                self.completionBolck(source);
                            }
                            if (self.capture.running ) {
                                [self.capture stop];
                            }
                            [self.navigationController popViewControllerAnimated:NO];
                        }
                    } failure:NULL];
                }
            }else{
                self.scanBlock(proId);
            }
        }else if ([resultObj[@"result"] isEqualToString:@"FAIL"]){
            if (self.capture.running ) {
                [self.capture stop];
            }
            [self.navigationController popViewControllerAnimated:NO];
            if(resultObj[@"msg"]) {
                NSLog(@"fail %@:",setting);
                [SVProgressHUD showErrorWithStatus:resultObj[@"msg"] duration:1.2f];
            }else{
                [SVProgressHUD showErrorWithStatus:@"药品扫描失败" duration:1.2f];
            }
        }
    } failure:^(NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:@"网络未连接，请重试" duration:0.8f];
        
    }];
}

- (void) readerView: (ZBarReaderView*) view
     didReadSymbols: (ZBarSymbolSet*) syms
          fromImage: (UIImage*) img
{
    NSString *proId = nil;
    for(ZBarSymbol *sym in syms)
    {
        proId = sym.data;
        break;
    }
    [view stop];
    NSLog(@"%@",proId);

    if(proId){
        if(self.useType == 3) {
            //优惠码逻辑
//______________________________________
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"barCode"] = proId;
            [[HTTPRequestManager sharedInstance] queryProductByBarCode:dic completion:^(id resultObj) {
                
                if([resultObj[@"result"] isEqualToString:@"OK"])
                    {
                        NSArray *array = resultObj[@"body"][@"data"];
                        if(array.count > 0){
                            //根据条形码获取商品ID,用商品ID去请求code
                            [self pushToGenerateView:array[0][@"proId"] barCode:proId];
                        }else{
                            self.useType = 1;
                            [self normalScan:proId];
                        }
                    }else{
                        self.useType = 1;
                        [self normalScan:proId];
                    }
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
                [SVProgressHUD showErrorWithStatus:@"加载失败!" duration:0.8f];
                return;
            }];
//______________________________________
        }else{
            [self normalScan:proId];
        }
    }
    [view start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
