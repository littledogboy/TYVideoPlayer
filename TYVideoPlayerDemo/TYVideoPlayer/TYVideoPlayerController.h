//
//  TYVideoPlayerController.h
//  TYVideoPlayerDemo
//
//  Created by tany on 16/7/6.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYVideoPlayerController : UIViewController

// 加载完视频是否自动播放
@property (nonatomic, assign) BOOL loadVideoEndAutoPlay;

// 播放地址
@property (nonatomic, strong, readonly) NSURL *streamURL;

// 加载视频
- (void)loadVideoWithStreamURL:(NSURL *)streamURL;

- (void)play;

- (void)pause;

- (void)stop;

@end
