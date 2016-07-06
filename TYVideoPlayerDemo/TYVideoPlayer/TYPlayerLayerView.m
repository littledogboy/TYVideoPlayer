//
//  TYPlayerLayerView.m
//  TYVideoPlayerDemo
//
//  Created by tany on 16/6/23.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYPlayerLayerView.h"

@implementation TYPlayerLayerView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer
{
    return (AVPlayerLayer *)[self layer];
}

- (AVPlayer *)player
{
    return [[self playerLayer] player];
}

- (void)setPlayer:(AVPlayer *)player
{
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

@end
