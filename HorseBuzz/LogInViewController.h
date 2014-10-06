//
//  LogInViewController.h
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 15/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPURLRequest.h"
@interface LogInViewController : UIViewController<HTTPURLRequestDelegate> {
    IBOutlet UIView *guideView;
    IBOutlet UIScrollView *guideScrollView;
    IBOutlet UIImageView *backImageView;
}
@property(weak,nonatomic)IBOutlet UITextField *userNameField;
@property(weak,nonatomic)IBOutlet UITextField *passwordField;
-(IBAction)CreateAccount:(id)sender;
-(IBAction)SignIn:(id)sender;
-(IBAction)Forgot:(id)sender;
-(IBAction)closeButton:(id)sender;
@end
