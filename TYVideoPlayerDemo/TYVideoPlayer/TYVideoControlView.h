//
//  TYPlayerControlView.h
//  TYVideoPlayerDemo
//
//  Created by tany on 16/7/5.
//  Copyright © 2016年 tany. All rights reserved.
//  播放器控制层

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TYVideoControlEvent) {
    TYVideoControlEventBack,
    TYVideoControlEventNormalScreen,
    TYVideoControlEventFullScreen,
    TYVideoControlEventPlay,
    TYVideoControlEventSuspend
};

typedef NS_ENUM(NSUInteger, TYSliderState) {
    TYSliderStateBegin,
    TYSliderStateDraging,
    TYSliderStateEnd,
};

@class TYVideoControlView;
@protocol TYVideoControlViewDelegate <NSObject>

@optional

- (BOOL)videoControlView:(TYVideoControlView *)videoControlView shouldResponseControlEvent:(TYVideoControlEvent)event;

- (void)videoControlView:(TYVideoControlView *)videoControlView recieveControlEvent:(TYVideoControlEvent)event;

- (void)videoControlView:(TYVideoControlView *)videoControlView state:(TYSliderState) state sliderToProgress:(CGFloat)progress;

@end

@interface TYVideoControlView : UIView

@property (nonatomic, weak, readonly) UIButton *suspendBtn;

@property (nonatomic, weak) id<TYVideoControlViewDelegate> delegate;

- (void)updateTotalVideoTime:(NSString *)time;

- (void)updateCurrentVideoTime:(NSString *)time;

@end
