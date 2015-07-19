//
//  Tweet+ Additions.m
//  TwitterOffline
//
//  Created by Hemanth Prasad on 7/18/15.
//  Copyright (c) 2015 Hemanth Prasad. All rights reserved.
//

#import "Tweet+Additions.h"
#import "AppDelegate.h"
@implementation Tweet(Additions)

+(instancetype)newTweet{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;

    Tweet *newEmployee = [NSEntityDescription
                                    insertNewObjectForEntityForName:@"Tweet"
                                    inManagedObjectContext:context];
    return newEmployee;
}

-(void)save{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    NSError *error;
    [context save:&error];
    if (error) {
        NSLog(@"unable to save:%@",[error localizedDescription]);
    }
}
@end
