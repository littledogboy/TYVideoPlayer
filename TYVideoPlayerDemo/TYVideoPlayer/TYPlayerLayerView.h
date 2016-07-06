//
//  TYPlayerLayerView.h
//  TYVideoPlayerDemo
//
//  Created by tany on 16/6/23.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol TYPlayerLayer <NSObject>

- (AVPlayerLayer *)playerLayer;

- (void)setPlayer:(AVPlayer *)player;

@end

@interface TYPlayerLayerView : UIView<TYPlayerLayer>

- (AVPlayerLayer *)playerLayer;

- (AVPlayer *)player;

- (void)setPlayer:(AVPlayer *)player;

@end
