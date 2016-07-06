//
//  TYVideoPlayer.h
//  TYVideoPlayerDemo
//
//  Created by tany on 16/6/21.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVPlayer+TYPlayer.h"
#import "TYVideoPlayerTrack.h"
#import "TYPlayerLayerView.h"

// 播放错误码
typedef NS_ENUM(NSUInteger, TYVideoPlayerErrorCode) {
    // The video was flagged as blocked due to licensing restrictions (geo or device).
    kVideoPlayerErrorVideoBlocked = 900,
    // There was an error fetching the stream.
    kVideoPlayerErrorFetchStreamError,
    // Could not find the stream type for video.
    kVideoPlayerErrorStreamNotFound,
    // There was an error loading the video as an asset.
    kVideoPlayerErrorAssetLoadError,
    // There was an error loading the video's duration.
    kVideoPlayerErrorDurationLoadError,
    // AVPlayer failed to load the asset.
    kVideoPlayerErrorAVPlayerFail,
    // AVPlayerItem failed to load the asset.
    kVideoPlayerErrorAVPlayerItemFail,
    // AVPlayerItem failed to play end
    kVideoPlayerErrorAVPlayerItemEndFail,
    // There was an unknown error.
    kVideoPlayerErrorUnknown,
};// this errcode quote VKVideoPlayerErrorCode

// 播放超时
typedef NS_ENUM(NSUInteger, TYVideoPlayerTimeOut) {
    // 开始加载超时
    TYVideoPlayerTimeOutLoad,
    // seek超时
    TYVideoPlayerTimeOutSeek,
    // 卡顿超时
    TYVideoPlayerTimeOutBuffer,
};

// 播放状态
typedef NS_ENUM(NSUInteger, TYVideoPlayerState) {
    // 未知
    TYVideoPlayerStateUnknown,
    // 初始化加载中
    TYVideoPlayerStateContentLoading,
    // 准备播放
    TYVideoPlayerStateContentReadyToPlay,
    // 播放
    TYVideoPlayerStateContentPlaying,
    // 暂停播放
    TYVideoPlayerStateContentPaused,
    // 暂停卡顿缓冲中
    TYVideoPlayerStateBuffering,
    // seek
    TYVideoPlayerStateSeeking,
    // 停止播放
    TYVideoPlayerStateStopped,
    // 失败
    TYVideoPlayerStateError
};

@class TYVideoPlayer;

// 视频播放代理
@protocol TYVideoPlayerDelegate <NSObject>

@optional

// 是否应该播放
- (BOOL)videoPlayer:(TYVideoPlayer*)videoPlayer shouldPlayTrack:(id<TYVideoPlayerTrack>)track;

// 将要播放
- (BOOL)videoPlayer:(TYVideoPlayer*)videoPlayer willPlayTrack:(id<TYVideoPlayerTrack>)track;

// 播放完成
- (BOOL)videoPlayer:(TYVideoPlayer*)videoPlayer didEndToPlayTrack:(id<TYVideoPlayerTrack>)track;

// 是否应该改变状态
- (BOOL)videoPlayer:(TYVideoPlayer*)videoPlayer shouldChangeToState:(TYVideoPlayerState)toState;

// 将要改变状态
- (void)videoPlayer:(TYVideoPlayer*)videoPlayer track:(id<TYVideoPlayerTrack>)track willChangeToState:(TYVideoPlayerState)toState;

// 已经改变状态
- (void)videoPlayer:(TYVideoPlayer*)videoPlayer track:(id<TYVideoPlayerTrack>)track didChangeFromState:(TYVideoPlayerState)fromState;

// 播放时间定时更新（s）
- (void)videoPlayer:(TYVideoPlayer*)videoPlayer track:(id<TYVideoPlayerTrack>)track didUpdatePlayTime:(NSTimeInterval)playTime;

// 播放超时
- (void)videoPlayer:(TYVideoPlayer *)videoPlayer track:(id<TYVideoPlayerTrack>)track receivedTimeout:(TYVideoPlayerTimeOut)timeout;

// 播放出错
- (void)videoPlayer:(TYVideoPlayer*)videoPlayer track:(id<TYVideoPlayerTrack>)track receivedErrorCode:(TYVideoPlayerErrorCode)errorCode error:(NSError *)error;


@end

// 视频播放类
@interface TYVideoPlayer : NSObject

@property (nonatomic, strong, readonly) AVPlayer *player;

@property (nonatomic, strong, readonly) AVPlayerItem* playerItem;

@property (nonatomic, strong, readonly) id<TYVideoPlayerTrack> track;

@property (nonatomic, weak, readonly) UIView<TYPlayerLayer> *playerLayer;

@property (nonatomic, assign, readonly) TYVideoPlayerState state;

@property (nonatomic, weak) id<TYVideoPlayerDelegate> delegate;

- (instancetype)initWithPlayerLayer:(UIView<TYPlayerLayer> *)playerLayer;

- (void)loadVideoWithStreamURL:(NSURL *)streamURL;

- (void)loadVideoWithStreamURL:(NSURL *)streamURL playerLayer:(UIView<TYPlayerLayer> *)playerLayer;

- (void)loadVideoWithTrack:(id<TYVideoPlayerTrack>)track;

- (void)loadVideoWithTrack:(id<TYVideoPlayerTrack>)track playerLayer:(UIView<TYPlayerLayer> *)layerView;

- (void)reloadCurrentVideoTrack;

- (BOOL)isPlaying;

- (void)play;

- (void)pause;

// stop will clear videoPlayer, so you need loadVideoWithTrack
- (void)stop;

- (void)seekToTime:(NSTimeInterval)time;

- (void)setRate:(float)rate;

- (NSTimeInterval)currentTime;

- (NSTimeInterval)currentDuration;

@end
