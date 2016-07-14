//
//  ViewController.m
//  TYVideoPlayerDemo
//
//  Created by tany on 16/6/20.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "ViewController.h"
#import "TYVideoPlayerController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

}

- (IBAction)presentVideoPlayerController:(id)sender {
    TYVideoPlayerController *playerController = [[TYVideoPlayerController alloc]init];
    playerController.streamURL = [NSURL URLWithString:@"http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8"];
    [self presentViewController:playerController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
