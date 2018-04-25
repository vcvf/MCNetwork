//
//  MCBaseRequestAgent.m
//  Pods
//
//  Created by 曹飞 on 2018/4/9.
//

#import "MCBaseRequestAgent.h"
#import "MCNetworkConfig.h"
#import "MCNetworkPrivate.h"
#import "MCRequestSerializer.h"
#import "MCResponseSerializer.h"
#import <pthread/pthread.h>

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

#define Lock() pthread_mutex_lock(&_lock)
#define Unlock() pthread_mutex_unlock(&_lock)

@implementation MCBaseRequestAgent {
    MCNetworkConfig *_config;
    AFHTTPSessionManager *_manager;
    AFJSONResponseSerializer *_jsonResponseSerializer;
    AFXMLParserResponseSerializer *_xmlParserResponseSerializer;
    NSMutableDictionary<NSNumber *, MCBaseRequest *> *_requestsRecord;
    
    pthread_mutex_t _lock;
}

+ (MCBaseRequestAgent *)sharedAgent {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        dispatch_queue_t processingQueue = dispatch_queue_create("cn.ecook.networkagent.processing", DISPATCH_QUEUE_CONCURRENT);
        pthread_mutex_init(&_lock, NULL);
        _config = [MCNetworkConfig sharedConfig];
        
        _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:_config.sessionConfiguration];
        _manager.securityPolicy = _config.securityPolicy;
        _manager.operationQueue.maxConcurrentOperationCount = _config.maxConcurrentOperationCount;
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.completionQueue = processingQueue;
        _requestsRecord = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addRequest:(MCBaseRequest *)request {
    NSParameterAssert(request != nil);
    
    // 根据NSURLRequest和MCBaseRequest配置生成SessionTask
    NSError * __autoreleasing requestSerializerError = nil;
    NSURLSessionTask *dataTask = [self sessionTaskForRequest:request error:&requestSerializerError];
    request.requestTask = dataTask;
    
    if (requestSerializerError) {
        // failure handle
        [self requestDidFailWithRequest:request error:requestSerializerError];
        return;
    }
    
    NSAssert(request.requestTask != nil, @"requestTask should not be nil");
    
    //设置请求优先级
    if (@available(iOS 8.0, *)) {
        switch (request.requestPriority) {
            case MCRequestPriorityHigh:
                request.requestTask.priority = NSURLSessionTaskPriorityHigh;
                break;
            case MCRequestPriorityLow:
                request.requestTask.priority = NSURLSessionTaskPriorityLow;
                break;
            case MCRequestPriorityDefault:
            default:
                request.requestTask.priority = NSURLSessionTaskPriorityDefault;
                break;
        }
    }
    
    //存储请求对象
    MCNetLog(@"Add Request: %@", NSStringFromClass([request class]));
    [self addRequestToRecord:request];
    [request.requestTask resume];
}

- (void)cancelRequest:(MCBaseRequest *)request {
    NSParameterAssert(request != nil);
    
    if (request.downloadFilePath) {
        NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask *)request.requestTask;
        [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            [self persistentDownloadResumeData:resumeData forRequest:request];
        }];
    } else {
        [request.requestTask cancel];
    }
    
    [self removeRequestFromRecord:request];
    [request clearCompletionBlock];
}

- (BOOL)containsRequest:(MCBaseRequest *)request {
    Lock();
    BOOL contains = ([_requestsRecord objectForKey:@(request.requestTask.taskIdentifier)] != nil);
    Unlock();
    return contains;
}

- (void)cancelAllRequest {
    Lock();
    NSArray *allKeys = [_requestsRecord allKeys];
    Unlock();
    if (allKeys && allKeys.count > 0) {
        NSArray *copiedKeys = [allKeys copy];
        for (NSNumber *key in copiedKeys) {
            Lock();
            MCBaseRequest *request = _requestsRecord[key];
            Unlock();
            [request stop];
        }  
    }
}

- (void)addRequestToRecord:(MCBaseRequest *)request {
    Lock();
    _requestsRecord[@(request.requestTask.taskIdentifier)] = request;
    MCNetLog(@"Request add queue size = %zd", [_requestsRecord count]);
    Unlock();
}

- (void)removeRequestFromRecord:(MCBaseRequest *)request {
    Lock();
    [_requestsRecord removeObjectForKey:@(request.requestTask.taskIdentifier)];
    MCNetLog(@"Request removed queue size = %zd", [_requestsRecord count]);
    Unlock();
}

#pragma mark - Session Task

- (NSURLSessionTask *)sessionTaskForRequest:(MCBaseRequest *)request error:(NSError * _Nullable __autoreleasing *)error {
    if (request.downloadFilePath) {
        return [self downloadTaskForRequest:request error:error];
    } else if (request.constructiongBodyBlock) {
        return [self uploadTaskForRequest:request error:error];
    }
    return [self dataTaskForRequest:request error:error];
}

- (NSURLSessionDataTask *)dataTaskForRequest:(MCBaseRequest *)request error:(NSError * _Nullable __autoreleasing *)error {
    NSURLRequest *URLRequest = [MCRequestSerializer serializerURLRequest:request error:error];

    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [_manager dataTaskWithRequest:URLRequest
                              uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      if (request.uploadProgressBlock) request.uploadProgressBlock(uploadProgress);
                                  });
                              }
                            downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (request.downloadProgressBlock) request.downloadProgressBlock(downloadProgress);
                                });
                            }
                           completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                               // result handle
                               [self handleRequestResult:dataTask responseObject:responseObject error:error];
                           }];
    return dataTask;
}

- (NSURLSessionDownloadTask *)downloadTaskForRequest:(MCBaseRequest *)request error:(NSError * _Nullable __autoreleasing *)error {
    NSURLRequest *URLRequest = [MCRequestSerializer serializerURLRequest:request error:error];
   
    NSString *downloadTaragetPath;
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:request.downloadFilePath isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    // 如果目标存储路劲是一个目录,则从URLRequest的url中取到文件名,拼接到存储路劲, 确保目标路劲是一个文件,不是一个目录
    if (isDirectory) {
        NSString *fileName = [URLRequest.URL lastPathComponent];
        downloadTaragetPath = [NSString pathWithComponents:@[request.downloadFilePath, fileName]];
    } else {
        downloadTaragetPath = request.downloadFilePath;
    }

    // AFN内部用'moveItemAtURL'方法移动下载好的文件到一个路劲
    // 下面这个方法会中止这一移动,如果在改路劲中已经有文件, 因为我们会提前移除目标路劲下已经存在的文件
    // https://github.com/AFNetworking/AFNetworking/issues/3775
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadTaragetPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:downloadTaragetPath error:nil];
    }
    
    NSData *data = [self incompleteDownloadResumeDataForRequest:request];
    BOOL resumeDataIsValid = [MCNetworkUtils validateResumeData:data];
    
    BOOL canBeResumed = resumeDataIsValid;
    BOOL resumeSucceeded = NO;
    
    __block NSURLSessionDownloadTask *downloadTask = nil;
    // 尝试去断点下载 (即使我们验证过本地断点文件的有效性, 这个断点下载操作依然可能失败,并抛出异常)
    if (canBeResumed) {
        @try {
            downloadTask = [_manager downloadTaskWithResumeData:data
                                                       progress:^(NSProgress * _Nonnull downloadProgress) {
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               if (request.downloadProgressBlock) request.downloadProgressBlock(downloadProgress);
                                                           });
                                                       }
                                                    destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                        return [NSURL fileURLWithPath:downloadTaragetPath isDirectory:NO];
                                                    }
                                              completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                                  // result handle
                                                  [self handleRequestResult:downloadTask responseObject:filePath error:error];
                                              }];
            resumeSucceeded = YES;
        } @catch (NSException *exception) {
            MCNetLog(@"Resume download failed, reason = %@", exception.reason);
            resumeSucceeded = NO;
        }
    }
    
    if (!resumeSucceeded) {
        downloadTask = [_manager downloadTaskWithRequest:URLRequest
                                                progress:^(NSProgress * _Nonnull downloadProgress) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        if (request.downloadProgressBlock) request.downloadProgressBlock(downloadProgress);
                                                    });
                                                }
                                             destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                 return [NSURL fileURLWithPath:downloadTaragetPath isDirectory:NO];
                                             }
                                       completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                           // result handle
                                           [self handleRequestResult:downloadTask responseObject:filePath error:error];
                                       }];
    }
    return downloadTask;
}

- (NSURLSessionUploadTask *)uploadTaskForRequest:(MCBaseRequest *)request error:(NSError * _Nullable __autoreleasing *)error {
    NSURLRequest *URLRequest = [MCRequestSerializer serializerURLRequest:request error:error];
    
    __block NSURLSessionUploadTask *uploadTask = nil;
    uploadTask = [_manager uploadTaskWithStreamedRequest:URLRequest
                                                progress:^(NSProgress * _Nonnull uploadProgress) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        if (request.uploadProgressBlock) request.uploadProgressBlock(uploadProgress);
                                                    });
                                                }
                                       completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                           // result handle
                                           [self handleRequestResult:uploadTask responseObject:responseObject error:error];
                                       }];
    return uploadTask;
}

#pragma mark - Handle

- (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error {
    Lock();
    MCBaseRequest *request = _requestsRecord[@(task.taskIdentifier)];
    Unlock();
    
    // 就算请求被取消或者从records中移除,AFNetworking的失败回调依然会调用
    // 所以我们这边忽略被取消的或者被移除的请求
    if (!request) {
        return;
    }
    
    MCNetLog(@"Finished Request: %@", NSStringFromClass([request class]));
    
    NSError * __autoreleasing responseSerializerError = nil;
    request.responseObject = responseObject;
    request.responseObject = [MCResponseSerializer serializerResponse:request error:&responseSerializerError];
    
    NSError *requestError = nil;
    BOOL succeed = YES;
    
    if (error) {
        succeed = NO;
        requestError = error;
    } else if (responseSerializerError) {
        succeed = NO;
        requestError = responseSerializerError;
    }
    
    if (succeed) {
        [self requestDidSuccessWithRequest:request];
    } else {
        [self requestDidFailWithRequest:request error:requestError];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeRequestFromRecord:request];
        [request clearCompletionBlock];
    });
}

- (void)requestDidSuccessWithRequest:(MCBaseRequest *)request {
    if (request.downloadFilePath) {
        // 成功后,清理之前的resumeData
        [self persistentDownloadResumeData:nil forRequest:request];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [request toggleAccessoriesWillStopCallBack];
        
        if ([request.delegate respondsToSelector:@selector(requestFinished:)]) {
            [request.delegate requestFinished:request];
        }
        if (request.successCompletionBlock) {
            request.successCompletionBlock(request);
        }
        
        [request toggleAccessoriesDidStopCallBack];
    });
}

- (void)requestDidFailWithRequest:(MCBaseRequest *)request error:(NSError *)error {
    request.error = error;
    MCNetLog(@"Request %@ failed, status code = %ld, error = %@", NSStringFromClass([request class]), (long)request.response.statusCode, error.localizedDescription);
    
    // 保存断点文件
    NSData *incompleteDownloadData = error.userInfo[NSURLSessionDownloadTaskResumeData];
    if (incompleteDownloadData) {
        [self persistentDownloadResumeData:incompleteDownloadData forRequest:request];
    }
    
    // 如果下载任务失败,移除该响应路劲上的文件
    if ([request.responseObject isKindOfClass:[NSURL class]]) {
        NSURL *url = request.responseObject;
        if (url.isFileURL && [[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
            [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [request toggleAccessoriesWillStopCallBack];
        
        if ([request.delegate respondsToSelector:@selector(requestFailed:)]) {
            [request.delegate requestFailed:request];
        }
        if (request.failureCompletionBlock) {
            request.failureCompletionBlock(request);
        }
        
        [request toggleAccessoriesDidStopCallBack];
    });
}

#pragma mark - Resumable Download

- (NSData *)incompleteDownloadResumeDataForRequest:(MCBaseRequest *)request {
    NSString *persistenceKey = [request.downloadFilePath stringByReplacingOccurrencesOfString:NSHomeDirectory() withString:@""];
    
    if (persistenceKey == nil || persistenceKey.length <= 0) {
        return nil;
    }
    
    NSString *folder = [self incompleteDownloadTempCacheFolder];
    if (folder == nil) {
        return nil;
    }
    
    NSString *validFileName = [folder stringByAppendingPathComponent:[MCNetworkUtils md5StringFromString:persistenceKey]];
    return [NSData dataWithContentsOfFile:validFileName];
}

- (BOOL)persistentDownloadResumeData:(NSData *)resumeData forRequest:(MCBaseRequest *)request {
    NSString *persistenceKey = [request.downloadFilePath stringByReplacingOccurrencesOfString:NSHomeDirectory() withString:@""];
    
    if (persistenceKey == nil || persistenceKey.length <= 0) {
        return NO;
    }
    
    // 再缓存到磁盘中
    NSString *folder = [self incompleteDownloadTempCacheFolder];
    if (folder == nil) {
        return NO;
    }
    
    NSString *validFileName = [folder stringByAppendingPathComponent:[MCNetworkUtils md5StringFromString:persistenceKey]];
    if (resumeData == nil) {
        return [[NSFileManager new] removeItemAtPath:validFileName error:NULL];
    }
    return [resumeData writeToFile:validFileName atomically:YES];
}

- (NSString *)incompleteDownloadTempCacheFolder {
    NSFileManager *fileManager = [NSFileManager new];
    // default manager is not thread safe
    static NSString *cacheFolder;
    
    if (!cacheFolder) {
        NSString *cacheDir = NSTemporaryDirectory();
        cacheFolder = [cacheDir stringByAppendingPathComponent:@"Incomplete"];
    }
    
    NSError *error = nil;
    if (![fileManager createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
        MCNetLog(@"Failed to create download cache directory at %@", cacheFolder);
        cacheFolder = nil;
    }
    
    return cacheFolder;
}

@end
