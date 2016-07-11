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

@property (nonatomic, assign) BOOL isDragSlider;
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
    [bottomView.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView.progressSlider addTarget:self action:@selector(sliderBeginDraging:) forControlEvents:UIControlEventTouchDown];
    [bottomView.progressSlider addTarget:self action:@selector(sliderEndDraging:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
    [self addSubview:bottomView];
    _bottomView = bottomView;
}

- (void)addSuspendButton
{
    UIButton *suspendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    suspendBtn.frame = CGRectMake(0, 0, kSuspendBtnHeight, kSuspendBtnHeight);
    suspendBtn.adjustsImageWhenHighlighted = NO;
    [suspendBtn setBackgroundImage:[UIImage imageNamed:@"pause-butt"] forState:UIControlStateNormal];
    [suspendBtn setBackgroundImage:[UIImage imageNamed:@"play-butt"] forState:UIControlStateSelected];
    [suspendBtn addTarget:self action:@selector(suspendAction:) forControlEvents:UIControlEventTouchUpInside];
    suspendBtn.selected = YES;
    [self addSubview:suspendBtn];
    _suspendBtn = suspendBtn;
}

#pragma mark - action

- (void)sliderBeginDraging:(UISlider *)sender
{
    _isDragSlider = YES;
    NSLog(@"sliderBeginDraging");
}

- (void)sliderEndDraging:(UISlider *)sender
{
    NSLog(@"sliderEndDraging");
    //_isDragSlider = NO;
    if ([_delegate respondsToSelector:@selector(videoControlView:sliderToProgress:)]) {
        [_delegate videoControlView:self sliderToProgress:sender.value];
    }
}

- (void)fullScreenAction:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(videoControlView:recieveControlEvent:)]) {
        [_delegate videoControlView:self recieveControlEvent:TVVideoControlEventFullScreen];
    }
}

- (void)backAction:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(videoControlView:recieveControlEvent:)]) {
        [_delegate videoControlView:self recieveControlEvent:TVVideoControlEventBack];
    }
}

- (void)suspendAction:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(videoControlView:recieveControlEvent:)]) {
        [_delegate videoControlView:self recieveControlEvent:sender.isSelected ? TVVideoControlEventPlay:TVVideoControlEventSuspend];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _titleView.frame = CGRectMake(0, kTitleViewTopEdge, CGRectGetWidth(self.frame), kTitleViewHight);
    _bottomView.frame = CGRectMake(0, CGRectGetHeight(self.frame) - kBottomViewHeight - kBottomViewBottomEdge, CGRectGetWidth(self.frame), kBottomViewHeight);
    _suspendBtn.center = self.center;
}

@end
