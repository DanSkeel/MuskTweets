//
//  MTTweetViewController.m
//  MuskTweets
//
//  Created by Danila Shikulin on 12/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import "MTTweetViewController.h"

#import "MTMacros.h"
#import "MTTweetMO+CoreDataClass.h"


@interface MTTweetViewController ()
@property (strong, nonatomic) NSManagedObjectContext *viewContext;
@property (strong, nonatomic) NSManagedObjectID *tweetObjectID;

@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UILabel *likesCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *retweetsCountLabel;

@end

@implementation MTTweetViewController

- (instancetype)initWithTweetObjectID:(id)tweetObjectID inViewContext:(NSManagedObjectContext *)viewContext {
    if (viewContext.concurrencyType != NSMainQueueConcurrencyType) {
        ALog(@"context should be of type NSMainQueueConcurrencyType");
        return nil;
    }
    
    self = [self init];
    if (!self) {return nil;}
    
    _tweetObjectID = tweetObjectID;
    _viewContext = viewContext;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // viewDidLoad can be called only on main thread, so we may use the context without blocks.
    MTTweetMO *tweet = [self.viewContext objectWithID:self.tweetObjectID];
    self.textLabel.text = tweet.text;
    self.likesCountLabel.text = [NSString stringWithFormat:@"%d", tweet.favorite_count];
    self.retweetsCountLabel.text = [NSString stringWithFormat:@"%d", tweet.retweet_count];
}

@end
