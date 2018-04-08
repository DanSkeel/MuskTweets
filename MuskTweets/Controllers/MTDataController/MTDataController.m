//
//  MTDataController.m
//  MuskTweets
//
//  Created by Danila Shikulin on 11/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import "MTDataController.h"

#import "MTMacros.h"


@interface MTDataController ()
@property (strong, nonatomic, readwrite) NSPersistentContainer *persistentContainer;

@end

@implementation MTDataController

- (instancetype)init {
    return [self initWithContainerSetupFinishBlock:nil];
}

- (instancetype)initWithContainerSetupFinishBlock:(void(^)(NSPersistentContainer *))finishBlock {
    self = [super init];
    if (!self) return nil;
    
    NSError *error = nil;
    NSURL *URL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    if (!URL) {
        ALog(@"Failed to get cache folder URL: %@", error);
        return nil;
    }
    URL = [URL URLByAppendingPathComponent:@"MuskTweets.sqlite"];
    
    NSPersistentContainer *container = [[NSPersistentContainer alloc] initWithName:@"MuskTweets"];
    _persistentContainer = container;
    
    NSPersistentStoreDescription *description = [NSPersistentStoreDescription persistentStoreDescriptionWithURL:URL];
    description.shouldAddStoreAsynchronously = YES;
    container.persistentStoreDescriptions = @[description];
    
    [container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *description, NSError *error) {
        if (error != nil) {
            ALog(@"Failed to load Core Data stack: %@", error);
            return;
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = YES;
        
        if (finishBlock) finishBlock(container);
    }];    
    return self;
}

@end
