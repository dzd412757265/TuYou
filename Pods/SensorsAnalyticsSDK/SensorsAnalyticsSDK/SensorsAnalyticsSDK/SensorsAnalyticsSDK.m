//  SensorsAnalyticsSDK.m
//  SensorsAnalyticsSDK
//
//  Created by 曹犟 on 15/7/1.
//  Copyright (c) 2015年 SensorsData. All rights reserved.

#import <objc/runtime.h>
#include <sys/sysctl.h>

#import <AdSupport/ASIdentifierManager.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIDevice.h>
#import <UIKit/UIScreen.h>

#import "JSONUtil.h"
#import "LFCGzipUtility.h"
#import "MessageQueueBySqlite.h"
#import "NSData+SABase64.h"
#import "SADesignerConnection.h"
#import "SADesignerEventBindingMessage.h"
#import "SADesignerSessionCollection.h"
#import "SAEventBinding.h"
#import "SALogger.h"
#import "SASwizzler.h"
#import "SensorsAnalyticsSDK.h"

#define VERSION @"1.5.7"

#define PROPERTY_LENGTH_LIMITATION 8191

@implementation SensorsAnalyticsDebugException

@end

@interface SensorsAnalyticsSDK()

// 在内部，重新声明成可读写的
@property (atomic, strong) SensorsAnalyticsPeople *people;

@property (atomic, copy) NSString *serverURL;
@property (atomic, copy) NSString *configureURL;
@property (atomic, copy) NSString *vtrackServerURL;

@property (atomic, copy) NSString *distinctId;
@property (atomic, copy) NSString *originalId;
@property (nonatomic, strong) dispatch_queue_t serialQueue;

@property (atomic, strong) NSDictionary *automaticProperties;
@property (atomic, strong) NSDictionary *superProperties;
@property (nonatomic, strong) NSMutableDictionary *trackTimer;

@property (nonatomic, strong) NSPredicate *regexTestName;

@property (atomic, strong) MessageQueueBySqlite *messageQueue;

@property (nonatomic, strong) id abtestDesignerConnection;
@property (atomic, strong) NSSet *eventBindings;

@property (assign, nonatomic) BOOL safariRequestInProgress;

@property (nonatomic, strong) NSTimer *timer;

// 用于 SafariViewController
@property (strong, nonatomic) UIWindow *secondWindow;

- (instancetype)initWithServerURL:(NSString *)serverURL
                  andConfigureURL:(NSString *)configureURL
               andVTrackServerURL:(NSString *)vtrackServerURL
                     andDebugMode:(SensorsAnalyticsDebugMode)debugMode;

@end

@implementation SensorsAnalyticsSDK {
    SensorsAnalyticsDebugMode _debugMode;
    UInt64 _flushBulkSize;
    UInt64 _flushInterval;
    UIWindow *_vtrackWindow;
    NSDateFormatter *_dateFormatter;
}

static SensorsAnalyticsSDK *sharedInstance = nil;

#pragma mark - Initialization

+ (SensorsAnalyticsSDK *)sharedInstanceWithServerURL:(NSString *)serverURL
                                     andConfigureURL:(NSString *)configureURL
                                        andDebugMode:(SensorsAnalyticsDebugMode)debugMode {
    // 根据参数 <code>configureURL</code> 自动生成 <code>vtrackServerURL</code>
    NSURL *url = [NSURL URLWithString:configureURL];
    
    // 将 URI Path (/api/vtrack/config/iOS.conf) 替换成 VTrack WebSocket 的 '/api/ws'
    UInt64 pathComponentSize = [url pathComponents].count;
    for (UInt64 i = 2; i < pathComponentSize; ++i) {
        url = [url URLByDeletingLastPathComponent];
    }
    url = [url URLByAppendingPathComponent:@"ws"];

    // 将 URL Scheme 替换成 'ws:'
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    components.scheme = @"ws";

    NSString *vtrackServerURL = [components.URL absoluteString];
    
    return [SensorsAnalyticsSDK sharedInstanceWithServerURL:serverURL
                                            andConfigureURL:configureURL
                                         andVTrackServerURL:vtrackServerURL
                                               andDebugMode:debugMode];
}


+ (SensorsAnalyticsSDK *)sharedInstanceWithServerURL:(NSString *)serverURL
                                     andConfigureURL:(NSString *)configureURL
                                  andVTrackServerURL:(NSString *)vtrackServerURL
                                        andDebugMode:(SensorsAnalyticsDebugMode)debugMode {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initWithServerURL:serverURL
                                          andConfigureURL:configureURL
                                       andVTrackServerURL:vtrackServerURL
                                             andDebugMode:debugMode];
    });
    return sharedInstance;
}

+ (SensorsAnalyticsSDK *)sharedInstance {
    if (sharedInstance == nil) {
        SAError(@"sharedInstanceWithServerURL:andConfigureURL:andVTrackServerURL:andDebugMode: should be called before calling sharedInstance");
    }
    return sharedInstance;
}

+ (UInt64)getCurrentTime {
    UInt64 time = [[NSDate date] timeIntervalSince1970] * 1000;
    return time;
}

+ (NSString *)getUniqueHardwareId:(BOOL *)isReal {
    NSString *distinctId = NULL;

    // 宏 SENSORS_ANALYTICS_IDFA 定义时，优先使用IDFA
#if defined(SENSORS_ANALYTICS_IDFA)
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) {
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
        SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
        NSUUID *uuid = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
        distinctId = [uuid UUIDString];
        *isReal = YES;
    }
#endif
    
    // 没有IDFA，则使用IDFV
    if (!distinctId && NSClassFromString(@"UIDevice")) {
        distinctId = [[UIDevice currentDevice].identifierForVendor UUIDString];
        *isReal = YES;
    }
    
    // 没有IDFV，则使用UUID
    if (!distinctId) {
        SADebug(@"%@ error getting device identifier: falling back to uuid", self);
        distinctId = [[NSUUID UUID] UUIDString];
        *isReal = NO;
    }
    
    return distinctId;
}

- (instancetype)initWithServerURL:(NSString *)serverURL
                  andConfigureURL:(NSString *)configureURL
               andVTrackServerURL:(NSString *)vtrackServerURL
                     andDebugMode:(SensorsAnalyticsDebugMode)debugMode {
    if (serverURL == nil || [serverURL length] == 0) {
        @throw [NSException exceptionWithName:@"InvalidArgumentException"
                                       reason:@"serverURL is nil"
                                     userInfo:nil];
    }
    
    if (debugMode != SensorsAnalyticsDebugOff) {
        // 将 Server URI Path 替换成 Debug 模式的 '/debug'
        NSURL *url = [[[NSURL URLWithString:serverURL] URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"debug"];
        serverURL = [url absoluteString];
    }
    
    // 将 Configure URI Path 末尾补齐 iOS.conf
    NSURL *url = [NSURL URLWithString:configureURL];
    if ([[url lastPathComponent] isEqualToString:@"config"]) {
        url = [url URLByAppendingPathComponent:@"iOS.conf"];
    }
    configureURL = [url absoluteString];
    
    SADebug(@"%@ Initializing the instance of Sensors Analytics SDK with server url '%@', configure url '%@', vtrack server url '%@'",
          self, serverURL, configureURL, vtrackServerURL);
    
    if (self = [self init]) {
        self.people = [[SensorsAnalyticsPeople alloc] initWithSDK:self];
        
        self.serverURL = serverURL;
        self.configureURL = configureURL;
        self.vtrackServerURL = vtrackServerURL;
        _debugMode = debugMode;
        
        _flushInterval = 15 * 1000;
        _flushBulkSize = 100;
        _vtrackWindow = nil;
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss.SSS"];
        
        self.checkForEventBindingsOnActive = YES;
        self.flushBeforeEnterBackground = YES;
        self.safariRequestInProgress = NO;

        self.messageQueue = [[MessageQueueBySqlite alloc] initWithFilePath:[self filePathForData:@"message-v2"]];
        if (self.messageQueue == nil) {
            @throw [NSException exceptionWithName:@"SqliteException"
                                           reason:@"init Message Queue in Sqlite fail"
                                         userInfo:nil];
        }
        
        // 取上一次进程退出时保存的distinctId、superProperties和eventBindings
        [self unarchive];
        
        self.automaticProperties = [self collectAutomaticProperties];
        self.trackTimer = [NSMutableDictionary dictionary];
        
        NSString *namePattern = @"^((?!^distinct_id$|^original_id$|^time$|^event$|^properties$|^id$|^first_id$|^second_id$|^users$|^events$|^event$|^user_id$|^date$|^datetime$)[a-zA-Z_$][a-zA-Z\\d_$]{0,99})$";
        self.regexTestName = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", namePattern];
        
        NSString *label = [NSString stringWithFormat:@"com.sensorsdata.%@.%p", @"test", self];
        self.serialQueue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
        
        [self setUpListeners];
        
        [self executeEventBindings:self.eventBindings];
        
        [self checkForConfigure];
 
        [self startFlushTimer];
    }
    
    return self;
}

- (void)flushByType:(NSString *)type withSize:(int)flushSize andFlushMethod:(BOOL (^)(NSArray *))flushMethod {
    while (true) {
        NSArray *recordArray = [self.messageQueue getFirstRecords:flushSize withType:type];
        if (recordArray == nil) {
            SAError(@"Failed to get records from SQLite.");
            break;
        }
        
        if ([recordArray count] == 0 || !flushMethod(recordArray)) {
            break;
        }
        
        if (![self.messageQueue removeFirstRecords:flushSize withType:type]) {
            SAError(@"Failed to remove records from SQLite.");
            break;
        }

        SADebug(@"flush one batch success.");
    }
}

- (void)_flush:(BOOL) vacuumAfterFlushing {
    // 使用 Post 发送数据
    BOOL (^flushByPost)(NSArray *) = ^(NSArray *recordArray) {
        // 1. 先完成这一系列Json字符串的拼接
        NSString *jsonString = [NSString stringWithFormat:@"[%@]",[recordArray componentsJoinedByString:@","]];
        // 2. 使用gzip进行压缩
        NSData *zippedData = [LFCGzipUtility gzipData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        // 3. base64
        NSString *b64String = [zippedData sa_base64EncodedString];
        b64String = (id)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                  (CFStringRef)b64String,
                                                                                  NULL,
                                                                                  CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                  kCFStringEncodingUTF8));
        
        NSString *postBody = [NSString stringWithFormat:@"gzip=1&data_list=%@", b64String];
        
        NSURL *URL = [NSURL URLWithString:self.serverURL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
        [request setValue:@"SensorsAnalytics iOS SDK" forHTTPHeaderField:@"User-Agent"];
        if (_debugMode == SensorsAnalyticsDebugOnly) {
            [request setValue:@"true" forHTTPHeaderField:@"Dry-Run"];
        }
        
        dispatch_semaphore_t flushSem = dispatch_semaphore_create(0);
        __block BOOL flushSucc = YES;
        
        void (^block)(NSData*, NSURLResponse*, NSError*) = ^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                NSString *errMsg = [NSString stringWithFormat:@"%@ network failure: %@", self, error];
                SAError(@"%@", errMsg);
                flushSucc = NO;
                dispatch_semaphore_signal(flushSem);
                return;
            }
            
            if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
                flushSucc = NO;
                dispatch_semaphore_signal(flushSem);
                return;
            }
            
            NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse*)response;
            if([urlResponse statusCode] != 200) {
                NSString *urlResponseContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSString *errMsg = [NSString stringWithFormat:@"%@ flush failure with response '%@'.", self, urlResponseContent];
                if (_debugMode != SensorsAnalyticsDebugOff) {
                    SAError(@"==========================================================================");
                    SAError(@"%@ invalid message: %@", self, jsonString);
                    SAError(@"%@ ret_code: %ld", self, [urlResponse statusCode]);
                    SAError(@"%@ ret_content: %@", self, urlResponseContent);
                    
                    if ([urlResponse statusCode] >= 300) {
                        @throw [SensorsAnalyticsDebugException exceptionWithName:@"IllegalDataException"
                                                                          reason:errMsg
                                                                        userInfo:nil];
                    }
                } else {
                    SAError(@"%@", errMsg);
                    flushSucc = NO;
                    dispatch_semaphore_signal(flushSem);
                    return;
                }
            } else {
                if (_debugMode != SensorsAnalyticsDebugOff) {
                    SAError(@"==========================================================================");
                    SAError(@"%@ valid message: %@", self, jsonString);
                }
            }
            
            dispatch_semaphore_signal(flushSem);
        };
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:block];
        
        [task resume];
#else
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
         ^(NSURLResponse *response, NSData* data, NSError *error) {
             return block(data, response, error);
         }];
#endif
        
        dispatch_semaphore_wait(flushSem, DISPATCH_TIME_FOREVER);
        
        return flushSucc;
    };
    
    // 使用 SFSafariViewController 发送数据 (>= iOS 9.0)
    BOOL (^flushBySafariVC)(NSArray *) = ^(NSArray *recordArray) {
        if (self.safariRequestInProgress) {
            return NO;
        }
        
        self.safariRequestInProgress = YES;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
        Class SFSafariViewControllerClass = NSClassFromString(@"SFSafariViewController");
        if (!SFSafariViewControllerClass) {
            SAError(@"Cannot use cookie-based installation tracking. Please import the SafariService.framework.");
            self.safariRequestInProgress = NO;
            return YES;
        }
        
        // 1. 先完成这一系列Json字符串的拼接
        NSString *jsonString = [NSString stringWithFormat:@"[%@]",[recordArray componentsJoinedByString:@","]];
        // 2. 使用gzip进行压缩
        NSData *zippedData = [LFCGzipUtility gzipData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        // 3. base64
        NSString *b64String = [zippedData sa_base64EncodedString];
        b64String = (id)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                  (CFStringRef)b64String,
                                                                                  NULL,
                                                                                  CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                  kCFStringEncodingUTF8));
        
        NSURL *url = [NSURL URLWithString:self.serverURL];
        NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
        if (components.query.length > 0) {
            NSString *urlQuery = [[NSString alloc] initWithFormat:@"%@&gzip=1&data_list=%@", components.percentEncodedQuery, b64String];
            components.percentEncodedQuery = urlQuery;
        } else {
            NSString *urlQuery = [[NSString alloc] initWithFormat:@"gzip=1&data_list=%@", b64String];
            components.percentEncodedQuery = urlQuery;
        }
        
        // Must be on next run loop to avoid a warning
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIViewController *safController = [[SFSafariViewControllerClass alloc] initWithURL:[components URL]];
            
            UIViewController *windowRootController = [[UIViewController alloc] init];
            
            if (self.vtrackWindow == nil) {
                self.secondWindow = [[UIWindow alloc] initWithFrame:[[[[UIApplication sharedApplication] delegate] window] bounds]];
            } else {
                self.secondWindow = [[UIWindow alloc] initWithFrame:[self.vtrackWindow bounds]];
            }
            self.secondWindow.rootViewController = windowRootController;
            self.secondWindow.windowLevel = UIWindowLevelNormal - 1;
            [self.secondWindow setHidden:NO];
            [self.secondWindow setAlpha:0];
            
            // Add the safari view controller using view controller containment
            [windowRootController addChildViewController:safController];
            [windowRootController.view addSubview:safController.view];
            [safController didMoveToParentViewController:windowRootController];
            
            // Give a little bit of time for safari to load the request.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // Remove the safari view controller from view controller containment
                [safController willMoveToParentViewController:nil];
                [safController.view removeFromSuperview];
                [safController removeFromParentViewController];
                
                // Remove the window and release it's strong reference. This is important to ensure that
                // applications using view controller based status bar appearance are restored.
                [self.secondWindow removeFromSuperview];
                self.secondWindow = nil;
                
                self.safariRequestInProgress = NO;
            });
            
            if (_debugMode != SensorsAnalyticsDebugOff) {
                SAError(@"%@ The validation in DEBUG mode is unavailable while using track_installtion. Please check the result with 'debug_data_viewer'.", self);
                SAError(@"%@ 使用 track_installation 时无法直接获得 Debug 模式数据校验结果，请登录 Sensors Analytics 并进入 '数据接入辅助工具' 查看校验结果。", self);
            }
        });
#else
        // DO NOTHING
#endif
        return YES;
    };

    [self flushByType:@"Post" withSize:(_debugMode == SensorsAnalyticsDebugOff ? 50 : 1) andFlushMethod:flushByPost];
    [self flushByType:@"SFSafariViewController" withSize:50 andFlushMethod:flushBySafariVC];
    
    if (vacuumAfterFlushing) {
        if (![self.messageQueue vacuum]) {
            SAError(@"Failed to VACUUM SQLite.");
        }
    }
}

- (void)flush {
    dispatch_async(self.serialQueue, ^{
        [self _flush:NO];
    });
}

- (BOOL) isValidName : (NSString *) name {
    return [self.regexTestName evaluateWithObject:name];
}

- (NSString *)filePathForData:(NSString *)data {
    NSString *filename = [NSString stringWithFormat:@"sensorsanalytics-%@.plist", data];
    NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]
            stringByAppendingPathComponent:filename];
    SADebug(@"filepath for %@ is %@", data, filepath);
    return filepath;
}

- (void)enqueueWithType:(NSString *)type andEvent:(NSDictionary *)e {
    NSMutableDictionary *event = [[NSMutableDictionary alloc] initWithDictionary:e];
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] initWithDictionary:[event objectForKey:@"properties"]];
    
    NSString *from_vtrack = [properties objectForKey:@"$from_vtrack"];
    if (from_vtrack != nil && [from_vtrack length] > 0) {
        // 来自可视化埋点的事件
        BOOL binding_depolyed = [[properties objectForKey:@"$binding_depolyed"] boolValue];
        if (!binding_depolyed) {
            // 未部署的事件，不发送正式的track
            return;
        }
        
        NSString *binding_trigger_id = [[properties objectForKey:@"$binding_trigger_id"] stringValue];
        
        NSMutableDictionary *libProperties = [[NSMutableDictionary alloc] initWithDictionary:[event objectForKey:@"lib"]];
        
        [libProperties setValue:@"vtrack" forKey:@"$lib_method"];
        [libProperties setValue:binding_trigger_id forKey:@"$lib_detail"];
        
        [properties removeObjectsForKeys:@[@"$binding_depolyed", @"$binding_path", @"$binding_trigger_id"]];
        
        [event setObject:properties forKey:@"properties"];
        [event setObject:libProperties forKey:@"lib"];
    }
    
    if ([properties objectForKey:@"$ios_install_source"]) {
        [self.messageQueue addObejct:event withType:@"SFSafariViewController"];
    } else {
        [self.messageQueue addObejct:event withType:@"Post"];
    }
}

- (void)track:(NSString *)event withProperties:(NSDictionary *)propertieDict withType:(NSString *)type {
    // 对于type是track数据，它们的event名称是有意义的
    if ([type isEqualToString:@"track"]) {
        if (event == nil || [event length] == 0) {
            NSString *errMsg = @"SensorsAnalytics track called with empty event parameter";
            if (_debugMode != SensorsAnalyticsDebugOff) {
                @throw [SensorsAnalyticsDebugException exceptionWithName:@"InvalidDataException"
                                                                  reason:errMsg
                                                                userInfo:nil];
            } else {
                SAError(@"%@", errMsg);
                return;
            }
        }
        if (![self isValidName:event]) {
            NSString *errMsg = [NSString stringWithFormat:@"Event name[%@] not valid", event];
            if (_debugMode != SensorsAnalyticsDebugOff) {
                @throw [SensorsAnalyticsDebugException exceptionWithName:@"InvalidDataException"
                                                                  reason:errMsg
                                                                userInfo:nil];
            } else {
                SAError(@"%@", errMsg);
                return;
            }
        }
    }
    
    if (propertieDict) {
        if (![self assertPropertyTypes:[propertieDict copy] withEventType:type]) {
            SAError(@"%@ failed to track event.", self);
            return;
        }
    }
    
    NSNumber *timeStamp = @([[self class] getCurrentTime]);
    
    NSMutableDictionary *libProperties = [[NSMutableDictionary alloc] init];
    
    [libProperties setValue:[_automaticProperties objectForKey:@"$lib"] forKey:@"$lib"];
    [libProperties setValue:[_automaticProperties objectForKey:@"$lib_version"] forKey:@"$lib_version"];
    
    id app_version = [_automaticProperties objectForKey:@"$app_version"];
    if (app_version) {
        [libProperties setValue:app_version forKey:@"$app_version"];
    }
    
    [libProperties setValue:@"code" forKey:@"$lib_method"];
    
    NSArray *syms = [NSThread callStackSymbols];
    
    if ([syms count] > 2) {
        NSString *trace = [syms objectAtIndex:2];
        
        NSRange start = [trace rangeOfString:@"["];
        NSRange end = [trace rangeOfString:@"]"];
        if (start.location != NSNotFound && end.location != NSNotFound && end.location > start.location) {
            NSString *trace_info = [trace substringWithRange:NSMakeRange(start.location+1, end.location-(start.location+1))];
            NSRange split = [trace_info rangeOfString:@" "];
            NSString *class = [trace_info substringWithRange:NSMakeRange(0, split.location)];
            NSString *function = [trace_info substringWithRange:NSMakeRange(split.location + 1, trace_info.length-(split.location + 1))];
            
            NSString *detail = [NSString stringWithFormat:@"%@##%@####", class, function];
            [libProperties setValue:detail forKey:@"$lib_detail"];
        }
    }

    dispatch_async(self.serialQueue, ^{
        NSMutableDictionary *p = [NSMutableDictionary dictionary];
        if ([type isEqualToString:@"track"] || [type isEqualToString:@"track_signup"]) {
            // track / track_signup 类型的请求，还是要加上各种公共property
            // 这里注意下顺序，按照优先级从低到高，依次是automaticProperties, superProperties和propertieDict
            [p addEntriesFromDictionary:self.automaticProperties];
            [p addEntriesFromDictionary:_superProperties];

            // 是否WIFI是每次track的时候需要判断一次的
            NSString *networkType = [SensorsAnalyticsSDK getNetWorkStates];
            [p setObject:networkType forKey:@"$network_type"];
            
            if ([networkType isEqualToString:@"WIFI"]) {
                [p setObject:@YES forKey:@"$wifi"];
            } else {
                [p setObject:@NO forKey:@"$wifi"];
            }
            
            NSNumber *eventBegin = self.trackTimer[event];
            if (eventBegin) {
                [self.trackTimer removeObjectForKey:event];
                [p setObject:@([timeStamp longValue] - [eventBegin longValue]) forKey:@"event_duration"];
            }
        }
        
        if (propertieDict) {
            for (id key in propertieDict) {
                NSObject *obj = propertieDict[key];
                if ([obj isKindOfClass:[NSDate class]]) {
                    // 序列化所有 NSDate 类型
                    NSString *dateStr = [_dateFormatter stringFromDate:(NSDate *)obj];
                    [p setObject:dateStr forKey:key];
                } else {
                    [p setObject:obj forKey:key];
                }
            }
        }
        
        NSDictionary *e;
        if ([type isEqualToString:@"track_signup"]) {
            e = @{
                  @"event": event,
                  @"properties": [NSDictionary dictionaryWithDictionary:p],
                  @"distinct_id": self.distinctId,
                  @"original_id": self.originalId,
                  @"time": timeStamp,
                  @"type": type,
                  @"lib": libProperties,
                  };
        } else if([type isEqualToString:@"track"]){
            e = @{
                  @"event": event,
                  @"properties": [NSDictionary dictionaryWithDictionary:p],
                  @"distinct_id": self.distinctId,
                  @"time": timeStamp,
                  @"type": type,
                  @"lib": libProperties,
                  };
        } else {
            // 此时应该都是对Profile的操作
            e = @{
                  @"properties": [NSDictionary dictionaryWithDictionary:p],
                  @"distinct_id": self.distinctId,
                  @"time": timeStamp,
                  @"type": type,
                  @"lib": libProperties,
                  };
        }
        
        [self enqueueWithType:type andEvent:[e copy]];
        
        if (_debugMode != SensorsAnalyticsDebugOff) {
            // 在DEBUG模式下，直接发送事件
            [self _flush:NO];
        } else {
            // 否则，在满足发送条件时，发送事件
            if ([type isEqualToString:@"track_signup"] || [[self messageQueue] count] >= self.flushBulkSize) {
                // 2. 判断当前网络类型是否是3G/4G/WIFI
                NSString *networkType = [SensorsAnalyticsSDK getNetWorkStates];
                if (![networkType isEqualToString:@"NULL"] && ![networkType isEqualToString:@"2G"]) {
                    [self _flush:YES];
                }
            }
        }
    });
}

- (void)track:(NSString *)event withProperties:(NSDictionary *)propertieDict {
    [self track:event withProperties:propertieDict withType:@"track"];
}

- (void)track:(NSString *)event {
    [self track:event withProperties:nil withType:@"track"];
}

- (void)trackTimer:(NSString *)event {
    NSNumber *eventBegin = @([[self class] getCurrentTime]);
    
    if (![self isValidName:event]) {
        NSString *errMsg = [NSString stringWithFormat:@"Event name[%@] not valid", event];
        if (_debugMode != SensorsAnalyticsDebugOff) {
            @throw [SensorsAnalyticsDebugException exceptionWithName:@"InvalidDataException"
                                                              reason:errMsg
                                                            userInfo:nil];
        } else {
            SAError(@"%@", errMsg);
            return;
        }
    }
    
    dispatch_async(self.serialQueue, ^{
        self.trackTimer[event] = eventBegin;
    });
}

- (void)clearTrackTimer {
    dispatch_async(self.serialQueue, ^{
        self.trackTimer = [NSMutableDictionary dictionary];
    });
}


- (void)signUp:(NSString *)newDistinctId withProperties:(NSDictionary *)propertieDict {
    [self identify:newDistinctId];
    [self track:@"$SignUp" withProperties:propertieDict withType:@"track_signup"];
}

- (void)trackSignUp:(NSString *)newDistinctId withProperties:(NSDictionary *)propertieDict {
    [self identify:newDistinctId];
    [self track:@"$SignUp" withProperties:propertieDict withType:@"track_signup"];
}

- (void)signUp:(NSString *)newDistinctId {
    [self identify:newDistinctId];
    [self track:@"$SignUp" withProperties:nil withType:@"track_signup"];
}

- (void)trackSignUp:(NSString *)newDistinctId {
    [self identify:newDistinctId];
    [self track:@"$SignUp" withProperties:nil withType:@"track_signup"];
}

- (void)trackInstallation:(NSString *)event withProperties:(NSDictionary *)propertyDict {
    // 追踪渠道是特殊功能，需要同时发送 track 和 profile_set_once
    
    // 先发送 track
    NSMutableDictionary *eventProperties;
    if (propertyDict == nil) {
        eventProperties = [[NSMutableDictionary alloc] init];
    } else {
        eventProperties = [[NSMutableDictionary alloc] initWithDictionary:propertyDict];
    }
    
    [eventProperties setValue:@"" forKey:@"$ios_install_source"];
    [self track:event withProperties:eventProperties withType:@"track"];
    
    // 再发送 profile_set_once
    NSDictionary *profiles = @{@"$ios_install_source" : @""};
    [self track:nil withProperties:profiles withType:@"profile_set_once"];
}

- (void)trackInstallation:(NSString *)event {
    // 追踪渠道是特殊功能，需要同时发送 track 和 profile_set_once
    
    NSDictionary *properties = @{@"$ios_install_source" : @""};
    
    // 先发送 track
    [self track:event withProperties:properties withType:@"track"];
    
    // 再发送 profile_set_once
    [self track:nil withProperties:properties withType:@"profile_set_once"];
}

- (void)identify:(NSString *)distinctId {
    if (distinctId == nil || distinctId.length == 0) {
        SAError(@"%@ cannot identify blank distinct id: %@", self, distinctId);
        @throw [NSException exceptionWithName:@"InvalidDataException" reason:@"SensorsAnalytics distinct_id should not be nil or empty" userInfo:nil];
    }
    if (distinctId.length > 255) {
        SAError(@"%@ max length of distinct_id is 255, distinct_id: %@", self, distinctId);
        @throw [NSException exceptionWithName:@"InvalidDataException" reason:@"SensorsAnalytics max length of distinct_id is 255" userInfo:nil];
    }
    dispatch_async(self.serialQueue, ^{
        // 先把之前的distinctId设为originalId
        self.originalId = self.distinctId;
        // 更新distinctId
        self.distinctId = distinctId;
        [self archiveDistinctId];
    });
}

- (NSString *)deviceModel {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char answer[size];
    sysctlbyname("hw.machine", answer, &size, NULL, 0);
    NSString *results = @(answer);
    return results;
}

- (NSString *)libVersion {
    return VERSION;
}

- (BOOL)assertPropertyTypes:(NSDictionary *)properties withEventType:(NSString *)eventType {
    for (id __unused k in properties) {
        // key 必须是NSString
        if (![k isKindOfClass: [NSString class]]) {
            NSString *errMsg = @"Property Key should by NSString";
            if (_debugMode != SensorsAnalyticsDebugOff) {
                @throw [SensorsAnalyticsDebugException exceptionWithName:@"InvalidDataException"
                                                                  reason:errMsg
                                                                userInfo:nil];
            } else {
                SAError(@"%@", errMsg);
                return NO;
            }
        }
        
        // key的名称必须符合要求
        if (![self isValidName: k]) {
            NSString *errMsg = [NSString stringWithFormat:@"property name[%@] is not valid", k];
            if (_debugMode != SensorsAnalyticsDebugOff) {
                @throw [SensorsAnalyticsDebugException exceptionWithName:@"InvalidDataException"
                                                                  reason:errMsg
                                                                userInfo:nil];
            } else {
                SAError(@"%@", errMsg);
                return NO;
            }
        }
        
        // value的类型检查
        if( ![properties[k] isKindOfClass:[NSString class]] &&
           ![properties[k] isKindOfClass:[NSNumber class]] &&
           ![properties[k] isKindOfClass:[NSNull class]] &&
           ![properties[k] isKindOfClass:[NSSet class]] &&
           ![properties[k] isKindOfClass:[NSDate class]]) {
            NSString * errMsg = [NSString stringWithFormat:@"%@ property values must be NSString, NSNumber, NSSet or NSDate. got: %@ %@", self, [properties[k] class], properties[k]];
            if (_debugMode != SensorsAnalyticsDebugOff) {
                @throw [SensorsAnalyticsDebugException exceptionWithName:@"InvalidDataException"
                                                                  reason:errMsg
                                                                userInfo:nil];
            } else {
                SAError(@"%@", errMsg);
                return NO;
            }
        }
        
        // NSSet 类型的属性中，每个元素必须是 NSString 类型
        if ([properties[k] isKindOfClass:[NSSet class]]) {
            NSEnumerator *enumerator = [((NSSet *)properties[k]) objectEnumerator];
            id object;
            while (object = [enumerator nextObject]) {
                if (![object isKindOfClass:[NSString class]]) {
                    NSString * errMsg = [NSString stringWithFormat:@"%@ value of NSSet must be NSString. got: %@ %@", self, [object class], object];
                    if (_debugMode != SensorsAnalyticsDebugOff) {
                        @throw [SensorsAnalyticsDebugException exceptionWithName:@"InvalidDataException"
                                                                          reason:errMsg
                                                                        userInfo:nil];
                    } else {
                        SAError(@"%@", errMsg);
                        return NO;
                    }
                }
                NSUInteger objLength = [((NSString *)object) lengthOfBytesUsingEncoding:NSUnicodeStringEncoding];
                if (objLength > PROPERTY_LENGTH_LIMITATION) {
                    NSString * errMsg = [NSString stringWithFormat:@"%@ The value in NSString is too long: %@", self, (NSString *)object];
                    if (_debugMode != SensorsAnalyticsDebugOff) {
                        @throw [SensorsAnalyticsDebugException exceptionWithName:@"InvalidDataException"
                                                                          reason:errMsg
                                                                        userInfo:nil];
                    } else {
                        SAError(@"%@", errMsg);
                        // 打印错误日志，但不抛弃数据
                    }
                }
            }
        }
        
        // NSString 检查长度，但忽略部分属性
        if ([properties[k] isKindOfClass:[NSString class]] && ![k isEqualToString:@"$binding_path"]) {
            NSUInteger objLength = [((NSString *)properties[k]) lengthOfBytesUsingEncoding:NSUnicodeStringEncoding];
            if (objLength > PROPERTY_LENGTH_LIMITATION) {
                NSString * errMsg = [NSString stringWithFormat:@"%@ The value in NSString is too long: %@", self, (NSString *)properties[k]];
                if (_debugMode != SensorsAnalyticsDebugOff) {
                    @throw [SensorsAnalyticsDebugException exceptionWithName:@"InvalidDataException"
                                                                      reason:errMsg
                                                                    userInfo:nil];
                } else {
                    SAError(@"%@", errMsg);
                    // 打印错误日志，但不抛弃数据
                }
            }
        }
        
        // profileIncrement的属性必须是NSNumber
        if ([eventType isEqualToString:@"profile_increment"]) {
            if (![properties[k] isKindOfClass:[NSNumber class]]) {
                NSString *errMsg = [NSString stringWithFormat:@"%@ profile_increment value must be NSNumber. got: %@ %@", self, [properties[k] class], properties[k]];
                if (_debugMode != SensorsAnalyticsDebugOff) {
                    @throw [SensorsAnalyticsDebugException exceptionWithName:@"InvalidDataException"
                                                                      reason:errMsg
                                                                    userInfo:nil];
                } else {
                    SAError(@"%@", errMsg);
                    return NO;
                }
            }
        }
        
        // profileAppend的属性必须是个NSSet
        if ([eventType isEqualToString:@"profile_append"]) {
            if (![properties[k] isKindOfClass:[NSSet class]]) {
                NSString *errMsg = [NSString stringWithFormat:@"%@ profile_append value must be NSSet. got %@ %@", self, [properties[k] class], properties[k]];
                if (_debugMode != SensorsAnalyticsDebugOff) {
                    @throw [SensorsAnalyticsDebugException exceptionWithName:@"InvalidDataException"
                                                                      reason:errMsg
                                                                    userInfo:nil];
                } else {
                    SAError(@"%@", errMsg);
                    return NO;
                }
            }
        }
    }
    return YES;
}

- (NSDictionary *)collectAutomaticProperties {
    NSMutableDictionary *p = [NSMutableDictionary dictionary];
    UIDevice *device = [UIDevice currentDevice];
    NSString *deviceModel = [self deviceModel];
    struct CGSize size = [UIScreen mainScreen].bounds.size;
    CTCarrier *carrier = [[[CTTelephonyNetworkInfo alloc] init] subscriberCellularProvider];
    // Use setValue semantics to avoid adding keys where value can be nil.
    [p setValue:[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] forKey:@"$app_version"];
    [p setValue:carrier.carrierName forKey:@"$carrier"];
    [p addEntriesFromDictionary:@{
                                  @"$lib": @"iOS",
                                  @"$lib_version": [self libVersion],
                                  @"$manufacturer": @"Apple",
                                  @"$os": [device systemName],
                                  @"$os_version": [device systemVersion],
                                  @"$model": deviceModel,
                                  @"$screen_height": @((NSInteger)size.height),
                                  @"$screen_width": @((NSInteger)size.width),
                                      }];
    return [p copy];
}

- (void)registerSuperProperties:(NSDictionary *)propertyDict {
    propertyDict = [propertyDict copy];
    if (![self assertPropertyTypes:propertyDict withEventType:@"register_super_properties"]) {
        SAError(@"%@ failed to register super properties.", self);
        return;
    }
    dispatch_async(self.serialQueue, ^{
        // 注意这里的顺序，发生冲突时是以propertyDict为准，所以它是后加入的
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:_superProperties];
        [tmp addEntriesFromDictionary:propertyDict];
        _superProperties = [NSDictionary dictionaryWithDictionary:tmp];
        [self archiveSuperProperties];
    });
}

- (void)unregisterSuperProperty:(NSString *)property {
    dispatch_async(self.serialQueue, ^{
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:_superProperties];
        if (tmp[property] != nil) {
            [tmp removeObjectForKey:property];
        }
        _superProperties = [NSDictionary dictionaryWithDictionary:tmp];
        [self archiveSuperProperties];
    });
    
}

- (void)clearSuperProperties {
    dispatch_async(self.serialQueue, ^{
        _superProperties = @{};
        [self archiveSuperProperties];
    });
}

- (NSDictionary *)currentSuperProperties {
    return [_superProperties copy];
}

#pragma mark - Local caches

- (void)unarchive {
    [self unarchiveDistinctId];
    [self unarchiveSuperProperties];
    [self unarchiveEventBindings];
}

- (id)unarchiveFromFile:(NSString *)filePath {
    id unarchivedData = nil;
    @try {
        unarchivedData = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    } @catch (NSException *exception) {
        SAError(@"%@ unable to unarchive data in %@, starting fresh", self, filePath);
        unarchivedData = nil;
    }
    return unarchivedData;
}

- (void)unarchiveDistinctId {
    NSString *archivedDistinctId = (NSString *)[self unarchiveFromFile:[self filePathForData:@"distinct_id"]];
    if (archivedDistinctId == nil) {
        BOOL isReal;
        self.distinctId = [[self class] getUniqueHardwareId:&isReal];
        [self archiveDistinctId];
    } else {
        self.distinctId = archivedDistinctId;
    }
}

- (void)unarchiveSuperProperties {
    NSDictionary *archivedSuperProperties = (NSDictionary *)[self unarchiveFromFile:[self filePathForData:@"super_properties"]];
    if (archivedSuperProperties == nil) {
        _superProperties = [NSDictionary dictionary];
    } else {
        _superProperties = [archivedSuperProperties copy];
    }
}

- (void)unarchiveEventBindings {
    NSSet *eventBindings = (NSSet *)[self unarchiveFromFile:[self filePathForData:@"event_bindings"]];
    SADebug(@"%@ unarchive event bindings %@", self, eventBindings);
    if (eventBindings == nil || ![eventBindings isKindOfClass:[NSSet class]]) {
        eventBindings = [NSSet set];
    }
    self.eventBindings = eventBindings;
}

- (void)archiveDistinctId {
    NSString *filePath = [self filePathForData:@"distinct_id"];
    if (![NSKeyedArchiver archiveRootObject:[[self distinctId] copy] toFile:filePath]) {
        SAError(@"%@ unable to archive distinctId", self);
    }
    SADebug(@"%@ archived distinctId", self);
}

- (void)archiveSuperProperties {
    NSString *filePath = [self filePathForData:@"super_properties"];
    if (![NSKeyedArchiver archiveRootObject:[self.superProperties copy] toFile:filePath]) {
        SAError(@"%@ unable to archive super properties", self);
    }
    SADebug(@"%@ archive super properties data", self);
}

- (void)archiveEventBindings {
    NSString *filePath = [self filePathForData:@"event_bindings"];
    if (![NSKeyedArchiver archiveRootObject:[self.eventBindings copy] toFile:filePath]) {
        SAError(@"%@ unable to archive tracking events data", self);
    }
    SADebug(@"%@ archive tracking events data, %@", self, [self.eventBindings copy]);
}

#pragma mark - Network control

+ (NSString *)getNetWorkStates {
#ifdef SA_UT
    SADebug(@"In unit test, set NetWorkStates to wifi");
    return @"WIFI";
#endif
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *children = [[[app valueForKeyPath:@"statusBar"]valueForKeyPath:@"foregroundView"]subviews];
    NSString *state = [[NSString alloc]init];
    state = @"NULL";
    int netType = 0;
    //获取到网络返回码
    for (id child in children) {
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取到状态栏
            netType = [[child valueForKeyPath:@"dataNetworkType"]intValue];
            switch (netType) {
                case 0:
                    state = @"NULL";
                    //无网模式
                    break;
                case 1:
                    state = @"2G";
                    break;
                case 2:
                    state = @"3G";
                    break;
                case 3:
                    state = @"4G";
                    break;
                case 5:
                    state = @"WIFI";
                    break;
                default:
                    break;
            }
        }
    }
    return state;
}

- (UInt64)flushInterval {
    @synchronized(self) {
        return _flushInterval;
    }
}

- (void)setFlushInterval:(UInt64)interval {
    @synchronized(self) {
        _flushInterval = interval;
    }
    [self flush];
    [self startFlushTimer];
}

- (void)startFlushTimer {
    [self stopFlushTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_flushInterval > 0) {
            double interval = _flushInterval > 100 ? (double)_flushInterval / 1000.0 : 0.1f;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                          target:self
                                                        selector:@selector(flush)
                                                        userInfo:nil
                                                         repeats:YES];
        }
    });
}

- (void)stopFlushTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.timer) {
            [self.timer invalidate];
        }
        self.timer = nil;
    });
}

- (UInt64)flushBulkSize {
    @synchronized(self) {
        return _flushBulkSize;
    }
}

- (void)setFlushBulkSize:(UInt64)bulkSize {
    @synchronized(self) {
        _flushBulkSize = bulkSize;
    }
}

- (UIWindow *)vtrackWindow {
    @synchronized(self) {
        return _vtrackWindow;
    }
}

- (void)setVtrackWindow:(UIWindow *)vtrackWindow {
    @synchronized(self) {
        _vtrackWindow = vtrackWindow;
    }
}

#pragma mark - UIApplication Events

- (void)setUpListeners {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidBecomeActive:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillResignActive:)
                               name:UIApplicationWillResignActiveNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidEnterBackground:)
                               name:UIApplicationDidEnterBackgroundNotification
                             object:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(connectGestureRecognized:)];
        recognizer.minimumPressDuration = 3;
        recognizer.cancelsTouchesInView = NO;
#if TARGET_IPHONE_SIMULATOR
        // 模拟器
        recognizer.numberOfTouchesRequired = 2;
#elif TARGET_OS_IPHONE
        // 物理机
        recognizer.numberOfTouchesRequired = 3;
#endif
        [[UIApplication sharedApplication].keyWindow addGestureRecognizer:recognizer];
    });
}

- (void)connectGestureRecognized:(id)sender {
    if(!sender
       || ([sender isKindOfClass:[UIGestureRecognizer class]]
           && ((UIGestureRecognizer *)sender).state == UIGestureRecognizerStateBegan )) {
        [self connectToVTrackDesigner];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    SADebug(@"%@ application did become active", self);
    
    [self startFlushTimer];
    
    if (self.checkForEventBindingsOnActive) {
        [self checkForConfigure];
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    SADebug(@"%@ application will resign active", self);
    
    [self stopFlushTimer];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    SADebug(@"%@ application did enter background", self);
    
    if (self.flushBeforeEnterBackground) {
        [self flush];
    }
    
    if ([self.abtestDesignerConnection isKindOfClass:[SADesignerConnection class]]
        && ((SADesignerConnection *)self.abtestDesignerConnection).connected) {
        ((SADesignerConnection *)self.abtestDesignerConnection).sessionEnded = YES;
        [((SADesignerConnection *)self.abtestDesignerConnection) close];
    }
}

#pragma mark - SensorsData VTrack Analytics

- (void)checkForConfigure {
    SADebug(@"%@ starting configure check", self);
    
    if (self.configureURL == nil || self.configureURL.length < 1) {
        return;
    }
    
    void (^block)(NSData*, NSURLResponse*, NSError*) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            SAError(@"%@ decide check http error: %@", self, error);
            return;
        }
        
        NSError *parseError;
        NSDictionary *object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if (parseError) {
            SAError(@"%@ decide check json error: %@, data: %@", self, error, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            return;
        }
        
        NSDictionary *rawEventBindings = object[@"event_bindings"];
        if (rawEventBindings && [rawEventBindings isKindOfClass:[NSDictionary class]]) {
            NSArray *eventBindings = rawEventBindings[@"events"];
            if (eventBindings && [eventBindings isKindOfClass:[NSArray class]]) {
                // Finished bindings are those which should no longer be run.
                [self.eventBindings makeObjectsPerformSelector:NSSelectorFromString(@"stop")];
                
                NSMutableSet *parsedEventBindings = [NSMutableSet set];
                for (id obj in eventBindings) {
                    SAEventBinding *binding = [SAEventBinding bindingWithJSONObject:obj];
                    if (binding) {
                        [binding execute];
                        [parsedEventBindings addObject:binding];
                    }
                }
                
                SADebug(@"%@ found %lu tracking events: %@", self, (unsigned long)[parsedEventBindings count], parsedEventBindings);
                
                self.eventBindings = parsedEventBindings;
                [self archiveEventBindings];
            } else {
                SADebug(@"%@ the configure of VTrack is not loaded: %@", self, object);
            }
        } else {
            SADebug(@"%@ the configure of VTrack is not loaded: %@", self, object);
        }
    };
    
    NSURL *URL = [NSURL URLWithString:self.configureURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"GET"];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:block];
    
    [task resume];
#else
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData* data, NSError *error) {
         return block(data, response, error);
     }];
#endif
}

- (void)connectToVTrackDesigner {
    [self connectToVTrackDesigner:NO];
}

- (void)connectToVTrackDesigner:(BOOL)reconnect {
    if (self.vtrackServerURL == nil || self.vtrackServerURL.length < 1) {
        return;
    }
    
    if ([self.abtestDesignerConnection isKindOfClass:[SADesignerConnection class]]
            && ((SADesignerConnection *)self.abtestDesignerConnection).connected) {
        SADebug(@"VTrack connection already exists");
    } else {
        static UInt64 oldInterval;

        __weak SensorsAnalyticsSDK *weakSelf = self;
        
        void (^connectCallback)(void) = ^{
            __strong SensorsAnalyticsSDK *strongSelf = weakSelf;
            oldInterval = strongSelf.flushInterval;
            strongSelf.flushInterval = 1000;
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            if (strongSelf) {
                NSMutableSet *eventBindings = [strongSelf.eventBindings mutableCopy];
                SAEventBindingCollection *bindingCollection = [[SAEventBindingCollection alloc] initWithEvents:eventBindings];
                
                SADesignerConnection *connection = strongSelf.abtestDesignerConnection;
                [connection setSessionObject:bindingCollection forKey:@"event_bindings"];

                void (^block)(id, SEL, NSString*, id) = ^(id obj, SEL sel, NSString *type, NSDictionary *e) {
                    if (![type isEqualToString:@"track"]) {
                        return;
                    }
                    
                    NSMutableDictionary *event = [[NSMutableDictionary alloc] initWithDictionary:e];
                    NSMutableDictionary *properties = [[NSMutableDictionary alloc] initWithDictionary:[event objectForKey:@"properties"]];
                    
                    NSString *from_vtrack = [properties objectForKey:@"$from_vtrack"];
                    if (from_vtrack == nil || [from_vtrack length] < 1) {
                        return;
                    }
                    
                    // 来自可视化埋点的事件
                    BOOL binding_depolyed = [[properties objectForKey:@"$binding_depolyed"] boolValue];
                    NSInteger binding_trigger_id = [[properties objectForKey:@"$binding_trigger_id"] integerValue];
                    NSString *binding_path = [properties objectForKey:@"$binding_path"];
                    
                    [properties removeObjectsForKeys:@[@"$binding_depolyed", @"$binding_trigger_id", @"$binding_path"]];
                    [event setObject:properties forKey:@"properties"];
                    
                    NSDictionary *payload = [[NSDictionary alloc] initWithObjectsAndKeys:
                                             binding_depolyed ? @YES : @NO, @"depolyed",
                                             @(binding_trigger_id), @"trigger_id",
                                             binding_path, @"path",
                                             event, @"event", nil];
                    
                    SADesignerTrackMessage *message = [SADesignerTrackMessage messageWithPayload:payload];
                    [connection sendMessage:message];
                };
                
                [SASwizzler swizzleSelector:@selector(enqueueWithType:andEvent:)
                                    onClass:[SensorsAnalyticsSDK class]
                                  withBlock:block
                                      named:@"track_properties"];
            }
        };
        
        void (^disconnectCallback)(void) = ^{
            __strong SensorsAnalyticsSDK *strongSelf = weakSelf;
            strongSelf.flushInterval = oldInterval;
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            if (strongSelf) {
                SADesignerConnection *connection = strongSelf.abtestDesignerConnection;
                id bindingCollection = [connection sessionObjectForKey:@"event_bindings"];
                if (bindingCollection && [bindingCollection conformsToProtocol:@protocol(SADesignerSessionCollection)]) {
                    [bindingCollection cleanup];
                }
                
                [strongSelf executeEventBindings:strongSelf.eventBindings];
                
                [SASwizzler unswizzleSelector:@selector(enqueueWithType:andEvent:)
                                      onClass:[SensorsAnalyticsSDK class]
                                        named:@"track_properties"];
            }
        };
        
        NSURL *designerURL = [NSURL URLWithString:self.vtrackServerURL];
        self.abtestDesignerConnection = [[SADesignerConnection alloc] initWithURL:designerURL
                                                                       keepTrying:reconnect
                                                                  connectCallback:connectCallback
                                                               disconnectCallback:disconnectCallback];
    }
}

- (void)executeEventBindings:(NSSet*) eventBindings {
    if (eventBindings) {
        for (id binding in eventBindings) {
            if ([binding isKindOfClass:[SAEventBinding class]]) {
                [binding execute];
            }
        }
        SADebug(@"%@ execute event bindings %@", self, eventBindings);
    }
}

@end

#pragma mark - People analytics

@implementation SensorsAnalyticsPeople {
    SensorsAnalyticsSDK *_sdk;
}

- (id)initWithSDK:(SensorsAnalyticsSDK *)sdk {
    self = [super init];
    if (self) {
        _sdk = sdk;
    }
    return self;
}

- (void)set:(NSDictionary *)profileDict {
    [_sdk track:nil withProperties:profileDict withType:@"profile_set"];
}

- (void)setOnce:(NSDictionary *)profileDict {
    [_sdk track:nil withProperties:profileDict withType:@"profile_set_once"];
}

- (void)set:(NSString *) profile to:(id)content {
    [_sdk track:nil withProperties:@{profile: content} withType:@"profile_set"];
}

- (void)setOnce:(NSString *) profile to:(id)content {
    [_sdk track:nil withProperties:@{profile: content} withType:@"profile_set_once"];
}

- (void)unset:(NSString *) profile {
    [_sdk track:nil withProperties:@{profile: @""} withType:@"profile_unset"];
}

- (void)increment:(NSString *)profile by:(NSNumber *)amount {
    [_sdk track:nil withProperties:@{profile: amount} withType:@"profile_increment"];
}

- (void)increment:(NSDictionary *)profileDict {
    [_sdk track:nil withProperties:profileDict withType:@"profile_increment"];
}

- (void)append:(NSString *)profile by:(NSSet *)content {
    [_sdk track:nil withProperties:@{profile: content} withType:@"profile_append"];
}

- (void)deleteUser {
    [_sdk track:nil withProperties:@{} withType:@"profile_delete"];
}

@end
