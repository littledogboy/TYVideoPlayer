//
//  TYVideoPlayerController.h
//  TYVideoPlayerDemo
//
//  Created by tany on 16/7/6.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TYVideoPlayerController;
@protocol TYVideoPlayerControllerDelegate <NSObject>
@optional

// 准备播放
- (void)videoPlayerController:(TYVideoPlayerController *)videoPlayerController readyToPlayURL:(NSURL *)streamURL;
// 播放结束
- (void)videoPlayerController:(TYVideoPlayerController *)videoPlayerController endToPlayURL:(NSURL *)streamURL;
// 退出控制器 返回 是否退出
- (BOOL)videoPlayerControllerShouldGoBack:(TYVideoPlayerController *)videoPlayerController;

@end

@interface TYVideoPlayerController : UIViewController

@property (nonatomic, weak) id<TYVideoPlayerControllerDelegate> delegate;
// 视频名 默认YES
@property (nonatomic, strong) NSString *videoTitle;
// 播放地址
@property (nonatomic, strong) NSURL *streamURL;
// 加载完视频是否自动播放
@property (nonatomic, assign) BOOL shouldAutoplayVideo;
// 是否全屏
@property (nonatomic, assign, readonly) BOOL isFullScreen;

// 加载视频URL，如果在viewDidLoad之前设置了streamURL 在viewDidLoad中将会自动调用这个
- (void)loadVideoWithStreamURL:(NSURL *)streamURL;

- (void)play;

- (void)pause;

- (void)stop;

@end
