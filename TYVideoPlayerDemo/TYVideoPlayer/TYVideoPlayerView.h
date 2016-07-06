//
//  TYPlayerView.h
//  TYVideoPlayerDemo
//
//  Created by tany on 16/7/5.
//  Copyright © 2016年 tany. All rights reserved.
//  播放器播放层

#import <UIKit/UIKit.h>
#import "TYPlayerLayerView.h"

@interface TYVideoPlayerView : UIView

@property (nonatomic, weak, readonly) TYPlayerLayerView *layerView;

@end
