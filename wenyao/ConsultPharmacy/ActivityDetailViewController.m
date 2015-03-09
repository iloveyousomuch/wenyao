//
//  ActivityDetailViewController.m
//  wenyao
//
//  Created by xiezhenghong on 14-10-14.
//  Copyright (c) 2014年 xiezhenghong. All rights reserved.
//

#import "ActivityDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "Constant.h"

@interface ActivityDetailViewController ()

@end

@implementation ActivityDetailViewController

//计算字体高度
- (CGFloat)calculateCollapseHeigtOffsetWithFontSize:(UIFont *)fontSize withTextSting:(NSString *)text
{
    CGSize adjustSize = [text sizeWithFont:fontSize constrainedToSize:CGSizeMake(292, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    if(adjustSize.height > 19.0f)
    {
        return ceilf(adjustSize.height - 19.0f);
    }else{
        return 0;
    }
}


- (void)initUI
{
    self.scrollView.frame = CGRectMake(0, 0, APP_W, APP_H - NAV_H);
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(10, self.dateLabel.frame.origin.y + self.dateLabel.frame.size.height + 5, APP_W - 20, 0.5)];
    line.backgroundColor = UIColorFromRGB(0xdbdbdb);
    [self.scrollView addSubview:line];
    
    
    CGSize titleSize = [self.infoDict[@"title"] sizeWithFont:[UIFont systemFontOfSize:18.0] constrainedToSize:CGSizeMake(SCREEN_W - 20, 2000)];
    CGRect rect = self.titleLabel.frame;
    rect.size.height = titleSize.height;
    self.titleLabel.frame = rect;
    self.titleLabel.text = self.infoDict[@"title"];
    
    self.dateLabel.text = [self.infoDict[@"createTime"] substringToIndex:10];
    NSString *imageUrl = self.infoDict[@"imgUrl"];
    
    UIImage * result = nil;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    
    result = [UIImage imageWithData:data];
    
    double height = result.size.height / result.size.width * self.imageView.frame.size.width;
    
    
    if(result)
    {
        
    
        if(result.size.width < self.imageView.frame.size.width){
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
        else{
            self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.imageView.frame.size.width, height);
        }
        [self.imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
    }else{
        self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, self.imageView.frame.size.width, 1);
        self.imageView.hidden = YES;
        
//        [self.imageView setImage:[UIImage imageNamed:@"药品默认图片.png"]];
    }
    self.contentLabel.text = self.infoDict[@"content"];
   
    CGSize size = [self.infoDict[@"content"] sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(APP_W-20, 1999)];
    
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.frame = CGRectMake(self.contentLabel.frame.origin.x, self.imageView.frame.origin.y + self.imageView.frame.size.height + 10, APP_W - 20, size.height + 40);
    

    self.scrollView.contentSize = CGSizeMake(APP_W, self.contentLabel.frame.origin.y + size.height + 50);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"活动详情";
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
