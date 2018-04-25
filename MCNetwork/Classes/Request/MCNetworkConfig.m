//
//  MCNetworkConfig.m
//  Pods
//
//  Created by 曹飞 on 2018/4/9.
//

#import "MCNetworkConfig.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

@implementation MCNetworkConfig {
    NSMutableArray<id<MCNetworkUrlFilterProtocol>> *_urlFilters;
}

+ (MCNetworkConfig *)sharedConfig {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _baseUrl = @"";
        _urlFilters = [NSMutableArray array];
        _securityPolicy = [AFSecurityPolicy defaultPolicy];
        _maxConcurrentOperationCount = 1;
        _debugLogEnabled = NO;
    }
    return self;
}

- (void)addUrlFilter:(id<MCNetworkUrlFilterProtocol>)filter {
    [_urlFilters addObject:filter];
}

- (void)clearUrlFilter {
    [_urlFilters removeAllObjects];
}

- (NSArray<id<MCNetworkUrlFilterProtocol>> *)urlFilters {
    return [_urlFilters copy];
}

#pragma mark - Description

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p>{ baseUrl:%@ }", NSStringFromClass([self class]), self, self.baseUrl];
}

@end
