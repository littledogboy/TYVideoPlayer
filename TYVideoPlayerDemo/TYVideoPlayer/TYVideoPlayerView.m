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
@end

@implementation TYVideoPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addPlayerLayerView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self addPlayerLayerView];
    }
    return self;
}

- (void)addPlayerLayerView
{
    TYPlayerLayerView *layerView = [[TYPlayerLayerView alloc]init];
    [self addSubview:layerView];
    _layerView = layerView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _layerView.frame = self.bounds;
}

@end
