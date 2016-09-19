//
//  Macro.h
//  rongyun
//
//  Created by TANHUAZHE on 2/27/16.
//  Copyright © 2016 jianjian. All rights reserved.
//

#ifndef EIDefine_h
#define EIDefine_h

#define DEBUG_MODE 1

#define DebugLog(s, ...) NSLog(@"%s(%d): %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#define kTipAlert(_S_, ...)     [[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:(_S_), ##__VA_ARGS__] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show]

#define kDefaultAvatar [UIImage imageNamed:@"DefaultAvatar"]

#define kKeyWindow [UIApplication sharedApplication].keyWindow

#define kScreen_Bounds [UIScreen mainScreen].bounds
#define kScreen_Height [UIScreen mainScreen].bounds.size.height
#define kScreen_Width [UIScreen mainScreen].bounds.size.width

#define kDevice_Is_iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define NETWORKACTIVITY [UIApplication sharedApplication].networkActivityIndicatorVisible

#define ESWeak(var, weakVar) __weak __typeof(&*var) weakVar = var
#define ESStrong_DoNotCheckNil(weakVar, _var) __typeof(&*weakVar) _var = weakVar
#define ESStrong(weakVar, _var) ESStrong_DoNotCheckNil(weakVar, _var); if (!_var) return;

#define ESWeak_(var) ESWeak(var, weak_##var);
#define ESStrong_(var) ESStrong(weak_##var, _##var);

#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__);
#else
#   define DLog(...)
#endif

#define NSStringFromInt(a)              [NSString stringWithFormat:@"%d",a]
#define NSStringFromInteger(a)          [NSString stringWithFormat:@"%zd",a]

/** defines a weak `self` named `__weakSelf` */
#define ESWeakSelf      ESWeak(self, __weakSelf);
/** defines a strong `self` named `_self` from `__weakSelf` */
#define ESStrongSelf    ESStrong(__weakSelf, _self);

#define RGBCOLOR(r, g, b) [UIColor colorWithRed : (r) / 255.0 green : (g) / 255.0 blue : (b) / 255.0 alpha : 1]
#define RGBACOLOR(r, g, b, a) [UIColor colorWithRed : (r) / 255.0 green : (g) / 255.0 blue : (b) / 255.0 alpha : (a)]
#define UIColorFromRGB(rgb) [UIColor colorWithRed:((float)((rgb & 0xFF0000) >> 16)) / 255.0 green : ((float)((rgb & 0xFF00) >> 8)) / 255.0 blue : ((float)(rgb & 0xFF)) / 255.0 alpha : 1.0]
#define UIColorFromHex(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]
#define RGBRandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]

#define EIFont(a)                       [UIFont systemFontOfSize:a]
#define EILabelTextColor                [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.87]

#define EINavigationBarTitleColor       [UIColor colorWithRed:55/255.0 green:58/255.0 blue:64/255.0 alpha:1]
#define EIGreyColor                     [UIColor colorWithRed:155/255.0 green:158/255.0 blue:166/255.0 alpha:1]
#define EINickNameColor                 [UIColor colorWithRed:42/255.0 green:43/255.0 blue:49/255.0 alpha:1]
#define EIBlueColor                     UIColorFromHex(0x4285F4)
#define EIPinkColor                     UIColorFromHex(0xFF336E)
#define EIReceiveMessageNotification    @"kReceiveMessageNotification"
#define EISendMessageNotification       @"kSendMessageNotification"
#define EIClearMessageCacheNotification @"kClearMessageCacheNotification"

//链接颜色
#define kLinkAttributes     @{(__bridge NSString *)kCTUnderlineStyleAttributeName : [NSNumber numberWithBool:NO],(NSString *)kCTForegroundColorAttributeName : (__bridge id)[UIColor colorWithHexString:@"0x3bbd79"].CGColor}
#define kLinkAttributesActive       @{(NSString *)kCTUnderlineStyleAttributeName : [NSNumber numberWithBool:NO],(NSString *)kCTForegroundColorAttributeName : (__bridge id)[[UIColor colorWithHexString:@"0x1b9d59"] CGColor]}

#define kCommonBackgroundColor [UIColor colorWithPatternImage: [UIImage imageNamed:@"background_img"]]

#define kTipAlert(_S_, ...)     [[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:(_S_), ##__VA_ARGS__] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show]

#define WeiXinLogin @"EIWeiXinLogin"

#define dispatch_main_sync_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_sync(dispatch_get_main_queue(), block);\
    }

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }

#define IOS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IOS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define XcodeAppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define EINotificationReceiveMessage @"kNotificationReceiveMessage"
#define EINotificationUnreadMessage @"kNotificationUnreadMessage"
#endif /* EIDefine_h */
