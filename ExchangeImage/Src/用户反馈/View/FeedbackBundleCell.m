//
//  FeedbackBundleCell.m
//  Jianjian
//
//  Created by admin on 15/4/9.
//  Copyright (c) 2015年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "FeedbackBundleCell.h"
#import "EIDefines.h"
#import "EIAvatarView.h"
#import "UIImageView+WebCache.h"
#import "EIUserCenter.h"

@interface FeedbackBundleCell()
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,strong)UILabel *contentLabel;
@property(nonatomic,strong)UIImageView *bundleBg;
@property(nonatomic,assign)CGFloat maxWidth;
@property(nonatomic,strong)EIAvatarView *avatar;
@end
@implementation FeedbackBundleCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle=UITableViewCellSelectionStyleNone;
    
    _avatar = [[EIAvatarView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.contentView addSubview:_avatar];
    
    _timeLabel=[[UILabel alloc] init];
    _timeLabel.font=[UIFont systemFontOfSize:12];
    _timeLabel.textColor=[UIColor lightGrayColor];
    _timeLabel.textAlignment=NSTextAlignmentCenter;
    [self.contentView addSubview:_timeLabel];
    
    _bundleBg=[[UIImageView alloc]init];

    [self.contentView addSubview:_bundleBg];
    
    _contentLabel=[[UILabel alloc] init];
    _contentLabel.font=[UIFont systemFontOfSize:14];
    _contentLabel.textColor=[UIColor blackColor];
    _contentLabel.textAlignment=NSTextAlignmentLeft;
    _contentLabel.lineBreakMode=NSLineBreakByCharWrapping;
    [self.bundleBg addSubview:_contentLabel];
    
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    self.backgroundColor = [UIColor clearColor];
    self.maxWidth = kScreen_Width * .6f;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _avatar = [[EIAvatarView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.contentView addSubview:_avatar];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor colorWithRed:172/255.0 green:174/255.0 blue:174/255.0 alpha:1.0];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_timeLabel];
    
    _bundleBg = [[UIImageView alloc]init];
    [self.contentView addSubview:_bundleBg];
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.font = [UIFont systemFontOfSize:16];
    _contentLabel.textColor = [UIColor blackColor];
    _contentLabel.textAlignment = NSTextAlignmentLeft;
    _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _contentLabel.numberOfLines = 0;
    [self.contentView addSubview:_contentLabel];
    
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setData:(NSDictionary *)dict
{
    [self calculateTime:[dict objectForKey:@"created_at"]];
    self.contentLabel.text=[dict objectForKey:@"content"];
    NSStringDrawingContext *ctx = [NSStringDrawingContext new];
    CGRect textRect = [self.contentLabel.text boundingRectWithSize: CGSizeMake(self.maxWidth, 10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.contentLabel.font} context:ctx];
    NSString *type=[dict objectForKey:@"type"];

    if ([type isEqualToString:@"dev_reply"]) {
        UIImage *image=[UIImage imageNamed:@"chat_bubble_left"];
        self.bundleBg.image=[image stretchableImageWithLeftCapWidth:20 topCapHeight:25];
        
        self.avatar.frame = CGRectMake(12, 20 + 20 -10, 40, 40);
        
        if (textRect.size.width<20) {
            textRect.size.width = 20;
        }
        
        self.contentLabel.frame=CGRectMake(20 + 12 + 40 , 20+20, textRect.size.width, textRect.size.height);
        self.contentLabel.textColor = [UIColor lightGrayColor];
        
        self.bundleBg.frame = CGRectMake(5 + 12 + 40, 20+20-10, textRect.size.width+25, textRect.size.height+20);
        
        [self.avatar setImage:[UIImage imageNamed:@"DefaultAvatar"] sex:[NSNumber numberWithInteger:0]];
    }
    else if([type isEqualToString:@"user_reply"])
    {
        UIImage *image = [UIImage imageNamed:@"chat_bubble_right"];
        self.bundleBg.image = [image stretchableImageWithLeftCapWidth:20 topCapHeight:25];
        
        self.avatar.frame = CGRectMake(kScreen_Width - 12 - 40, 20 + 20 - 10, 40, 40);
        
        if (textRect.size.width<20) {
            textRect.size.width = 20;
        }
        
        self.contentLabel.frame = CGRectMake(kScreen_Width-20-textRect.size.width - 12 - 40, 20+20, textRect.size.width, textRect.size.height);
        self.contentLabel.textColor = [UIColor lightGrayColor];
        
        self.bundleBg.frame = CGRectMake(kScreen_Width-20-textRect.size.width-10 - 12 - 40, 20+20-10, textRect.size.width+25, textRect.size.height+20);
        
        [self.avatar setImageUrl:[EIUserCenter sharedInstance].userAvatar sex:[NSNumber numberWithInteger:[EIUserCenter sharedInstance].userSex]];
    }
}
-(CGFloat)setMutiLineLabelText:(NSDictionary *)dict
{
    self.contentLabel.text = [dict objectForKey:@"content"];
    NSStringDrawingContext *ctx = [NSStringDrawingContext new];
    CGRect textRect = [self.contentLabel.text boundingRectWithSize: CGSizeMake(self.maxWidth, 10000000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.contentLabel.font} context:ctx];
    
    return textRect.size.height+20+20+20;
}
-(void)calculateTime:(NSString *)theDate
{
    
    NSDate *dat=[NSDate dateWithTimeIntervalSinceNow:0];
    
    NSTimeInterval now=[dat timeIntervalSince1970]*1000;
    
    NSTimeInterval cha=now-[theDate doubleValue];
    
    NSString *timeString=[[NSString alloc]init];
    
    
    //转换为日期
    NSDate *d=[NSDate dateWithTimeIntervalSince1970:[theDate doubleValue]/1000];
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    
    
    if (cha/300000<1) {
        timeString=@"刚刚";
    }
    else if (cha/300000>=1&&cha/3600000<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60000];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
    }
    else if (cha/3600000>=1&&cha/86400000<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600000];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }
    else if (cha/86400000>=1)
    {
        [formatter setDateFormat:@"yyyy"];
        NSString *newYear=[formatter stringFromDate:dat];
        NSString *theYear=[formatter stringFromDate:d];
        if ([newYear isEqualToString:theYear]) {
            [formatter setDateFormat:@"MM-dd"];
            timeString=[formatter stringFromDate:d];
        }
        else
        {
            timeString=theYear;
        }
        
    }
    self.timeLabel.text=timeString;
}
@end
