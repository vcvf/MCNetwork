//
//  MCNetworkDefine.h
//  Pods
//
//  Created by 曹飞 on 2018/4/9.
//

#ifndef MCNetworkDefine_h
#define MCNetworkDefine_h

typedef NS_ENUM(NSInteger, MCRequestMethod) {
    MCRequestMethodGET = 0,
    MCRequestMethodPOST,
    MCRequestMethodHEAD,
    MCRequestMethodPUT,
    MCRequestMethodDELETE,
    MCRequestMethodPATCH,
};

/// 请求序列化类型
typedef NS_ENUM(NSInteger, MCRequestSerializerType) {
    MCRequestSerializerTypeHTTP = 0,
    MCRequestSerializerTypeJSON,
};

/// 响应序列化类型
typedef NS_ENUM(NSInteger, MCResponseSerializerType) {
    /// NSData type
    MCResponseSerializerTypeHTTP = 0,
    /// JSON object type
    MCResponseSerializerTypeJSON,
    /// NSXMLParser type
    MCResponseSerializerTypeXMLParser,
};

/// 请求优先级
typedef NS_ENUM(NSInteger, MCRequestPriority) {
    MCRequestPriorityLow = -4L,
    MCRequestPriorityDefault = 0,
    MCRequestPriorityHigh = 4,
};


@class MCBaseRequest;

/// 该网络请求回调代理, 在主线程中返回
@protocol MCRequestDelegate <NSObject>

@optional

/// 请求成功回调
- (void)requestFinished:(__kindof MCBaseRequest *)request;

/// 请求失败回调
- (void)requestFailed:(__kindof MCBaseRequest *)request;

@end


/// 网络请求状态回调, 在主线程中返回
@protocol MCRequestAccessory <NSObject>

@optional

/// 即将开始请求
- (void)requestWillStart:(id)request;

/// 即将结束请求, 在 'requestFinished:' 和 'successCompletionBlock' 之前执行
- (void)requestWillStop:(id)request;

/// 请求已经结束, 在 'requestFinished:' 和 'successCompletionBlock' 之后执行
- (void)requestDidStop:(id)request;

@end

#endif /* MCNetworkDefine_h */
