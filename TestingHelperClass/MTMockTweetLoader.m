//
//  MTMockTweetLoader.m
//  MuskTweets
//
//  Created by Danila Shikulin on 10/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import "MTMockTweetLoader.h"

#import "MTMacros.h"
#import "MTTweetMO+CoreDataClass.h"


@interface MTMockTweetLoader ()
@property (copy, nonatomic) NSArray *cachedTweetsInfo;
@property (strong, nonatomic) NSOperationQueue *backgroundQueue;

@end

@implementation MTMockTweetLoader {
    NSInteger _batchSize;
    NSInteger _indexFromEnd;
}

- (instancetype)init {
    self = [super init];
    if (!self) {return nil;}
    
    _batchSize = 5;
    _indexFromEnd = _batchSize;
    
    return self;
}

- (NSOperationQueue *)backgroundQueue {
    if (!_backgroundQueue) {
        _backgroundQueue = [NSOperationQueue new];
    }
    return _backgroundQueue;
}

- (void)loadTweetsWithFinishBlock:(void (^)(id))finishBlock {
    [self.backgroundQueue addOperationWithBlock:^{
        NSArray *cachedTweetsInfo = self.cachedTweetsInfo;
        NSInteger offset = cachedTweetsInfo.count-1 - _indexFromEnd;
        if (offset <= 0) {
            offset = 0;
        } else {
            _indexFromEnd += 1;
        }
        NSRange range = NSMakeRange(offset, _batchSize);
        NSArray *tweetsJSON = [cachedTweetsInfo objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
        
        [NSThread sleepForTimeInterval:2];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            finishBlock(tweetsJSON);
        }];
    }];
}

- (NSArray *)cachedTweetsInfo {
    if (!_cachedTweetsInfo) {
        NSError *error;
        NSArray *array = [NSJSONSerialization JSONObjectWithData:[self cahcedJSONData] options:0 error:&error];
        if (!array) {
            ALog(@"Failed to load cahced JSON: %@", error);
        }
        _cachedTweetsInfo = array;
    }
    return _cachedTweetsInfo;
}

- (NSData *)cahcedJSONData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MockMuskTweets" ofType:@"json"];
    NSError *error;
    NSData *JSONData = [NSData dataWithContentsOfFile:path options:0 error:&error];
    if (!JSONData) {
        ALog(@"failed to load JSON %@", error);
    }
    return JSONData;
}

- (NSString *)tweetsCollectionName {
    return @"@elonmusk";
}

@end
