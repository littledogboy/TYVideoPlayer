//
//  TYVideoPlayer.m
//  TYVideoPlayerDemo
//
//  Created by tany on 16/6/21.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYVideoPlayer.h"

#ifdef DEBUG
#   define TYDLog(fmt, ...) NSLog((@"%s [Line %d] \n" fmt), __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define TYDLog(...)
#endif

// 延迟执行
NS_INLINE void dispatch_delay_main_async_ty(NSTimeInterval delay, dispatch_block_t block)
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(),block);
}

// 主线程执行
NS_INLINE void dispatch_main_async_safe_ty(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

// player KVO
static NSString *const kTYVideoPlayerTracksKey = @"tracks";
static NSString *const kTYVideoPlayerPlayableKey = @"playable";
static NSString *const kTYVideoPlayerDurationKey = @"duration";

static NSString *const kTYVideoPlayerStatusKey = @"status";
static NSString *const kTYVideoPlayerBufferEmptyKey = @"playbackBufferEmpty";
static NSString *const kTYVideoPlayerLikelyToKeepUpKey = @"playbackLikelyToKeepUp";


@interface TYVideoPlayer () {
    BOOL _isFinishSeek;
    
    NSInteger _loadingTimeOut;
    NSInteger _seekingTimeOut;
    NSInteger _bufferingTimeOut;
}

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerItem* playerItem;

@property (nonatomic, strong) id<TYVideoPlayerTrack> track;

@property (nonatomic, weak) UIView<TYPlayerLayer> *playerLayer;

@property (nonatomic, assign) TYVideoPlayerState state;

@property (nonatomic, weak) AVURLAsset *URLAsset;

@property (nonatomic, strong) id timeObserver;

@end

@implementation TYVideoPlayer

- (instancetype)init
{
    if (self = [super init]) {
        
        [self configureVideoPlayer];
    }
    return self;
}

- (instancetype)initWithPlayerLayer:(UIView<TYPlayerLayer> *)playerLayer
{
    if (self = [super init]) {
        
        _playerLayer = playerLayer;
        
        [self configureVideoPlayer];
    }
    return self;
}

#pragma mark - configre player

- (void)configureVideoPlayer
{
    _bufferingTimeOut = 60;
    _seekingTimeOut = 60;
    _loadingTimeOut = 60;
    
    _state = TYVideoPlayerStateUnknown;
    
    [self addRouteObservers];
}

#pragma mark - setter

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    [self removePlayerItemObservers:_playerItem];
    
    _playerItem = playerItem;
    if (!playerItem) {
        return;
    }
    [self addPlayerItemObservers:playerItem];
    
}

- (void)setPlayer:(AVPlayer *)player
{
    self.timeObserver = nil;
    if (_player) {
        [_player replaceCurrentItemWithPlayerItem:nil];
        [_player removeObserver:self forKeyPath:@"status"];
    }
    
    _player = player;
    if (player) {
        [player addObserver:self forKeyPath:@"status" options:0 context:nil];
        [self addPlayerTimeObserver];
    }
}

- (void)setTimeObserver:(id)timeObserver
{
    if (_timeObserver) {
        [_player removeTimeObserver:_timeObserver];
    }
    _timeObserver = timeObserver;
}

- (void)setTrack:(id<TYVideoPlayerTrack>)track
{
    [self clearVideoPlayer];
    _track = track;
}

- (void)setState:(TYVideoPlayerState)state
{
    TYDLog(@"is MianThread %@",[NSThread isMainThread] ? @"YES":@"NO");
    // TODO
    if ([_delegate respondsToSelector:@selector(videoPlayer:shouldChangeToState:)]){
        if (![_delegate videoPlayer:self shouldChangeToState:state]) {
            TYDLog(@"shouldChangeToState NO");
            return;
        }
    }
    
    TYDLog(@"willChangeToState %@",[self descriptionState:state]);
    if ([_delegate respondsToSelector:@selector(videoPlayer:track:willChangeToState:)]) {
        [_delegate videoPlayer:self track:_track willChangeToState:state];
    }
    
    TYVideoPlayerState oldState = _state;
    if (oldState == state) {
        if (![self isPlaying] && state == TYVideoPlayerStateContentPlaying) {
            [self.player play];
        }
        return;
    }
    
    switch (oldState) {
        case TYVideoPlayerStateContentLoading:
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(URLAssetTimeOut) object:nil];
            break;
        case TYVideoPlayerStateSeeking:
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(seekingTimeOut) object:nil];
            break;
        case TYVideoPlayerStateBuffering:
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(bufferingTimeOut) object:nil];
            break;
        case TYVideoPlayerStateStopped:
            if (_state == TYVideoPlayerStateContentPlaying) {
                return;
            }
            break;
        default:
            break;
    }
    
    _state = state;
    
    switch (state) {
        case TYVideoPlayerStateRequestStreamURL:
            if (oldState == TYVideoPlayerStateContentPlaying && [self isPlaying]) {
                [_player pause];
            }
            break;
        case TYVideoPlayerStateContentLoading:
             [self performSelector:@selector(URLAssetTimeOut) withObject:nil afterDelay:_loadingTimeOut];
            break;
        case TYVideoPlayerStateSeeking:
            [self performSelector:@selector(seekingTimeOut) withObject:nil afterDelay:_seekingTimeOut];
            break;
        case TYVideoPlayerStateBuffering:
            [self performSelector:@selector(bufferingTimeOut) withObject:nil afterDelay:_bufferingTimeOut];
            break;
        case TYVideoPlayerStateContentPlaying:
            if (![self isPlaying]) {
                [_player play];
            }
            break;
        case TYVideoPlayerStateContentPaused:
            if (oldState != TYVideoPlayerStateContentLoading && oldState != TYVideoPlayerStateRequestStreamURL) {
                _track.isVideoLoadedBefore = NO;
                _track.lastTimeInSeconds = [self currentTime];
            }
            [_player pause];
            break;
        case TYVideoPlayerStateError:
            [self cancleAllTimeOut];
            [_player pause];
            if (oldState != TYVideoPlayerStateContentLoading && oldState != TYVideoPlayerStateRequestStreamURL) {
                _track.isVideoLoadedBefore = NO;
                _track.lastTimeInSeconds = [self currentTime];
            }
            [self notifyErrorCode:kVideoPlayerErrorAVPlayerFail error:nil];
        case TYVideoPlayerStateStopped:
            [self cancleAllTimeOut];
            [_playerItem cancelPendingSeeks];
            [_player pause];
            if (oldState != TYVideoPlayerStateContentLoading && oldState != TYVideoPlayerStateRequestStreamURL) {
                _track.isVideoLoadedBefore = NO;
                _track.lastTimeInSeconds = [self currentTime];
            }
            [self clearVideoPlayer];
        default:
            break;
    }
    
    TYDLog(@"didChangeFromState %@",[self descriptionState:oldState]);
    if ([_delegate respondsToSelector:@selector(videoPlayer:track:didChangeFromState:)]) {
        [_delegate videoPlayer:self track:_track didChangeFromState:oldState];
    }
}

- (NSString *)descriptionState:(TYVideoPlayerState)state
{
    switch (state) {
        case TYVideoPlayerStateUnknown:
            return @"TYVideoPlayerStateUnknown";
        case TYVideoPlayerStateRequestStreamURL:
            return @"TYVideoPlayerStateRequestStreamURL";
        case TYVideoPlayerStateContentLoading:
            return @"TYVideoPlayerStateContentLoading";
        case TYVideoPlayerStateContentReadyToPlay:
            return @"TYVideoPlayerStateContentReadyToPlay";
        case TYVideoPlayerStateContentPlaying:
            return @"TYVideoPlayerStateContentPlaying";
        case TYVideoPlayerStateContentPaused:
            return @"TYVideoPlayerStateContentPaused";
        case TYVideoPlayerStateBuffering:
            return @"TYVideoPlayerStateBuffering";
        case TYVideoPlayerStateSeeking:
            return @"TYVideoPlayerStateSeeking";
        case TYVideoPlayerStateStopped:
            return @"TYVideoPlayerStateStopped";
        case TYVideoPlayerStateError:
            return @"TYVideoPlayerStateError";
        default:
            break;
    }
}

#pragma mark - load video URL

- (void)reloadCurrentVideoTrackContinueLastTime:(BOOL)continueLastTime
{
    _track.videoLoadContinueLastTime = continueLastTime;
    [self reloadCurrentVideoTrack];
}

- (void)reloadCurrentVideoTrack
{
    switch (_state) {
        case TYVideoPlayerStateRequestStreamURL:
        case TYVideoPlayerStateContentLoading:
        case TYVideoPlayerStateContentPaused:
        case TYVideoPlayerStateStopped:
        case TYVideoPlayerStateError:
            [self reloadVideoTrack:_track];
            break;
        case TYVideoPlayerStateContentPlaying:
            [self pauseContent];
            [self reloadVideoTrack:_track];
            break;
        default:
            break;
    }
}

- (void)loadVideoWithStreamURL:(NSURL *)streamURL
{
    [self loadVideoWithStreamURL:streamURL playerLayer:nil];
}

- (void)loadVideoWithStreamURL:(NSURL *)streamURL playerLayer:(UIView<TYPlayerLayer> *)playerLayer
{
    TYVideoPlayerTrack *track = [[TYVideoPlayerTrack alloc]initWithStreamURL:streamURL];
    [self loadVideoWithTrack:track playerLayer:playerLayer];
}

- (void)loadVideoWithTrack:(id<TYVideoPlayerTrack>)track
{
    [self loadVideoWithTrack:track playerLayer:nil];
}

- (void)loadVideoWithTrack:(id<TYVideoPlayerTrack>)track playerLayer:(UIView<TYPlayerLayer> *)playerLayer
{
    if (_track && _state != TYVideoPlayerStateError) {
        [self stop];
    }
    
    if (playerLayer) {
        _playerLayer = playerLayer;
    }
    self.track = track;
    self.track.isPlayedToEnd = NO;
    
    [self reloadVideoTrack:track];
}

- (void)reloadVideoTrack:(id<TYVideoPlayerTrack>)track
{
    self.state = TYVideoPlayerStateRequestStreamURL;
    switch (_state) {
        case TYVideoPlayerStateError:
        case TYVideoPlayerStateContentPaused:
        case TYVideoPlayerStateContentLoading:
        case TYVideoPlayerStateRequestStreamURL:
            [self playVideoWithTrack:track];
            break;
        default:
            break;
    };
}

- (void)playVideoWithTrack:(id<TYVideoPlayerTrack>)track
{
    if (![self shouldPlayTrack:track]) {
        return;
    }
    
    [self clearVideoPlayer];
    
    [self getStreamURLWithTrack:track];
}

- (void)getStreamURLWithTrack:(id<TYVideoPlayerTrack>)track
{
    __weak typeof(self) weakSelf = self;
    [track streamURLWithCompleteBlock:^(NSURL *url) {
        if (!url) {
            TYDLog(@"streamURL don't nil!");
            NSError *error = [NSError errorWithDomain:@"player streamURL is nil!" code:kVideoPlayerErrorFetchStreamError userInfo:nil];
            [weakSelf notifyErrorCode:kVideoPlayerErrorFetchStreamError error:error];
            return;
        }
        TYDLog(@"playVideoWithStreamURL %@",url);
        [weakSelf playVideoWithStreamURL:url playerLayerView:weakSelf.playerLayer];
    }];
}

#pragma mark - play video URL

- (void)playVideoWithStreamURL:(NSURL *)streamURL playerLayerView:(UIView<TYPlayerLayer> *)layerView
{
    if (_state == TYVideoPlayerStateStopped) {
        return;
    }
    
    _track.streamURL = streamURL;
    self.state = TYVideoPlayerStateContentLoading;
    
    [self willPlayTrack:_track];
    
    [self asynLoadURLAssetWithStreamURL:streamURL];
}

- (void)asynLoadURLAssetWithStreamURL:(NSURL *)streamURL
{
    if (_URLAsset) {
        [_URLAsset cancelLoading];
    }
    AVURLAsset *URLAsset = [[AVURLAsset alloc] initWithURL:streamURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey : @YES}];
    _URLAsset = URLAsset;
    
    [URLAsset loadValuesAsynchronouslyForKeys:@[kTYVideoPlayerTracksKey,kTYVideoPlayerPlayableKey,kTYVideoPlayerDurationKey] completionHandler:^{
        dispatch_main_async_safe_ty(^{
            if (_state == TYVideoPlayerStateStopped) {
                return;
            }
            TYDLog(@"asset loaded");
            if (![URLAsset.URL.absoluteString isEqualToString:streamURL.absoluteString]) {
                NSError *error = [NSError errorWithDomain:@"URLAsset URL is not equal to streamURL!" code:kVideoPlayerErrorAssetLoadError userInfo:nil];
                [self notifyErrorCode:kVideoPlayerErrorAssetLoadError error:error];
                return;
            }
            
            NSError *error = nil;
            AVKeyValueStatus status = [URLAsset statusOfValueForKey:kTYVideoPlayerTracksKey error:&error];
            if (status == AVKeyValueStatusLoaded) {
                _track.videoType = CMTimeGetSeconds([URLAsset duration]) == 0 ? TYVideoPlayerTrackLIVE : TYVideoPlayerTrackVOD;
                _track.videoDuration = CMTimeGetSeconds([URLAsset duration]);
                
                self.playerItem = [AVPlayerItem playerItemWithAsset:URLAsset];
                if (_track.lastTimeInSeconds > _track.videoDuration) {
                    _track.lastTimeInSeconds = 0;
                }
                if (_track.videoLoadContinueLastTime && _track.lastTimeInSeconds > 0) {
                    [_playerItem seekToTime:CMTimeMakeWithSeconds(_track.lastTimeInSeconds, 1)];
                }
                self.player = [AVPlayer playerWithPlayerItem:_playerItem];
                [_playerLayer setPlayer:_player];
                TYDLog(@"setPlayer");
            }else if (status == AVKeyValueStatusFailed || status == AVKeyValueStatusUnknown) {
                [self notifyErrorCode:kVideoPlayerErrorAssetLoadError error:error];
            }
        });
    }];
}

#pragma mark - video control

- (void)play
{
    if (_state == TYVideoPlayerStateContentLoading || _state == TYVideoPlayerStateUnknown || (_state == TYVideoPlayerStateContentPlaying && [self isPlaying])) {
        return;
    }
    [self playContent];
}

- (void)pause
{
    if (![self isPlaying]) {
        return;
    }
    [self pauseContent];
}

- (void)stop
{
    dispatch_main_async_safe_ty(^{
        if (_state == TYVideoPlayerStateUnknown || (_state == TYVideoPlayerStateStopped && !_player && !_playerItem)) {
            return;
        }
        self.state = TYVideoPlayerStateStopped;
        self.track.isVideoLoadedBefore = YES;
    });
}

- (void)playContent
{
    dispatch_main_async_safe_ty(^{
        self.state = TYVideoPlayerStateContentPlaying;
    });
}

- (void)pauseContent
{
    [self pauseContentCompletion:nil];
}

- (void)pauseContentCompletion:(void (^)())completion
{
    dispatch_main_async_safe_ty(^{
        switch ([_playerItem status]) {
            case AVPlayerItemStatusFailed:
                self.state = TYVideoPlayerStateError;
                return;
            case AVPlayerItemStatusUnknown:
                NSLog(@"Trying to pause content but AVPlayerItemStatusUnknown.");
                self.state = TYVideoPlayerStateContentLoading;
                if (completion) completion();
                return;
            default:
                break;
        }
        
        switch ([_player status]) {
            case AVPlayerStatusFailed:
                self.state = TYVideoPlayerStateError;
                return;
            case AVPlayerStatusUnknown:
                NSLog(@"Trying to pause content but AVPlayerStatusUnknown.");
                self.state = TYVideoPlayerStateContentLoading;
                return;
            default:
                break;
        }
        
        switch (_state) {
            case TYVideoPlayerStateContentLoading:
            case TYVideoPlayerStateContentReadyToPlay:
            case TYVideoPlayerStateContentPlaying:
            case TYVideoPlayerStateContentPaused:
            case TYVideoPlayerStateBuffering:
            case TYVideoPlayerStateSeeking:
            case TYVideoPlayerStateError:
                self.state = TYVideoPlayerStateContentPaused;
                if (completion) completion();
                break;
            default:
                break;
        }

    });
}

#pragma mark - seeking

- (void)seekToTime:(NSTimeInterval)time
{
    if (_state == TYVideoPlayerStateContentLoading) {
        return;
    }
    self.state = TYVideoPlayerStateSeeking;
    __weak typeof(self) weakSelf = self;
    [self seekToTimeInSecond:time completion:^(BOOL finished) {
        if (finished){
            [weakSelf pauseContentCompletion:^{
                [weakSelf playContent];
            }];
        }
    }];
}

- (void)seekToLastWatchTime
{
    if (_track.lastTimeInSeconds > _track.videoDuration) {
        _track.lastTimeInSeconds = 0;
    }
    __weak typeof(self) weakSelf = self;
    [self seekToTimeInSecond:_track.lastTimeInSeconds completion:^(BOOL finished) {
        if (finished) {
            [weakSelf playContent];
        }
    }];
}

- (void)seekToTimeInSecond:(NSTimeInterval)time completion:(void (^)(BOOL finished))completion
{
    _isFinishSeek = NO;
    [_player seekToTime:CMTimeMakeWithSeconds(time, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:completion];
}

#pragma mark - public 

- (void)setRate:(float)rate
{
    if (self.state == TYVideoPlayerStateContentPlaying) {
        [_player setRate:rate];
    }
}

- (BOOL)isPlaying
{
    return (self.player && self.player.rate != 0.0);
}

- (NSTimeInterval)currentTime
{
    if (_track.isVideoLoadedBefore) {
        _track.isVideoLoadedBefore = NO;
        return MIN(_track.lastTimeInSeconds, 0);
    }else{
        return CMTimeGetSeconds([self.player currentTime]);
    }
}

- (NSTimeInterval)currentDuration
{
    return CMTimeGetSeconds([self.player.currentItem duration]);
}

#pragma mark - private method

- (BOOL)shouldPlayTrack:(id<TYVideoPlayerTrack>)track
{
    if ([_delegate respondsToSelector:@selector(videoPlayer:shouldPlayTrack:)]) {
        return [_delegate videoPlayer:self shouldPlayTrack:track];
    }
    return YES;
}

- (void)willPlayTrack:(id<TYVideoPlayerTrack>)track
{
    if ([_delegate respondsToSelector:@selector(videoPlayer:willPlayTrack:)]) {
        [_delegate videoPlayer:self willPlayTrack:track];
    }
}

- (void)notifyErrorCode:(TYVideoPlayerErrorCode)errorCode error:(NSError *)error
{
    if ([_delegate respondsToSelector:@selector(videoPlayer:track:receivedErrorCode:error:)]) {
        TYDLog(@"receivedErrorCode %ld error %@",errorCode,error);
        [_delegate videoPlayer:self track:_track receivedErrorCode:errorCode error:error];
    }
}

- (void)clearVideoPlayer
{
    self.playerItem = nil;
    self.player = nil;
}

#pragma mark - time Out

-(void)URLAssetTimeOut
{
    if (_state == TYVideoPlayerStateContentLoading) {
        [self notifyTimeOut:TYVideoPlayerTimeOutLoad];
    }
}

-(void)seekingTimeOut
{
    if (_state == TYVideoPlayerStateSeeking) {
        [self notifyTimeOut:TYVideoPlayerTimeOutSeek];
    }
}

-(void)bufferingTimeOut
{
    if (_state == TYVideoPlayerStateBuffering) {
        [self notifyTimeOut:TYVideoPlayerTimeOutBuffer];
    }
}

- (void)setLoadingTimeOutTime:(NSUInteger)time
{
    _loadingTimeOut = time;
}

- (void)setSeekTimeOutTime:(NSUInteger)time
{
    _seekingTimeOut = time;
}

- (void)setBufferTimeOutTime:(NSUInteger)time
{
    _bufferingTimeOut = time;
}

- (void)notifyTimeOut:(TYVideoPlayerTimeOut)timeOut
{
    dispatch_main_async_safe_ty(^{
        if ([_delegate respondsToSelector:@selector(videoPlayer:track:receivedTimeout:)]) {
            TYDLog(@"receivedTimeout %ld",timeOut);
            [_delegate videoPlayer:self track:_track receivedTimeout:timeOut];
        }
    });
}

- (void)cancleAllTimeOut
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(URLAssetTimeOut) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(seekingTimeOut) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(bufferingTimeOut) object:nil];
}

#pragma mark - add & remove notification

- (void)addRouteObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //添加耳机插入、拔出监听控制
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeInterrypt:) name:AVAudioSessionInterruptionNotification object:nil];
}

- (void)addPlayerTimeObserver
{
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time){
        [weakSelf periodicTimeObserver:time];
    }];
}

- (void)addPlayerItemObservers:(AVPlayerItem *)playerItem
{
    [playerItem addObserver:self forKeyPath:kTYVideoPlayerStatusKey options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:kTYVideoPlayerBufferEmptyKey options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:kTYVideoPlayerLikelyToKeepUpKey options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidFailedToPlay:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:playerItem];
}

- (void)removePlayerItemObservers:(AVPlayerItem *)playerItem
{
    [playerItem removeObserver:self forKeyPath:kTYVideoPlayerStatusKey];
    [playerItem removeObserver:self forKeyPath:kTYVideoPlayerBufferEmptyKey];
    [playerItem removeObserver:self forKeyPath:kTYVideoPlayerLikelyToKeepUpKey];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:playerItem];
}

#pragma mark - notification observers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == _player) {
        if ([keyPath isEqualToString:kTYVideoPlayerStatusKey]) {
            switch ([_player status]) {
                case AVPlayerStatusReadyToPlay:
                    self.state = TYVideoPlayerStateContentReadyToPlay;
                    break;
                case AVPlayerStatusFailed:
                    [self notifyErrorCode:kVideoPlayerErrorAVPlayerFail error:_player.error];
                    break;
                default:
                    break;
            }
        }
    }else if (object == _playerItem) {
        if ([keyPath isEqualToString:kTYVideoPlayerBufferEmptyKey]) {
            TYDLog(@"playbackBufferEmpty");
            if (self.playerItem.isPlaybackBufferEmpty && [self currentTime] > 0 && [self currentTime] < [self currentDuration] - 1 && _state == TYVideoPlayerStateContentPlaying) {
                self.state = TYVideoPlayerStateBuffering;
            }
        }else if ([keyPath isEqualToString:kTYVideoPlayerLikelyToKeepUpKey]) {
            TYDLog(@"playbackLikelyToKeepUp");
            if (_playerItem.playbackLikelyToKeepUp) {
                _isFinishSeek = YES;
                if (![self isPlaying] && _state == TYVideoPlayerStateContentPlaying) {
                    [_player play];
                }
                if (_state == TYVideoPlayerStateBuffering) {
                    self.state = TYVideoPlayerStateContentPlaying;
                }
            }
        }else if ([keyPath isEqualToString:kTYVideoPlayerStatusKey]) {
            switch ([_playerItem status]) {
                case AVPlayerItemStatusReadyToPlay:
                    self.state = TYVideoPlayerStateContentReadyToPlay;
                    break;
                case AVPlayerItemStatusFailed:
                    [self notifyErrorCode:kVideoPlayerErrorAVPlayerItemFail error:_playerItem.error];
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)periodicTimeObserver:(CMTime)time
{
    NSTimeInterval timeInSeconds = CMTimeGetSeconds(time);
    if (timeInSeconds <= 0) {
        return;
    }
    
    if ([self isPlaying]) {
        _track.videoTime = timeInSeconds;
        TYDLog(@"timeInSeconds %ld",(NSInteger)timeInSeconds);
        if ([_delegate respondsToSelector:@selector(videoPlayer:track:didUpdatePlayTime:)]) {
            [_delegate videoPlayer:self track:_track didUpdatePlayTime:timeInSeconds];
        }
    }
}

- (void)playerDidPlayToEnd:(NSNotification *)notification
{
    dispatch_main_async_safe_ty(^{
        _track.isPlayedToEnd = YES;
        if ([_delegate respondsToSelector:@selector(videoPlayer:didEndToPlayTrack:)]) {
            [_delegate videoPlayer:self didEndToPlayTrack:_track];
        }
    });
}

- (void)playerDidFailedToPlay:(NSNotification *)notification
{
    NSError *error = notification.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey];
    [self notifyErrorCode:kVideoPlayerErrorAVPlayerItemEndFail error:error];
}

-(void)routeChange:(NSNotification *)notification
{
    NSDictionary *dic=notification.userInfo;
    int changeReason= [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    //等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable表示旧输出不可用
    if (changeReason==AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *routeDescription=dic[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription= [routeDescription.outputs firstObject];
        //原设备为耳机则暂停
        if ([portDescription.portType isEqualToString:@"Headphones"]) {
            //如果是在播放状态下拔出耳机，导致系统级暂停播放，而播放状态未改变
            dispatch_delay_main_async_ty(0.3,^{
                if (self.state == TYVideoPlayerStateContentPlaying) {//只有在播放状态下才恢复播放
                    [self play];
                }
            });
        }
    }
}

-(void)routeInterrypt:(NSNotification *)notification
{
    NSDictionary *dic=notification.userInfo;
    int changeReason= [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    if (changeReason==AVAudioSessionRouteChangeReasonUnknown) {
        if (self.state == TYVideoPlayerStateContentPlaying) {
            [self pauseContent];
        }
        // TODO 有来电则不恢复播放
        if (self.track.isPlayedToEnd) {
            return;
        }
        //1秒后恢复播放，立即恢复会导致无法播放卡顿
       dispatch_delay_main_async_ty(1.0, ^{
            [self play];
        });
    }
}

- (void)dealloc
{
    TYDLog(@"TYVideoPlayer dealloc");
}

@end




