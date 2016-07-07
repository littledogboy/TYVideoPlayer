//
//  TYPlayerView.m
//  TYVideoPlayerDemo
//
//  Created by tany on 16/7/5.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYVideoPlayerView.h"

@interface TYVideoPlayerView ()
@property (nonatomic, weak) TYPlayerLayerView *layerView;
@property (nonatomic, weak) TYVideoControlView *controlView;
@end

@implementation TYVideoPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addPlayerLayerView];
        
        [self addVideoControlView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self addPlayerLayerView];
        
        [self addVideoControlView];
    }
    return self;
}

- (void)addPlayerLayerView
{
    TYPlayerLayerView *layerView = [[TYPlayerLayerView alloc]init];
    [self addSubview:layerView];
    _layerView = layerView;
}

- (void)addVideoControlView
{
    TYVideoControlView *controlView = [[TYVideoControlView alloc]init];
    [self addSubview:controlView];
    _controlView = controlView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _layerView.frame = self.bounds;
    _controlView.frame = self.bounds;
}

@end
