//
//  SettingsViewController.h
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 20/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "HorseBuzzDataManager.h"
#import "HTTPURLRequest.h"
#import "Facebook.h"
#import "FBRequest.h"
#import "Twitter/Twitter.h"
#import "Social/Social.h"
#import "MessageUI/MessageUI.h"
#import "MessageUI/MFMailComposeViewController.h"

@interface SettingsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,HTTPURLRequestDelegate,FBSessionDelegate,FBDialogDelegate,FBLoginDialogDelegate,FBRequestDelegate, MFMailComposeViewControllerDelegate> {
    IBOutlet UIView *shareView;
    MFMailComposeViewController *mailComposer;
}
@property(nonatomic,retain)IBOutlet UITableView *settingsList;

-(IBAction)facebookButton:(id)sender;
-(IBAction)twitterButton:(id)sender;
-(IBAction)emailButton:(id)sender;
-(IBAction)closeButton:(id)sender;
@end
