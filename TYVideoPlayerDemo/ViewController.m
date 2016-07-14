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
    playerController.streamURL = [NSURL URLWithString:@"http://down.233.com/2014_2015/2014/jzs1/jingji_zhenti_yjw/6-qllgl2v5x9b80vvgwgzzlnzydkj1bpr66hnool80.mp4"];
    [self presentViewController:playerController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
