//
//  Tweet.h
//  TwitterOffline
//
//  Created by Hemanth Prasad on 7/18/15.
//  Copyright (c) 2015 Hemanth Prasad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * tweet;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSDate * savedTime;

@end
