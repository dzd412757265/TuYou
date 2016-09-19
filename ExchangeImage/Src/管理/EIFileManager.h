//
//  EIFileManager.h
//  ExchangeImage
//
//  Created by 张博成 on 16/7/29.
//  Copyright © 2016年 Beijing Jianjian Technology Development Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EIFileManager : NSObject

//tmp 文件目录
+ (NSString *)tempPath;

//Library 文件目录
+ (NSString *)libraryPath;

//Document文件目录
+ (NSString *)documentPath;

//cache文件目录
+ (NSString *)cachePath;

//计算目录的size 大小，单位为byte
+ (long long)fileSizeOfPath:(NSString *)path;

//创建需要的路径，在cache下面
+ (NSString*)filesRootPath:(NSString *)fileName;

//删除目下制定的文件
+ (BOOL)removeFileAtPath:(NSString *)filePath;

@end
