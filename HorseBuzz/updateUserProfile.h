//
//  updateUserProfile.h
//  HorseBuzz
//
//  Created by Ritheesh Koodalil on 28/03/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPURLRequest.h"

@interface updateUserProfile : UIViewController<HTTPURLRequestDelegate>{
    
    IBOutlet UITextField *emailField;
}

@property(weak,nonatomic)IBOutlet UITextField *firstNameField;
@property(weak,nonatomic)IBOutlet UITextField *lastNameFiled;
@property(weak,nonatomic)IBOutlet UITextField *dobFiled;
@property(nonatomic,retain)IBOutlet UITextView *aboutMeTextView;
@property(weak,nonatomic)IBOutlet UIButton *maleSel;
@property(weak,nonatomic)IBOutlet UIButton *femaleSel;
-(IBAction)MaleSelection:(id)sender;
-(IBAction)updateAccount:(id)sender;
- (IBAction)showCalender:(id)sender;

@end
