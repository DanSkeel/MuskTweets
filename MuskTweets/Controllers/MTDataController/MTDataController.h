//
//  MTDataController.h
//  MuskTweets
//
//  Created by Danila Shikulin on 11/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>


@interface MTDataController : NSObject
@property (strong, nonatomic, readonly) NSPersistentContainer *persistentContainer;

- (instancetype)initWithContainerSetupFinishBlock:(void(^)(NSPersistentContainer *persistentContainer))finishBlock NS_DESIGNATED_INITIALIZER;
@end
