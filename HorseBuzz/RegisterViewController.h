//
//  RegisterViewController.h
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 16/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import  <MobileCoreServices/MobileCoreServices.h>
#import "HTTPURLRequest.h"
#import "AppInfoViewController.h"
#import "LogInViewController.h"
@interface RegisterViewController : UIViewController<HTTPURLRequestDelegate,UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UINavigationControllerDelegate>

@property(weak,nonatomic)IBOutlet UIButton *maleSel;
@property(weak,nonatomic)IBOutlet UIButton *femaleSel;
@property(weak,nonatomic)IBOutlet UITextField *firstNameField;
@property(weak,nonatomic)IBOutlet UITextField *lastNameFiled;
@property(weak,nonatomic)IBOutlet UITextField *dobFiled;
@property(weak,nonatomic)IBOutlet UITextField *emailField;
@property(weak,nonatomic)IBOutlet UITextField *userNameField;
@property(weak,nonatomic)IBOutlet UITextField *passwordField;
@property(weak,nonatomic)IBOutlet UIView *createView;
@property(nonatomic,strong)IBOutlet UIScrollView *scrollView;
@property(nonatomic,retain)IBOutlet UITableView *interestTable;
@property(nonatomic,retain)IBOutlet UITextView *aboutMeTextView;
@property(weak,nonatomic)IBOutlet UIButton *profileBttn;
@property(strong,nonatomic)IBOutlet UILabel *termsAndConditions;
@property(weak,nonatomic)IBOutlet UIButton *termsAccept;
@property(weak,nonatomic)IBOutlet UIView *termsAndConditionView;

-(IBAction)CreateAccount:(id)sender;
-(IBAction)SignIn:(id)sender;
-(IBAction)MaleSelection:(id)sender;
-(IBAction)FemaleSelection:(id)sender;
-(IBAction)CalenderClicked:(id)sender;
-(IBAction)addPic:(id)sender;
-(IBAction)termsAcceptAction:(id)sender;
-(IBAction)showTermsAndCondition;
-(IBAction)removeTermsAndCondition;
- (IBAction)genderSelectionTap:(UITapGestureRecognizer *)sender;


@end
