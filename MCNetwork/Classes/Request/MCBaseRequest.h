//
//  MCBaseRequest.h
//  Pods
//
//  Created by 曹飞 on 2018/4/9.
//

#import <Foundation/Foundation.h>
#import "MCNetworkDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class MCBaseRequest;
@protocol AFMultipartFormData;

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);
typedef void (^MCRequestDownloadProgressBlock)(NSProgress *downloadProgress);
typedef void (^MCRequestUploadProgressBlock)(NSProgress *uploadProgress);
typedef void (^MCRequestCompletionBlock)(__kindof MCBaseRequest *request);

@interface MCBaseRequest : NSObject

#pragma mark - Request and Response Information

/// 请求任务,只有在start后才不为nil
@property (nonatomic, strong, readonly) NSURLSessionTask *requestTask;

/// 请求响应
@property (nonatomic, strong, readonly) NSHTTPURLResponse *response;

/// 响应结果
@property (nonatomic, strong, readonly) id responseObject;

/// 请求错误,可以是请求失败或者解析失败
@property (nonatomic, strong, readonly, nullable) NSError *error;

/// 请求任务是否被取消
@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;
/// 请求任务是否正在进行
@property (nonatomic, readonly, getter=isExecuting) BOOL executing;

#pragma mark - Request Configuration

/// Tag可以用来标识一个请求, 默认是0
@property (nonatomic) NSInteger tag;

/// UserInfo可以用来存储附加的信息, 和tag作用差不多, 默认是nil
@property (nonatomic, strong, nullable) NSDictionary *userInfo;

/// 请求回调代理
@property (nonatomic, weak, nullable) id<MCRequestDelegate> delegate;

/// 请求优先级, 只在iOS8+系统有效, 默认是 MCRequestPriorityDefault
@property (nonatomic) MCRequestPriority requestPriority NS_AVAILABLE_IOS(8_0);

@property (nonatomic, strong, readonly, nullable) NSArray<id<MCRequestAccessory>> *requestAccessories;

/// 添加请求额外回调, 参考 'requestAccessories', 添加到里面的对象自动弱引用
- (void)addAccessory:(id<MCRequestAccessory>)accessory;

#pragma mark - DownLoad Request Configuration

///-------------------------------------------
/// @name 设置下载请求的配置, 下载请求只使用GET方法, downloadFilePath为nil, 内部不会选择downloadTask,
/// 使用下载请求, responseObject是个NSURL类型的文件路径
///-------------------------------------------

/// 下载任务的存储路径, downloadFilePath会作为断点下载ResumeData的存储key
@property (nonatomic, copy, nullable) NSString *downloadFilePath;

#pragma mark - Upload Request Configuration

///-------------------------------------------
/// @name 设置上传请求的配置, 上传请求只使用POST方法, 如果constructiongBodyBlock为nil,内部不会选择uploadTask
///-------------------------------------------

/// 用来在POST请求上构建Http body, 默认为nil
@property (nonatomic, copy, nullable) AFConstructingBlock constructiongBodyBlock;

#pragma mark - Request Action

/// 添加到请求队列中去, 并发送请求
- (void)start;

/**
 添加到请求队列中去, 并发送请求
 
 @param success 成功回调, 主线程返回, 如果 'requestFinished:' 也实现, delegate的回调会在block之前调用
 @param failure 失败回调, 主线程返回, 如果 'requestFailed:' 也实现, delegate的回调会在block之前调用
 */
- (void)startWithCompletionBlockWithSuccess:(nullable MCRequestCompletionBlock)success
                                    failure:(nullable MCRequestCompletionBlock)failure;

/**
 添加到请求队列中去, 并发送请求
 
 @param progress 下载进度
 @param success 成功回调, 主线程返回, 如果 'requestFinished:' 也实现, delegate的回调会在block之前调用
 @param failure 失败回调, 主线程返回, 如果 'requestFailed:' 也实现, delegate的回调会在block之前调用
 */
- (void)startWithDownloadProgress:(nullable MCRequestDownloadProgressBlock)progress
                          success:(nullable MCRequestCompletionBlock)success
                          failure:(nullable MCRequestCompletionBlock)failure;

/**
 添加到请求队列中去, 并发送请求
 
 @param progress 上传进度
 @param success 成功回调, 主线程返回, 如果 'requestFinished:' 也实现, delegate的回调会在block之前调用
 @param failure 失败回调, 主线程返回, 如果 'requestFailed:' 也实现, delegate的回调会在block之前调用
 */
- (void)startWithUploadProgress:(nullable MCRequestUploadProgressBlock)progress
                        success:(nullable MCRequestCompletionBlock)success
                        failure:(nullable MCRequestCompletionBlock)failure;

/// 从请求队列中移除, 并取消请求
- (void)stop;

#pragma mark - Subclass Override

/// 请求域名, 规定只包含url.host部分, 如:"http://api.ecook.cn", 默认为nil
@property (nonatomic, copy) NSString *baseUrl;

/// 请求路径, 规定只包含url.path部分, 如:"/recipe/detail", 他将会和 'baseUrl' 以 '[NSURL URLWithString: relativeToURL:]' 方法组合, 默认为nil
@property (nonatomic, copy) NSString *requestUrl;

/// 请求超时时间, 默认 20s
@property (nonatomic, assign) NSTimeInterval requestTimeoutInterval;

/// HTTP请求参数, 默认为nil
@property (nonatomic, strong, nullable) id requestParameter;

/// HTTP请求方法类型, 默认是 'MCRequestMethodPOST'
@property (nonatomic, assign) MCRequestMethod requestMethod;

/// 请求序列化类型, 默认是 'MCRequestSerializerTypeHTTP'
@property (nonatomic, assign) MCRequestSerializerType requestSerializerType;

/// 响应序列化类型, 默认是 'MCResponseSerializerTypeJSON'
@property (nonatomic, assign) MCResponseSerializerType responseSerializerType;

/// 用户名和密码授权, 规定格式为 @[@"Username", @"Password"], 默认为nil
@property (nonatomic, strong, nullable) NSArray<NSString *> *requestAuthorizationHeaderFieldArray;

/// HTTP请求头配置, 默认为nil
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *requestHeaderFieldValueDictionary;

/// 配置一个自定义请求, 如果不为nil, 'requestUrl', 'requestTimeoutInterval', 'requestParameter', 'requestMethod', 'requestSerializerType', 'allowsCellularAccess' 都将被忽略
@property (nonatomic, strong, nullable) NSURLRequest *buildCustomURLRequest;

/// 是否允许移动网络环境下发送请求, 默认为YES
@property (nonatomic, assign) BOOL allowsCellularAccess;

@end

NS_ASSUME_NONNULL_END
