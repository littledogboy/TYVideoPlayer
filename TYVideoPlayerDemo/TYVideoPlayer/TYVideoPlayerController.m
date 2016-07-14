//
//  TYVideoPlayerController.m
//  TYVideoPlayerDemo
//
//  Created by tany on 16/7/6.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYVideoPlayerController.h"
#import "TYVideoPlayer.h"
#import "TYVideoPlayerView.h"
#import "TYVideoControlView.h"
#import "TYLoadingView.h"
#import "TYVideoErrorView.h"

@interface TYVideoPlayerController () <TYVideoPlayerDelegate, TYVideoControlViewDelegate>

// 播放视图层
@property (nonatomic, weak) TYVideoPlayerView *playerView;
// 播放控制层
@property (nonatomic, weak) TYVideoControlView *controlView;
// 播放loading
@property (nonatomic, weak) TYLoadingView *loadingView;
// 播放错误view
@property (nonatomic, weak) TYVideoErrorView *errorView;

// 播放器
@property (nonatomic, strong) TYVideoPlayer *videoPlayer;

// 是否正在拖动slider
@property (nonatomic, assign) BOOL isDraging;

@end

@implementation TYVideoPlayerController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self configrePropertys];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self configrePropertys];
    }
    return self;
}

- (void)configrePropertys
{
    _shouldAutoplayVideo = YES;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addPlayerView];
    
    [self addLoadingView];
    
    [self addVideoControlView];
    
    [self addSingleTapGesture];
    
    [self addVideoPlayer];
    
    if (_streamURL) {
        [self loadVideoWithStreamURL:_streamURL];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _playerView.frame = self.view.bounds;
    _loadingView.center = _playerView.center;
    _controlView.frame = self.view.bounds;
    [_controlView setFullScreen:self.isFullScreen];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - add subview

- (void)addPlayerView
{
    TYVideoPlayerView *playerView = [[TYVideoPlayerView alloc]init];
    playerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:playerView];
    _playerView = playerView;
}

- (void)addVideoControlView
{
    TYVideoControlView *controlView = [[TYVideoControlView alloc]init];
    [controlView setTitle:_videoTitle];
    controlView.delegate = self;
    [self.view addSubview:controlView];
    _controlView = controlView;
}

- (void)addLoadingView
{
    TYLoadingView *loadingView = [[TYLoadingView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    loadingView.lineWidth = 1.5;
    [self.view addSubview:loadingView];
    _loadingView = loadingView;
}

- (void)addSingleTapGesture
{
    UITapGestureRecognizer *hideTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];
    [_controlView addGestureRecognizer:hideTap];
}

#pragma mark - getter

- (BOOL)isFullScreen
{
    return [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight;
}

#pragma mark - video player

- (void)addVideoPlayer
{
    TYVideoPlayer *videoPlayer = [[TYVideoPlayer alloc]initWithPlayerLayerView:_playerView];
    videoPlayer.delegate = self;
    _videoPlayer = videoPlayer;
}

#pragma mark - player control

- (void)loadVideoWithStreamURL:(NSURL *)streamURL
{
    _streamURL = streamURL;
    
    [_videoPlayer loadVideoWithStreamURL:streamURL];
}

- (void)play
{
    [_videoPlayer play];
}

- (void)pause
{
    [_videoPlayer pause];
}

- (void)stop
{
    [_videoPlayer stop];
}

#pragma mark - show & hide view

// show loadingView
- (void)showLoadingView
{
    if (!_loadingView.isAnimating && _videoPlayer.track.videoType != TYVideoPlayerTrackLocal) {
        [_controlView setPlayBtnHidden:YES];
        [_loadingView startAnimation];
    }
}

- (void)stopLoadingView
{
    if (_loadingView.isAnimating) {
        [_controlView setPlayBtnHidden:NO];
        [_loadingView stopAnimation];
    }
}

// show ControlView
- (void)showControlViewWithAnimation:(BOOL)animation
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            [_controlView setContenViewHidden:NO];
        }];
    }else {
        [_controlView setContenViewHidden:NO];
    }
    [_controlView setPlayBtnHidden:[_loadingView isAnimating]];
}

- (void)hideControlViewWithAnimation:(BOOL)animation
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
             [_controlView setContenViewHidden:YES];
        }];
    }else {
         [_controlView setContenViewHidden:YES];
    }
}

- (void)hideControlViewWithDelay:(CGFloat)delay
{
    if (delay > 0) {
        [self performSelector:@selector(hideControlView) withObject:nil afterDelay:delay];
    }else {
        [self hideControlView];
    }
}

- (void)hideControlView
{
    if (![_controlView contenViewHidden]  && !_isDraging) {
        [self hideControlViewWithAnimation:YES];
    };
}

// show errorView
- (void)showErrorViewWithTitle:(NSString *)title actionHandle:(void (^)(void))actionHandle
{
    if (!_errorView) {
        TYVideoErrorView *errorView = [[TYVideoErrorView alloc]initWithFrame:self.view.bounds];
        errorView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [self.view addSubview:errorView];
        _errorView = errorView;
    }
    
    __weak typeof(self) weakSelf = self;
    [_errorView setTitle:title];
    [_errorView setEventActionHandle:^(TYVideoErrorEvent event) {
        switch (event) {
            case TYVideoErrorEventBack:
                [weakSelf goBackAction];
                break;
            case TYVideoErrorEventReplay:
                if (actionHandle) {
                    actionHandle();
                }
                break;
            default:
                break;
        }
    }];
}

- (void)hideErrorView
{
    if (_errorView) {
        [_errorView removeFromSuperview];
    }
}

#pragma mark - private

- (void)playerViewDidChangeToState:(TYVideoPlayerState)state
{
    switch (state) {
        case TYVideoPlayerStateRequestStreamURL:
            [self showLoadingView];
            if (_shouldAutoplayVideo) {
                [self hideControlViewWithAnimation:NO];
            }
            [_controlView setSliderProgress:0];
            [_controlView setCurrentVideoTime:@"00:00"];
            [_controlView setTotalVideoTime:@"00:00"];
            break;
        case TYVideoPlayerStateContentReadyToPlay:
        {
            NSString *time = [self covertToStringWithTime:[_videoPlayer duration]];
            [_controlView setTotalVideoTime:time];
            [_controlView setTimeSliderHidden:_videoPlayer.track.videoType == TYVideoPlayerTrackLIVE];
            [self hideControlViewWithDelay:5.0];
            break;
        }
        case TYVideoPlayerStateContentPlaying:
            [self hideErrorView];
            [_controlView setPlayBtnState:NO];
            [self stopLoadingView];
            [_controlView setPlayBtnHidden:NO];
            break;
        case TYVideoPlayerStateContentPaused:
            [_controlView setPlayBtnState:YES];
            break;
        case TYVideoPlayerStateSeeking:
            [self showLoadingView];
            break;
        case TYVideoPlayerStateBuffering:
            [self showLoadingView];
            break;
        case TYVideoPlayerStateStopped:
            [self stopLoadingView];
            [_controlView setPlayBtnHidden:YES];
            break;
        case TYVideoPlayerStateError:
            [self stopLoadingView];
            [_controlView setPlayBtnHidden:YES];
            break;
        default:
            break;
    }
}

- (void)player:(TYVideoPlayer*)videoPlayer didChangeToState:(TYVideoPlayerState)state
{
    // player control
    switch (state) {
        case TYVideoPlayerStateContentReadyToPlay:
            if (_shouldAutoplayVideo) {
                [videoPlayer play];
            }
            break;
        default:
            break;
    }
}

- (NSString *)covertToStringWithTime:(NSInteger)time
{
    NSInteger seconds = time % 60;
    NSInteger minutes = time / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld",(long)minutes,(long)seconds];
}

#pragma mark - action

- (void)reloadVideo
{
    [self loadVideoWithStreamURL:_streamURL];
    [self hideErrorView];
}

- (void)reloadCurrentVideo
{
    self.videoPlayer.track.continueLastWatchTime = YES;
    [self.videoPlayer reloadCurrentVideoTrack];
    [self hideErrorView];
}

- (void)singleTapAction:(UITapGestureRecognizer *)tap
{
    if ([_controlView contenViewHidden]) {
        [self showControlViewWithAnimation:YES];
    }else {
        [self hideControlViewWithAnimation:YES];
    }
}

- (void)goBackAction
{
    if (self.isFullScreen){
        [self changeToOrientation:UIInterfaceOrientationPortrait];
    }else {
        [self goBack];
    }
}

- (void)goBack
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self stop];
    if (_goBackHandle) {
        _goBackHandle(self);
    }else if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark - TYVideoPlayerDelegate

- (void)videoPlayer:(TYVideoPlayer*)videoPlayer track:(id<TYVideoPlayerTrack>)track didChangeFromState:(TYVideoPlayerState)fromState
{
    // update UI
    [self playerViewDidChangeToState:videoPlayer.state];
    
    // player control
    [self player:videoPlayer didChangeToState:videoPlayer.state];
}

- (void)videoPlayer:(TYVideoPlayer *)videoPlayer track:(id<TYVideoPlayerTrack>)track didUpdatePlayTime:(NSTimeInterval)playTime
{
    if (_isDraging) {
        return;
    }
    
    NSString *time = [self covertToStringWithTime:playTime];
    [_controlView setCurrentVideoTime:time];
    [_controlView setSliderProgress:playTime/[videoPlayer duration]];
}

- (void)videoPlayer:(TYVideoPlayer *)videoPlayer didEndToPlayTrack:(id<TYVideoPlayerTrack>)track
{
    NSLog(@"播放完成！");
    __weak typeof(self) weakSelf = self;
    [self showErrorViewWithTitle:@"重播" actionHandle:^{
        [weakSelf reloadVideo];
    }];
}

- (void)videoPlayer:(TYVideoPlayer *)videoPlayer track:(id<TYVideoPlayerTrack>)track receivedErrorCode:(TYVideoPlayerErrorCode)errorCode error:(NSError *)error
{
    NSLog(@"videoPlayer receivedErrorCode %@",error);
    __weak typeof(self) weakSelf = self;
    [self showErrorViewWithTitle:@"视频播放失败,重试" actionHandle:^{
        [weakSelf reloadCurrentVideo];
    }];
}

- (void)videoPlayer:(TYVideoPlayer *)videoPlayer track:(id<TYVideoPlayerTrack>)track receivedTimeout:(TYVideoPlayerTimeOut)timeout
{
    NSLog(@"videoPlayer receivedTimeout %ld",timeout);
    __weak typeof(self) weakSelf = self;
    [self showErrorViewWithTitle:@"视频播放超时,重试" actionHandle:^{
        [weakSelf reloadCurrentVideo];
    }];
}

#pragma mark - TYVideoControlViewDelegate

- (BOOL)videoControlView:(TYVideoControlView *)videoControlView shouldResponseControlEvent:(TYVideoControlEvent)event
{
     switch (event) {
         case TYVideoControlEventPlay:
             return _videoPlayer.state == TYVideoPlayerStateContentPaused;
         case TYVideoControlEventSuspend:
             return [_videoPlayer isPlaying];
         default:
             return YES;
     }
}

- (void)videoControlView:(TYVideoControlView *)videoControlView recieveControlEvent:(TYVideoControlEvent)event
{
    switch (event) {
        case TYVideoControlEventBack:
            [self goBackAction];
            break;
        case TYVideoControlEventFullScreen:
            [self changeToOrientation:UIInterfaceOrientationLandscapeRight];
            break;
        case TYVideoControlEventNormalScreen:
            [self changeToOrientation:UIInterfaceOrientationPortrait];
            break;
        case TYVideoControlEventPlay:
            [self play];
            break;
        case TYVideoControlEventSuspend:
            [self pause];
            break;
        default:
            break;
    }
}

- (void)videoControlView:(TYVideoControlView *)videoControlView state:(TYSliderState)state sliderToProgress:(CGFloat)progress
{
    switch (state) {
        case TYSliderStateBegin:
            _isDraging = YES;
            break;
        case TYSliderStateDraging:
        {
            NSTimeInterval sliderTime = floor([_videoPlayer duration]*progress);
            NSString *time = [self covertToStringWithTime:sliderTime];
            [_controlView setCurrentVideoTime:time];
            break;
        }
        case TYSliderStateEnd:
        {
            _isDraging = NO;
            NSTimeInterval sliderTime = floor([_videoPlayer duration]*progress);
            NSString *time = [self covertToStringWithTime:sliderTime];
            [_videoPlayer seekToTime:sliderTime];
            [_controlView setCurrentVideoTime:time];
            [self hideControlViewWithAnimation:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Autorotate

- (void)changeToOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        UIInterfaceOrientation val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self stop];
    NSLog(@"TYVideoPlayerController dealloc");
}

@end
