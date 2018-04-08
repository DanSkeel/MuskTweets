//
//  MTTweetsTableViewController.m
//  MuskTweets
//
//  Created by Danila Shikulin on 11/04/2018.
//  Copyright © 2018 DanSkeel. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "MTTweetsTableViewController.h"

#import "MTMacros.h"
#import "MTTweetMO+CoreDataClass.h"
#import "MTTweetTableViewCell.h"
#import "MTTweetViewController.h"


static NSString *const kMTCellID = @"MTCellID";

@interface MTTweetsTableViewController () <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation MTTweetsTableViewController

- (void)setTweetsController:(NSObject<MTTweetsControllerP> *)tweetsController {
    if (tweetsController && _tweetsController) {
        ALog(@"Changing tweet controller is not implemented");
        return;
    }
    _tweetsController = tweetsController;

    [self setupFetchedResultsControllerWithTweetsController:tweetsController];
    
    // display cahced tweets
    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
    
    // start refreshing them
    [self refreshTweets];
}

- (NSPersistentContainer *)persistentContainer {
    return self.tweetsController.persistentContainer;
}

- (void)setupFetchedResultsControllerWithTweetsController:(NSObject<MTTweetsControllerP> *)tweetsController {
    NSParameterAssert(tweetsController);
    if (!tweetsController) {return;}
    
    NSFetchRequest *request = [self.tweetsController fetchRequest];
    ZAssert(request, @"request is required");
    if (!request) {return;}
    
    NSManagedObjectContext *viewContext = [self persistentContainer].viewContext;
    ZAssert(viewContext, @"viewContext is required");
    if (!viewContext) {return;}
    
    NSFetchedResultsController *resultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:viewContext
                                          sectionNameKeyPath:nil
                                                   cacheName:@"tweets"];
    resultsController.delegate = self;
    self.fetchedResultsController = resultsController;
    
    NSError *error = nil;
    if (![resultsController performFetch:&error]) {
        ALog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView *tableView = self.tableView;
    tableView.rowHeight = 100;
    
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MTTweetTableViewCell class]) bundle:nil]
    forCellReuseIdentifier:kMTCellID];
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(refreshControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Tableview inserts new rows under refresh control.
    [self.refreshControl.superview sendSubviewToBack:self.refreshControl];
}

- (void)refreshTweets {
    if (!self.refreshControl.refreshing) {
        [self.refreshControl beginRefreshing];
    }
    
    [self setupTitleForTweetCollection];
    
    __weak typeof(self) weakSelf = self;
    [self.tweetsController refreshWithCompletionBlock:^(BOOL success) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {return;}
     
        if (success) {
            [strongSelf setupTitleForTweetCollection];
        } else {
            strongSelf.title = @"Update failed";
        }
        
        // Hide refresh control after dragging finished
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [strongSelf.refreshControl endRefreshing];
        }];
    }];
}

- (void)setupTitleForTweetCollection {
    self.title = self.tweetsController.tweetsCollectionName;
}

- (void)updateCell:(MTTweetTableViewCell *)cell withTweet:(MTTweetMO *)tweet {
    [cell setCreationDate:tweet.creation_date];
    [cell setText:tweet.text];
}

#pragma mark - UI Interaction

- (void)refreshControlDidChangeValue:(UIRefreshControl *)refreshControl {
    if (refreshControl.refreshing) {
        [self refreshTweets];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedResultsController.sections[section].numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MTTweetMO *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    MTTweetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMTCellID forIndexPath:indexPath];
    [self updateCell:cell withTweet:tweet];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    childContext.parentContext = [self persistentContainer].viewContext;
    MTTweetViewController *viewController = [[MTTweetViewController alloc] initWithTweetObjectID:tweet.objectID
                                                                                   inViewContext:childContext];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self updateCell:[self.tableView cellForRowAtIndexPath:indexPath] withTweet:anObject];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
