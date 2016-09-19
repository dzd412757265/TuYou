//
//  EIFileManager.m
//  ExchangeImage
//
//  Created by 张博成 on 16/7/29.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import "EIFileManager.h"

@implementation EIFileManager
+ (NSString *)documentPath {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return documentDirectory;
}

+ (NSString *)cachePath {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return documentDirectory;
}

+ (NSString *)libraryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = [paths objectAtIndex:0];
    return libraryPath;
}

// 创建目录
+ (NSString*)filesRootPath:(NSString *)fileName {
    NSString *path = [[EIFileManager cachePath] stringByAppendingPathComponent:fileName];
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
        
    } else {
        //在这里需要创建下目录
        NSError * error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
        assert(!error);
    }
    
    return path;
}

+ (NSString *)tempPath {
    return NSTemporaryDirectory();
}

+ (long long)fileSizeOfPath:(NSString *)path {
    NSFileManager* manager = [NSFileManager defaultManager];
    if (!path || path.length == 0) {
        return 0.f;
    }
    if (![manager fileExistsAtPath:path]) {
        return 0.f;
    }
    //如果path存在，且不是一个目录时，计算文件大小
    BOOL isDirectory;
    if ([manager fileExistsAtPath:path isDirectory:&isDirectory]) {
        if (!isDirectory) {
            NSDictionary *fileInfo = [manager attributesOfItemAtPath:path error:nil];
            return [[fileInfo objectForKey:NSFileSize] floatValue];
        }
    }
    //如果是个目录的话，递归遍历所有子目录
    long long folderSize = 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:path] objectEnumerator];
    NSString* fileName;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [path stringByAppendingPathComponent:fileName];
        folderSize += [[self class] fileSizeOfPath:fileAbsolutePath];
    }
    return folderSize;
}
+ (BOOL)removeFileAtPath:(NSString *)filePath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (!filePath || filePath.length == 0) {
        
        NSLog(@"filePath为空");
        return NO;
    }
    if (![manager fileExistsAtPath:filePath]) {
        
        NSLog(@"未能找到文件");
        
        return NO;
    }
    
    NSError *error;
    return [manager removeItemAtPath:filePath error:&error];
}
@end
