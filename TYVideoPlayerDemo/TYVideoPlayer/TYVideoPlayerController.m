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


@interface TYVideoPlayerController () <TYVideoPlayerDelegate, TYVideoControlViewDelegate>

// 播放视图层
@property (nonatomic, weak) TYVideoPlayerView *playerView;

// 弹幕层

// 播放控制层
@property (nonatomic, weak) TYVideoControlView *controlView;

// ad广告层

// 播放器
@property (nonatomic, strong) TYVideoPlayer *videoPlayer;

@property (nonatomic, strong) NSURL *streamURL;

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
    _loadVideoEndAutoPlay = YES;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addPlayerView];
    
    [self addVideoControlView];
    
    [self addVideoPlayer];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _playerView.frame = self.view.bounds;
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
    [self.view addSubview:controlView];
    _controlView = controlView;
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

#pragma mark - TYVideoPlayerDelegate

- (void)videoPlayer:(TYVideoPlayer*)videoPlayer track:(id<TYVideoPlayerTrack>)track didChangeFromState:(TYVideoPlayerState)fromState
{
    switch (videoPlayer.state) {
        case TYVideoPlayerStateContentReadyToPlay:
            if (_loadVideoEndAutoPlay) {
                [videoPlayer play];
            }
            break;
            
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
