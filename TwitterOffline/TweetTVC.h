//
//  TweetTVC.h
//  TwitterOffline
//
//  Created by Hemanth Prasad on 7/18/15.
//  Copyright (c) 2015 Hemanth Prasad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface TweetTVC : MGSwipeTableCell
@property (nonatomic,retain) NSString *userName;
@property (nonatomic,retain) NSString *tweet;
@end
