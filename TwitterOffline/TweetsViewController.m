//
//  ViewController.m
//  TwitterOffline
//
//  Created by Hemanth Prasad on 7/15/15.
//  Copyright (c) 2015 Hemanth Prasad. All rights reserved.
//

#import "TweetsViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "TwitterHelper.h"
#import "TweetTVC.h"
#import "Tweet+Additions.h"
#import "MGSwipeButton.h"
@interface TweetsViewController ()<UITableViewDataSource, UITableViewDelegate,TwitterHelperDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate,MGSwipeTableCellDelegate,UISearchBarDelegate>
@property (strong, nonatomic) NSArray *dataSource;
@property BOOL loading;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,retain) NSString *query;
@end

@implementation TweetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [NSArray array];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
    self.tableView.estimatedRowHeight = 68.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [TwitterHelper sharedInstance].delegate = self;
    [[TwitterHelper sharedInstance] login];
    self.query = @"";
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    TweetTVC *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDictionary *tweet = _dataSource[[indexPath row]];
    cell.userName = tweet[@"name"];
    cell.tweet = tweet[@"text"];
    
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Save" backgroundColor:[UIColor lightGrayColor]]];
    cell.delegate = self;
    cell.rightSwipeSettings.transition = MGSwipeTransition3D;
    return cell;
}


- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion{
    [self saveTweetAtIndex:[[self.tableView indexPathForCell:cell] row]];
    return YES;
}

- (void)newStatusFetched:(NSArray *)statuses forQuery:(NSString *)query{
    self.loading = NO;
    
    NSMutableArray *newStatuses = [NSMutableArray array];
    for (NSDictionary *status in statuses) {
        NSMutableDictionary *newStatus = [NSMutableDictionary dictionary];
        newStatus[@"name"] = status[@"user"][@"name"];
        newStatus[@"text"] = status[@"text"];
        [newStatuses addObject:newStatus];
    }
    
    if ([query isEqual:self.query]) {
        self.dataSource = [self.dataSource arrayByAddingObjectsFromArray:newStatuses];
    }else{
        self.dataSource = [newStatuses copy];
    }
    
    self.query = query;
    [self.tableView reloadData];
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:@"Save"
                                                        otherButtonTitles:nil];
        [actionSheet showInView:self.view];
    }
}

- (void)saveTweetAtIndex:(NSInteger)index{
    NSDictionary *data = self.dataSource[index];
    Tweet *tweet = [Tweet newTweet];
    tweet.username = data[@"name"];
    tweet.tweet = data[@"text"];
    tweet.savedTime = [NSDate date];
    [tweet save];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton=NO;
    if ([searchBar.text length]==0) {
        [[TwitterHelper sharedInstance] getTimeline];
    }
    [[TwitterHelper sharedInstance] searchTwitterWithQuery:searchBar.text];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)sender
{
    sender.showsCancelButton=YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)sender
{
    sender.text=@"";
    [sender resignFirstResponder];
    sender.showsCancelButton=NO;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == [actionSheet cancelButtonIndex]) {
        return;
    }
    
    [self saveTweetAtIndex:[[self.tableView indexPathForSelectedRow] row]];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y > 0 && scrollView.contentOffset.y + self.tableView.bounds.size.height > scrollView.contentSize.height*.75) {
        if (!self.loading) {
            self.loading = YES;
            [[TwitterHelper sharedInstance] loadMore];
        }
    }
}

@end
