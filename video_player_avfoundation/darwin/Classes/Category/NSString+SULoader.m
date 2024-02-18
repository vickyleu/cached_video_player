//
//  NSString+SULoader.m
//  SULoader
//
//  Created by 万众科技 on 16/6/28.
//  Copyright © 2016年 万众科技. All rights reserved.
//

#import "NSString+SULoader.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (SULoader)

+ (NSString *)tempFilePath {
    return [[NSHomeDirectory( ) stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"MusicTemp.mp4"];
}


+ (NSString *)cacheFolderPath {
    return [[NSHomeDirectory( ) stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"MusicCaches"];
}

//+ (NSString *)fileNameWithURL:(NSURL *)url {
//    return [[url.path componentsSeparatedByString:@"/"] lastObject];
//}
+ (NSString *)md5OfString:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

+ (NSString *)fileNameWithURL:(NSURL *)url {
    NSString *urlMD5 = [self md5OfString:url.host];
    NSString *fileMD5 = [self md5OfString:url.lastPathComponent];
    NSString *fileExtension = url.pathExtension;
    NSString *newFileName = [NSString stringWithFormat:@"%@%@.%@", urlMD5, fileMD5, fileExtension];
    return newFileName;
}


@end
