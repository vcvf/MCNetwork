//
//  MCRequestSerializer.h
//  Pods
//
//  Created by 曹飞 on 2018/4/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MCBaseRequest;

@interface MCRequestSerializer : NSObject

/**
 根据request对象配置和NetworkConfig解析出NSURLRequest

 @param request 请求对象
 @param error 解析失败回调
 @return NSURLRequest
 */
+ (NSURLRequest *)serializerURLRequest:(MCBaseRequest *)request error:(NSError * _Nullable __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
