//
//  MCResponseSerializer.h
//  Pods
//
//  Created by 曹飞 on 2018/4/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MCBaseRequest;

@interface MCResponseSerializer : NSObject

+ (id)serializerResponse:(MCBaseRequest *)request error:(NSError * _Nullable __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
