//
//  TYVideoErrorView.m
//  TYVideoPlayerDemo
//
//  Created by tany on 16/7/12.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYVideoErrorView.h"

@interface TYVideoErrorView ()
@property (nonatomic,weak) UILabel *titleLabel;
@property (nonatomic,weak) UIButton *msgBtn;
@end

#define kTitleLabelHeight 21
#define kMsgBtnWidth 100
#define kMsgBtnHeight 32

@implementation TYVideoErrorView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addTitleLabel];
        
        [self addMsgButton];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self addTitleLabel];
        
        [self addMsgButton];
    }
    return self;
}

- (void)addTitleLabel
{
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    _titleLabel = titleLabel;
}

- (void)addMsgButton
{
    UIButton *msgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [msgBtn setBackgroundColor:[UIColor colorWithRed:237/255. green:96/255. blue:30/255. alpha:1]];
    [self addSubview:msgBtn];
    _msgBtn = msgBtn;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _titleLabel.frame = CGRectMake(0, CGRectGetHeight(self.frame)/2 - kTitleLabelHeight - 10, CGRectGetWidth(self.frame), kTitleLabelHeight);
    _msgBtn.frame = CGRectMake((CGRectGetWidth(self.frame)-kMsgBtnWidth)/2, CGRectGetMaxY(_titleLabel.frame)+20, kMsgBtnWidth, kMsgBtnHeight);
}

@end
