//
//  MCDownloadModel.h
//  MCNetwork_Example
//
//  Created by 曹飞 on 2018/4/17.
//  Copyright © 2018年 1594717129@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadRequest.h"

typedef NS_ENUM(NSInteger, DownloadTaskState) {
    DownloadTaskStateCancel = 0, // 已经取消,暂停,或不在下载
    DownloadTaskStateRuning, // 正在下载
    DownloadTaskStateComplete, // 下载完成
};


@interface MCDownloadModel : NSObject

@property (nonatomic, strong) DownloadRequest *request;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) float progress; //0~1

// 默认是Cancel
@property (nonatomic, assign) DownloadTaskState state;

@end
