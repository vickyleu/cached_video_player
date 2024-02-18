//
//  SUFileHandle.m
//  SULoader
//
//  Created by 万众科技 on 16/6/28.
//  Copyright © 2016年 万众科技. All rights reserved.
//

#import "SUFileHandle.h"

@interface SUFileHandle ()

@property (nonatomic, strong) NSFileHandle * writeFileHandle;
@property (nonatomic, strong) NSFileHandle * readFileHandle;

@end

@implementation SUFileHandle

+ (BOOL)createTempFile {
    NSFileManager * manager = [NSFileManager defaultManager];
    NSString * path = [NSString tempFilePath];
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error:nil];
    }
    return [manager createFileAtPath:path contents:nil attributes:nil];
}

+ (void)writeTempFileData:(NSData *)data {
    NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:[NSString tempFilePath]];
    [handle seekToEndOfFile];
    [handle writeData:data];
}

+ (NSData *)readTempFileDataWithOffset:(NSUInteger)offset length:(NSUInteger)length {
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:[NSString tempFilePath]];
    [handle seekToFileOffset:offset];
    return [handle readDataOfLength:length];
}

+ (void)cacheTempFileWithFileName:(NSString *)name {
    NSFileManager * manager = [NSFileManager defaultManager];
    NSString * cacheFolderPath = [NSString cacheFolderPath];
    if (![manager fileExistsAtPath:cacheFolderPath]) {
        [manager createDirectoryAtPath:cacheFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString * cacheFilePath = [NSString stringWithFormat:@"%@/%@", cacheFolderPath, name];
    BOOL success = [[NSFileManager defaultManager] copyItemAtPath:[NSString tempFilePath] toPath:cacheFilePath error:nil];
    NSLog(@"cache file : %@", success ? @"success" : @"fail");
}

+ (NSString *)cacheFileExistsWithURL:(NSURL *)url {
    NSString * cacheFilePath = [NSString stringWithFormat:@"%@/%@", [NSString cacheFolderPath], [NSString fileNameWithURL:url]];
    NSFileManager*manager=[NSFileManager defaultManager];
    if ([manager fileExistsAtPath:cacheFilePath]) {
        NSError *error;
        NSDictionary *attr=[manager attributesOfItemAtPath:cacheFilePath error:&error];
        if (attr) {
            // 从属性中获取文件大小
            NSNumber *fileSize = [attr objectForKey:NSFileSize];
            NSString *formattedSize = [self formatFileSize:fileSize];
            
            NSLog(@"cacheFilePathcacheFilePathcacheFilePath:::%@",formattedSize);
        } else {
            NSLog(@"获取文件属性时发生错误: %@", [error localizedDescription]);
            
        }
        NSLog(@"cacheFilePathcacheFilePathcacheFilePath:::%@",cacheFilePath);
        return cacheFilePath;
    }
    return nil;
}
+ (NSString *)formatFileSize:(NSNumber *)fileSize {
    double size = [fileSize doubleValue];
    NSArray *units = @[@"Bytes", @"KB", @"MB", @"GB", @"TB"];
    
    NSInteger unitIndex = 0;
    
    while (size > 1024 && unitIndex < (units.count - 1)) {
        size /= 1024.0;
        unitIndex++;
    }
    
    return [NSString stringWithFormat:@"%.2f %@", size, units[unitIndex]];
}

+ (BOOL)clearCache {
    NSFileManager * manager = [NSFileManager defaultManager];
    return [manager removeItemAtPath:[NSString cacheFolderPath] error:nil];
}

@end
