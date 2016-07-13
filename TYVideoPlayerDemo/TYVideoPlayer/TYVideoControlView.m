//
//  TYPlayerControlView.m
//  TYVideoPlayerDemo
//
//  Created by tany on 16/7/5.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYVideoControlView.h"
#import "TYVideoTitleView.h"
#import "TYVideoBottomView.h"

#define kBackBtnHeight 35
#define kBackBtnTopEdage 12
#define kBackBtnLeftEdage 10
#define kTitleViewTopEdge 10
#define kTitleViewHight 25
#define kBottomViewBottomEdge 8
#define kBottomViewHeight 22
#define kSuspendBtnHeight 65

@interface TYVideoControlView ()
@property (nonatomic, weak) TYVideoTitleView *titleView;
@property (nonatomic, weak) TYVideoBottomView *bottomView;
@property (nonatomic, weak) UIButton *suspendBtn;

@end

@implementation TYVideoControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addTitleView];
        
        [self addBottomView];
        
        [self addSuspendButton];
        
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self addTitleView];
        
        [self addBottomView];
        
        [self addSuspendButton];
    }
    return self;
}

#pragma mark - add subvuew

- (void)addTitleView
{
    TYVideoTitleView *titleView = [[TYVideoTitleView alloc]init];
    [titleView.backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:titleView];
    _titleView = titleView;
}

- (void)addBottomView
{
    TYVideoBottomView *bottomView = [[TYVideoBottomView alloc]init];
    bottomView.curTimeLabel.text = @"00:00";
    bottomView.totalTimeLabel.text = @"00:00";
    [bottomView.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView.progressSlider addTarget:self action:@selector(sliderBeginDraging:) forControlEvents:UIControlEventTouchDown];
    [bottomView.progressSlider addTarget:self action:@selector(sliderIsDraging:) forControlEvents:UIControlEventValueChanged];
    [bottomView.progressSlider addTarget:self action:@selector(sliderEndDraging:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
    [self addSubview:bottomView];
    _bottomView = bottomView;
}

- (void)addSuspendButton
{
    UIButton *suspendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    suspendBtn.frame = CGRectMake(0, 0, kSuspendBtnHeight, kSuspendBtnHeight);
    suspendBtn.adjustsImageWhenHighlighted = NO;
    [suspendBtn setBackgroundImage:[UIImage imageNamed:@"pauseBig"] forState:UIControlStateNormal];
    [suspendBtn setBackgroundImage:[UIImage imageNamed:@"playBig"] forState:UIControlStateSelected];
    [suspendBtn addTarget:self action:@selector(suspendAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:suspendBtn];
    _suspendBtn = suspendBtn;
}

#pragma mark - pravite

- (BOOL)isOrientationPortrait
{
    return [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown;
}

- (void)recieveControlEvent:(TYVideoControlEvent)event
{
    if ([_delegate respondsToSelector:@selector(videoControlView:shouldResponseControlEvent:)]
        && ![_delegate videoControlView:self shouldResponseControlEvent:event]) {
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(videoControlView:recieveControlEvent:)]) {
        [_delegate videoControlView:self recieveControlEvent:event];
    }
}

#pragma mark - public

- (void)setTitle:(NSString *)title
{
    _titleView.titleLabel.text = title;
}

- (void)setCurrentVideoTime:(NSString *)time
{
    _bottomView.curTimeLabel.text = time;
}

- (void)setTotalVideoTime:(NSString *)time
{
    _bottomView.totalTimeLabel.text = time;
}

- (void)setSliderProgress:(CGFloat)progress
{
    _bottomView.progressSlider.value = progress;
}

- (void)setFullScreen:(BOOL)fullScreen
{
    _bottomView.fullScreenBtn.hidden = fullScreen;
}

#pragma mark - action

- (void)sliderBeginDraging:(UISlider *)sender
{
    NSLog(@"sliderBeginDraging");
    if ([_delegate respondsToSelector:@selector(videoControlView:state:sliderToProgress:)]) {
        [_delegate videoControlView:self state:TYSliderStateBegin sliderToProgress:sender.value];
    }
}

- (void)sliderIsDraging:(UISlider *)sender
{
    if ([_delegate respondsToSelector:@selector(videoControlView:state:sliderToProgress:)]) {
        [_delegate videoControlView:self state:TYSliderStateDraging sliderToProgress:sender.value];
    }
}

- (void)sliderEndDraging:(UISlider *)sender
{
    NSLog(@"sliderEndDraging");
    if ([_delegate respondsToSelector:@selector(videoControlView:state:sliderToProgress:)]) {
        [_delegate videoControlView:self state:TYSliderStateEnd sliderToProgress:sender.value];
    }
}

- (void)fullScreenAction:(UIButton *)sender
{
    [self recieveControlEvent:[self isOrientationPortrait] ? TYVideoControlEventFullScreen : TYVideoControlEventNormalScreen];
}

- (void)backAction:(UIButton *)sender
{
    [self recieveControlEvent:TYVideoControlEventBack];
}

- (void)suspendAction:(UIButton *)sender
{
    [self recieveControlEvent:sender.isSelected ? TYVideoControlEventPlay:TYVideoControlEventSuspend];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _titleView.frame = CGRectMake(0, kTitleViewTopEdge, CGRectGetWidth(self.frame), kTitleViewHight);
    _bottomView.frame = CGRectMake(0, CGRectGetHeight(self.frame) - kBottomViewHeight - kBottomViewBottomEdge, CGRectGetWidth(self.frame), kBottomViewHeight);
    _suspendBtn.center = self.center;
}

@end
