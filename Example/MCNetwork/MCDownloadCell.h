//
//  MCDownloadCell.h
//  MCNetwork_Example
//
//  Created by 曹飞 on 2018/4/16.
//  Copyright © 2018年 1594717129@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCDownloadModel;
@protocol MCDownloadCellDelegate;

@interface MCDownloadCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLab;
@property (weak, nonatomic) IBOutlet UILabel *videoNameLab;
@property (weak, nonatomic) IBOutlet UIButton *playVideoBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelDownloadBtn;
@property (weak, nonatomic) IBOutlet UIButton *startDownloadBtn;
@property (weak, nonatomic) id<MCDownloadCellDelegate> delegate;

@property (nonatomic, strong) MCDownloadModel *model;

@end

@protocol MCDownloadCellDelegate <NSObject>

- (void)onCell:(MCDownloadCell *)cell didClickedButtonStartDownloadAction:(UIButton *)sender;
- (void)onCell:(MCDownloadCell *)cell didClickedButtonCancelDownloadAction:(UIButton *)sender;

@end
