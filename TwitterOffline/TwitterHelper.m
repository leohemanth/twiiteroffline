//
//  TwitterHelper.m
//  TwitterOffline
//
//  Created by Hemanth Prasad on 7/18/15.
//  Copyright (c) 2015 Hemanth Prasad. All rights reserved.
//

#import "TwitterHelper.h"
#import "STTwitter.h"
#import <Accounts/Accounts.h>
#import <UIKit/UIKit.h>

typedef void (^accountChooserBlock_t)(ACAccount *account, NSString *errorMessage);

#define AccountTwitterSelectedIdentifier @"TwitterAccountSelectedIdentifier"

@interface TwitterHelper()<UIActionSheetDelegate>

@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, weak)  NSString *consumerKey;
@property (nonatomic, weak)  NSString *consumerSecret;
@property (nonatomic,strong) NSString *lastID,*query;
@end

@implementation TwitterHelper

-(instancetype)init
{
    if (self=[super init]) {
        self.accountStore = [[ACAccountStore alloc] init];
        self.consumerKey= @"PdLBPYUXlhQpt4AguShUIw";
        self.consumerSecret = @"drdhGuKSingTbsDLtYpob4m5b5dn1abf9XXYyZKQzk";
        return self;
    }
    return nil;
}

+(instancetype)sharedInstance{
    static dispatch_once_t oncetoken;
    static TwitterHelper *sharedTwitterManager;
    dispatch_once(&oncetoken,^{
        sharedTwitterManager = [[TwitterHelper alloc] init];
    });
    return sharedTwitterManager;
}

- (void)login {
    __weak typeof(self) weakSelf = self;
    
    [self chooseAccount:^(ACAccount *account) {
        [weakSelf loginWithAccount:account];
    } failure:^(NSString *string) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Twitter Error" message:@"Please make sure you have a Twitter account set up in Settings. Also grant access to this app" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
    }];
}

- (void)getTimeline{
    self.query = @"";
    [_twitter getHomeTimelineSinceID:self.lastID
                               count:20
                        successBlock:^(NSArray *statuses) {
                            self.lastID = [statuses lastObject][@"id_str"];
                            [self.delegate newStatusFetched:statuses forQuery:@""];
                        } errorBlock:^(NSError *error) {
                            NSLog(@"error %@",error);
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Twitter Error!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                            [alertView show];
                        }];
}

-(void)loadMore{
    if (![self.query isEqualToString:@""] && self.query) {
        [self searchTwitterWithQuery:self.query];
    }else{
        [self getTimeline];
    }
}

-(void)searchTwitterWithQuery:(NSString*)query
{
    self.query = query;
    
    if (![self.query isEqual:query]) {
        self.lastID = nil;
    }
    
    [_twitter getSearchTweetsWithQuery:query geocode:nil lang:nil locale:nil resultType:nil count:nil until:nil sinceID:self.lastID maxID:nil includeEntities:nil callback:nil successBlock:^(NSDictionary *searchMetadata, NSArray *statuses) {
        self.lastID = [statuses lastObject][@"id_str"];
        [self.delegate newStatusFetched:statuses forQuery:query];

    } errorBlock:^(NSError *error) {
         NSLog(@"error %@",error);
    }];
}

- (void)chooseAccount:(void(^)(ACAccount *account))success failure:(void (^)(NSString *string))failure{
    
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreRequestCompletionHandler = ^(BOOL granted, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if(granted == NO) {
                failure(@"Acccess not granted.");
                return;
            }
            
            NSString *twitterAccountIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:AccountTwitterSelectedIdentifier];
            if (twitterAccountIdentifier) {
                ACAccount *account = [_accountStore accountWithIdentifier:twitterAccountIdentifier];
                self.accounts = @[account];
            }
            else {
                self.accounts = [_accountStore accountsWithAccountType:accountType];
            }
            
            if ([_accounts count] == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Twitter Error" message:@"Please make sure you have a Twitter account set up in Settings. Also grant access to this app" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
            if([_accounts count] == 1) {
                ACAccount *account = [_accounts lastObject];
                success(account);
            } else {
                UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Select an account:"
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                  destructiveButtonTitle:nil otherButtonTitles:nil];
                for(ACAccount *account in _accounts) {
                    [as addButtonWithTitle:[NSString stringWithFormat:@"@%@", account.username]];
                }
                UIWindow* window = [[UIApplication sharedApplication] keyWindow];
                
                [as showInView:window];
            }
        }];
    };
    
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:NULL
                                            completion:accountStoreRequestCompletionHandler];
    
}

- (void)loginWithAccount:(ACAccount *)account {
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:account];
    
    [[NSUserDefaults standardUserDefaults] setObject:[account identifier] forKey:AccountTwitterSelectedIdentifier];
    
    [_twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        [self getTimeline];
    } errorBlock:^(NSError *error) {
    }];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == [actionSheet cancelButtonIndex]) {
        NSLog(@"cancelled!");
        return;
    }
    
    NSUInteger accountIndex = buttonIndex - 1;
    ACAccount *account = [_accounts objectAtIndex:accountIndex];
    
    [self loginWithAccount:account];
}
@end
