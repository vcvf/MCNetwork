//
//  MCBaseRequest.m
//  Pods
//
//  Created by 曹飞 on 2018/4/9.
//

#import "MCBaseRequest.h"
#import "MCBaseRequestAgent.h"
#import "MCNetworkPrivate.h"

@interface MCBaseRequest ()

@property (nonatomic, strong, readwrite) NSURLSessionTask *requestTask;
@property (nonatomic, strong, readwrite) id responseObject;
@property (nonatomic, strong, readwrite) NSError *error;
@property (nonatomic, strong, readwrite) NSPointerArray *weakRequestAccessories;
@property (nonatomic, copy, readwrite) MCRequestCompletionBlock successCompletionBlock;
@property (nonatomic, copy, readwrite) MCRequestCompletionBlock failureCompletionBlock;
@property (nonatomic, copy, readwrite) MCRequestDownloadProgressBlock downloadProgressBlock;
@property (nonatomic, copy, readwrite) MCRequestUploadProgressBlock uploadProgressBlock;

@end

@implementation MCBaseRequest

#pragma mark - Request and Response Information

- (NSHTTPURLResponse *)response {
    return (NSHTTPURLResponse *)self.requestTask.response;
}

- (BOOL)isCancelled {
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateCanceling;
}

- (BOOL)isExecuting {
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateRunning;
}

#pragma mark - Request Configuration

- (void)addAccessory:(id<MCRequestAccessory>)accessory {
    if (!self.weakRequestAccessories) {
        self.weakRequestAccessories = [NSPointerArray weakObjectsPointerArray];
    }
    [self.weakRequestAccessories addPointer:(__bridge void * _Nullable)(accessory)];
}

- (NSArray<id<MCRequestAccessory>> *)requestAccessories {
    return self.weakRequestAccessories.allObjects;
}

#pragma mark - Request Action

- (void)start {
    if ([[MCBaseRequestAgent sharedAgent] containsRequest:self]) {
        return;
    }
    
    [self toggleAccessoriesWillStartCallBack];
    [[MCBaseRequestAgent sharedAgent] addRequest:self];
}

- (void)stop {
    [self toggleAccessoriesWillStopCallBack];
    [[MCBaseRequestAgent sharedAgent] cancelRequest:self];
    [self toggleAccessoriesDidStopCallBack];
}

- (void)startWithCompletionBlockWithSuccess:(nullable MCRequestCompletionBlock)success
                                    failure:(nullable MCRequestCompletionBlock)failure {
    [self startWithDownloadProgress:nil uploadProgress:nil success:success failure:failure];
}

- (void)startWithDownloadProgress:(MCRequestDownloadProgressBlock)progress
                          success:(MCRequestCompletionBlock)success
                          failure:(MCRequestCompletionBlock)failure {
    [self startWithDownloadProgress:progress uploadProgress:nil success:success failure:failure];
}

- (void)startWithUploadProgress:(MCRequestUploadProgressBlock)progress
                        success:(MCRequestCompletionBlock)success
                        failure:(MCRequestCompletionBlock)failure {
    [self startWithDownloadProgress:nil uploadProgress:progress success:success failure:failure];
}

#pragma mark - Private method

- (void)startWithDownloadProgress:(MCRequestDownloadProgressBlock)downloadProgress
                   uploadProgress:(MCRequestUploadProgressBlock)uploadProgress
                          success:(MCRequestCompletionBlock)success
                          failure:(MCRequestCompletionBlock)failure {
    [self setTaskBlockForDownloadProgress:downloadProgress uploadProgress:uploadProgress success:success failure:failure];
    [self start];
}

- (void)setTaskBlockForDownloadProgress:(MCRequestDownloadProgressBlock)downloadProgress
                         uploadProgress:(MCRequestUploadProgressBlock)uploadProgress
                                success:(MCRequestCompletionBlock)success
                                failure:(MCRequestCompletionBlock)failure {
    self.downloadProgressBlock = downloadProgress;
    self.uploadProgressBlock = uploadProgress;
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)clearCompletionBlock {
    self.downloadProgressBlock = nil;
    self.uploadProgressBlock = nil;
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

#pragma mark - Subclass Override

- (instancetype)init {
    if (self = [super init]) {
        _baseUrl = @"";
        _requestUrl = @"";
        _requestTimeoutInterval = 20;
        _requestParameter = nil;
        _requestMethod = MCRequestMethodPOST;
        _requestSerializerType = MCRequestSerializerTypeHTTP;
        _responseSerializerType = MCResponseSerializerTypeJSON;
        _requestAuthorizationHeaderFieldArray = nil;
        _requestHeaderFieldValueDictionary = nil;
        _buildCustomURLRequest = nil;
        _allowsCellularAccess = YES;
    }
    return self;
}

#pragma mark - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p>{ URL: %@ } { method: %@ } { arguments: %@ }", NSStringFromClass([self class]), self, self.requestTask.currentRequest.URL, self.requestTask.currentRequest.HTTPMethod, self.requestParameter];
}

@end

