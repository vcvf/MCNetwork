//
//  MCBaseRequestAgent.h
//  Pods
//
//  Created by 曹飞 on 2018/4/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MCBaseRequest;

/**
 MCBaseRequestAgent 是真正的管理请求的生成,发送和结束回调的底层类
 */
@interface MCBaseRequestAgent : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (MCBaseRequestAgent *)sharedAgent;

- (void)addRequest:(MCBaseRequest *)request;

- (void)cancelRequest:(MCBaseRequest *)request;

- (BOOL)containsRequest:(MCBaseRequest *)request;

- (void)cancelAllRequest;

@end

NS_ASSUME_NONNULL_END
