//
//  MTRecentTweetsController.m
//  MuskTweets
//
//  Created by Danila Shikulin on 11/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import "MTRecentTweetsController.h"

#import "MTMacros.h"
#import "MTTweetMO+CoreDataClass.h"


@interface MTRecentTweetsController ()
@property (strong, nonatomic) NSObject<MTTweetsLoaderP> *tweetLoader;
@property (nonatomic, readwrite) BOOL refreshing;

@end

@implementation MTRecentTweetsController
@synthesize persistentContainer = _persistentContainer;

- (instancetype)init {
    MT_UNAVAILABLE_INITIALIZER
    return nil;
}

- (instancetype)initWithPersistentContainer:(NSPersistentContainer *)persistentContainer
                               tweetsLoader:(NSObject<MTTweetsLoaderP> *)tweetLoader
{
    NSParameterAssert(persistentContainer);
    if (!persistentContainer) {return nil;}
    NSParameterAssert(tweetLoader);
    if (!tweetLoader) {return nil;}
    
    self = [super init];
    if (!self) {return nil;}
    
    _persistentContainer = persistentContainer;
    _tweetLoader = tweetLoader;
    _tweetsCount = 10;
    _refreshing = NO;
    
    return self;
}

- (void)refreshWithCompletionBlock:(void (^)(BOOL))completionBlock {
    if (self.refreshing) {return;}
    
    self.tweetLoader.desiredNumber = self.tweetsCount;
    
    self.refreshing = YES;
    __weak typeof(self) weakSelf = self;  // preventing unexpected lifetime
    [self.tweetLoader loadTweetsWithFinishBlock:^(id tweetsInfo) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {return;}
        
        strongSelf.refreshing = NO;
    
        if (!tweetsInfo) {
            DLog(@"Refresh failed");
            if (completionBlock) completionBlock(NO);
            return;
        }
        
        [strongSelf.persistentContainer performBackgroundTask:^(NSManagedObjectContext *context) {
            context.mergePolicy = [NSMergePolicy mergeByPropertyObjectTrumpMergePolicy];
            
            [strongSelf.tweetLoader enumerateTweetsInfo:tweetsInfo usingBlock:^(id aTweetInfo) {
                MTTweetMO *tweet = [[MTTweetMO alloc] initWithContext:context];
                [strongSelf.tweetLoader fillTweet:tweet withTweetInfo:aTweetInfo];
            }];
            
            NSError *error = nil;
            if (![context save:&error]) {
                ALog(@"Failure to save context: %@\n%@", [error localizedDescription], [error userInfo]);
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if (completionBlock) completionBlock(NO);
                }];
                return;
            }
    
            NSFetchRequest *fetch = [strongSelf fetchRequest];
            fetch.fetchOffset = strongSelf.tweetsCount;
            NSBatchDeleteRequest *request = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetch];
            request.resultType = NSBatchDeleteResultTypeObjectIDs;
            NSError *deleteError = nil;
            NSBatchDeleteResult *result = [context executeRequest:request error:&deleteError];
            if (result) {
                NSDictionary *changes = @{NSDeletedObjectsKey : result.result};
                NSManagedObjectContext *viewContext = strongSelf.persistentContainer.viewContext;
                [NSManagedObjectContext mergeChangesFromRemoteContextSave:changes
                                                             intoContexts:@[context, viewContext]];
            } else {
                ALog(@"Failed to delete old tweets: %@", deleteError);
            }

            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (completionBlock) completionBlock(YES);
            }];
        }];
    }];
}

- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *request = [MTTweetMO fetchRequest];
    
    NSString *dateSortKey = NSStringFromSelector(@selector(creation_date));
    NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey:dateSortKey ascending:NO];
    request.sortDescriptors = @[dateSort];
    
    return request;
}

- (NSString *)tweetsCollectionName {
    return [self.tweetLoader tweetsCollectionName];
}

@end
