//
//  MCRequestCenter.h
//  AFNetworking
//
//  Created by 曹飞 on 2018/4/18.
//

#import <Foundation/Foundation.h>
#import "MCBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^MCRequestConfigBlock)(__kindof MCBaseRequest *request);
typedef void (^MCRequestProgressBlock)(NSProgress *progress);

@interface MCRequestCenter : NSObject

/// 创建并返回一个新的实例
+ (instancetype)center;

/// 返回一个单例
+ (instancetype)defaultCenter;

/// 请求对象的Class, MCBaseRequest类或者继承于他的类, 默认是MCBaseRequest类
/// 为了满足部分用户项目中设置了继承与MCBaseRequest的基类,为了保存这些基类的配置, 所以用户可以指定Center中调用请求方法时,配置什么类型的请求对象
@property (assign) Class requestMetaClass;

#pragma mark - Instance Method

/**
 @param configBlock 请求对象配置Block
 @return 请求对象
 */
- (__kindof MCBaseRequest *)sendRequest:(nullable MCRequestConfigBlock)configBlock;

/**
 @param configBlock 请求对象配置Block
 @param successBlock 成功回调
 @return 请求对象
 */
- (__kindof MCBaseRequest *)sendRequest:(nullable MCRequestConfigBlock)configBlock
                                success:(nullable MCRequestCompletionBlock)successBlock;

/**
 @param configBlock 请求对象配置Block
 @param failureBlock 失败回调
 @return 请求对象
 */
- (__kindof MCBaseRequest *)sendRequest:(nullable MCRequestConfigBlock)configBlock
                                failure:(nullable MCRequestCompletionBlock)failureBlock;

/**
 @param configBlock 请求对象配置Block
 @param successBlock 成功回调
 @param failureBlock 失败回调
 @return 请求对象
 */
- (__kindof MCBaseRequest *)sendRequest:(nullable MCRequestConfigBlock)configBlock
                                success:(nullable MCRequestCompletionBlock)successBlock
                                failure:(nullable MCRequestCompletionBlock)failureBlock;

/**
 @param klass 指定请求对象类
 @param configBlock 请求对象配置Block
 @param successBlock 成功回调
 @param failureBlock 失败回调
 @return 请求对象
 */
- (__kindof MCBaseRequest *)sendRequestByAppointedClass:(Class)klass
                                            configBlock:(nullable MCRequestConfigBlock)configBlock
                                                success:(nullable MCRequestCompletionBlock)successBlock
                                                failure:(nullable MCRequestCompletionBlock)failureBlock;

/**
 @param configBlock 请求对象配置Block
 @param progressBlock 进度回调,根据下载或上传决定哪一种回调
 @param successBlock 成功回调
 @param failureBlock 失败回调
 @return 请求对象
 */
- (__kindof MCBaseRequest *)sendRequest:(nullable MCRequestConfigBlock)configBlock
                          progressBlock:(nullable MCRequestProgressBlock)progressBlock
                                success:(nullable MCRequestCompletionBlock)successBlock
                                failure:(nullable MCRequestCompletionBlock)failureBlock;

/**
 @param klass 指定请求对象类
 @param configBlock 请求对象配置Block
 @param progressBlock 进度回调,根据下载或上传决定哪一种回调
 @param successBlock 成功回调
 @param failureBlock 失败回调
 @return 请求对象
 */
- (__kindof MCBaseRequest *)sendRequestByAppointedClass:(Class)klass
                                            configBlock:(nullable MCRequestConfigBlock)configBlock
                                          progressBlock:(nullable MCRequestProgressBlock)progressBlock
                                                success:(nullable MCRequestCompletionBlock)successBlock
                                                failure:(nullable MCRequestCompletionBlock)failureBlock;

#pragma mark - Class Method

///-------------------------------------------
/// @name 类方法内部采用defaultCenter对象调用实例方法
///-------------------------------------------

/**
 @param configBlock 请求对象配置Block
 @return 请求对象
 */
+ (__kindof MCBaseRequest *)sendRequest:(nullable MCRequestConfigBlock)configBlock;

/**
 @param configBlock 请求对象配置Block
 @param successBlock 成功回调
 @return 请求对象
 */
+ (__kindof MCBaseRequest *)sendRequest:(nullable MCRequestConfigBlock)configBlock
                       success:(nullable MCRequestCompletionBlock)successBlock;

/**
 @param configBlock 请求对象配置Block
 @param failureBlock 失败回调
 @return 请求对象
 */
+ (__kindof MCBaseRequest *)sendRequest:(nullable MCRequestConfigBlock)configBlock
                       failure:(nullable MCRequestCompletionBlock)failureBlock;

/**
 @param configBlock 请求对象配置Block
 @param successBlock 成功回调
 @param failureBlock 失败回调
 @return 请求对象
 */
+ (__kindof MCBaseRequest *)sendRequest:(nullable MCRequestConfigBlock)configBlock
                       success:(nullable MCRequestCompletionBlock)successBlock
                       failure:(nullable MCRequestCompletionBlock)failureBlock;

/**
 @param klass 指定请求对象类
 @param configBlock 请求对象配置Block
 @param successBlock 成功回调
 @param failureBlock 失败回调
 @return 请求对象
 */
+ (__kindof MCBaseRequest *)sendRequestByAppointedClass:(Class)klass
                                            configBlock:(nullable MCRequestConfigBlock)configBlock
                                                success:(nullable MCRequestCompletionBlock)successBlock
                                                failure:(nullable MCRequestCompletionBlock)failureBlock;

/**
 @param configBlock 请求对象配置Block
 @param progressBlock 进度回调,根据下载或上传决定哪一种回调
 @param successBlock 成功回调
 @param failureBlock 失败回调
 @return 请求对象
 */
+ (__kindof MCBaseRequest *)sendRequest:(nullable MCRequestConfigBlock)configBlock
                 progressBlock:(nullable MCRequestProgressBlock)progressBlock
                       success:(nullable MCRequestCompletionBlock)successBlock
                       failure:(nullable MCRequestCompletionBlock)failureBlock;

/**
 @param klass 指定请求对象类
 @param configBlock 请求对象配置Block
 @param progressBlock 进度回调,根据下载或上传决定哪一种回调
 @param successBlock 成功回调
 @param failureBlock 失败回调
 @return 请求对象
 */
+ (__kindof MCBaseRequest *)sendRequestByAppointedClass:(Class)klass
                                            configBlock:(nullable MCRequestConfigBlock)configBlock
                                          progressBlock:(nullable MCRequestProgressBlock)progressBlock
                                                success:(nullable MCRequestCompletionBlock)successBlock
                                                failure:(nullable MCRequestCompletionBlock)failureBlock;

@end

NS_ASSUME_NONNULL_END
