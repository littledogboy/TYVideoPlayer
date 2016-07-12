//
//  TYVideoPlayerController.h
//  TYVideoPlayerDemo
//
//  Created by tany on 16/7/6.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYVideoPlayerController : UIViewController

// 视频名 默认YES
@property (nonatomic, strong) NSString *videoTitle;
// 播放地址
@property (nonatomic, strong) NSURL *streamURL;
// 加载完视频是否自动播放
@property (nonatomic, assign) BOOL loadVideoShouldAutoplay;

@property (nonatomic, assign, readonly) BOOL isFullScreen;
// 返回， 默认nil，pop或者dismiss
@property (nonatomic, copy) void (^goBackHandle)(TYVideoPlayerController *);

// 加载视频streamURL ， 注意：如果在viewDidLoad之前设置了streamURL 在viewDidLoad中将会自动调用这个
- (void)loadVideoWithStreamURL:(NSURL *)streamURL;

- (void)play;

- (void)pause;

- (void)stop;

@end
