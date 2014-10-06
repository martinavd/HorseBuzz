//
//  FeedbackViewController.h
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 27/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPURLRequest.h"
#import "CMLNetworkManager.h"

@interface FeedbackViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate,HTTPURLRequestDelegate,UIAlertViewDelegate>
@property(nonatomic,weak)IBOutlet UITextField *subject;
@property(nonatomic,weak)IBOutlet UITextView *description;
@property(nonatomic,weak)IBOutlet UILabel *placeHolder;
-(IBAction)sendFeedback:(id)sender;
@end
