//
//  MCNetworkConfig.h
//  Pods
//
//  Created by 曹飞 on 2018/4/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MCBaseRequest;
@class AFSecurityPolicy;

/// MCNetworkUrlFilterProtocol 可以在发送请求前给它添加公共参数
@protocol MCNetworkUrlFilterProtocol <NSObject>

/**
 在请求真的发出前,预处理url

 @param originUrl 请求对象的初始url, 来自 [request requestUrl];
 @param request 请求对象本身
 @return 新的请求url, 就像 [request requestUrl]
 */
- (NSString *)filterUrl:(NSString *)originUrl withRequest:(MCBaseRequest *)request;

@end

/**
 全局请求配置类
 配置后可以用在 'MCBaseRequestAgent' 中形成和改造请求
 */
@interface MCNetworkConfig : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (MCNetworkConfig *)sharedConfig;

/// 域名, e.g. "http://api.ecook.cn", 默认为 @""
@property (nonatomic, copy) NSString *baseUrl;

/// URL filters,
@property (nonatomic, strong, readonly) NSArray<id<MCNetworkUrlFilterProtocol>> *urlFilters;

/// 使用'AFNetworking'的默认安全策略, 可以自己根据 'AFSecurityPolicy'定制
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

/// 用来初始化 'AFHTTPSessionManager', 默认为nil
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;

/// 用来初始化 'AFHTTPSessionManager' 中的operationQueue, 默认是5
@property (assign) NSInteger maxConcurrentOperationCount;

/// 是否开启log调试
@property (nonatomic) BOOL debugLogEnabled;

/// 添加一个新的url预处理对象
- (void)addUrlFilter:(id<MCNetworkUrlFilterProtocol>)filter;

/// 移除所有的url预处理对象
- (void)clearUrlFilter;

@end

NS_ASSUME_NONNULL_END
