//
//  MessagesViewController.h
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 20/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPURLRequest.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "checkNullString.h"
@interface MessagesViewController : UIViewController<HTTPURLRequestDelegate>

{
    NSMutableArray *buttonArray;
    

}

- (IBAction)SearchBuddies:(id)sender;
- (IBAction)AddNewGroup:(id)sender;

-(void)log:(NSDictionary *)dict;
-(void)callService;
@end
