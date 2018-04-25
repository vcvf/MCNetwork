//
//  MCDownloadCell.m
//  MCNetwork_Example
//
//  Created by 曹飞 on 2018/4/16.
//  Copyright © 2018年 1594717129@qq.com. All rights reserved.
//

#import "MCDownloadCell.h"
#import "MCDownloadModel.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@implementation MCDownloadCell

- (void)setModel:(MCDownloadModel *)model {
    _model = model;
    
    self.videoNameLab.text = _model.name;
    self.progressView.progress = _model.progress;
    self.progressLab.text = [NSString stringWithFormat:@"%.2f%%",_model.progress * 100];
    
    self.playVideoBtn.enabled = (_model.state == DownloadTaskStateComplete);
    
    self.startDownloadBtn.enabled = (_model.state == DownloadTaskStateCancel);
    
    self.cancelDownloadBtn.enabled = (_model.state == DownloadTaskStateRuning);
}

- (IBAction)playVideoAction:(id)sender {
    NSURL *urlPath = (NSURL *)self.model.request.responseObject;
    
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:urlPath];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    playerVC.player = player;
    
    [[self viewController] presentViewController:playerVC animated:YES completion:^{
        [playerVC.player play];
    }];
    
}

- (IBAction)startDownloadAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(onCell:didClickedButtonStartDownloadAction:)]) {
        [_delegate onCell:self didClickedButtonStartDownloadAction:sender];
    }
    
    [self.model.request start];
    self.model.state = DownloadTaskStateRuning;
    
    [self setModel:self.model];
}

- (IBAction)cancelDownloadAction:(id)sender {
    if ([_delegate respondsToSelector:@selector(onCell:didClickedButtonCancelDownloadAction:)]) {
        [_delegate onCell:self didClickedButtonCancelDownloadAction:sender];
    }
    
    [self.model.request stop];
    self.model.state = DownloadTaskStateCancel;
    
    [self setModel:self.model];
}

- (UIViewController *)viewController {
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

@end
