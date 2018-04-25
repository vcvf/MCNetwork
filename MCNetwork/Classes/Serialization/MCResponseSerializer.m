//
//  MCResponseSerializer.m
//  Pods
//
//  Created by 曹飞 on 2018/4/10.
//

#import "MCResponseSerializer.h"
#import "MCNetworkPrivate.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

@implementation MCResponseSerializer

+ (id)serializerResponse:(MCBaseRequest *)request error:(NSError * _Nullable __autoreleasing *)error {
    if ([request.responseObject isKindOfClass:[NSData class]]) {
        switch (request.responseSerializerType) {
            case MCResponseSerializerTypeHTTP:
                // Defalut serializer. Do nothing
                return request.responseObject;
            case MCResponseSerializerTypeJSON:
                return [[[self class] jsonResponseSerializer] responseObjectForResponse:request.response data:request.responseObject error:error];
                break;
            case MCResponseSerializerTypeXMLParser:
                return [[[self class] xmlParserResponseSerializer] responseObjectForResponse:request.response data:request.responseObject error:error];
                break;
        }
    }
    return request.responseObject;
}

+ (AFJSONResponseSerializer *)jsonResponseSerializer {
    static AFJSONResponseSerializer *instance = nil;
    if (instance == nil) {
        instance = [AFJSONResponseSerializer serializer];
        instance.acceptableContentTypes = [[self class] acceptableContentTypes];
    }
    return instance;
}

+ (AFXMLParserResponseSerializer *)xmlParserResponseSerializer {
    static AFXMLParserResponseSerializer *instance = nil;
    if (instance == nil) {
        instance = [AFXMLParserResponseSerializer serializer];
        instance.acceptableContentTypes = [[self class] acceptableContentTypes];
    }
    return instance;
}

+ (NSSet *)acceptableContentTypes {
    static NSSet *set = nil;
    if (set == nil) {
        set = [NSSet setWithObjects:
               @"application/json",
               @"text/html",
               @"image/jpeg",
               @"image/png",
               @"text/json",
               @"application/octet-stream",
               @"text/javascript",
               @"text/plain",
               @"application/x-javascript",
               @"application/xml",
               @"text/xml",nil];
    }
    return set;
}

@end
