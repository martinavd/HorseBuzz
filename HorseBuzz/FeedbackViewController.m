//
//  FeedbackViewController.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 27/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "FeedbackViewController.h"
#import "HorseBuzzConfig.h"
#import "MBProgressHUD.h"
#import "HorseBuzzDataManager.h"
#import <QuartzCore/QuartzCore.h>
#import "SetInvisibleUser.h"
#import "GAI.h"

@interface FeedbackViewController ()
{
    CGFloat animatedDistance;
    MBProgressHUD *mbProgressHUD;
    NSMutableArray *textArray;
    UIButton *eyeButton;
}
@end

@implementation FeedbackViewController
@synthesize subject,description,placeHolder;
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
    //[tracker trackView:@"Horse Buzz - Feedback view"];
    [tracker set:@"ScreenName" value:@"Horse Buzz - Feedback view" ];
    // google tracking code end
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    float version = [[[UIDevice currentDevice] systemVersion]floatValue];
    if (version >= 7.0) {
        self.navigationItem.hidesBackButton =FALSE;
    }else{
        UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0,85, 20);
        [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
        // [backButton setTitleEdgeInsets:UIEdgeInsetsMake(70.0, -150.0, 5.0, 5.0)];
        [backButton setTitle:@" Settings" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(moveBack) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarButton =[[UIBarButtonItem alloc]initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButton;
    }
    
    
    mbProgressHUD = [[MBProgressHUD alloc]initWithView:self.view];
    [mbProgressHUD setMode:MBProgressHUDModeIndeterminate];
    [self.view addSubview:mbProgressHUD];
    textArray = [[NSMutableArray alloc]init];
    for(int i = 1 ; i < 3 ; i++){
        UITextField *reffield = (UITextField *)[self.view viewWithTag:i];
        [textArray addObject:reffield];
    }
    self.placeHolder.hidden = NO;
    self.title=@"Feed Back";
    
    eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    eyeButton.frame = CGRectMake(0, 0, 19, 19);
    [eyeButton addTarget:self action:@selector(setVisibilty) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *eyeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:eyeButton];
    self.navigationItem.rightBarButtonItem = eyeButtonItem;
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)moveBack{
    [self.navigationController popViewControllerAnimated:YES];
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
    if (phnNumber.length >= 1 && [self checkStringByRemovingSpaces:phnNumber]) valid = YES;
    else valid = NO;
    return valid;
}

-(BOOL)validateFields:(NSMutableArray *)textFieldArray{
    BOOL valid;
    int count = 0;
    for(int i = 0 ; i < textFieldArray.count ; i++){
        UITextField *reffield  = (UITextField *)[textFieldArray objectAtIndex:i]  ;
        reffield.layer.borderWidth = 1.0;
        self.description.layer.borderWidth = 1.0;
        NSString *checkString = reffield.text;
        if (checkString.length > 0) {
            if (i == 0)
                valid = [self checkNumberOfChars:self.subject.text];
            else
                valid = [self checkNumberOfChars:self.description.text];
            
            if (valid) {
                if (i !=1 )reffield.layer.borderColor = [UIColor whiteColor].CGColor;
                else
                    self.description.layer.borderColor = [UIColor whiteColor].CGColor;
                count++;
            }
            else {
                if (i !=1 )reffield.layer.borderColor = [UIColor redColor].CGColor;
                else
                    self.description.layer.borderColor = [UIColor redColor].CGColor;
                count--;
            }
            
        }
        else {
            if (i !=1 )reffield.layer.borderColor = [UIColor redColor].CGColor;
            else
                self.description.layer.borderColor = [UIColor redColor].CGColor;
            valid = FALSE;
            count--;
        }
    }
    if (count == 2)return valid =TRUE;
    else return valid = FALSE;
    
}


-(void)sendFeedback:(id)sender{
    if ([self validateFields:textArray]) {
        if ([[CMLNetworkManager sharedInstance]hasConnectivity]) {
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            
            [dictionary setObject:self.subject.text forKey:@"subject"];
            [dictionary setObject:self.description.text forKey:@"feedback"];
            [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
            
            [mbProgressHUD show:YES];
            [self.view setUserInteractionEnabled:NO];
            HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
            request.delegate=self;
            [request initwithurl:BASE_URL  requestStr:@"SendEnquiry" requestType:POST input:YES inputValues:dictionary ];
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
            [alert show];}
    }
}

#pragma mark - TextField Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - TextView Delegates
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 200.0;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 172.0;

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
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.placeHolder.hidden = YES;
    return YES;
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if(self.description.text.length == 0)
        self.placeHolder.hidden = NO;
    return YES;
}
-(void) textViewDidChange:(UITextView *)textView
{
    if(self.description.text.length == 0){
        self.placeHolder.hidden = NO;
        [self.description resignFirstResponder];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.description.text= @"";
    self.placeHolder.hidden = NO;
    self.subject.text= @"";
}

#pragma mark - HTTPrequest delegates
-(void)getResponsedata:(NSDictionary *)data{
    [self.view setUserInteractionEnabled:YES];
    [mbProgressHUD hide:YES];
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    
    if (status) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:@"Your feedback sent successfully." delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:@"Error in sending enquiry. Please try again." delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
}
-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
}
@end
