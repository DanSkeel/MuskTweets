//
//  MTTweetViewController.h
//  MuskTweets
//
//  Created by Danila Shikulin on 12/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <CoreData/CoreData.h>

#import <UIKit/UIKit.h>


@interface MTTweetViewController : UIViewController

- (instancetype)initWithTweetObjectID:(NSManagedObjectID *)tweetObjectID
                        inViewContext:(NSManagedObjectContext *)viewContext;
@end
