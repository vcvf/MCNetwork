//
//  NormalRequest.m
//  MCNetwork_Example
//
//  Created by 曹飞 on 2018/4/12.
//  Copyright © 2018年 1594717129@qq.com. All rights reserved.
//

#import "NormalRequest.h"

@implementation NormalRequest

- (NSString *)baseUrl {
    return @"http://api.ecook.cn";
}

- (NSString *)requestUrl {
    return @"/public/getHomeData.shtml";
}

@end
