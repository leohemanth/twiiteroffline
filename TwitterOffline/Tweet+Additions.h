//
//  Tweet+ Additions.h
//  TwitterOffline
//
//  Created by Hemanth Prasad on 7/18/15.
//  Copyright (c) 2015 Hemanth Prasad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tweet.h"

@interface Tweet(Additions)
+(instancetype)newTweet;
-(void)save;
@end
