//
//  SingletonHelper.h
//  jiuwuliao
//
//  Created by TANHUAZHE on 7/17/15.
//  Copyright (c) 2015 jianjian. All rights reserved.
//

#import <UIKit/UIKit.h>
#undef	AS_SINGLETON
#define AS_SINGLETON( __class ) \
- (__class *)sharedInstance; \
+ (__class *)sharedInstance;
#undef	DEF_SINGLETON
#define DEF_SINGLETON( __class ) \
- (__class *)sharedInstance \
{ \
return [__class sharedInstance]; \
} \
+ (__class *)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[[self class] alloc] init]; } ); \
return __singleton__; \
}
