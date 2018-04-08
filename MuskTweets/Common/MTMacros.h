//
//  MTMacros.h
//  MuskTweets
//
//  Created by Danila Shikulin on 11/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#ifndef MTMacros_h
#define MTMacros_h

#define __DS_LOG(...) NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])

#ifdef DEBUG

#define DLog(...) __DS_LOG(__VA_ARGS__)

#define ALog(...) \
do { \
    __DS_LOG(__VA_ARGS__); \
    [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] \
                                                        file:[NSString stringWithCString:__FILE__ \
                                                    encoding:NSUTF8StringEncoding] \
                                                  lineNumber:__LINE__ \
                                                 description:__VA_ARGS__]; \
} while(0)

#else /* DEBUG */

#define DLog(...) do {} while (0)
#define ALog(...) __DS_LOG(__VA_ARGS__)

#endif /* DEBUG */

#define ZAssert(condition, ...) \
do { \
    if (!(condition)) { ALog(__VA_ARGS__); } \
} while(0)

#define MT_UNAVAILABLE_INITIALIZER ZAssert(NO, @"MT_UNAVAILABLE_INITIALIZER");

#endif /* MTMacros_h */
