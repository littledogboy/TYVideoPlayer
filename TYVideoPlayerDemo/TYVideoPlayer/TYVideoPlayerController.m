//
//  TYVideoPlayerController.m
//  TYVideoPlayerDemo
//
//  Created by tany on 16/7/6.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYVideoPlayerController.h"
#import "TYVideoPlayerView.h"
#import "TYVideoControlView.h"

@interface TYVideoPlayerController ()

@property (nonatomic, weak) TYVideoPlayerView *playerView;

@property (nonatomic, weak) TYVideoControlView *controlView;

@end

@implementation TYVideoPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addPlayerView];
    
    [self addVideoControlView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _playerView.frame = self.view.bounds;
    _controlView.frame = self.view.bounds;
}

- (void)addPlayerView
{
    TYVideoPlayerView *playerView = [[TYVideoPlayerView alloc]init];
    [self.view addSubview:playerView];
    _playerView = playerView;
}

- (void)addVideoControlView
{
    TYVideoControlView *controlView = [[TYVideoControlView alloc]init];
    [self.view addSubview:controlView];
    _controlView = controlView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
