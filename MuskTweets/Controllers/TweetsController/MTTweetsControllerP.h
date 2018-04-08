//
//  MTTweetsControllerP.h
//  MuskTweets
//
//  Created by Danila Shikulin on 11/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MTTweetsLoaderP.h"


@class NSPersistentContainer;
@class NSFetchRequest;

@protocol MTTweetsControllerP <NSObject>
@property (strong, nonatomic, readonly) NSPersistentContainer *persistentContainer;
@property (nonatomic, readonly) BOOL refreshing;

- (instancetype)initWithPersistentContainer:(NSPersistentContainer *)persistentContainer
                               tweetsLoader:(NSObject<MTTweetsLoaderP> *)tweetsLoader;
- (void)refreshWithCompletionBlock:(void(^)(BOOL success))completionBlock;
- (NSFetchRequest *)fetchRequest;
- (NSString *)tweetsCollectionName;
@end
