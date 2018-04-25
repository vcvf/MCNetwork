//
//  MCNetworkPrivate.h
//  Pods
//
//  Created by 曹飞 on 2018/4/10.
//

#import <Foundation/Foundation.h>
#import "MCBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT void MCNetLog(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);

@interface MCNetworkUtils : NSObject

+ (NSString *)md5StringFromString:(NSString *)string;
+ (BOOL)validateResumeData:(NSData *)data;

/**
 返回简短的请求URL, 根据MCBaseRequest的'BaseUR' 和 'requestUrl'组成
 该URL可以用作DownlaodTask的存储key
 */
+ (NSString *)simpleUrlForRequest:(MCBaseRequest *)request;

@end

@interface MCBaseRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end

@interface MCBaseRequest ()

- (void)clearCompletionBlock;

@end

@interface MCBaseRequest (Setter)

@property (nonatomic, strong, readwrite) NSURLSessionTask *requestTask;
@property (nonatomic, strong, readwrite) id responseObject;
@property (nonatomic, strong, readwrite) NSError *error;
@property (nonatomic, copy, readonly) MCRequestCompletionBlock successCompletionBlock;
@property (nonatomic, copy, readonly) MCRequestCompletionBlock failureCompletionBlock;
@property (nonatomic, copy, readonly) MCRequestDownloadProgressBlock downloadProgressBlock;
@property (nonatomic, copy, readonly) MCRequestUploadProgressBlock uploadProgressBlock;

@end

NS_ASSUME_NONNULL_END
