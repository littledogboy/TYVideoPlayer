//
//  TVPlayerBottomView.h
//  AVPlayerDemo
//
//  Created by tanyang on 15/11/18.
//  Copyright © 2015年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYVideoBottomView : UIView

@property (nonatomic, weak, readonly) UILabel *curTimeLabel;
@property (nonatomic, weak, readonly) UILabel *totalTimeLabel;
@property (nonatomic, weak, readonly) UIButton *fullScreenBtn;
@property (nonatomic, weak, readonly) UISlider *progressSlider;


@end
