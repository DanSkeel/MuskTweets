//
//  MTTweetTableViewCell.m
//  MuskTweets
//
//  Created by Danila Shikulin on 11/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import "MTTweetTableViewCell.h"


@interface MTTweetTableViewCell ()
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation MTTweetTableViewCell

- (void)setCreationDate:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    self.dateLabel.text = [formatter stringFromDate:date];
}

- (void)setText:(NSString *)text {
    self.messageLabel.text = text;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.dateLabel.text = nil;
    self.messageLabel.text = nil;
}

@end
