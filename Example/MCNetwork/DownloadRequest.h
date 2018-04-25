//
//  DownloadRequest.h
//  MCNetwork_Example
//
//  Created by 曹飞 on 2018/4/12.
//  Copyright © 2018年 1594717129@qq.com. All rights reserved.
//

#import <MCNetwork/MCNetwork.h>

@interface DownloadRequest : MCBaseRequest

- (instancetype)initWithDownloadUrl:(NSString *)downloadUrl;

/// 进阶版
@property (assign) BOOL advanced;

@end
