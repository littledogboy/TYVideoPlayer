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

@interface TYVideoPlayerController () <TYVideoPlayerDelegate, TYVideoControlViewDelegate>

// 播放视图层
@property (nonatomic, weak) TYVideoPlayerView *playerView;

// 播放控制层
@property (nonatomic, weak) TYVideoControlView *controlView;

@property (nonatomic, weak) TYLoadingView *loadingView;

// 播放器
@property (nonatomic, strong) TYVideoPlayer *videoPlayer;

@property (nonatomic, strong) NSURL *streamURL;

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
    _loadVideoShouldAutoplay = YES;
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
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _playerView.frame = self.view.bounds;
    _loadingView.center = _playerView.center;
    _controlView.frame = self.view.bounds;
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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];
    [self.view addGestureRecognizer:tap];
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

#pragma mark - private

- (void)showLoadingView
{
    if (!_loadingView.isAnimating) {
        _controlView.suspendBtn.hidden = YES;
        [_loadingView startAnimation];
    }
}

- (void)stopLoadingView
{
    if (_loadingView.isAnimating) {
        _controlView.suspendBtn.hidden = NO;
        [_loadingView stopAnimation];
    }
}

- (void)updatePlayerViewDidChangeToState:(TYVideoPlayerState)state
{
    switch (state) {
        case TYVideoPlayerStateRequestStreamURL:
            [self showLoadingView];
            break;
        case TYVideoPlayerStateContentReadyToPlay:
        {
            NSString *time = [self covertToStringWithTime:[_videoPlayer duration]];
            [_controlView updateTotalVideoTime:time];
            [self hideControlViewWithDelay:5.0];
            break;
        }
        case TYVideoPlayerStateContentPlaying:
            _controlView.suspendBtn.selected = NO;
            [self stopLoadingView];
            break;
        case TYVideoPlayerStateContentPaused:
            _controlView.suspendBtn.selected = YES;
            break;
        case TYVideoPlayerStateSeeking:
            [self showLoadingView];;
            break;
        case TYVideoPlayerStateBuffering:
            [self showLoadingView];;
            break;
        case TYVideoPlayerStateStopped:
            [self stopLoadingView];
            break;
        case TYVideoPlayerStateError:
            [self stopLoadingView];
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
            if (_loadVideoShouldAutoplay) {
                [videoPlayer play];
            }
            break;
        default:
            break;
    }
}

- (void)showControlViewWithAnimation:(BOOL)animation
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            _controlView.hidden = NO;
        }];
    }else {
        _controlView.hidden = NO;
    }
    _controlView.suspendBtn.hidden = [_loadingView isAnimating];
}

- (void)hideControlViewWithAnimation:(BOOL)animation
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            _controlView.hidden = YES;
        }];
    }else {
        _controlView.hidden = YES;
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
    if (!_controlView.hidden && !_isDraging) {
        [self hideControlViewWithAnimation:YES];
    };
}

- (NSString *)covertToStringWithTime:(NSInteger)time
{
    NSInteger seconds = time % 60;
    NSInteger minutes = time / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld",(long)minutes,(long)seconds];
}

#pragma mark - action

- (void)singleTapAction:(UITapGestureRecognizer *)tap
{
    if (_controlView.hidden) {
        [self showControlViewWithAnimation:YES];
    }else {
        [self hideControlViewWithAnimation:YES];
    }
}

- (void)navBack
{
    [self stop];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - TYVideoPlayerDelegate

- (void)videoPlayer:(TYVideoPlayer*)videoPlayer track:(id<TYVideoPlayerTrack>)track didChangeFromState:(TYVideoPlayerState)fromState
{
    // update UI
    [self updatePlayerViewDidChangeToState:videoPlayer.state];
    
    // player control
    [self player:videoPlayer didChangeToState:videoPlayer.state];
}

- (void)videoPlayer:(TYVideoPlayer *)videoPlayer track:(id<TYVideoPlayerTrack>)track didUpdatePlayTime:(NSTimeInterval)playTime
{
    if (_isDraging) {
        return;
    }
    
    NSString *time = [self covertToStringWithTime:playTime];
    [_controlView updateCurrentVideoTime:time];
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
            if (self.isFullScreen){
                [self changeToOrientation:UIInterfaceOrientationPortrait];
            }else {
                [self navBack];
            }
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
            NSTimeInterval sliderTime = [_videoPlayer duration]*progress;
            NSString *time = [self covertToStringWithTime:sliderTime];
            [_controlView updateCurrentVideoTime:time];
            break;
        }
        case TYSliderStateEnd:
        {
            _isDraging = NO;
            NSTimeInterval sliderTime = [_videoPlayer duration]*progress;
            NSString *time = [self covertToStringWithTime:sliderTime];
            [_videoPlayer seekToTime:sliderTime];
            [_controlView updateCurrentVideoTime:time];
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
    NSLog(@"TYVideoPlayerController dealloc");
}

@end
