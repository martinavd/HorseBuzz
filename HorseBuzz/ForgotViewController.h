//
//  ForgotViewController.h
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 23/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPURLRequest.h"
@interface ForgotViewController : UIViewController<UITextFieldDelegate,HTTPURLRequestDelegate>
@property(weak,nonatomic)IBOutlet UIView *otpView;
@property(weak,nonatomic)IBOutlet UIView *setPasswordView;
@property(weak,nonatomic)IBOutlet UITextField *username;
@property(weak,nonatomic)IBOutlet UITextField *otp;
@property(weak,nonatomic)IBOutlet UITextField *password;
@property(assign,nonatomic)BOOL isNewpassword;

-(IBAction)generateOTP:(id)sender;
-(IBAction)setNewpsssword:(id)sender;

@end
