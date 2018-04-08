//
//  MTTweetsLoaderP.h
//  MuskTweets
//
//  Created by Danila Shikulin on 11/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MTTweetMO;

@protocol MTTweetsLoaderP <NSObject>
/**
 Desired count of tweets to load. Loader will try to return amount of tweets closest to this value.
 
 If `excludeReplies` is `NO`, then loader will return precisely `desiredNumber` of tweets.
 
 If `excludeReplies` is `YES`, loader will try to use some API features to get `desiredNumber` of tweets.
 
 Twitter API doesn't allow you to fetch precise number of tweets if you use `exclude_replies` parameter,
 beacuse API first fetches `count` number of tweets and then filter out `replies`.
 see https://developer.twitter.com/en/docs/tweets/timelines/api-reference/get-statuses-user_timeline.html
 */
@property (nonatomic) NSInteger desiredNumber;
@property (nonatomic) BOOL excludeReplies;

/** Loads tweets and passes them as an abstract data type to `finishBlock`.
 
 To iterate over `tweetsInfo` use `enumerateTweetsInfo:usingBlock:`.
 
 @param finishBlock
 If error occured, `tweetsInfo` == `nil`.
 If no results returned, `tweetsInfo` == `@[]`.
 In other cases `tweetsInfo` will contain info about loaded tweets.
 Block will be called on Main queue.
 */
- (void)loadTweetsWithFinishBlock:(void(^)(id tweetsInfo))finishBlock;
- (void)enumerateTweetsInfo:(id)tweetsInfo usingBlock:(void(^)(id aTweetInfo))enumarationBlock;
- (void)fillTweet:(MTTweetMO *)tweet withTweetInfo:(id)aTweetInfo;
- (NSString *)tweetsCollectionName;
@end
