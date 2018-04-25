//
//  MCRequestCenter.m
//  AFNetworking
//
//  Created by 曹飞 on 2018/4/18.
//

#import "MCRequestCenter.h"

@implementation MCRequestCenter

+ (instancetype)center {
    return [[[self class] alloc] init];
}

+ (instancetype)defaultCenter {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self center];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _requestMetaClass = [MCBaseRequest class];
    }
    return self;
}

#pragma mark - Instance Method

- (__kindof MCBaseRequest *)sendRequest:(MCRequestConfigBlock)configBlock {
    return [self sendRequestByAppointedClass:_requestMetaClass configBlock:configBlock progressBlock:nil success:nil failure:nil];
}

- (__kindof MCBaseRequest *)sendRequest:(MCRequestConfigBlock)configBlock
                                success:(MCRequestCompletionBlock)successBlock {
    return [self sendRequestByAppointedClass:_requestMetaClass configBlock:configBlock progressBlock:nil success:successBlock failure:nil];
}

- (__kindof MCBaseRequest *)sendRequest:(MCRequestConfigBlock)configBlock
                                failure:(MCRequestCompletionBlock)failureBlock {
    return [self sendRequestByAppointedClass:_requestMetaClass configBlock:configBlock progressBlock:nil success:nil failure:failureBlock];
}

- (__kindof MCBaseRequest *)sendRequest:(MCRequestConfigBlock)configBlock
                                success:(MCRequestCompletionBlock)successBlock
                                failure:(MCRequestCompletionBlock)failureBlock {
    return [self sendRequestByAppointedClass:_requestMetaClass configBlock:configBlock progressBlock:nil success:successBlock failure:failureBlock];
}

- (__kindof MCBaseRequest *)sendRequestByAppointedClass:(Class)klass
                                            configBlock:(MCRequestConfigBlock)configBlock
                                                success:(MCRequestCompletionBlock)successBlock
                                                failure:(MCRequestCompletionBlock)failureBlock {
    return [self sendRequestByAppointedClass:klass configBlock:configBlock progressBlock:nil success:successBlock failure:failureBlock];
}

- (__kindof MCBaseRequest *)sendRequest:(MCRequestConfigBlock)configBlock
                          progressBlock:(MCRequestProgressBlock)progressBlock
                                success:(MCRequestCompletionBlock)successBlock
                                failure:(MCRequestCompletionBlock)failureBlock {
    return [self sendRequestByAppointedClass:_requestMetaClass configBlock:configBlock progressBlock:progressBlock success:successBlock failure:failureBlock];
}

- (__kindof MCBaseRequest *)sendRequestByAppointedClass:(Class)klass
                                            configBlock:(MCRequestConfigBlock)configBlock
                                          progressBlock:(MCRequestProgressBlock)progressBlock
                                                success:(MCRequestCompletionBlock)successBlock
                                                failure:(MCRequestCompletionBlock)failureBlock {
    // 该Class只能以MCBaseRequest为元类
    NSParameterAssert(![klass isKindOfClass:[MCBaseRequest class]]);

    // 利用多态特性,并利用block配置好请求对象
    MCBaseRequest *request = [[klass alloc] init];
    if(configBlock) configBlock(request);

    if (request.constructiongBodyBlock) {
        [request startWithUploadProgress:progressBlock success:successBlock failure:failureBlock];
    } else if (request.downloadFilePath) {
        [request startWithDownloadProgress:progressBlock success:successBlock failure:failureBlock];
    }
    
    return request;
}

#pragma mark - Class Method

+ (__kindof MCBaseRequest *)sendRequest:(MCRequestConfigBlock)configBlock {
    return [[MCRequestCenter defaultCenter] sendRequestByAppointedClass:[MCRequestCenter defaultCenter].requestMetaClass configBlock:configBlock progressBlock:nil success:nil failure:nil];
}

+ (__kindof MCBaseRequest *)sendRequest:(MCRequestConfigBlock)configBlock
                       success:(MCRequestCompletionBlock)successBlock {
    return [[MCRequestCenter defaultCenter] sendRequestByAppointedClass:[MCRequestCenter defaultCenter].requestMetaClass configBlock:configBlock progressBlock:nil success:successBlock failure:nil];
}

+ (__kindof MCBaseRequest *)sendRequest:(MCRequestConfigBlock)configBlock
                       failure:(MCRequestCompletionBlock)failureBlock {
    return [[MCRequestCenter defaultCenter] sendRequestByAppointedClass:[MCRequestCenter defaultCenter].requestMetaClass configBlock:configBlock progressBlock:nil success:nil failure:failureBlock];
}

+ (__kindof MCBaseRequest *)sendRequest:(MCRequestConfigBlock)configBlock
                       success:(MCRequestCompletionBlock)successBlock
                       failure:(MCRequestCompletionBlock)failureBlock {
    return [[MCRequestCenter defaultCenter] sendRequestByAppointedClass:[MCRequestCenter defaultCenter].requestMetaClass configBlock:configBlock progressBlock:nil success:successBlock failure:failureBlock];
}

+ (__kindof MCBaseRequest *)sendRequestByAppointedClass:(Class)klass
                                            configBlock:(nullable MCRequestConfigBlock)configBlock
                                                success:(nullable MCRequestCompletionBlock)successBlock
                                                failure:(nullable MCRequestCompletionBlock)failureBlock {
    return [[MCRequestCenter defaultCenter] sendRequestByAppointedClass:klass configBlock:configBlock progressBlock:nil success:successBlock failure:failureBlock];
}

+ (__kindof MCBaseRequest *)sendRequest:(MCRequestConfigBlock)configBlock
                 progressBlock:(MCRequestProgressBlock)progressBlock
                       success:(MCRequestCompletionBlock)successBlock
                       failure:(MCRequestCompletionBlock)failureBlock {
    return [[MCRequestCenter defaultCenter] sendRequestByAppointedClass:[MCRequestCenter defaultCenter].requestMetaClass configBlock:configBlock progressBlock:progressBlock success:successBlock failure:failureBlock];
}

+ (__kindof MCBaseRequest *)sendRequestByAppointedClass:(Class)klass
                                            configBlock:(nullable MCRequestConfigBlock)configBlock
                                          progressBlock:(nullable MCRequestProgressBlock)progressBlock
                                                success:(nullable MCRequestCompletionBlock)successBlock
                                                failure:(nullable MCRequestCompletionBlock)failureBlock {
    return [[MCRequestCenter defaultCenter] sendRequestByAppointedClass:klass configBlock:configBlock progressBlock:progressBlock success:successBlock failure:failureBlock];
}

@end
