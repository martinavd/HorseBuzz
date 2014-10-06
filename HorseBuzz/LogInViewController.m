//
//  LogInViewController.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 15/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "LogInViewController.h"
#import "RegisterViewController.h"
#import "NearByViewController.h"
#import "AppDelegate.h"
#import "ForgotViewController.h"
#import "HorseBuzzConfig.h"
#import "CMLNetworkManager.h"
#import "MBProgressHUD.h"
#import "LocationManager.h"
#import "HorseBuzzDataManager.h"
#import "GAI.h"
#import "ChangePassword.h"

@interface LogInViewController ()
{
NSMutableArray *textArray;
UITextField *selTextField;
CGFloat animatedDistance;
      MBProgressHUD *mbProgressHUD;
}

@property(nonatomic,strong) UIToolbar *keyBoardBar;
@end

@implementation LogInViewController
@synthesize userNameField,passwordField;
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
    //[tracker trackView:@"Horse Buzz - Login view"];
    [tracker set:@"ScreenName" value:@"Horse Buzz - Login view" ];
    // google tracking code end
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    mbProgressHUD = [[MBProgressHUD alloc]initWithView:self.view];
    [mbProgressHUD setMode:MBProgressHUDModeIndeterminate];
    [self.view addSubview:mbProgressHUD];
     self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    self.title = @"Sign In";
    
    self.navigationItem.hidesBackButton =TRUE;
    
    textArray = [[NSMutableArray alloc]init];
    for(int i = 1 ; i < 3 ; i++){
        UITextField *reffield = (UITextField *)[self.view viewWithTag:i];
        [textArray addObject:reffield];
    }
    [self setupKeyBoard];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupKeyBoard{
    self.keyBoardBar = [[UIToolbar alloc] init];
    self.keyBoardBar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem * previousButton = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self
                                                                       action:@selector(keyboardPrevious:)];
    
    UIBarButtonItem * nextButon = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(keyboardNext:)];
    UIBarButtonItem * doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(keyboardDone:)];
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self.keyBoardBar setItems:[NSArray arrayWithObjects: previousButton,nextButon,flexible,doneBarButton,nil]];
    [self.keyBoardBar sizeToFit];
}
#pragma mark - keyboard functions

-(IBAction)keyboardPrevious:(id)sender{
    
    int currentTag = selTextField.tag;
    if (currentTag-1 > 0) {
        [[textArray objectAtIndex:currentTag-1] resignFirstResponder];
        [[textArray objectAtIndex:currentTag-2] becomeFirstResponder];
    }
}
-(IBAction)keyboardNext:(id)sender{
    
    int currentTag = selTextField.tag;
    if (currentTag  < [textArray count]) {
        [[textArray objectAtIndex:currentTag-1] resignFirstResponder];
        [[textArray objectAtIndex:currentTag] becomeFirstResponder];
    }
}
-(IBAction)keyboardDone:(id)sender{
    // if (selTextField == self.regField) {
    [selTextField resignFirstResponder];
    //  }
    //  else
    //  [self keyboardNext:nil];
}

#pragma mark - Textfeild delegate methods
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 200.0;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 172.0;


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    textField.inputAccessoryView = self.keyBoardBar;
    selTextField = textField;
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
	CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
	CGFloat numerator =midline - viewRect.origin.y- MINIMUM_SCROLL_FRACTION * viewRect.size.height;
	CGFloat denominator =(MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)* viewRect.size.height;
	CGFloat heightFraction = numerator / denominator;
	
	if (heightFraction < 0.0)
	{
        heightFraction = 0.0;
	}
	else if (heightFraction > 1.0)
	{
        heightFraction = 1.0;
	}
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (orientation == UIInterfaceOrientationPortrait ||orientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
	}
	else
	{
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
	}
	CGRect viewFrame = self.view.frame;
	viewFrame.origin.y -= animatedDistance;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	
	[self.view setFrame:viewFrame];
    [UIView commitAnimations];
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    CGRect viewFrame = self.view.frame;
	viewFrame.origin.y += animatedDistance;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	[self.view setFrame:viewFrame];
    [UIView commitAnimations];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - HTTP request delegate methods
-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
    
}
-(void)getResponsedata:(NSDictionary *)data{
    //NSLog(@"getResponsedata%@",data);
    
    [mbProgressHUD hide:YES];
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    NSString * code = [data objectForKey:@"code"];
    if (status) {
        if ([[[data objectForKey:@"userDetails"]objectForKey:@"otp_request"]boolValue]) {
            ForgotViewController *forgotViewController = [[ForgotViewController alloc]initWithNibName:@"ForgotViewController" bundle:nil ];
            forgotViewController.isNewpassword = YES;
            
            [HorseBuzzDataManager sharedInstance].userId = [[data objectForKey:@"userDetails"]objectForKey:@"id"];
            [self.navigationController pushViewController:forgotViewController animated:NO];
        }else{
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isInvisible"];
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isLogin"];
            [[NSUserDefaults standardUserDefaults]setValue:[[data objectForKey:@"userDetails"]objectForKey:@"id"] forKey:@"userID"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [HorseBuzzDataManager sharedInstance].userId = [[data objectForKey:@"userDetails"]objectForKey:@"id"];
            
            if ([[[data objectForKey:@"userDetails"]objectForKey:@"otp"]boolValue]) {
                ChangePassword *password = [[ChangePassword alloc]initWithNibName:@"ChangePassword" bundle:nil];
                password.isOTPLogin=TRUE;
                //NSLog(@"password");
                [self.navigationController pushViewController:password animated:YES];
            } else {
                if([[NSUserDefaults standardUserDefaults] boolForKey:@"guideVisitedStatus"] != 1) {
                    [self showGuideScreen];
                } else {
                    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [appdelegate setRootView];
                }
            }
        }
    }else if ([code intValue] == 2){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:[NSString stringWithFormat:@"%@",[data objectForKey:@"errors"]] delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        alert.tag = 101;
        [alert show];
        
    }else{
        
    }
}

-(BOOL)checkStringByRemovingSpaces:(NSString*)string{
    NSString * checkString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (checkString.length < 1)
        return FALSE;
    else
        return TRUE;
}
-(BOOL)checkNumberOfChars:(NSString *)phnNumber{
    BOOL valid;
    if (phnNumber.length >= 8 && phnNumber.length <= 12 ) valid = YES;
    else valid = NO;
    
    return valid;
}

-(BOOL)validateFields:(NSMutableArray *)textFieldArray{
    BOOL valid;
    int count = 0;
    for (int i = 0; i < textFieldArray.count; i++) {
        UITextField *refField = [textFieldArray objectAtIndex:i];
        refField.layer.borderWidth = 1.0;
        NSString *checkString = refField.text;
        if (checkString.length > 0 && [self checkStringByRemovingSpaces:checkString]) {
           
           if (i == 1)
                valid = [self checkNumberOfChars:checkString];
            else
                valid = TRUE;
            
            if (valid) {refField.layer.borderColor = [UIColor whiteColor].CGColor;
                count++;
            }
            else {refField.layer.borderColor = [UIColor redColor].CGColor;
                count--;
            }
            
        }
        else {
            refField.layer.borderColor = [UIColor redColor].CGColor;
            valid = FALSE;
            count--;
        }
    }
    if (count == 2)return valid =TRUE;
    else return valid = FALSE;
    
}
#pragma mark - Instance methods
-(void)CreateAccount:(id)sender{
    RegisterViewController *registerViewController = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
    [self.navigationController pushViewController:registerViewController animated:NO];
}

-(void)SignIn:(id)sender{
      if ([self validateFields:textArray])
      {
          [selTextField resignFirstResponder];
            if([[CMLNetworkManager sharedInstance] hasConnectivity]){
          NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
          
          [dictionary setObject:self.userNameField.text forKey:@"username"];
          [dictionary setObject:self.passwordField.text forKey:@"password"];
        if ([[LocationManager sharedInstance]CheckLocation]) {
                    [dictionary setObject:[LocationManager sharedInstance].latitude forKey:@"latitude"];
                    [dictionary setObject:[LocationManager sharedInstance].longitude forKey:@"longitude"];
            }
        if ([HorseBuzzDataManager sharedInstance].deviceToken) {
                    [dictionary setObject:[HorseBuzzDataManager sharedInstance].deviceToken forKey:@"device_token"];
          }
     
            [mbProgressHUD show:YES];
          HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
          request.delegate=self;
          [request initwithurl:BASE_URL requestStr:LOGIN requestType:POST input:YES inputValues:dictionary];
            }else{
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
                [alert show];
            }
          
        }
//    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appdelegate setRootView];
    }
-(void)Forgot:(id)sender{
    ForgotViewController *forgotViewController = [[ForgotViewController alloc]initWithNibName:@"ForgotViewController" bundle:nil ];
    [self.navigationController pushViewController:forgotViewController animated:NO];
}

-(IBAction)closeButton:(id)sender {
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appdelegate setRootView];
}

-(void)changeCheckboxStatus:(UIButton *)bttn {
    if (bttn.selected) {
        bttn.selected = FALSE;
        [bttn setBackgroundImage:[UIImage imageNamed:@"tick_box@2x"] forState:UIControlStateNormal];
        
        //when checkbox checked don't show this for next time
        [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:@"guideVisitedStatus"];
       
        //NSLog(@"guideVisitedStatus    %d",[[NSUserDefaults standardUserDefaults] boolForKey:@"guideVisitedStatus"]);
        
    }else{
        bttn.selected = TRUE;
        [bttn setBackgroundImage:[UIImage imageNamed:@"tick@2x"] forState:UIControlStateNormal];
        
        //when checkbox un checked show this for next time
        [[NSUserDefaults standardUserDefaults]setBool:TRUE forKey:@"guideVisitedStatus"];
        
        //NSLog(@"guideVisitedStatus    %d",[[NSUserDefaults standardUserDefaults] boolForKey:@"guideVisitedStatus"]);
        
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(void)showGuideScreen {
    self.title = @"Information";
    guideView.hidden=NO;
    [self.view addSubview: guideScrollView];
    
    UITextView *textView=[[UITextView alloc]initWithFrame:CGRectMake(5, 20, 299, 210)];
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor whiteColor];
    textView.font = [UIFont systemFontOfSize:14];
    textView.editable=NO;
    textView.userInteractionEnabled=NO;
    
    float heightOfText=5;
    
    UILabel *knowYourApp = [[UILabel alloc]initWithFrame:CGRectMake(5, heightOfText, 299, 20)];
    knowYourApp.text = @"Know your App";
    knowYourApp.textAlignment = UITextAlignmentCenter;
    knowYourApp.backgroundColor=[UIColor clearColor];
    knowYourApp.textColor = [UIColor whiteColor];
    knowYourApp.font=[UIFont systemFontOfSize:18];
    
    [guideScrollView addSubview:knowYourApp];
    
    heightOfText=(knowYourApp.frame.origin.y+20);
    
    UILabel *homeLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, heightOfText, 299, 20)];
    homeLabel.text = @"Home Screen";
    homeLabel.textAlignment = UITextAlignmentLeft;
    homeLabel.backgroundColor=[UIColor clearColor];
    homeLabel.textColor = [UIColor whiteColor];
    homeLabel.font=[UIFont systemFontOfSize:16];
    [guideScrollView addSubview:homeLabel];
    
    NSMutableArray *arrayDecription = [[NSMutableArray alloc]initWithObjects:@"New? Sign Up – Lets you sign up as a new user for the app",@"Sign in – Registered user can sign in with his/her credentials", nil];
    NSMutableArray *arrayImage = [[NSMutableArray alloc]initWithObjects:@"create_ac@2x",@"login_icon@2x", nil];
    
    heightOfText = homeLabel.frame.origin.y + 20;
    float heightOfFullText =0;
    
    for (int i=0; i < 2; i++) {
        
        float height1 = (heightOfText+18)+(i*60);
        float height2 = heightOfText+(i*60);
        
        UIImageView *imgForLbl = [[UIImageView alloc]initWithFrame:CGRectMake(10, height1, 26, 26)];
        imgForLbl.image = [UIImage imageNamed:[arrayImage objectAtIndex:i]];
        imgForLbl.contentMode = UIViewContentModeScaleAspectFit;
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(50, height2, 245, 60)];
        lbl.text = [arrayDecription objectAtIndex:i];
        lbl.textAlignment = UITextAlignmentLeft;
        lbl.backgroundColor=[UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.font=[UIFont systemFontOfSize:14];
        lbl.numberOfLines = 10;
        lbl.lineBreakMode = NO;
        
        [guideScrollView addSubview:imgForLbl];
        [guideScrollView addSubview:lbl];
        
        heightOfFullText = lbl.frame.size.height + lbl.frame.origin.y;
    }
    
    UILabel *topMenuLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, heightOfFullText, 299, 20)];
    topMenuLabel.text = @"Top Menu";
    topMenuLabel.textAlignment = UITextAlignmentLeft;
    topMenuLabel.backgroundColor=[UIColor clearColor];
    topMenuLabel.textColor = [UIColor whiteColor];
    topMenuLabel.font=[UIFont systemFontOfSize:16];
    [guideScrollView addSubview:topMenuLabel];
    
    NSMutableArray *arrayDecription1 = [[NSMutableArray alloc]initWithObjects:@"Settings icon – Lets you manage all your app and user settings",@"Eye icon – Turn yourself visible",@"Eye icon – Turn yourself invisible",@"Filter icon – Search for users based on your interests/preferences", nil];
    NSMutableArray *arrayImage1 = [[NSMutableArray alloc]initWithObjects:@"setting@2x",@"eye-show@2x",@"eye-hide@2x",@"filtericon@2x", nil];
    
    heightOfText = heightOfFullText + 20;
    
    for (int i=0; i < 4; i++) {
        
        float height1 = (heightOfText+18)+(i*60);
        float height2 = heightOfText+(i*60);
        
        UIImageView *imgForLbl = [[UIImageView alloc]initWithFrame:CGRectMake(10, height1, 26, 26)];
        imgForLbl.image = [UIImage imageNamed:[arrayImage1 objectAtIndex:i]];
        imgForLbl.contentMode = UIViewContentModeScaleAspectFit;
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(50, height2, 245, 60)];
        lbl.text = [arrayDecription1 objectAtIndex:i];
        lbl.textAlignment = UITextAlignmentLeft;
        lbl.backgroundColor=[UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.font=[UIFont systemFontOfSize:14];
        lbl.numberOfLines = 10;
        lbl.lineBreakMode = NO;
        
        [guideScrollView addSubview:imgForLbl];
        [guideScrollView addSubview:lbl];
        
        heightOfFullText = lbl.frame.size.height + lbl.frame.origin.y;
    }
    
    UILabel *bottomMenuLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, heightOfFullText, 299, 20)];
    bottomMenuLabel.text = @"Bottom Menu";
    bottomMenuLabel.textAlignment = UITextAlignmentLeft;
    bottomMenuLabel.backgroundColor=[UIColor clearColor];
    bottomMenuLabel.textColor = [UIColor whiteColor];
    bottomMenuLabel.font=[UIFont systemFontOfSize:16];
    [guideScrollView addSubview:bottomMenuLabel];
    
    NSMutableArray *arrayDecription2 = [[NSMutableArray alloc]initWithObjects:@"Near By – This lists all the users, with your profile displaying first and the other users, starting with the person closest to you",@"Buzz – Displays ‘New Riders’, who have recently joined the app, and ‘Who viewed my profile’, with users who have viewed your profile",@"Chats – Displays the recent chats. Click on the user to start chatting",@"Current location icon – Takes to back to your current location",@"Favourites - Lists your favourites", nil];
    NSMutableArray *arrayImage2 = [[NSMutableArray alloc]initWithObjects:@"tab_nearby@2x",@"tab_buzz@2x",@"pro-chat@2x",@"location@2x",@"favorite@2x", nil];
    
    heightOfText = heightOfFullText + 20;
    
    for (int i=0; i < 5; i++) {
        
        float height1 = (heightOfText+18)+(i*60);
        float height2 = heightOfText+(i*60);
        
        UIImageView *imgForLbl = [[UIImageView alloc]initWithFrame:CGRectMake(10, height1, 26, 26)];
        imgForLbl.image = [UIImage imageNamed:[arrayImage2 objectAtIndex:i]];
        imgForLbl.contentMode = UIViewContentModeScaleAspectFit;
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(50, height2, 245, 60)];
        lbl.text = [arrayDecription2 objectAtIndex:i];
        lbl.textAlignment = UITextAlignmentLeft;
        lbl.backgroundColor=[UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.font=[UIFont systemFontOfSize:14];
        lbl.numberOfLines = 10;
        lbl.lineBreakMode = NO;
        
        [guideScrollView addSubview:imgForLbl];
        [guideScrollView addSubview:lbl];
        
        heightOfFullText = lbl.frame.size.height + lbl.frame.origin.y;
    }
    
    UILabel *profileViewLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, heightOfFullText, 299, 20)];
    profileViewLabel.text = @"Profile Screen";
    profileViewLabel.textAlignment = UITextAlignmentLeft;
    profileViewLabel.backgroundColor=[UIColor clearColor];
    profileViewLabel.textColor = [UIColor whiteColor];
    profileViewLabel.font=[UIFont systemFontOfSize:16];
    [guideScrollView addSubview:profileViewLabel];
    
    NSMutableArray *arrayDecription3 = [[NSMutableArray alloc]initWithObjects:@"Scroll up/down to see images of the user",@"Scroll left/right to see other user profiles",@"Click on the profile image to see details of user", nil];
    
    heightOfText = heightOfFullText + 20;
    
    for (int i=0; i < 3; i++) {
        
        float height2 = heightOfText+(i*40);
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(15, height2, 245, 40)];
        lbl.text = [arrayDecription3 objectAtIndex:i];
        lbl.textAlignment = UITextAlignmentLeft;
        lbl.backgroundColor=[UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.font=[UIFont systemFontOfSize:14];
        lbl.numberOfLines = 10;
        lbl.lineBreakMode = NO;
        
        [guideScrollView addSubview:lbl];
        
        heightOfFullText = lbl.frame.size.height + lbl.frame.origin.y;
    }
    
    NSMutableArray *arrayDecription4 = [[NSMutableArray alloc]initWithObjects:@"Chat icon – Lets you chat with the user",@"Favourites icon – Lets you add the user to your favourites list",@"Block icon – Lets you block the user", nil];
    NSMutableArray *arrayImage4 = [[NSMutableArray alloc]initWithObjects:@"pro-chat@2x",@"favorite@2x",@"white_block@2x", nil];
    
    heightOfText = heightOfFullText;
    
    for (int i=0; i < 3; i++) {
        
        float height1 = (heightOfText+18)+(i*60);
        float height2 = heightOfText+(i*60);
        
        UIImageView *imgForLbl = [[UIImageView alloc]initWithFrame:CGRectMake(10, height1, 26, 26)];
        imgForLbl.image = [UIImage imageNamed:[arrayImage4 objectAtIndex:i]];
        imgForLbl.contentMode = UIViewContentModeScaleAspectFit;
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(50, height2, 245, 60)];
        lbl.text = [arrayDecription4 objectAtIndex:i];
        lbl.textAlignment = UITextAlignmentLeft;
        lbl.backgroundColor=[UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.font=[UIFont systemFontOfSize:14];
        lbl.numberOfLines = 10;
        lbl.lineBreakMode = NO;
        
        [guideScrollView addSubview:imgForLbl];
        [guideScrollView addSubview:lbl];
        
        heightOfFullText = lbl.frame.size.height + lbl.frame.origin.y;
    }
    
    UILabel *settingsScreenLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, heightOfFullText, 299, 20)];
    settingsScreenLabel.text = @"Settings screen";
    settingsScreenLabel.textAlignment = UITextAlignmentLeft;
    settingsScreenLabel.backgroundColor=[UIColor clearColor];
    settingsScreenLabel.textColor = [UIColor whiteColor];
    settingsScreenLabel.font=[UIFont systemFontOfSize:16];
    [guideScrollView addSubview:settingsScreenLabel];
    
    NSMutableArray *arrayDecription5 = [[NSMutableArray alloc]initWithObjects:@"Settings-> Profile screen\nLets you see your profile, add photos and set your mood message Click on any of your photos. You will get a Photos Screen",@"Settings-> Account screen",@"Settings-> Account screen-> Change password – Lets you modify your password",@"Account screen-> Blocked List – Shows list of blocked users. You can unblock from here",@"Account screen-> Delete Profile – Lets you delete your profile completely and exit. This action is irreversible",@"Settings-> Filters screen - Lets you update your areas of interest",@"Settings-> Update Profile screen - Lets you update your personal details",@"Settings-> App Share screen - You can share your app via facebook, twitter or email",@"Settings-> App info screen - Gives you information about the app",@"Settings-> Feedback screen - Lets you give feedback about the app",@"Settings -> Logout - Logout of the application", nil];
    NSMutableArray *arrayImage5 = [[NSMutableArray alloc]initWithObjects:@"profile_white@2x",@"update_white@2x",@"change-pass-white@2x",@"white_block@2x",@"remove_white@2x",@"filtericon@2x",@"profile_white@2x",@"share_white@2x",@"appinfo_white@2x",@"feedback_white@2x",@"menu_log@2x", nil];
    
    heightOfText = heightOfFullText + 20;
    
    for (int i=0; i < 11; i++) {
        
        float height1 = (heightOfText+18)+(i*60);
        float height2 = heightOfText+(i*60);
        
        UIImageView *imgForLbl = [[UIImageView alloc]initWithFrame:CGRectMake(10, height1, 26, 26)];
        imgForLbl.image = [UIImage imageNamed:[arrayImage5 objectAtIndex:i]];
        imgForLbl.contentMode = UIViewContentModeScaleAspectFit;
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(50, height2, 245, 60)];
        lbl.text = [arrayDecription5 objectAtIndex:i];
        lbl.textAlignment = UITextAlignmentLeft;
        lbl.backgroundColor=[UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.font=[UIFont systemFontOfSize:14];
        lbl.numberOfLines = 10;
        lbl.lineBreakMode = NO;
        
        [guideScrollView addSubview:imgForLbl];
        [guideScrollView addSubview:lbl];
        
        heightOfFullText = lbl.frame.size.height + lbl.frame.origin.y;
    }
    
    UILabel *textInfo = [[UILabel alloc]initWithFrame:CGRectMake(5, heightOfFullText, 299, 40)];
    textInfo.text = @"This information will also be available in Settings->App Info.";
    textInfo.textAlignment = UITextAlignmentLeft;
    textInfo.backgroundColor=[UIColor clearColor];
    textInfo.textColor = [UIColor whiteColor];
    textInfo.font=[UIFont systemFontOfSize:14];
    textInfo.numberOfLines=10;
    [guideScrollView addSubview:textInfo];
    
    heightOfFullText = heightOfFullText+40;
    
    int heightCheckbox = guideScrollView.frame.size.height + guideScrollView.frame.origin.y;
    
    //NSLog(@"heightCheckbox%i",heightCheckbox);
    UIButton *checkBoxButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [checkBoxButton setBackgroundImage:[UIImage imageNamed:@"tick_box"] forState:UIControlStateNormal];
    [checkBoxButton addTarget:self
                       action:@selector(changeCheckboxStatus:)
             forControlEvents:UIControlEventTouchUpInside];
    checkBoxButton.contentMode = UIViewContentModeScaleAspectFit;
    checkBoxButton.frame = CGRectMake(10, heightCheckbox, 20, 20);
    [guideView addSubview:checkBoxButton];
    
    
    UILabel *dontShowLbl = [[UILabel alloc]initWithFrame:CGRectMake(35, 390, 270, 20)];
    dontShowLbl.textColor = [UIColor whiteColor];
    dontShowLbl.backgroundColor = [UIColor clearColor];
    dontShowLbl.text = @"Do not show this message again.";
    dontShowLbl.font = [UIFont systemFontOfSize:13];
    [guideView addSubview:dontShowLbl];
    guideScrollView.contentSize=CGSizeMake(299, heightOfFullText);
    
    if([UIScreen mainScreen].bounds.size.height ==568) {
        checkBoxButton.frame = CGRectMake(10, 470, 20, 20);
        dontShowLbl.frame =CGRectMake(35, 470, 270, 20);
        
    } else{
        backImageView.frame = CGRectMake(backImageView.frame.origin.x, backImageView.frame.origin.y-10, backImageView.frame.size.width, backImageView.frame.size.height+20);
        checkBoxButton.frame = CGRectMake(10, 390, 20, 20);
        dontShowLbl.frame =CGRectMake(35, 390, 270, 20);
    }
    
}

@end
