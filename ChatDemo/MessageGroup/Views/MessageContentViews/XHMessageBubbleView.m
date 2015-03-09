
//
//  XHMessageBubbleView.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-24.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHMessageBubbleView.h"
#import "TQRichTextURLRun.h"
#import "XHMessageBubbleHelper.h"
#import "XHMessageTableViewController.h"
#import "TQRichTextEmojiRun.h"
#import "MLEmojiLabel.h"
#import "UIImageView+WebCache.h"
#define kMarginTop 8.0f
#define kMarginBottom 5.0f
#define kPaddingTop 4.0f
#define kBubblePaddingRight 10.0f

#define kVoiceMargin 20.0f

#define kXHArrowMarginWidth 14

@interface XHMessageBubbleView ()<UIActionSheetDelegate,MLEmojiLabelDelegate>

@property (nonatomic, weak, readwrite) MLEmojiLabel *displayTextView;

@property (nonatomic, weak, readwrite) UIImageView *bubbleImageView;

@property (nonatomic, weak, readwrite) UIImageView *animationVoiceImageView;

@property (nonatomic, weak, readwrite) XHBubblePhotoImageView *bubblePhotoImageView;

@property (nonatomic, weak, readwrite) UIImageView *videoPlayImageView;

@property (nonatomic, weak, readwrite) UILabel *geolocationsLabel;

@property (nonatomic, strong, readwrite) id <XHMessageModel> message;

@end

@implementation XHMessageBubbleView

#pragma mark - Bubble view

+ (CGFloat)neededWidthForText:(NSString *)text {
    CGSize stringSize;
    stringSize = [text sizeWithFont:[[XHMessageBubbleView appearance] font]
                     constrainedToSize:CGSizeMake(MAXFLOAT, 19)];
    return roundf(stringSize.width);
}

+ (CGSize)neededSizeForText:(NSString *)text
{
    CGFloat maxWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) * (kIsiPad ? 0.8 : 0.6);
//    CGFloat dyWidth = [XHMessageBubbleView neededWidthForText:text];
    CGSize textSize = [MLEmojiLabel needSizeWithText:text WithConstrainSize:CGSizeMake(maxWidth, MAXFLOAT)];
    if(textSize.height == 25)
        textSize.height -= 2;
    return CGSizeMake(textSize.width + kBubblePaddingRight * 2 + kXHArrowMarginWidth, textSize.height);
}

+ (CGSize)neededSizeForText:(NSString *)text withDelta:(CGFloat)delta
{
    CGFloat maxWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) * delta;
    //    CGFloat dyWidth = [XHMessageBubbleView neededWidthForText:text];
    CGSize textSize = [MLEmojiLabel needSizeWithText:text WithConstrainSize:CGSizeMake(maxWidth, MAXFLOAT)];
    if(textSize.height == 25)
        textSize.height -= 2;
    return CGSizeMake(textSize.width + kBubblePaddingRight * 2 + kXHArrowMarginWidth, textSize.height);
}


+ (CGSize)neededSizeForPhoto:(UIImage *)photo {
    // 这里需要缩放后的size
    CGSize photoSize = CGSizeMake(120, 150);
    return photoSize;
}

+ (CGSize)neededSizeForVoicePath:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration {
    // 这里的100只是暂时固定，到时候会根据一个函数来计算
    float gapDuration = (!voiceDuration || voiceDuration.length == 0 ? -1 : [voiceDuration floatValue] - 1.0f);
    CGSize voiceSize = CGSizeMake(100 + (gapDuration > 0 ? (120.0 / (60 - 1) * gapDuration) : 0),30);
    return voiceSize;
}

+ (CGFloat)calculateCellHeightWithMessage:(id <XHMessageModel>)message {
    CGSize size = [XHMessageBubbleView getBubbleFrameWithMessage:message];
    return size.height + kMarginTop + kMarginBottom;
}

+ (CGSize)getBubbleFrameWithMessage:(id <XHMessageModel>)message {
    CGSize bubbleSize;
    switch (message.messageMediaType) {
        case XHBubbleMessageMediaTypeText:
        case XHBubbleMessageMediaTypePurchaseMedicine:
        {
            if([message officialType]) {
                bubbleSize = [self neededSizeForText:message.text withDelta:0.8];
            }else {
                bubbleSize = [XHMessageBubbleView neededSizeForText:message.text];
            }
            break;
        }
        case XHBubbleMessageMediaTypeStarStore:{
            bubbleSize = [XHMessageBubbleView neededSizeForText:message.text ];
            break;
        }
        case XHBubbleMessageMediaTypeStarClient:
        {
            bubbleSize = [XHMessageBubbleView neededSizeForText:message.text ];
            if(bubbleSize.height == 25)
                bubbleSize.height -= 5;
            bubbleSize.height += 25.0f;
            CGFloat maxWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) * (kIsiPad ? 0.8 : 0.6);
            bubbleSize.width = maxWidth + kBubblePaddingRight * 2 + kXHArrowMarginWidth;
            break;
        }
        case XHBubbleMessageMediaTypeLocation:
        {
            bubbleSize = CGSizeMake(APP_W * 0.6, 25);
            CGSize size = [[message text] sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:CGSizeMake(190, 45)];
            bubbleSize.height += size.height;
            CGFloat maxWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) * (kIsiPad ? 0.8 : 0.6);
            bubbleSize.width = maxWidth + kBubblePaddingRight * 2 + kXHArrowMarginWidth;
            break;
        }
        case XHBubbleMessageMediaTypeActivity:
        {
            CGSize constrainedSize = CGSizeZero;
            if([message messageMediaType] == XHBubbleMessageMediaTypeDrugGuide) {
                constrainedSize = CGSizeMake(260, 45);
            }else{
                constrainedSize = CGSizeMake(190, 45);
            }
            if(message.activityUrl == nil || [message.activityUrl isEqualToString:@""])
            {
                NSString *content = message.text;
                
                CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(0.6 * APP_W, 65)];
                
                CGFloat maxWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) * (kIsiPad ? 0.8 : 0.6);
                bubbleSize.width = maxWidth + kBubblePaddingRight * 2 + kXHArrowMarginWidth;
                CGSize titleSize = [[message title] sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:constrainedSize];
                bubbleSize.height += titleSize.height + 8 + size.height;
                
            }else{
                bubbleSize = CGSizeMake(APP_W * 0.6, 65);
                CGSize size = [[message title] sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:constrainedSize];
                bubbleSize.height += size.height;
                CGFloat maxWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) * (kIsiPad ? 0.8 : 0.6);
                bubbleSize.width = maxWidth + kBubblePaddingRight * 2 + kXHArrowMarginWidth;
            }
            break;
        }
        case XHBubbleMessageMediaTypePhoto: {
            bubbleSize = [XHMessageBubbleView neededSizeForPhoto:message.photo];
            break;
        }
        case XHBubbleMessageMediaTypeAutoSubscription:
        {
            bubbleSize = [self neededSizeForText:message.text withDelta:0.8];
            bubbleSize.height += 25;
            break;
        }
        case XHBubbleMessageMediaTypeDrugGuide:
        {
            if([message officialType]){
                bubbleSize = [self neededSizeForText:message.text withDelta:0.8];
            }else{
                bubbleSize = [self neededSizeForText:message.text];
            }
            bubbleSize.height += 60;
            break;
        }
        case XHBubbleMessageMediaTypeEmotion:
            // 是否固定大小呢？
            bubbleSize = CGSizeMake(100, 100);
            break;
        case XHBubbleMessageMediaTypeLocalPosition:
            // 固定大小，必须的
            bubbleSize = CGSizeMake(119, 119);
            break;
        default:
            break;
    }
    return bubbleSize;
}

#pragma mark - UIAppearance Getters

- (UIFont *)font {
    if (_font == nil) {
        _font = [[[self class] appearance] font];
    }
    
    if (_font != nil) {
        return _font;
    }
    
    return [UIFont systemFontOfSize:15.0f];
}

#pragma mark - Getters


- (CGRect)bubbleFrame
{
    CGSize bubbleSize = [XHMessageBubbleView getBubbleFrameWithMessage:self.message];
    return CGRectIntegral(CGRectMake((self.message.bubbleMessageType == XHBubbleMessageTypeSending ? CGRectGetWidth(self.bounds) - bubbleSize.width : 0.0f),
                                     kMarginTop,
                                     bubbleSize.width,
                                     bubbleSize.height + kMarginTop + kMarginBottom));
}

#pragma mark -
#pragma mark TQRichTextViewDelegate

#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.superParentViewController.shouldPreventAutoScrolling = YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.superParentViewController.shouldPreventAutoScrolling = NO;
}
#pragma mark - Life cycle

- (void)configureCellWithMessage:(id <XHMessageModel>)message {
    _message = message;
    
    [self configureBubbleImageView:message];
    
    [self configureMessageDisplayMediaWithMessage:message];
    
}

- (void)configureBubbleImageView:(id <XHMessageModel>)message {
    XHBubbleMessageMediaType currentType = [message messageMediaType];
    
    _voiceDurationLabel.hidden = YES;
    switch (currentType) {
        case XHBubbleMessageMediaTypeVoice:
        {
            _voiceDurationLabel.hidden = NO;
        }
        case XHBubbleMessageMediaTypeText:
        case XHBubbleMessageMediaTypePurchaseMedicine:
        case XHBubbleMessageMediaTypeStarStore:
        case XHBubbleMessageMediaTypeStarClient:
        case XHBubbleMessageMediaTypeEmotion: {
            if( currentType == XHBubbleMessageMediaTypeStarStore)
            {
                if([message isMarked])
                {
                    self.remarkLabel.hidden = YES;
                }else{
                    self.remarkLabel.hidden = NO;
                }
            }else{
                self.remarkLabel.hidden = YES;
            }
            if([message officialType]){
                _bubbleImageView.image = [XHMessageBubbleFactory bubbleImageViewForOfficialType:message.bubbleMessageType];
            }else{
                _bubbleImageView.image = [XHMessageBubbleFactory bubbleImageViewForType:message.bubbleMessageType style:XHBubbleImageViewStyleWeChat meidaType:message.messageMediaType];
            }
            // 只要是文本、语音、第三方表情，背景的气泡都不能隐藏
            _bubbleImageView.hidden = NO;
            _checkButton.hidden = YES;
            // 只要是文本、语音、第三方表情，都需要把显示尖嘴图片的控件隐藏了
            _bubblePhotoImageView.hidden = YES;
            self.activityContent.hidden = YES;
            self.activityImage.hidden = YES;
            self.activityTitle.hidden = YES;
            _footGuide.hidden = YES;
            if (currentType == XHBubbleMessageMediaTypeText || currentType == XHBubbleMessageMediaTypeStarStore || currentType == XHBubbleMessageMediaTypeStarClient || currentType == XHBubbleMessageMediaTypePurchaseMedicine) {
                // 如果是文本消息，那文本消息的控件需要显示
                _displayTextView.hidden = NO;
                // 那语言的gif动画imageView就需要隐藏了
                _animationVoiceImageView.hidden = YES;
                
            } else {
                // 那如果不文本消息，必须把文本消息的控件隐藏了啊
                _displayTextView.hidden = YES;
                
                // 对语音消息的进行特殊处理，第三方表情可以直接利用背景气泡的ImageView控件
                if (currentType == XHBubbleMessageMediaTypeVoice) {
                    [_animationVoiceImageView removeFromSuperview];
                    _animationVoiceImageView = nil;
                    
                    UIImageView *animationVoiceImageView = [XHMessageVoiceFactory messageVoiceAnimationImageViewWithBubbleMessageType:message.bubbleMessageType];
                    [self addSubview:animationVoiceImageView];
                    _animationVoiceImageView = animationVoiceImageView;
                    _animationVoiceImageView.hidden = NO;
                } else {
                    _animationVoiceImageView.hidden = YES;
                }
            }
            break;
        }
        case XHBubbleMessageMediaTypeAutoSubscription:
        case XHBubbleMessageMediaTypeDrugGuide:
        {
            // 只要是文本、语音、第三方表情，背景的气泡都不能隐藏
            _bubbleImageView.hidden = NO;
            self.remarkLabel.hidden = YES;
            // 只要是文本、语音、第三方表情，都需要把显示尖嘴图片的控件隐藏了
            _bubblePhotoImageView.hidden = YES;
            self.activityContent.hidden = YES;
            self.activityImage.hidden = YES;
            self.activityTitle.hidden = YES;
            self.ratingView.hidden = YES;
            self.serviceLabel.hidden = YES;
            if([message officialType]){
                _bubbleImageView.image = [XHMessageBubbleFactory bubbleImageViewForOfficialType:message.bubbleMessageType];
            }else{
                _bubbleImageView.image = [XHMessageBubbleFactory bubbleImageViewForType:message.bubbleMessageType style:XHBubbleImageViewStyleWeChat meidaType:message.messageMediaType];
            }
            if(currentType == XHBubbleMessageMediaTypeDrugGuide) {
                self.activityTitle.hidden = NO;
                _checkButton.hidden = YES;
                _footGuide.hidden = NO;
            }else{
                self.activityTitle.hidden = YES;
                _checkButton.hidden = NO;
                _footGuide.hidden = YES;
            }
            break;
        }
        case XHBubbleMessageMediaTypeLocation:
        {
            _checkButton.hidden = YES;
            _footGuide.hidden = YES;
            _bubbleImageView.image = [XHMessageBubbleFactory bubbleImageViewForType:message.bubbleMessageType style:XHBubbleImageViewStyleWeChat meidaType:message.messageMediaType];
            // 只要是文本、语音、第三方表情，背景的气泡都不能隐藏
            _bubbleImageView.hidden = NO;
            _bubblePhotoImageView.hidden = YES;
            _displayTextView.hidden = YES;
            
            self.activityContent.hidden = NO;
            self.activityImage.hidden = NO;
            self.activityTitle.hidden = YES;
            
            self.ratingView.hidden = YES;
            self.serviceLabel.hidden = YES;
            break;
        }
        case XHBubbleMessageMediaTypeActivity:
        {
            self.remarkLabel.hidden = YES;
            _footGuide.hidden = YES;
            _checkButton.hidden = YES;
            if([message officialType]){
                _bubbleImageView.image = [XHMessageBubbleFactory bubbleImageViewForOfficialType:message.bubbleMessageType];
            }else{
                _bubbleImageView.image = [XHMessageBubbleFactory bubbleImageViewForType:message.bubbleMessageType style:XHBubbleImageViewStyleWeChat meidaType:message.messageMediaType];
            }
            // 只要是文本、语音、第三方表情，背景的气泡都不能隐藏
            _bubbleImageView.hidden = NO;
            _bubblePhotoImageView.hidden = YES;
            _displayTextView.hidden = YES;
            self.activityContent.hidden = NO;
            self.activityImage.hidden = NO;
            self.activityTitle.hidden = NO;
            self.ratingView.hidden = YES;
            self.serviceLabel.hidden = YES;
            
            
            break;
        }
        default:
            break;
    }
}

- (void)configureMessageDisplayMediaWithMessage:(id <XHMessageModel>)message {
    switch (message.messageMediaType) {
        case XHBubbleMessageMediaTypeText:
        case XHBubbleMessageMediaTypeStarStore:
        case XHBubbleMessageMediaTypeStarClient:
        case XHBubbleMessageMediaTypePurchaseMedicine:
        {
            [_displayTextView setEmojiText:[message text]];
            NSArray *tagList = [message tagList];
            if(tagList)
                [_displayTextView addLinkTags:tagList];
            self.footGuide.emojiText = [NSString stringWithFormat:@"根据您的用药为您推送"];
//            if([message title])
//            {
//                NSDictionary *tag = [message tagList][0];
//                NSDictionary *tagDict = @{@"start":@"6",
//                                          @"length":[NSNumber numberWithInteger:self.footGuide.emojiText.length - 10],
//                                          @"tagId":tag[@"tagId"],
//                                          @"tagType":@"1"
//                                          };
//                [self.footGuide addLinkTags:@[tagDict]];
//            }
            break;
        }
        case XHBubbleMessageMediaTypeAutoSubscription:
        case XHBubbleMessageMediaTypeDrugGuide:
        {
            self.activityTitle.textColor = APP_COLOR_STYLE;
            self.activityTitle.userInteractionEnabled = YES;
            
            [_displayTextView setEmojiText:[message text]];
            NSArray *tagList = [message tagList];
            [_displayTextView addLinkTags:tagList];
    
            self.activityTitle.text = [message title];
//            [self.activityTitle setTitle:@"1213123123yfiu3hfiuh3rfgiuh3giufh3quihkhkhkhkhkhkjhkjhkhkhkuhkuhkugh3ruig3iugh3rv" forState:UIControlStateNormal];
            if(tagList)
                [_displayTextView addLinkTags:tagList];
            self.footGuide.emojiText = [NSString stringWithFormat:@"根据您的用药为您推送"];

            break;
        }
        case XHBubbleMessageMediaTypePhoto:
            [_bubblePhotoImageView configureMessagePhoto:message.photo thumbnailUrl:message.thumbnailUrl originPhotoUrl:message.originPhotoUrl onBubbleMessageType:self.message.bubbleMessageType];
            break;
        case XHBubbleMessageMediaTypeEmotion:
            // 直接设置GIF
            if (message.emotionPath) {
                _bubbleImageView.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL fileURLWithPath:message.emotionPath]];
            }
            break;
        case XHBubbleMessageMediaTypeLocalPosition:
            [_bubblePhotoImageView configureMessagePhoto:message.localPositionPhoto thumbnailUrl:nil originPhotoUrl:nil onBubbleMessageType:self.message.bubbleMessageType];
            
            _geolocationsLabel.text = message.geolocations;
            break;
        case XHBubbleMessageMediaTypeActivity:
            case XHBubbleMessageMediaTypeLocation:
        {
            self.activityTitle.textColor = [UIColor blackColor];
            self.activityTitle.userInteractionEnabled = NO;
            self.activityTitle.text = message.title;
            self.activityContent.text = message.text;

            
            self.activityImage.image = nil;
            if(message.messageMediaType == XHBubbleMessageMediaTypeActivity) {
                self.activityContent.numberOfLines = 4;
                if(message.activityUrl == nil || [message.activityUrl isEqualToString:@""]){
                    self.activityImage.hidden = YES;
                }else{
                    self.activityImage.hidden = NO;
                    [self.activityImage setImageWithURL:[NSURL URLWithString:message.activityUrl] placeholderImage:[UIImage imageNamed:@"药品默认图片.png"]];
                }
            }else{
                self.activityContent.numberOfLines = 2;
                self.activityImage.hidden = NO;
                [self.activityImage setImage:[UIImage imageNamed:@"mapIcon.png"]];
            }
            break;
        }
        default:
            break;
    }
    
    [self setNeedsLayout];
}

- (void)setSendType:(SendType)sendType
{
    _sendType = sendType;
    CGRect rect = self.bubbleImageView.frame;
    
    switch (sendType) {
        case Sending:
        {
            if([[self message] bubbleMessageType] == XHBubbleMessageTypeReceiving){
                rect.origin.x += rect.size.width + 10;
            }else{
                rect.origin.x -= 25;
            }
            rect.origin.y += rect.size.height / 2 - 7.5;
            rect.size.width = 15;
            rect.size.height = 15;
            
            [self.activityView startAnimating];
            [self bringSubviewToFront:self.activityView];
            self.activityView.frame = rect;
            break;
        }
        case SendFailure:
        {
            rect.origin.x -= 40;
            rect.origin.y += rect.size.height / 2 - 20;
            rect.size.width = 40;
            rect.size.height = 40;
            
            self.resendButton.hidden = NO;
            [self bringSubviewToFront:self.resendButton];
            self.resendButton.frame = rect;
            break;
        }
        case Sended:
        default:{
            [self.activityView stopAnimating];
            self.resendButton.hidden = YES;
            break;
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame
                      message:(id <XHMessageModel>)message {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _message = message;
        
        // 1、初始化气泡的背景
        if (!_bubbleImageView) {
            //bubble image
            UIImageView *bubbleImageView = [[UIImageView alloc] init];
            bubbleImageView.frame = self.bounds;
            bubbleImageView.userInteractionEnabled = YES;
            [self addSubview:bubbleImageView];
            _bubbleImageView = bubbleImageView;
        }
        
        // 2、初始化显示文本消息的TextView
        if (!_displayTextView) {
            MLEmojiLabel *displayTextView = [[MLEmojiLabel alloc] init];
            displayTextView.numberOfLines = 0;
            //displayTextView.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
            displayTextView.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
            displayTextView.disableThreeCommon = YES;
            displayTextView.customEmojiPlistName = @"expressionImage_custom.plist";
            displayTextView.font = [UIFont systemFontOfSize:15.0f];
            displayTextView.emojiDelegate = self;
            displayTextView.backgroundColor = [UIColor clearColor];
            displayTextView.lineBreakMode = NSLineBreakByCharWrapping;
            displayTextView.isNeedAtAndPoundSign = YES;
            [self addSubview:displayTextView];
            _displayTextView = displayTextView;
        }
        
        // 3、初始化显示图片的控件
        if (!_bubblePhotoImageView) {
            XHBubblePhotoImageView *bubblePhotoImageView = [[XHBubblePhotoImageView alloc] initWithFrame:CGRectZero];
            [self addSubview:bubblePhotoImageView];
            _bubblePhotoImageView = bubblePhotoImageView;
            
            if (!_videoPlayImageView) {
                UIImageView *videoPlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MessageVideoPlay"]];
                [bubblePhotoImageView addSubview:videoPlayImageView];
                _videoPlayImageView = videoPlayImageView;
            }
            
            if (!_geolocationsLabel) {
                UILabel *geolocationsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                geolocationsLabel.numberOfLines = 0;
                geolocationsLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                geolocationsLabel.textColor = [UIColor whiteColor];
                geolocationsLabel.backgroundColor = [UIColor clearColor];
                geolocationsLabel.font = [UIFont systemFontOfSize:12];
                [bubblePhotoImageView addSubview:geolocationsLabel];
                _geolocationsLabel = geolocationsLabel;
            }
        }
        
        //4、初始化显示语音时长的label
        if (!_voiceDurationLabel) {
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 30, 30)];
            lbl.textColor = [UIColor lightGrayColor];
            lbl.backgroundColor = [UIColor clearColor];
            lbl.font = [UIFont systemFontOfSize:13.f];
            lbl.textAlignment = NSTextAlignmentRight;
            lbl.hidden = YES;
            [self addSubview:lbl];
            self.voiceDurationLabel = lbl;
        }
        
        if(!_ratingView) {
            self.ratingView = [[RatingView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
            [self.ratingView setImagesDeselected:@"star_none_medium.png" partlySelected:@"star_half_medium.png" fullSelected:@"star_full_medium.png" andDelegate:nil];
            [self.ratingView setBackgroundColor:[UIColor clearColor]];
            self.ratingView.userInteractionEnabled = NO;
        }

        self.ratingView.hidden = YES;
        self.resendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.resendButton.frame = CGRectMake(0, 0, 40, 40);
        [self.resendButton setImage:[UIImage imageNamed:@"发送失败图标.png"] forState:UIControlStateNormal];
        self.resendButton.hidden = YES;
        [self addSubview:self.resendButton];
        self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        self.activityView.color = [UIColor grayColor];
        self.activityView.hidesWhenStopped = YES;

        self.serviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 25)];
        self.serviceLabel.font = [UIFont systemFontOfSize:15.0];
        self.serviceLabel.text = @"服务打分:";
        self.serviceLabel.backgroundColor = [UIColor clearColor];
        self.serviceLabel.hidden = YES;

        [self addSubview:self.serviceLabel];
        [self addSubview:self.activityView];
        [self addSubview:self.ratingView];
        
        self.activityTitle = [[UILabel alloc] init];
        if([self.message messageMediaType] == XHBubbleMessageMediaTypeDrugGuide) {
            self.activityTitle.frame = CGRectMake(0, 0, 260, 45);
        }else{
            self.activityTitle.frame = CGRectMake(0, 0, 190, 45);
        }
        self.activityTitle.textAlignment =  
        self.activityTitle.font = [UIFont systemFontOfSize:16.0];
        self.activityTitle.numberOfLines = 2;
        self.activityTitle.textColor = APP_COLOR_STYLE;
        self.activityTitle.backgroundColor = [UIColor clearColor];

        [self addSubview:self.activityTitle];
        self.activityTitle.hidden = YES;

        self.remarkLabel = [[UILabel alloc] init];
        self.remarkLabel.frame = CGRectMake(148,22.5, 190, 45);
        self.remarkLabel.text = @"立即评价";
        self.remarkLabel.font = [UIFont systemFontOfSize:14.0];
        self.remarkLabel.textColor = [UIColor blueColor];
        self.remarkLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.remarkLabel];
        self.remarkLabel.hidden = YES;
        
        
        self.activityContent = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 125, 65)];
        self.activityContent.font = [UIFont systemFontOfSize:13.0];
        self.activityContent.numberOfLines = 4;
        self.activityContent.backgroundColor = [UIColor clearColor];
        [self addSubview:self.activityContent];
        self.activityContent.hidden = YES;

        self.activityImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 55, 55)];
        [self addSubview:self.activityImage];
        self.activityImage.hidden = YES;

        //慢病订阅立即查看按钮
        self.checkButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.checkButton setTitle:@"立即去查看" forState:UIControlStateNormal];
        self.checkButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        self.checkButton.titleLabel.textColor = [UIColor blueColor];
        self.checkButton.backgroundColor = [UIColor clearColor];
        self.checkButton.frame = CGRectMake(160, 0, 80, 20);
        [self addSubview:self.checkButton];
        
        //用药指导注标
        if([_message officialType]){
            self.footGuide = [[MLEmojiLabel alloc] initWithFrame:CGRectMake(-22, 0, APP_W * 0.8, 20)];
        }else{
            self.footGuide = [[MLEmojiLabel alloc] initWithFrame:CGRectMake(-22, 0, APP_W * 0.6, 20)];
        }
        self.footGuide.emojiDelegate = self;
        
        self.footGuide.textColor = UICOLOR(153, 153, 153);
        self.footGuide.font = [UIFont systemFontOfSize:12.0];
        [self addSubview:self.footGuide];
    }
    return self;
}


- (void)dealloc {
    _message = nil;
    
    _displayTextView = nil;
    
    _bubbleImageView = nil;
    
    _bubblePhotoImageView = nil;
    
    _animationVoiceImageView = nil;
    
    _voiceDurationLabel = nil;
    
    _videoPlayImageView = nil;
    
    _geolocationsLabel = nil;
    
    _font = nil;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    XHBubbleMessageMediaType currentType = self.message.messageMediaType;
    CGRect bubbleFrame = [self bubbleFrame];
    
    switch (currentType) {
        case XHBubbleMessageMediaTypeText:
        case XHBubbleMessageMediaTypeStarStore:
        case XHBubbleMessageMediaTypeStarClient:
        case XHBubbleMessageMediaTypePurchaseMedicine:
        case XHBubbleMessageMediaTypeEmotion:
        {
            CGRect bubbleFrameCopy = bubbleFrame;
            if([self.message officialType]) {
                bubbleFrameCopy.origin.x = -40;
            }
            bubbleFrameCopy.size.height = MAX(35, bubbleFrameCopy.size.height);
            self.bubbleImageView.frame = bubbleFrameCopy;
            CGFloat textX = CGRectGetMinX(bubbleFrame) + kBubblePaddingRight;
            
            if (self.message.bubbleMessageType == XHBubbleMessageTypeReceiving) {
                textX += kXHArrowMarginWidth  - 5;
            }
            CGRect textFrame = CGRectMake(textX,
                                          CGRectGetMinY(bubbleFrame) + kPaddingTop + 2,
                                          CGRectGetWidth(bubbleFrame) - kBubblePaddingRight * 2 - kXHArrowMarginWidth,
                                          bubbleFrame.size.height - kMarginTop - kMarginBottom);
            if(textFrame.size.height <= 30) {
                textFrame.origin.y += 3;
            }
            if([self.message officialType]) {
                textFrame.origin.x = -20;
            }
            self.displayTextView.frame = CGRectIntegral(textFrame);
            
            [self.displayTextView sizeToFit];
            
            CGRect animationVoiceImageViewFrame = self.animationVoiceImageView.frame;
            animationVoiceImageViewFrame.origin = CGPointMake((self.message.bubbleMessageType == XHBubbleMessageTypeReceiving ? (bubbleFrame.origin.x + kVoiceMargin) : (bubbleFrame.origin.x + CGRectGetWidth(bubbleFrame) - kVoiceMargin - CGRectGetWidth(animationVoiceImageViewFrame))), 17);
            self.animationVoiceImageView.frame = animationVoiceImageViewFrame;
            [self resetVoiceDurationLabelFrameWithBubbleFrame:bubbleFrame];
            if (currentType == XHBubbleMessageMediaTypeStarStore)
            {
                self.ratingView.hidden = NO;
                self.serviceLabel.hidden = YES;
                CGRect rect = self.ratingView.frame;
                [self.ratingView displayRating:5.0f];
                if (self.message.bubbleMessageType == XHBubbleMessageTypeReceiving) {
                    if(HIGH_RESOLUTION){
                        rect.origin.x = 35;
                    }
                    else{
                        rect.origin.x = 50;
                    }
                }else{
                    rect.origin.x = 45;
                }
                rect.origin.y = 36.5;
                self.ratingView.frame = rect;
                [self.ratingView displayRating:0.0];
                
            }else if (currentType == XHBubbleMessageMediaTypeStarClient) {
                self.ratingView.hidden = NO;
                
                self.serviceLabel.hidden = NO;
                CGRect rect = self.serviceLabel.frame;
                rect.origin.x = 51;
                rect.origin.y = 12;
                self.serviceLabel.frame = rect;
                
                rect = self.ratingView.frame;
                rect.origin.x = 135;
                rect.origin.y  = 16;
                self.ratingView.frame = rect;
                [self.ratingView displayRating:self.message.starMark];
                rect = self.displayTextView.frame;
                //[self.displayTextView setBackgroundColor:[UIColor yellowColor]];
                rect.origin.x = 51;
                rect.origin.y = 40;
                self.displayTextView.frame = rect;
       
            }else{
                self.serviceLabel.hidden = YES;
                self.ratingView.hidden = YES;
            }
            break;
        }
        case XHBubbleMessageMediaTypeLocation:
        {
            CGRect bubbleFrameCopy = bubbleFrame;
            bubbleFrameCopy.size.height = MAX(35, bubbleFrameCopy.size.height);
            self.bubbleImageView.frame = bubbleFrameCopy;
            CGFloat textX = CGRectGetMinX(bubbleFrame) + kBubblePaddingRight;
            
            if (self.message.bubbleMessageType == XHBubbleMessageTypeReceiving) {
                textX += kXHArrowMarginWidth  - 5;
            }
            CGRect textFrame = CGRectMake(textX,
                                          CGRectGetMinY(bubbleFrame) + kPaddingTop + 2,
                                          CGRectGetWidth(bubbleFrame) - kBubblePaddingRight * 2 - kXHArrowMarginWidth,
                                          bubbleFrame.size.height - kMarginTop - kMarginBottom);
            if(textFrame.size.height <= 30) {
                textFrame.origin.y += 3;
            }
            
            CGRect rect = CGRectZero;

           
            CGSize constrainedSize = CGSizeZero;
            if([self.message messageMediaType] == XHBubbleMessageMediaTypeDrugGuide) {
                constrainedSize = CGSizeMake(260, 45);
            }else{
                constrainedSize = CGSizeMake(190, 45);
            }

            rect = self.activityImage.frame;
            rect.origin.x = 21;
            rect.origin.y = 19.5;
            self.activityImage.frame = rect;
            
            rect = self.activityContent.frame;
            rect.origin.x = 90;
            rect.origin.y = 12.5;
            rect.size.width = 125;
            rect.size.height = 65;
            self.activityContent.frame = rect;
            
            break;
        }
        case XHBubbleMessageMediaTypeActivity:
        {
            CGRect bubbleFrameCopy = bubbleFrame;
            bubbleFrameCopy.size.height = MAX(35, bubbleFrameCopy.size.height);
            self.bubbleImageView.frame = bubbleFrameCopy;
            CGFloat textX = CGRectGetMinX(bubbleFrame) + kBubblePaddingRight;
            
            if (self.message.bubbleMessageType == XHBubbleMessageTypeReceiving) {
                textX += kXHArrowMarginWidth  - 5;
            }
            CGRect textFrame = CGRectMake(textX,
                                          CGRectGetMinY(bubbleFrame) + kPaddingTop + 2,
                                          CGRectGetWidth(bubbleFrame) - kBubblePaddingRight * 2 - kXHArrowMarginWidth,
                                          bubbleFrame.size.height - kMarginTop - kMarginBottom);
            if(textFrame.size.height <= 30) {
                textFrame.origin.y += 3;
            }
            
            CGRect rect = self.activityTitle.frame;
            rect.origin.x = 21;
            rect.origin.y = 14;
            self.activityTitle.frame = rect;
            
            if(self.message.activityUrl == nil || [self.message.activityUrl isEqualToString:@""])
            {
                CGSize constrainedSize = CGSizeZero;
                if([self.message messageMediaType] == XHBubbleMessageMediaTypeDrugGuide) {
                    constrainedSize = CGSizeMake(260, 45);
                }else{
                    constrainedSize = CGSizeMake(190, 45);
                }
                
                CGSize size = [[_message title] sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:constrainedSize];
                CGRect rect = self.activityTitle.frame;
                rect.size.height = ceilf(size.height);
                self.activityTitle.frame = rect;
                rect = self.activityContent.frame;
                
                rect.origin.x = 21;
                rect.origin.y = self.activityTitle.frame.origin.y + size.height + 4;
                CGSize textSize = [[self.message text] sizeWithFont:[UIFont systemFontOfSize:13.0f] constrainedToSize:CGSizeMake(0.6 * APP_W, 65)];
                rect.size = textSize;
                self.activityContent.frame = rect;
                
            }else{
                CGSize constrainedSize = CGSizeZero;
                if([self.message messageMediaType] == XHBubbleMessageMediaTypeDrugGuide) {
                    constrainedSize = CGSizeMake(260, 45);
                }else{
                    constrainedSize = CGSizeMake(190, 45);
                }
                
                CGSize size = [[_message title] sizeWithFont:[UIFont systemFontOfSize:16.0f] constrainedToSize:constrainedSize];
                CGRect rect = self.activityTitle.frame;
                rect.size.height = ceilf(size.height);
                self.activityTitle.frame = rect;
                rect = self.activityImage.frame;
                rect.origin.x = 21;
                rect.origin.y = self.activityTitle.frame.origin.y + size.height + 8;
                self.activityImage.frame = rect;
            
                rect = self.activityContent.frame;
                rect.origin.x = 90;
                rect.origin.y = self.activityTitle.frame.origin.y + size.height + 4;
                rect.size.width = 125;
                rect.size.height = 65;
                self.activityContent.frame = rect;
            }
            break;
        }
        case XHBubbleMessageMediaTypeDrugGuide:
        {
            if([_message officialType]) {
                bubbleFrame.origin.x = -40.0;
            }
            
            CGRect bubbleFrameCopy = bubbleFrame;
            bubbleFrameCopy.size.height = MAX(35, bubbleFrameCopy.size.height);
            self.bubbleImageView.frame = bubbleFrameCopy;
            CGFloat textX = CGRectGetMinX(bubbleFrame) + kBubblePaddingRight;
            
            if (self.message.bubbleMessageType == XHBubbleMessageTypeReceiving) {
                textX += kXHArrowMarginWidth  - 5;
            }
            if([_message officialType]) {
                CGRect titleFrame = self.activityTitle.frame;
                titleFrame.origin.x = textX;
                titleFrame.origin.y = 8;
                if([self.message messageMediaType] == XHBubbleMessageMediaTypeDrugGuide) {
                    titleFrame.size = CGSizeMake(260, 45);
                }else{
                    titleFrame.size = CGSizeMake(190, 45);
                }
                self.activityTitle.frame = titleFrame;
                CGRect footFrame = self.footGuide.frame;
                footFrame.origin.y = bubbleFrameCopy.origin.y + bubbleFrameCopy.size.height - 26.5;
                self.footGuide.frame = footFrame;
            }else{
                CGRect titleFrame = self.activityTitle.frame;
                if([self.message messageMediaType] == XHBubbleMessageMediaTypeDrugGuide) {
                    titleFrame.size = CGSizeMake(260, 45);
                }else{
                    titleFrame.size = CGSizeMake(190, 45);
                }
                titleFrame.origin.x = 20;
                titleFrame.origin.y = 8;
                self.activityTitle.frame = titleFrame;
                
                CGRect footFrame = self.footGuide.frame;
                footFrame.origin.y = bubbleFrameCopy.origin.y + bubbleFrameCopy.size.height - 26.5;
                footFrame.origin.x = 20;
                self.footGuide.frame = footFrame;
                
            }
            CGRect textFrame = CGRectMake(textX,
                                          CGRectGetMinY(bubbleFrame) + kPaddingTop + 30,
                                          CGRectGetWidth(bubbleFrame) - kBubblePaddingRight * 2 - kXHArrowMarginWidth,
                                          bubbleFrame.size.height - kMarginTop - kMarginBottom);
            if(textFrame.size.height <= 30) {
                textFrame.origin.y += 3;
            }
            textFrame.origin.y += 10;
            self.displayTextView.frame = CGRectIntegral(textFrame);
            [self.displayTextView sizeToFit];
            
            
            break;
        }
        case XHBubbleMessageMediaTypeAutoSubscription:
        {
            bubbleFrame.origin.x = -40.0;
            CGRect bubbleFrameCopy = bubbleFrame;

            bubbleFrameCopy.size.height = MAX(35, bubbleFrameCopy.size.height);
            self.bubbleImageView.frame = bubbleFrameCopy;
            CGFloat textX = CGRectGetMinX(bubbleFrame) + kBubblePaddingRight;
            
            if (self.message.bubbleMessageType == XHBubbleMessageTypeReceiving) {
                textX += kXHArrowMarginWidth  - 5;
            }
            CGRect textFrame = CGRectMake(textX,
                                          CGRectGetMinY(bubbleFrame) + kPaddingTop + 2,
                                          CGRectGetWidth(bubbleFrame) - kBubblePaddingRight * 2 - kXHArrowMarginWidth,
                                          bubbleFrame.size.height - kMarginTop - kMarginBottom);
            if(textFrame.size.height <= 30) {
                textFrame.origin.y += 3;
            }
            self.displayTextView.frame = CGRectIntegral(textFrame);
            [self.displayTextView sizeToFit];
            CGRect buttonFrame = self.checkButton.frame;
            buttonFrame.origin.y = bubbleFrameCopy.origin.y + bubbleFrameCopy.size.height - 25;
            self.checkButton.frame = buttonFrame;
            
            break;
        }
        case XHBubbleMessageMediaTypePhoto:
        case XHBubbleMessageMediaTypeLocalPosition: {
            self.ratingView.hidden = YES;
            CGRect photoImageViewFrame = CGRectMake(bubbleFrame.origin.x - 2, 0, bubbleFrame.size.width, bubbleFrame.size.height);
            self.bubblePhotoImageView.frame = photoImageViewFrame;
            
            self.videoPlayImageView.center = CGPointMake(CGRectGetWidth(photoImageViewFrame) / 2.0, CGRectGetHeight(photoImageViewFrame) / 2.0);
            
            CGRect geolocationsLabelFrame = CGRectMake(11, CGRectGetHeight(photoImageViewFrame) - 47, CGRectGetWidth(photoImageViewFrame) - 20, 40);
            self.geolocationsLabel.frame = geolocationsLabelFrame;
            
            break;
        }
        default:
            break;
    }
    [self setSendType:self.sendType];
}

- (void)resetVoiceDurationLabelFrameWithBubbleFrame:(CGRect)bubbleFrame {
    CGRect voiceFrame = _voiceDurationLabel.frame;
    voiceFrame.origin.x = (self.message.bubbleMessageType == XHBubbleMessageTypeSending ? bubbleFrame.origin.x - _voiceDurationLabel.frame.size.width : bubbleFrame.origin.x + bubbleFrame.size.width);
    _voiceDurationLabel.frame = voiceFrame;
    
    _voiceDurationLabel.textAlignment = (self.message.bubbleMessageType == XHBubbleMessageTypeSending ? NSTextAlignmentRight : NSTextAlignmentLeft);
}

@end
