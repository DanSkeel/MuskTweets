//
//  MTTweetTableViewCell.h
//  MuskTweets
//
//  Created by Danila Shikulin on 11/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MTTweetTableViewCell : UITableViewCell
- (void)setCreationDate:(NSDate *)date;
- (void)setText:(NSString *)text;
@end
