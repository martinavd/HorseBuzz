//
//  ChangePassword.m
//  HorseBuzz
//
//  Created by Ritheesh Koodalil on 20/02/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "ChangePassword.h"
#import "CMLNetworkManager.h"
#import "HorseBuzzDataManager.h"
#import "MBProgressHUD.h"
#import "HorseBuzzConfig.h"
#import "SetInvisibleUser.h"
#import "GAI.h"
#import "AppDelegate.h"

@interface ChangePassword (){
    MBProgressHUD *mbProgressHUD;
    UITextField *selTextField;
    NSMutableArray *textArray;
    CGFloat animatedDistance;
    UIButton *eyeButton;
}
@property(nonatomic,strong) UIToolbar *keyBoardBar;
@end

@implementation ChangePassword
@synthesize keyBoardBar;
@synthesize isOTPLogin;
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
    //[tracker trackView:@"Horse Buzz - Change password view"];
    [tracker set:@"ScreenName" value:@"Horse Buzz - Change password view"];
    // google tracking code end
    
    float version = [[[UIDevice currentDevice] systemVersion]floatValue];
    if (version >= 7.0) {
        self.navigationItem.hidesBackButton =FALSE;
    }else{
        UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0,100, 20);
        [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
        [backButton setTitle:@" Account" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(moveBack) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarButton =[[UIBarButtonItem alloc]initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButton;
    }
    textArray = [[NSMutableArray alloc]init];
    for(int i = 1 ; i < 4 ; i++){
        UITextField *reffield = (UITextField *)[self.view viewWithTag:i];
        [textArray addObject:reffield];
    }
    self.title=@"Change Password";
    mbProgressHUD = [[MBProgressHUD alloc]initWithView:self.view];
    [mbProgressHUD setMode:MBProgressHUDModeIndeterminate];
    [self.view addSubview:mbProgressHUD];
    [super viewDidLoad];
    
    eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    eyeButton.frame = CGRectMake(0, 0, 19, 19);
    [eyeButton addTarget:self action:@selector(setVisibilty) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *eyeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:eyeButton];
    
    
    if (isOTPLogin) {
        self.navigationItem.hidesBackButton=YES;
    }
    
    self.navigationItem.rightBarButtonItem = eyeButtonItem;
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"isInvisible"]){
        [eyeButton setImage:[UIImage imageNamed:@"eye-show"] forState:UIControlStateNormal];
    }
    else{
        [eyeButton setImage:[UIImage imageNamed:@"eye-hide"] forState:UIControlStateNormal];
    }
}

-(void)setVisibilty{
    SetInvisibleUser *setVisible =[[SetInvisibleUser alloc]init];
    [setVisible setVisibilty];
    
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"isInvisible"]){
        [eyeButton setImage:[UIImage imageNamed:@"eye-show"] forState:UIControlStateNormal];
    }
    else{
        [eyeButton setImage:[UIImage imageNamed:@"eye-hide"] forState:UIControlStateNormal];
    }
}
-(void)moveBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)changePassword:(id)sender{
    NSMutableArray *checkTextFiled=[[NSMutableArray alloc]initWithObjects:oldPasswordTxt,newPasswordTxt,comfirmPasswordTxt, nil];
    if([self validateFields:checkTextFiled]){
        if([comfirmPasswordTxt.text isEqualToString:newPasswordTxt.text]){
            if([[CMLNetworkManager sharedInstance] hasConnectivity]){
                
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
                ;
                [dictionary setObject:newPasswordTxt.text forKey:@"new_password"];
                [dictionary setObject:oldPasswordTxt.text forKey:@"old_password"];
                [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
                
                
                [mbProgressHUD show:YES];
                HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
                request.delegate=self;
                [request initwithurl:BASE_URL requestStr:USERCHANGEPASSWORD requestType:POST input:YES inputValues:dictionary];
            }else{
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"New password and Confirm password is not matching" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

-(void)getResponsedata:(NSDictionary *)data{
    [mbProgressHUD hide:YES];
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    NSString *code = [data objectForKey:@"code"];
    
    BOOL equal=[[NSString stringWithFormat:@"%d",[code integerValue]] isEqualToString:@"2"];
    
    NSString *errorMsg = [data objectForKey:@"errors"];
    
    if (status) {
        //NSLog(@"errorMsgasds%@",errorMsg);
        
        if (isOTPLogin) {
            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appdelegate setRootView];
        } else {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Your Password is updated" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            alert.tag=100;
            [alert show];
        }
    }
    else if(equal) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:errorMsg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        alert.tag=101;
        [alert show];
        [oldPasswordTxt becomeFirstResponder];
        oldPasswordTxt.layer.borderColor = [UIColor redColor].CGColor;
        oldPasswordTxt.text = @"";
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==100){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
}

-(BOOL)checkStringByRemovingSpaces:(NSString*)string{
    NSString * checkString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (checkString.length < 1)
        return FALSE;
    else
        return TRUE;
}


-(BOOL)validateFields:(NSMutableArray *)textFieldArray{
    
    BOOL valid;
    int count = 0;
    for (int i = 0; i < textFieldArray.count; i++) {
        UITextField *refField = [textFieldArray objectAtIndex:i];
        refField.layer.borderWidth = 1.0;
        NSString *checkString = refField.text;
        if (checkString.length > 0 && [self checkStringByRemovingSpaces:checkString]) {
            refField.layer.borderColor = [UIColor whiteColor].CGColor;
            count++;
        }
        else {
            refField.layer.borderColor = [UIColor redColor].CGColor;
            valid = FALSE;
            count--;
        }
        
        if (i == 1 && checkString.length < 8) {
            refField.layer.borderColor = [UIColor redColor].CGColor;
            [refField becomeFirstResponder];
            count--;
        }
    }
    
    if (count == 3)return valid =TRUE;
    else return valid = FALSE;
    
}

#pragma mark - Textfeild delegate methods
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 200.0;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 172.0;


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    selTextField=textField;
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


-(void)textViewDidBeginEditing:(UITextView *)textView{
    
    CGRect textFieldRect = [self.view.window convertRect:textView.bounds fromView:textView];
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
-(void)textViewDidEndEditing:(UITextView *)textView{
    CGRect viewFrame = self.view.frame;
	viewFrame.origin.y += animatedDistance;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	[self.view setFrame:viewFrame];
    [UIView commitAnimations];
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    textView.inputAccessoryView = self.keyBoardBar;
    selTextField=nil;
    
    return YES;
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
    int currentTag =0;
    if (selTextField != nil) {
        currentTag = selTextField.tag;
    }
    
    if (currentTag - 1 > 0) {
        [[textArray objectAtIndex:currentTag-1] resignFirstResponder];
        [[textArray objectAtIndex:currentTag-2] becomeFirstResponder];
    }
}
-(IBAction)keyboardNext:(id)sender{
    
    int currentTag;
    if (selTextField != nil) {
        currentTag = selTextField.tag;
    }
    
    if (currentTag  < [textArray count]) {
        [[textArray objectAtIndex:currentTag-1] resignFirstResponder];
        [[textArray objectAtIndex:currentTag] becomeFirstResponder];
    }
}

-(IBAction)keyboardDone:(id)sender{
    [selTextField resignFirstResponder];
    
    
}


@end
