//
//  MarketDetailViewController.m
//  quanzhi
//
//  Created by xiezhenghong on 14-7-3.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "MarketDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "HTTPRequestManager.h"
#import "Constant.h"
#import "AppDelegate.h"
#import "ReturnIndexView.h"



@interface MarketDetailViewController ()<ReturnIndexViewDelegate>
{
    float imageViewheight;
}
@property (strong, nonatomic) ReturnIndexView *indexView;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (strong,nonatomic)NSMutableArray *imageArray;
@property (strong,nonatomic)NSMutableArray *imageArrayUrl;
@property (strong, nonatomic) IBOutlet UIView *setimageViews;
@property (strong,nonatomic)NSMutableDictionary *activiDic;
@end

@implementation MarketDetailViewController

- (id)init
{
    if (self = [super init])
    {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.activiDic=[NSMutableDictionary dictionary];
    imageViewheight=0;
    
    self.setimageViews.backgroundColor= COLOR(236, 240, 241);
    if (iOSv7 && self.view.frame.origin.y==0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    self.contentLabel.textColor=[UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1];
    

    self.titleLabel.textColor=[UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1];
    self.title = @"活动详情";
    [self setUpRightItem];
    
//    [self calculatedframe];

    //设置UIlable的行间距

//  if(!self.previewMode == 1){
//
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStylePlain target:self action:@selector(editMarketActivity:)];
//  }else if(self.previewMode == 3){
//      self.title=@"预览营销活动";
//      self.navigationItem.rightBarButtonItem = nil;
//  }else{
//      self.title=@"预览营销活动";
//      NSDateFormatter *formate=[[NSDateFormatter alloc]init];
//      [formate setDateFormat:@"yyyy-MM-dd"];
//      NSString *darte=[NSString stringWithFormat:@"%@",[formate stringFromDate:[NSDate date]]];
//      self.dateLabel.text=darte;
//      self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(gotoback:)];
//  }
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

-(void)getInfomation
{
    NSMutableDictionary *setting=[NSMutableDictionary dictionary];
    setting[@"activityId"]=self.infoDict[@"activityId"];
    setting[@"groupId"]= self.infoDict[@"groupId"];
    [[HTTPRequestManager sharedInstance] getActivity:setting completion:^(id resultObj) {
        NSLog(@"%@",resultObj);
        if ([resultObj[@"result"]isEqualToString:@"OK"]) {
            if([resultObj[@"body"] isKindOfClass:[NSString class]] && [resultObj[@"body"] isEqualToString:@""])
                return;
            self.activiDic=resultObj[@"body"];
            NSLog(@"%@",self.activiDic);
            CGSize sizes=[resultObj[@"body"][@"title"] boundingRectWithSize:CGSizeMake(APP_W-20, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]} context:nil].size;
            self.titleLabel.frame=CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y, sizes.width, sizes.height+8);
            self.dateLabel.frame=CGRectMake(self.dateLabel.frame.origin.x, self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height+10, self.dateLabel.frame.size.width, self.dateLabel.frame.size.height);
            self.lineView.frame=CGRectMake(self.lineView.frame.origin.x, self.dateLabel.frame.origin.y+self.dateLabel.frame.size.height+10, self.lineView.frame.size.width, self.lineView.frame.size.height);

            self.contentLabel.text = [app replaceSpecialStringWith:resultObj[@"body"][@"content"]];
            self.dateLabel.text = [resultObj[@"body"][@"publishTime"] substringToIndex:10];
            self.titleLabel.text = [app replaceSpecialStringWith:resultObj[@"body"][@"title"]];
            NSDictionary *dic=resultObj[@"body"][@"imgs"];
     
            for (NSDictionary *dics in dic) {
                [self.imageArrayUrl addObject:[dics mutableCopy]];
            }
            if(self.imageArrayUrl.count==0) {
                self.setimageViews.hidden = YES;
                self.contentLabel.frame=CGRectMake(self.contentLabel.frame.origin.x,self.lineView.frame.origin.y+14, self.contentLabel.frame.size.width, self.contentLabel.frame.size.height);
                self.scrollView.contentSize = CGSizeMake(APP_W, self.contentLabel.frame.origin.y+self.contentLabel.frame.size.height+20);
                
            }else{
                
                self.setimageViews.hidden = NO;
                
            }
            [self calutepalace];
            
            if (self.imStatus==2&&resultObj[@"body"][@"deleted"]){
                if(1==[resultObj[@"body"][@"deleted"] intValue]){
                    UIImageView *deleted=[[UIImageView alloc]initWithFrame:CGRectMake(APP_W-120, 100, 100, 100)];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    NSDate *date = [dateFormatter dateFromString:resultObj[@"body"][@"endDate"]];
                    NSDate *nowDate=[dateFormatter dateFromString:[dateFormatter stringFromDate:[NSDate date]]];
                    NSComparisonResult result = [nowDate compare:date];
                    if(result == NSOrderedDescending){
                    [deleted setImage:[UIImage imageNamed:@"bg-activity expired.PNG"]];//大于
                    }else {
                    [deleted setImage:[UIImage imageNamed:@"bg-activity delete.PNG"]];
                    }
                    [self.view addSubview:deleted];
                    
                }
                
                
            }

            
            
            
     
        }
    } failure:^(id failMsg) {
        
    }];
    
}
-(void)getimages
{
     self.imageArray=[NSMutableArray array];

    for (int i=0; i<self.imageArrayUrl.count; i++) {
    
        [SDWebImageManager.sharedManager downloadWithURL:[NSURL URLWithString:self.imageArrayUrl[i][@"normalImg"]] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
            if (!self)
                return;
            if(image){
                NSLog(@"I%@",image);
            [self.imageArray addObject:image];
            }
            if (self.imageArray.count == self.imageArrayUrl.count)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self calculateFrames];
                });
            }else{
                self.contentLabel.frame=CGRectMake(self.contentLabel.frame.origin.x,self.lineView.frame.origin.y+14, self.contentLabel.frame.size.width, self.contentLabel.frame.size.height);
                self.scrollView.contentSize = CGSizeMake(APP_W, self.contentLabel.frame.origin.y+self.contentLabel.frame.size.height+20);
            }
        }];
    }
}

-(void)calculateFrames
{
//    self.setimageViews.backgroundColor=[UIColor redColor];
    if (self.imageArray.count>0) {
        for (int j=0; j<self.imageArray.count; j++) {
            
            UIImageView *imageView=[[UIImageView alloc] init];
      
            UIImage *image=[self.imageArray objectAtIndex:j];
          
            NSLog(@"%@",NSStringFromCGSize(image.size));
                if (image.size.width>self.setimageViews.frame.size.width) {
                    
                    CGFloat imageh=image.size.height*self.setimageViews.frame.size.width/image.size.width;
                    imageView.frame=CGRectMake(0, 0+imageViewheight, self.setimageViews.frame.size.width, imageh);
                    imageViewheight+=imageh+8;
                }else{
                    
                    imageView.frame=CGRectMake((self.setimageViews.frame.size.width-image.size.width)/2, 0+imageViewheight, image.size.width , image.size.height);;
                    imageViewheight+=image.size.height+8;
                }
            NSLog(@"%@",NSStringFromCGRect(imageView.frame));
                [imageView setImage:image];
//                imageView.frame = needRect;
                [self.setimageViews addSubview:imageView];
        }
        self.setimageViews.frame=CGRectMake(self.setimageViews.frame.origin.x, self.lineView.frame.origin.y+10, self.setimageViews.frame.size.width, imageViewheight);
        
        self.contentLabel.frame=CGRectMake(self.setimageViews.frame.origin.x,self.setimageViews.frame.origin.y+self.setimageViews.frame.size.height+10, self.contentLabel.frame.size.width, self.contentLabel.frame.size.height);

        
        self.scrollView.contentSize = CGSizeMake(APP_W, self.contentLabel.frame.origin.y+self.contentLabel.frame.size.height+20);
        
            }else{
                
        self.contentLabel.frame=CGRectMake(self.contentLabel.frame.origin.x,self.lineView.frame.origin.y+14, self.contentLabel.frame.size.width, self.contentLabel.frame.size.height);
        self.scrollView.contentSize = CGSizeMake(APP_W, self.contentLabel.frame.origin.y+self.contentLabel.frame.size.height+20);
    }

}
//-(void)calculatedframe{
//    
//    if(self.infoDict[@"imageSrc"]){
//        UIImage *image=self.infoDict[@"imageSrc"];
//        if (image.size.width>self.imageView.frame.size.width) {
//            
//            CGFloat imageh=image.size.height*self.imageView.frame.size.width/image.size.width;
//            self.imageView.frame=CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.imageView.frame.size.width, imageh);
//        }else{
//            self.imageView.contentMode=UIViewContentModeScaleAspectFit;
//        }
//        [self.imageView setImage:image];
//        self.contentLabel.frame=CGRectMake(self.contentLabel.frame.origin.x,self.imageView.frame.origin.y+self.imageView.frame.size.height+8, self.contentLabel.frame.size.width, self.contentLabel.frame.size.height);
//        self.imageheigt=self.imageView.frame.size.height;
//        self.scrollView.contentSize = CGSizeMake(APP_W, self.contentLabel.frame.origin.y+self.contentLabel.frame.size.height+20);
//    }else{
//        __weak HealthIndicatorDetailViewController *weakSelf = self;
//        
//        [SDWebImageManager.sharedManager downloadWithURL:[NSURL URLWithString:self.infoDict[@"imgUrl"]] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
//            if (!weakSelf) return;
//            dispatch_main_sync_safe(^{
//                if (!weakSelf) return;
//                if (image)
//                {
//                    [weakSelf.imageView setImage:image];
//                    if (image.size.width>weakSelf.imageView.frame.size.width) {
//                        CGFloat imageh=image.size.height*weakSelf.imageView.frame.size.width/image.size.width;
//                        weakSelf.imageView.frame=CGRectMake(weakSelf.imageView.frame.origin.x, weakSelf.imageView.frame.origin.y, weakSelf.imageView.frame.size.width, imageh);
//                    }else{
//                        weakSelf.imageView.contentMode=UIViewContentModeScaleAspectFit;
//                    }
//                    [weakSelf.imageView setImage:image];
//                    weakSelf.contentLabel.frame=CGRectMake(weakSelf.contentLabel.frame.origin.x,weakSelf.imageView.frame.origin.y+weakSelf.imageView.frame.size.height+8, weakSelf.contentLabel.frame.size.width, weakSelf.contentLabel.frame.size.height);
//                    weakSelf.imageheigt=weakSelf.imageView.frame.size.height;
//                    weakSelf.scrollView.contentSize = CGSizeMake(APP_W, weakSelf.contentLabel.frame.origin.y+weakSelf.contentLabel.frame.size.height+20);
//                 
//                }else{
//                       weakSelf.contentLabel.frame=CGRectMake(weakSelf.contentLabel.frame.origin.x,weakSelf.lineView.frame.origin.y+14, weakSelf.contentLabel.frame.size.width, weakSelf.contentLabel.frame.size.height);
//                        weakSelf.scrollView.contentSize = CGSizeMake(APP_W, weakSelf.contentLabel.frame.origin.y+weakSelf.contentLabel.frame.size.height+20);
//                    }
//            });
//        }];
//       
//        //        [self.imageView setImageWithURL:[NSURL URLWithString:self.infoDict[@"imgUrl"]] placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
//        //        NSLog(@"%@",self.imageView);
//    }
//}
-(void)gotoback:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)adjustSizeContent
{
    
    CGSize size = [self.infoDict[@"content"] sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(APP_W-20, 2000)];
    CGFloat offset = size.height - 27.0;
 
    if(offset > 0)
    {
        CGRect rect = self.contentLabel.frame;
        rect.size.height = size.height;
        if(!HIGH_RESOLUTION)
        {
            rect.origin.y = 280;
        }
        self.contentLabel.frame = CGRectMake(self.contentLabel.frame.origin.x, imageViewheight+self.setimageViews.frame.origin.y, rect.size.width, rect.size.height);
        self.scrollView.contentSize = CGSizeMake(APP_W, self.contentLabel.frame.origin.y+self.contentLabel.frame.size.height+20);
    }else{
        self.contentLabel.frame = CGRectMake(self.contentLabel.frame.origin.x, imageViewheight+self.setimageViews.frame.origin.y+8,self.contentLabel.frame.size.width,self.contentLabel.frame.size.height);
       
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.imageArrayUrl=[NSMutableArray array];
    //请求数据
    if (self.userType==1) {
        if(self.infoDict[@"title"]) {
            CGSize sizes=[self.infoDict[@"title"] boundingRectWithSize:CGSizeMake(APP_W-20, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]} context:nil].size;
            self.titleLabel.frame=CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y, sizes.width, sizes.height+8);
            self.dateLabel.frame=CGRectMake(self.dateLabel.frame.origin.x, self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height+10, self.dateLabel.frame.size.width, self.dateLabel.frame.size.height);
            self.lineView.frame=CGRectMake(self.lineView.frame.origin.x, self.dateLabel.frame.origin.y+self.dateLabel.frame.size.height+10, self.lineView.frame.size.width, self.lineView.frame.size.height);
            
            self.contentLabel.text = [app replaceSpecialStringWith:self.infoDict[@"content"]];
            NSLog(@"%@",NSStringFromCGRect(self.titleLabel.frame));
            self.dateLabel.text = [self.infoDict[@"publishTime"] substringToIndex:10];
            self.titleLabel.text = [app replaceSpecialStringWith:self.infoDict[@"title"]];
            if(self.infoDict[@"imgUrl"])
            {
                [self.imageArrayUrl addObject:@{@"normalImg":self.infoDict[@"imgUrl"]}];
            }
            if(self.imageArrayUrl.count==0) {
                self.setimageViews.hidden = YES;
                self.contentLabel.frame=CGRectMake(self.contentLabel.frame.origin.x,self.lineView.frame.origin.y+14, self.contentLabel.frame.size.width, self.contentLabel.frame.size.height);
                self.scrollView.contentSize = CGSizeMake(APP_W, self.contentLabel.frame.origin.y+self.contentLabel.frame.size.height+20);
                
            }else{
                
                self.setimageViews.hidden = NO;
                
            }
            [self calutepalace];
        }else{
            [self getInfomation];
        }
    }else{
        
    }
    

}
-(void)calutepalace{
    
    CGSize sizes=[self.contentLabel.text boundingRectWithSize:CGSizeMake(APP_W-20, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0f]} context:nil].size;
    self.contentLabel.frame=CGRectMake(self.contentLabel.frame.origin.x, self.contentLabel.frame.origin.y, sizes.width, sizes.height+8);
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:self.contentLabel.text];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:10];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [self.contentLabel.text length])];
    [self.contentLabel setAttributedText:attributedString1];
    [self.contentLabel sizeToFit];
    [self getimages];
    //[self calculateFrames];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
