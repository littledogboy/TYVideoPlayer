//
//  AVPlayer+TYPlayer.h
//  TYVideoPlayerDemo
//
//  Created by tany on 16/6/21.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVPlayer (TYPlayer)

// seek time
- (void)seekToTimeInSeconds:(NSTimeInterval)time completionHandler:(void (^)(BOOL finished))completionHandler;

// 当前总时长
- (NSTimeInterval)currentItemDuration;

// 当前播放时间
- (CMTime)currentCMTime;

@end
