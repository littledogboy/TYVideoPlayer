//
//  VideoPlayerViewController.m
//  TYVideoPlayerDemo
//
//  Created by tany on 16/7/11.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "TYVideoPlayerController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VideoPlayerViewController ()<TYVideoPlayerControllerDelegate>
@property (nonatomic, weak) TYVideoPlayerController *playerController;
@end

@implementation VideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addVideoPlayerController];
    
    [self loadVodVideo];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect bounds = self.view.frame;
    if (_playerController.isFullScreen) {
        _playerController.view.frame = CGRectMake(0, 0, MAX(CGRectGetHeight(bounds), CGRectGetWidth(bounds)), MIN(CGRectGetHeight(bounds), CGRectGetWidth(bounds)));
    }else {
         _playerController.view.frame = CGRectMake(0, 0, MIN(CGRectGetHeight(bounds), CGRectGetWidth(bounds)), MIN(CGRectGetHeight(bounds), CGRectGetWidth(bounds))*9/16);
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)addVideoPlayerController
{
    TYVideoPlayerController *playerController = [[TYVideoPlayerController alloc]init];
    playerController.delegate = self;
    [self addChildViewController:playerController];
    [self.view addSubview:playerController.view];
    _playerController = playerController;
}

- (void)loadVodVideo
{
    // 点播
    // http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8
    NSURL *streamURL = [NSURL URLWithString:@"http://down.233.com/2014_2015/2014/jzs1/jingji_zhenti_yjw/6-qllgl2v5x9b80vvgwgzzlnzydkj1bpr66hnool80.mp4"];
    
    // 直播
//    NSURL *streamURL = [NSURL URLWithString:@"http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8"];
    
    // 本地播放
    //NSString* path = [[NSBundle mainBundle] pathForResource:@"test_264" ofType:@"mp4"];
    //NSURL* streamURL = [NSURL fileURLWithPath:path];
    
    [_playerController loadVideoWithStreamURL:streamURL];
}

- (void)loadLiveVideo
{
    // 直播
    NSURL *streamURL = [NSURL URLWithString:@"http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8"];
    
    [_playerController loadVideoWithStreamURL:streamURL];
}

- (void)loadLocalVideo
{
    // 本地播放
    NSString* path = [[NSBundle mainBundle] pathForResource:@"test_264" ofType:@"mp4"];
    if (!path) {
        UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"本地文件不存在！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alerView show];
        return;
    }
    NSURL* streamURL = [NSURL fileURLWithPath:path];
    [_playerController loadVideoWithStreamURL:streamURL];
}


#pragma mark - action

- (IBAction)playVodAction:(id)sender {
    [self loadVodVideo];
}

- (IBAction)playLiveAction:(id)sender {
    [self loadLiveVideo];
}

- (IBAction)playLocalAction:(id)sender {
    [self loadLocalVideo];
}

#pragma mark - delegate

- (void)videoPlayerController:(TYVideoPlayerController *)videoPlayerController readyToPlayURL:(NSURL *)streamURL
{
    
}

- (void)videoPlayerController:(TYVideoPlayerController *)videoPlayerController endToPlayURL:(NSURL *)streamURL
{
    
}

#pragma mark - rotate

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //发生在翻转开始之前。
    CGRect bounds = self.view.frame;
    [UIView animateWithDuration:duration animations:^{
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
             _playerController.view.frame = CGRectMake(0, 0, MAX(CGRectGetHeight(bounds), CGRectGetWidth(bounds)), MIN(CGRectGetHeight(bounds), CGRectGetWidth(bounds)));
        }else {
             _playerController.view.frame = CGRectMake(0, 0, MIN(CGRectGetHeight(bounds), CGRectGetWidth(bounds)), MIN(CGRectGetHeight(bounds), CGRectGetWidth(bounds))*9/16);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
