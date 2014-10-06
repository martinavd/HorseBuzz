//
//  ChangePassword.h
//  HorseBuzz
//
//  Created by Ritheesh Koodalil on 20/02/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPURLRequest.h"

@interface ChangePassword : UIViewController<HTTPURLRequestDelegate,UIAlertViewDelegate>{
    IBOutlet UITextField *oldPasswordTxt;
    IBOutlet UITextField *newPasswordTxt;
    IBOutlet UITextField *comfirmPasswordTxt;
    
}
-(IBAction)changePassword:(id)sender;
@property(assign,nonatomic)BOOL isOTPLogin;

@end
