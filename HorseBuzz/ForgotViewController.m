//
//  ForgotViewController.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 23/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "ForgotViewController.h"
#import "LogInViewController.h"
#import "CMLNetworkManager.h"
#import "HorseBuzzConfig.h"
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "HorseBuzzDataManager.h"
#import "GAI.h"

@interface ForgotViewController (){
    
    UITextField *selTextField;
    CGFloat animatedDistance;
    
    MBProgressHUD *mbProgressHUD;
}
@property(nonatomic,strong) UIToolbar *keyBoardBar;

@end

@implementation ForgotViewController
@synthesize otpView,setPasswordView;
@synthesize keyBoardBar;
@synthesize username,otp,password;
@synthesize isNewpassword;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    // google tracking code
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLEANALITICSCODE];
    //[tracker trackView:@"Horse Buzz - Forgot view"];
    [tracker set:@"ScreenName" value:@"Horse Buzz - Forgot view" ];
    // google tracking code end
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillActive:) name:UIApplicationWillEnterForegroundNotification object:nil];
    self.navigationController.navigationBarHidden = NO;
    mbProgressHUD = [[MBProgressHUD alloc]initWithView:self.view];
    [mbProgressHUD setMode:MBProgressHUDModeIndeterminate];
    [self.view addSubview:mbProgressHUD];
    [self setupKeyBoard];
    if (self.isNewpassword) {
        self.navigationItem.hidesBackButton = YES;
        self.otpView.hidden = YES;
        self.setPasswordView.hidden = NO;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupKeyBoard{
    self.keyBoardBar = [[UIToolbar alloc] init];
    self.keyBoardBar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *previousButton = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self
                                                                      action:@selector(keyboardPrevious:)];
    
    UIBarButtonItem *nextButon = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(keyboardNext:)];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(keyboardDone:)];
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self.keyBoardBar setItems:[NSArray arrayWithObjects:previousButton,nextButon,flexible,doneBarButton,nil]];
    [self.keyBoardBar sizeToFit];
}

-(void)appWillActive:(NSNotification*)note
{
    if ([selTextField canResignFirstResponder]) {
        [selTextField resignFirstResponder];
    }
}

-(BOOL)checkStringByRemovingSpaces:(NSString*)string{
    NSString * checkString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (checkString.length < 1)
        return FALSE;
    else
        return TRUE;
}

#pragma mark - keyboard functions

-(IBAction)keyboardPrevious:(id)sender{
    
    
    if (selTextField == password) {
        [password resignFirstResponder];
        [otp becomeFirstResponder];
    }
}


-(IBAction)keyboardNext:(id)sender{
    if (selTextField == otp) {
        [otp resignFirstResponder];
        [password becomeFirstResponder];
    }
    
}


-(IBAction)keyboardDone:(id)sender{
    
    
    // if (selTextField == self.regField) {
    
    
    [selTextField resignFirstResponder];
    //  }
    //  else
    //  [self keyboardNext:nil];
}


#pragma mark - textfield  delegate methods
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    textField.inputAccessoryView = self.keyBoardBar;
    if (textField == username) {
        [[[ self.keyBoardBar items ] objectAtIndex: 0 ] setEnabled:NO];
        [[[ self.keyBoardBar items ] objectAtIndex: 1] setEnabled:NO];
        
    }else if(textField == otp){
        [[[ self.keyBoardBar items ] objectAtIndex: 0 ] setEnabled:NO];
        [[[ self.keyBoardBar items ] objectAtIndex: 1] setEnabled:YES];
    }else{
        [[[ self.keyBoardBar items ] objectAtIndex: 1 ] setEnabled:NO];
        [[[ self.keyBoardBar items ] objectAtIndex: 0 ] setEnabled:YES];
    }
    
    selTextField = textField;
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - HTTP request delegate methods
-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
}


-(void)getResponsedata:(NSDictionary *)data{
    [mbProgressHUD hide:YES];
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    NSString * code = [data objectForKey:@"code"];
    
    //NSLog(@"code%@",code);
    
    
    if (status) {
        if (isNewpassword) {
            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appdelegate setRootView];
            
        }else{
            LogInViewController *logInViewController = [[LogInViewController alloc]initWithNibName:@"LogInViewController" bundle:nil ];
            [self.navigationController pushViewController:logInViewController animated:NO];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:[NSString stringWithFormat:@"%@",[data objectForKey:@"errors"]] delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
            [alert show];
        }
    }else if ([code intValue] == 2){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:[NSString stringWithFormat:@"%@",[data objectForKey:@"errors"]] delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
}


#pragma mark - instance  methods
-(void)generateOTP:(id)sender{
    [username resignFirstResponder];
    if ([self validEmail:username.text]) {
        
        if([[CMLNetworkManager sharedInstance] hasConnectivity]){
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            
            [dictionary setObject:self.username.text forKey:@"email"];
            [mbProgressHUD show:YES];
            HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
            request.delegate=self;
            [request initwithurl:BASE_URL requestStr:OTP requestType:POST input:YES inputValues:dictionary];
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
            [alert show];
        }
    }else{
        //NSLog(@"username%@",username.text);
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:@"Invalid email entered" delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
        username.layer.borderColor = [UIColor redColor].CGColor;
        username.layer.borderWidth = 1.0f;
    }
}


-(void)setNewpsssword:(id)sender{
    
    if ([self validateFields]) {
        if([[CMLNetworkManager sharedInstance] hasConnectivity]){
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            
            [dictionary setObject:self.otp.text forKey:@"password"];
            [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
            [mbProgressHUD show:YES];
            HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
            request.delegate=self;
            [request initwithurl:BASE_URL requestStr:NEWPASSWORD requestType:POST input:YES inputValues:dictionary];
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
            [alert show];
        }
    }else{
        otp.layer.borderColor = [UIColor redColor].CGColor;
        otp.layer.borderWidth = 1.0f;
        password.layer.borderColor = [UIColor redColor].CGColor;
        password.layer.borderWidth = 1.0f;
        
    }
}


-(BOOL)checkNumberOfChars:(NSString *)phnNumber{
    BOOL valid;
    if ([self checkStringByRemovingSpaces:phnNumber]) {
        if (phnNumber.length >= 8 && phnNumber.length <= 12 ) valid = YES;
        else valid = NO;
    }else{
        valid = NO;
    }
    return valid;
}
-(BOOL)validateFields{
    NSString * newPassword = otp.text;
    NSString * cPassword = password.text;
    if ([self checkNumberOfChars:newPassword]&&[self checkNumberOfChars:cPassword]) {
        if ([newPassword isEqualToString:cPassword]) {
            return YES;
        }
    }
    return NO;
}


- (BOOL) validEmail:(NSString*) emailString {
    
    if([emailString length]==0){
        return NO;
    }
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    
    //NSLog(@"%i", regExMatches);
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

@end