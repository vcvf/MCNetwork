//
//  UploadRequest.m
//  MCNetwork_Example
//
//  Created by 曹飞 on 2018/4/13.
//  Copyright © 2018年 1594717129@qq.com. All rights reserved.
//

#import "UploadRequest.h"
#import <AFNetworking/AFNetworking.h>

@implementation UploadRequest

- (NSString *)requestUrl {
    return @"https://httpbin.org/post";
}

- (MCRequestMethod)requestMethod {
    return MCRequestMethodPOST;
}

- (AFConstructingBlock)constructiongBodyBlock {
    return ^(id<AFMultipartFormData>  _Nonnull formData) {
        // 选了一张图片比较大的,建议上传的内容比较大的时候,采用Urlpath上传
        for (int i = 0;i < 1;i ++) {
            NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"GOPR8638.JPG"], 1.0);
            [formData appendPartWithFileData:imageData name:@"GOPR8638.JPG" fileName:@"GOPR8638.JPG" mimeType:@"image/jpeg"];
        }
    };
}

- (NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary {
    return @{@"Authorization":@"SESSION OTBkYjkxODExZDlhODFjODUwYzQ5ZDFhZTIzOGRjY2Q="};
}

@end
