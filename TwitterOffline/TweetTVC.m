//
//  TweetTVC.m
//  TwitterOffline
//
//  Created by Hemanth Prasad on 7/18/15.
//  Copyright (c) 2015 Hemanth Prasad. All rights reserved.
//

#import "TweetTVC.h"

@interface TweetTVC()

@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;

@end


@implementation TweetTVC

- (void)awakeFromNib {
    // Initialization code
}

- (void)updateLabel{
    NSString *labelText = [NSString stringWithFormat:@"%@: %@",self.userName,self.tweet];
    UIFont *boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:labelText];
    [attrString setAttributes:@{ NSFontAttributeName: boldFont } range:NSMakeRange(0, self.userName.length)];
    [self.tweetLabel setAttributedText:attrString];
}

-(void)setUserName:(NSString *)userName{
    _userName = userName;
    [self updateLabel];
}

-(void)setTweet:(NSString *)tweet{
    _tweet = tweet;
    [self updateLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
