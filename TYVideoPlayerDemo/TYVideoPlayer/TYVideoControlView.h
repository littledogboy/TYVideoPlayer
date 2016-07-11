//
//  TYPlayerControlView.h
//  TYVideoPlayerDemo
//
//  Created by tany on 16/7/5.
//  Copyright © 2016年 tany. All rights reserved.
//  播放器控制层

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TVVideoControlEvent) {
    TVVideoControlEventBack,
    TVVideoControlEventNomarlScreen,
    TVVideoControlEventFullScreen,
    TVVideoControlEventPlay,
    TVVideoControlEventSuspend
};

@class TYVideoControlView;
@protocol TYVideoControlViewDelegate <NSObject>

@optional

- (void)videoControlView:(TYVideoControlView *)videoControlView recieveControlEvent:(TVVideoControlEvent)event;

- (void)videoControlView:(TYVideoControlView *)videoControlView sliderToProgress:(CGFloat)progress;

@end

@interface TYVideoControlView : UIView

@property (nonatomic, weak) id<TYVideoControlViewDelegate> delegate;

@end
