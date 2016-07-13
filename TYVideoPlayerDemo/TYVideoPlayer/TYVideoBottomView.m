//
//  TVPlayerBottomView.m
//  AVPlayerDemo
//
//  Created by tanyang on 15/11/18.
//  Copyright © 2015年 tanyang. All rights reserved.
//

#import "TYVideoBottomView.h"

@interface TYVideoBottomView ()
@property (nonatomic, weak) UILabel *curTimeLabel;
@property (nonatomic, weak) UILabel *totalTimeLabel;
@property (nonatomic, weak) UIButton *fullScreenBtn;
@property (nonatomic, weak) UISlider *progressSlider;
@end

#define kButtonHeight 20
#define kTimeLabelWidth 46
#define kViewHorizenlSpace 10

@implementation TYVideoBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addCurrentTimeLabel];
        
        [self addTotalTimeLabel];
        
        [self addFullScreenBtn];
        
        [self addProgressSlider];
    }
    return self;
}

- (void)addCurrentTimeLabel
{
    UILabel *curTimeLabel = [[UILabel alloc]init];
    curTimeLabel.textColor = [UIColor whiteColor];
    curTimeLabel.font = [UIFont systemFontOfSize:11];
    curTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:curTimeLabel];
    _curTimeLabel = curTimeLabel;
}

- (void)addTotalTimeLabel
{
    UILabel *totalTimeLabel = [[UILabel alloc]init];
    totalTimeLabel.textColor = [UIColor whiteColor];
    totalTimeLabel.font = [UIFont systemFontOfSize:11];
    totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:totalTimeLabel];
    _totalTimeLabel = totalTimeLabel;
}

- (void)addFullScreenBtn
{
    UIButton *fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [fullScreenBtn setImage:[UIImage imageNamed:@"miniplayer_fullsize"] forState:UIControlStateNormal];
    [self addSubview:fullScreenBtn];
    _fullScreenBtn = fullScreenBtn;
}

- (void)addProgressSlider
{
    UISlider *progressSlider = [[UISlider alloc]init];
    progressSlider.minimumTrackTintColor = [UIColor colorWithRed:252/225. green:110/255. blue:102/255. alpha:1.0];
    [progressSlider setThumbImage:[UIImage imageNamed:@"fullplayer_point"] forState:UIControlStateNormal];
    [self addSubview:progressSlider];
    _progressSlider = progressSlider;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _curTimeLabel.frame = CGRectMake(0, 0, kTimeLabelWidth, kButtonHeight);
    
    _fullScreenBtn.frame = CGRectMake(CGRectGetWidth(self.frame) - kButtonHeight - kViewHorizenlSpace, 0, kButtonHeight, kButtonHeight);
    
    _totalTimeLabel.frame = CGRectMake(CGRectGetMinX(_fullScreenBtn.frame) - kTimeLabelWidth, 0, kTimeLabelWidth, kButtonHeight);
    
    _progressSlider.frame = CGRectMake(CGRectGetMaxX(_curTimeLabel.frame), 0, CGRectGetMinX(_totalTimeLabel.frame) - CGRectGetMaxX(_curTimeLabel.frame), kButtonHeight);
}

@end
