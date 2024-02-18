//
//  NSURL+SULoader.m
//  SULoader
//
//  Created by 万众科技 on 16/6/28.
//  Copyright © 2016年 万众科技. All rights reserved.
//

#import "NSURL+SULoader.h"

@implementation NSURL (SULoader)

- (NSURL *)specialSchemeURL {
    //    // 创建 NSURLComponents 对象
    NSURLComponents * urlComponents = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    // 判断是否是 http 或 https
    NSLog(@"mother fucker urlComponents.scheme ::: %@",urlComponents.scheme);
    if ([urlComponents.scheme isEqualToString:@"http"] ) {
        // 修改 scheme 为 myscheme
        urlComponents.scheme = @"myscheme";
    }else if ([urlComponents.scheme isEqualToString:@"https"]) {
        // 修改 scheme 为 myscheme
        urlComponents.scheme = @"myschemes";
    }
    // 获取修改后的 URL
    NSURL *modifiedURL = urlComponents.URL;
    return modifiedURL;
}

- (NSURL *)originalSchemeURL {
    NSURLComponents * urlComponents = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    
    // 判断是否是 http 或 https
    if ([urlComponents.scheme isEqualToString:@"myscheme"] ) {
        // 修改 myscheme 为 http
        urlComponents.scheme = @"http";
    }else if ([urlComponents.scheme isEqualToString:@"myschemes"]) {
        // 修改 myschemes 为 https
        urlComponents.scheme = @"https";
    }
    // 获取修改后的 URL
    NSURL *modifiedURL = urlComponents.URL;
    NSString *modifiedURLString = [modifiedURL absoluteString];
    
    return modifiedURL;
}

@end
