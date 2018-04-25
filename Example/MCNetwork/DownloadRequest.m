//
//  DownloadRequest.m
//  MCNetwork_Example
//
//  Created by 曹飞 on 2018/4/12.
//  Copyright © 2018年 1594717129@qq.com. All rights reserved.
//

#import "DownloadRequest.h"

@implementation DownloadRequest {
    NSString *_downloadUrl;
}

- (instancetype)initWithDownloadUrl:(NSString *)downloadUrl {
    if (self = [super init]) {
        _downloadUrl = downloadUrl;
    }
    return self;
}

- (NSString *)requestUrl {
    if (!_advanced) {
        _downloadUrl = @"http://upyun-public.b0.upaiyun.com/live.ecook.cn/live/2963/recorder20171119171631.mp4";
    }
    return _downloadUrl;
}

- (MCRequestMethod)requestMethod {
    return MCRequestMethodGET;
}

- (NSString *)downloadFilePath {
    NSString *filePath;
    if (_advanced) {
        filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/videos/%@", [self requestUrl].lastPathComponent];
    } else {
        filePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", [self requestUrl].lastPathComponent];
    }
    return filePath;
}

@end
