//
//  MCRequestSerializer.m
//  Pods
//
//  Created by 曹飞 on 2018/4/10.
//

#import "MCRequestSerializer.h"
#import "MCBaseRequest.h"
#import "MCNetworkConfig.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

@implementation MCRequestSerializer

+ (NSURLRequest *)serializerURLRequest:(MCBaseRequest *)request error:(NSError * _Nullable __autoreleasing *)error {
    NSURLRequest *customURLRequest = [request buildCustomURLRequest];
    if (customURLRequest) {
        return customURLRequest;
    }
    
    NSString *url = [[self class] buildRequestUrl:request];
    MCRequestMethod method = [request requestMethod];
    id param = [request requestParameter];
    AFConstructingBlock constructingBlock = [request constructiongBodyBlock];
    AFHTTPRequestSerializer *requestSerializer = [[self class] requestSerializerForRequest:request];

    switch (method) {
        case MCRequestMethodGET:
            return [[self class] URLRequestWithHTTPMethod:@"GET" requestSerializer:requestSerializer URLString:url parameters:param error:error];
        case MCRequestMethodPOST:
            return [[self class] URLRequestWithHTTPMethod:@"POST" requestSerializer:requestSerializer URLString:url parameters:param constructiongBodyWithBlock:constructingBlock error:error];
        case MCRequestMethodHEAD:
            return [[self class] URLRequestWithHTTPMethod:@"HEAD" requestSerializer:requestSerializer URLString:url parameters:param error:error];
        case MCRequestMethodPUT:
            return [[self class] URLRequestWithHTTPMethod:@"PUT" requestSerializer:requestSerializer URLString:url parameters:param error:error];
        case MCRequestMethodDELETE:
            return [[self class] URLRequestWithHTTPMethod:@"DELETE" requestSerializer:requestSerializer URLString:url parameters:param error:error];
        case MCRequestMethodPATCH:
            return [[self class] URLRequestWithHTTPMethod:@"PATCH" requestSerializer:requestSerializer URLString:url parameters:param error:error];
    }
}

+ (NSString *)buildRequestUrl:(MCBaseRequest *)request {
    NSParameterAssert(request != nil);
    
    NSString *detailUrl = [request requestUrl];
    NSURL *temp = [NSURL URLWithString:detailUrl];
    // 如果是一个有效的URL
    if (temp && temp.host && temp.scheme) {
        return detailUrl;
    }
    // 是否有预处理URL的需求
    NSArray *filters = [MCNetworkConfig sharedConfig].urlFilters;
    for (id<MCNetworkUrlFilterProtocol> filter in filters) {
        detailUrl = [filter filterUrl:detailUrl withRequest:request];
    }
    
    NSString *baseUrl;
    if ([request baseUrl].length > 0) {
        baseUrl = [request baseUrl];
    } else {
        baseUrl = [MCNetworkConfig sharedConfig].baseUrl;
    }
    
    NSURL *url = [NSURL URLWithString:baseUrl];
    if (baseUrl.length > 0 && ![baseUrl hasSuffix:@"/"]) {
        url = [url URLByAppendingPathComponent:@""];
    }
    
    return [NSURL URLWithString:detailUrl relativeToURL:url].absoluteString;
}

+ (NSURLRequest *)URLRequestWithHTTPMethod:(NSString *)method
                         requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                 URLString:(NSString *)URLString
                                parameters:(id)parameters
                                     error:(NSError * _Nullable __autoreleasing *)error {
    return [[self class] URLRequestWithHTTPMethod:method
                                requestSerializer:requestSerializer
                                        URLString:URLString
                                       parameters:parameters
                       constructiongBodyWithBlock:nil
                                            error:error];
}

+ (NSURLRequest *)URLRequestWithHTTPMethod:(NSString *)method
                         requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                 URLString:(NSString *)URLString
                                parameters:(id)parameters
                constructiongBodyWithBlock:(AFConstructingBlock)block
                                     error:(NSError *__autoreleasing  _Nullable *)error {
    NSMutableURLRequest *request = nil;
    if (block) {
        request = [requestSerializer multipartFormRequestWithMethod:method
                                                          URLString:URLString
                                                         parameters:parameters
                                          constructingBodyWithBlock:block
                                                              error:error];
    } else {
        request = [requestSerializer requestWithMethod:method
                                             URLString:URLString
                                            parameters:parameters
                                                 error:error];
    }
    return request;
}

+ (AFHTTPRequestSerializer *)requestSerializerForRequest:(MCBaseRequest *)request {
    AFHTTPRequestSerializer *requestSerializer = nil;
    if (request.requestSerializerType == MCRequestSerializerTypeHTTP) {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.requestSerializerType == MCRequestSerializerTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    requestSerializer.allowsCellularAccess = [request allowsCellularAccess];
    
    // 如果API需要提供用户名和密码
    NSArray<NSString *> *authorizationHeaderFieldArray = [request requestAuthorizationHeaderFieldArray];
    if (authorizationHeaderFieldArray != nil) {
        [requestSerializer setAuthorizationHeaderFieldWithUsername:authorizationHeaderFieldArray.firstObject
                                                          password:authorizationHeaderFieldArray.lastObject];
    }
    
    // 如果API需要设置自定义请求头
    NSDictionary<NSString *, NSString *> *headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        [headerFieldValueDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull value, BOOL * _Nonnull stop) {
            [requestSerializer setValue:value forHTTPHeaderField:key];
        }];
    }
    return requestSerializer;
}

@end
