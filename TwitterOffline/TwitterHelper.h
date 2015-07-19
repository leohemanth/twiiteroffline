//
//  TwitterHelper.h
//  TwitterOffline
//
//  Created by Hemanth Prasad on 7/18/15.
//  Copyright (c) 2015 Hemanth Prasad. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol TwitterHelperDelegate
-(void)newStatusFetched:(NSArray*)status forQuery:(NSString*)string;

@end

@interface TwitterHelper : NSObject
- (void)login;
+(instancetype)sharedInstance;
- (void)getTimeline;
- (void)loadMore;
-(void)searchTwitterWithQuery:(NSString*)query;
@property (nonatomic,weak) id<TwitterHelperDelegate> delegate;
@end
