//
//  AVPlayer+TYPlayer.m
//  TYVideoPlayerDemo
//
//  Created by tany on 16/6/21.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "AVPlayer+TYPlayer.h"

@implementation AVPlayer (TYPlayer)

- (void)seekToTimeInSeconds:(NSTimeInterval)time completionHandler:(void (^)(BOOL finished))completionHandler {
    [self seekToTime:CMTimeMakeWithSeconds(time, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:completionHandler];
}

- (NSTimeInterval)currentItemDuration {
    return CMTimeGetSeconds([self.currentItem duration]);
}

- (CMTime)currentCMTime {
    return [self currentTime];
}

@end
