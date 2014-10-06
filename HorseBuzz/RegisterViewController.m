//
//  RegisterViewController.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 16/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "RegisterViewController.h"
#import "LogInViewController.h"
#import "CMLNetworkManager.h"
#import "HorseBuzzConfig.h"
#import "LocationManager.h"
#import "MBProgressHUD.h"
#import "InterestKeys.h"
#import "HorseBuzzDataManager.h"
#import "PECropViewController.h"
#import "GAI.h"
#import "AppDelegate.h"

@interface RegisterViewController ()<PECropViewControllerDelegate>
{
    NSMutableArray *textArray;
    UITextField *selTextField;
    UITextView *selTextView;
    CGFloat animatedDistance;
    NSString *gender;
    MBProgressHUD *mbProgressHUD;
    NSMutableArray *interestArray;
    NSMutableArray *selectedIndexArray;
    UIImagePickerController *picker;
    UIImage *pickedImage;
    int tag;
    UIView *termsview;
    BOOL wrongPassword;
    NSDate *maxAllowedDate;
    
    AppDelegate *appDelegate;
}
@property(nonatomic,strong) UIToolbar *keyBoardBar;
@property(nonatomic,strong) UIDatePicker *datePicker;


@end

@implementation RegisterViewController
@synthesize keyBoardBar;
@synthesize datePicker;
@synthesize maleSel,femaleSel;
@synthesize firstNameField,lastNameFiled,dobFiled,emailField,userNameField,passwordField;
@synthesize createView;
@synthesize scrollView;
@synthesize aboutMeTextView;
@synthesize interestTable;
@synthesize profileBttn;
@synthesize termsAndConditions;
@synthesize termsAccept;
@synthesize termsAndConditionView;
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
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // google tracking code
//    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLEANALITICSCODE];
//    [tracker trackView:@"Horse Buzz - Register view"];
    // google tracking code end
    
    [dobFiled setEnablesReturnKeyAutomatically:NO];
    
    wrongPassword = FALSE;
    termsAndConditionView.hidden=YES;
    scrollView.contentSize=CGSizeMake(320, 855);
    interestArray=[[NSMutableArray alloc]init];
    [interestArray addObjectsFromArray:[InterestKeys sharedInstance].interestArray];
    
    selectedIndexArray=[[NSMutableArray alloc]init];
    [super viewDidLoad];
    
    
    
    
    // Do any additional setup after loading the view from its nib.
    [LocationManager sharedInstance];
    mbProgressHUD = [[MBProgressHUD alloc]initWithView:self.view];
    [mbProgressHUD setMode:MBProgressHUDModeIndeterminate];
    [self.view addSubview:mbProgressHUD];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillActive:) name:UIApplicationWillEnterForegroundNotification object:nil];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    self.title = @"Create an account";
    textArray = [[NSMutableArray alloc]init];
    for(int i = 1 ; i < 8 ; i++){
        UITextField *reffield = (UITextField *)[self.view viewWithTag:i];
        [textArray addObject:reffield];
    }
    
    datePicker = [[UIDatePicker alloc] init];
	datePicker.datePickerMode = UIDatePickerModeDate;
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDate * currentDate = [NSDate date];
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    [comps setYear: -13];
    NSDate * maxDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    maxAllowedDate = maxDate;
    
    
    [comps setYear: -100];
    NSDate * minDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    
    //[datePicker setMaximumDate:maxDate];
    [datePicker setMinimumDate:minDate];
	[datePicker addTarget:self
                   action:@selector(changeDateInLabel:)
         forControlEvents:UIControlEventValueChanged];
    [datePicker setDate:maxDate];

    [self setupKeyBoard];
    gender = @"male";
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
     [self.termsAndConditions addGestureRecognizer: tapGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)appWillActive:(NSNotification*)note
{
    if ([selTextField canResignFirstResponder]) {
        [selTextField resignFirstResponder];
    }
}


- (void) handleTapGesture: (UIGestureRecognizer*) recognizer
{
    termsview  = [[UIView alloc]initWithFrame:CGRectMake(20, 20, 280, self.view.frame.size.height - 40) ];
    termsview.layer.cornerRadius = 5.0;
    termsview.backgroundColor = [UIColor grayColor];
    termsview.userInteractionEnabled  = true;
    UILabel *terms = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 240, 50) ];
    terms.backgroundColor = [UIColor clearColor];
    terms.text = @"Terms and Conditions.";
    terms.textAlignment = UITextAlignmentCenter;
    [termsview addSubview:terms];
    
    UITextView *termsText = [[UITextView alloc]initWithFrame:CGRectMake(10, 55, 260, termsview.frame.size.height - 55) ];
    termsview.userInteractionEnabled = NO;
    termsText.backgroundColor =[ UIColor clearColor];
    [termsview addSubview:termsText];
    
    UIButton *close =[UIButton buttonWithType:UIButtonTypeCustom];
    [close setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [close addTarget:self action:@selector(closeTermsView) forControlEvents:UIControlEventTouchUpInside];
    close.frame = CGRectMake(5, 5, 30, 30);
    [termsview addSubview:close];
    
    UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTermsView)];
    [termsview addGestureRecognizer: tapGesture];
    [self.view addSubview:termsview];
    
}
-(void)closeTermsView{
    
    [termsview removeFromSuperview];
    termsview = nil;
}
-(void)termsAcceptAction:(id)sender{
    if (self.termsAccept.selected) {
        self.termsAccept.selected = FALSE;
        [self.termsAccept setBackgroundImage:[UIImage imageNamed:@"tick_box"] forState:UIControlStateNormal];
        
    }else{
        self.termsAccept.selected = TRUE;
        [self.termsAccept setBackgroundImage:[UIImage imageNamed:@"tick"] forState:UIControlStateNormal];
    }
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

- (void)changeDateInLabel:(id)sender{
	//Use NSDateFormatter to write out the date in a friendly format
    
    NSDate *date = datePicker.date;
    
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    int year = [components1 year];
    int month = [components1 month];
    int day = [components1 day];
    
    NSDate *today1 = [NSDate date];
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:today1];
    int curYear = [components2 year];
    int curMonth = [components2 month];
    int curDay = [components2 day];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateStyle = NSDateFormatterMediumStyle;
    [df setDateFormat:@"dd-MMM-yyyy"];
    
    NSDate *today = [NSDate date];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit
                                                        fromDate:today
                                                          toDate:date
                                                         options:0];
    
    NSInteger tmpYear = year;
    [components1 setYear:( (curYear - year) >= 13)? year : (tmpYear =(curYear -13))];
    [components1 setYear:( ((curYear - tmpYear)<= 13 && (curMonth - month) < 0))? tmpYear = (curYear -13) - 1: year];
    [components1 setYear:( ((curYear - tmpYear)<= 13 && (curMonth - month) == 0) && (day > curDay))? tmpYear = (curYear -13) -1 : year];
    
    [components1 setYear: tmpYear];
    
    //NSLog(@"%d",((curYear - year) >= 13 && (curMonth - month) <= 0));
    //NSLog(@"[components day]%d",[components1 day]);
    //NSLog(@"[components month]%d",[components1 month]);
    //NSLog(@"[components year]%d",[components1 year]);
    
    date = [gregorianCalendar dateFromComponents:components1];
    datePicker.date = [gregorianCalendar dateFromComponents:components1];
    
    selTextField.text = [df stringFromDate:date];
    
//    if ((long)[components day] != 0) {
//        selTextField.text = [df stringFromDate:date];
//    } else {
//        selTextField.text = [df stringFromDate:maxAllowedDate];
//    }
}

-(IBAction)MaleSelection:(id)sender{
    UIButton *refButton = (UIButton *)sender;
    if (refButton.selected)
        return;
    if (refButton.selected) {
        refButton.selected = NO;
    }else{
        refButton.selected = YES;
        femaleSel.selected = NO;
        gender = @"male";
    }
}


-(IBAction)FemaleSelection:(id)sender{
    UIButton *refButton = (UIButton *)sender;
    if (refButton.selected)
        return;
    if (refButton.selected) {
        refButton.selected = NO;
    }else{
        refButton.selected = YES;
        maleSel.selected = NO;
        gender = @"female";
    }
}
-(IBAction)CalenderClicked:(id)sender{
    UITextField *refField = (UITextField *)[textArray objectAtIndex:2];
    
    [refField becomeFirstResponder];
}

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
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
            
            if (i == 3) {
                valid = [self validateEmailWithString:checkString];
            }
            else if (i == 5) {
                valid = [self checkNumberOfChars:checkString];
            }
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
    
    if(profileBttn.selected){
        profileBttn.layer.borderColor = [UIColor clearColor].CGColor;
        if (count == 7){
            return valid =TRUE;
        }
        else{
            [scrollView scrollRectToVisible:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) animated:YES];
            return valid = FALSE;
        }
    }
    else{
        profileBttn.layer.cornerRadius=3.0f;
        profileBttn.layer.masksToBounds=YES;
        profileBttn.layer.borderColor=[[UIColor redColor]CGColor];
        profileBttn.layer.borderWidth= 1.0f;
        if (count < 7){
            [scrollView scrollRectToVisible:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) animated:YES];
        }
        return valid = FALSE;
    }
}

#pragma mark - HTTP request delegate methods
-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
    
    
}
-(void)getResponsedata:(NSDictionary *)data{
    
    //NSLog(@"datadatadata%@",data);
    [mbProgressHUD hide:YES];
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    NSString * code = [data objectForKey:@"code"];
    if (status) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:@"You have been successfully registered with HorseBuzz. You Are Automatically signed in." delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
    [alert show];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"user_registered"];
        
    [self DoSignIn];
    
        
    }else if ([code intValue] == 2){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:[NSString stringWithFormat:@"%@",[data objectForKey:@"errors"]] delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        alert.tag = 101;
        [alert show];
        
    }
}

#pragma mark - keyboard functions

-(IBAction)keyboardPrevious:(id)sender{
    int currentTag;
    if (selTextField != nil) {
        currentTag = selTextField.tag;
    }
    else
        currentTag = selTextView.tag;
    if (currentTag-1 > 0) {
        [[textArray objectAtIndex:currentTag-1] resignFirstResponder];
        [[textArray objectAtIndex:currentTag-2] becomeFirstResponder];
    }
}
-(IBAction)keyboardNext:(id)sender{
    
    int currentTag;
    if (selTextField != nil) {
        currentTag = selTextField.tag;
    }
    else
        currentTag = selTextView.tag;
    
    
    if (selTextField == dobFiled) {
        [self changeDateInLabel:nil];
    }
    if (currentTag  < [textArray count]) {
        [[textArray objectAtIndex:currentTag-1] resignFirstResponder];
        [[textArray objectAtIndex:currentTag] becomeFirstResponder];
    }
}
-(IBAction)keyboardDone:(id)sender{
    if (selTextView != nil) {
        [selTextView resignFirstResponder];
    }
    else{
        
        if (selTextField == dobFiled) {
            [self changeDateInLabel:nil];
        }
        [selTextField resignFirstResponder];
    }
    
}

#pragma mark - Textfeild delegate methods
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 200.0;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 172.0;


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    selTextView=nil;
    selTextField=textField;
    textField.inputAccessoryView = self.keyBoardBar;
    if (textField.tag == 3) {
        textField.inputView = self.datePicker;
    }
    
    if (textField.tag==1 && textField.tag==2) {
        NSString *nameRegex = @"[A-Za-z]{2,50}";
        
        NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", textField.text];
        
        //NSLog(@"test%d",[nameTest evaluateWithObject:nameRegex]);
    }
    selTextField = textField;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField.tag==1 || textField.tag ==2) {
        if ([string isEqualToString:@"0"] || [string isEqualToString:@"1"] || [string isEqualToString:@"2"]|| [string isEqualToString:@"3"] || [string isEqualToString:@"4"] || [string isEqualToString:@"5"] || [string isEqualToString:@"6"] || [string isEqualToString:@"7"] || [string isEqualToString:@"8"] || [string isEqualToString:@"9"]) {
            return FALSE;
        } else {
            return TRUE;
        }
    } else {
        return TRUE;
    }
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
    selTextView=textView;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ((textView.text.length + text.length) < 200){
        return YES;
    }
    else{
        return NO;
    }
}


#pragma mark - Instance methods
-(void)CreateAccount:(id)sender{
    if ([self validateFields:textArray]) {
        if(selectedIndexArray.count!=0){
            if (self.termsAccept.selected) {
                if([[CMLNetworkManager sharedInstance] hasConnectivity]){
                    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
                    [dictionary setObject:self.firstNameField.text forKey:@"firstname"];
                    [dictionary setObject:self.lastNameFiled.text forKey:@"lastname"];
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"dd-MMM-yyyy"];
                    NSDate *orignalDate = [dateFormatter dateFromString:self.dobFiled.text];
                    
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    NSString *finalDOB = [dateFormatter stringFromDate:orignalDate];
                    
                    //NSLog(@"self.dobFiled.text%@",self.dobFiled.text);
                    //NSLog(@"finalDOB%@",finalDOB);
                    
                    [dictionary setObject:finalDOB forKey:@"dob"];
                    [dictionary setObject:gender forKey:@"gender"];
                    [dictionary setObject:self.emailField.text forKey:@"email"];
                    [dictionary setObject:self.userNameField.text forKey:@"username"];
                    [dictionary setObject:self.passwordField.text forKey:@"password"];
                    [dictionary setObject:self.aboutMeTextView.text forKey:@"about_me"];
                    if ([HorseBuzzDataManager sharedInstance].deviceToken) {
                        [dictionary setObject:[HorseBuzzDataManager sharedInstance].deviceToken forKey:@"device_token"];
                    }
                    
                    if (pickedImage) {
                        CGFloat quality = 0.85;
                        NSData *jpegdata = UIImageJPEGRepresentation(pickedImage,quality);
                        NSString * encodedImage=[jpegdata base64Encoding];
                        [dictionary setObject:encodedImage forKey:@"profileImage"];
                    }
                    
                    if([selectedIndexArray containsObject:@"0"]){
                        [selectedIndexArray removeObject:@"0"];
                    }
                    NSString *selInterest=@"";
                    for(int i=0;i<selectedIndexArray.count;i++){
                        selInterest=[selInterest stringByAppendingString:[NSString stringWithFormat:@"%@,",[[InterestKeys sharedInstance].interestIDArray objectAtIndex:[[selectedIndexArray objectAtIndex:i]intValue]]]];
                    }
                    
                    selInterest = [selInterest substringToIndex:[selInterest length] - 1];
                    
                    [dictionary setObject:selInterest forKey:@"area_intrest"];
                    [dictionary setObject:@"1" forKey:@"is_active"];
                    [dictionary setObject:@"0" forKey:@"is_deleted"];
                    
                    [mbProgressHUD show:YES];
                    HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
                    request.delegate=self;
                    [request initwithurl:BASE_URL requestStr:REGISTRATION requestType:POST input:YES inputValues:dictionary];
                }
                else{
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
            else{
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:@"Please accept the Terms and Conditions." delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
                [alert show];
            }}
        else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:@"Please select at least one area of interest" delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

-(void)DoSignIn {
    //NSLog(@"array isss%@",textArray);
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
            
            //MAR - Fix for auto login after registration
            [mbProgressHUD show:YES];
            HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
            LogInViewController *login = [[LogInViewController alloc] init];
            request.delegate= login;
            [request initwithurl:BASE_URL requestStr:LOGIN requestType:POST input:YES inputValues:dictionary];
            
            [[self navigationController] pushViewController:login animated:NO];
            
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    //    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //    [appdelegate setRootView];
}

-(void)SignIn:(id)sender{
  LogInViewController *logInViewController = [[LogInViewController alloc]initWithNibName:@"LogInViewController" bundle:nil ];
    [self.navigationController pushViewController:logInViewController animated:NO];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100) {
        [self SignIn:nil];
    }
    else if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.mediaTypes = [NSArray arrayWithObjects:
                                 (NSString *) kUTTypeImage,
                                 nil];
            picker.allowsEditing = NO;
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            [self presentModalViewController:picker animated:YES];
        }else if (buttonIndex == 2){
            picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            
            if( [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront ])
            {
                picker.sourceType = UIImagePickerControllerCameraDeviceFront;
                picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                picker.cameraDevice = UIImagePickerControllerSourceTypeCamera;
            }
            
            // Hide the controls
            picker.showsCameraControls = YES;
            picker.navigationBarHidden = YES;
            
            // Make camera view full screen
            picker.wantsFullScreenLayout = YES;
            
            [self presentModalViewController:picker animated:YES];
        }else{
            
        }
    }
    
}


-(IBAction)addPic:(id)sender{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:@"Choose your image SourceType." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Album",@"Camera", nil];
    alert.tag = 101;
    [alert show];
}


- (UIImage *)cropImage:(UIImage *)oldImage {
    CGSize imageSize = oldImage.size;
    UIGraphicsBeginImageContextWithOptions( CGSizeMake( imageSize.width,
                                                       imageSize.height - 200),
                                           NO,
                                           0.);
    [oldImage drawAtPoint:CGPointMake( 0, -100)
                blendMode:kCGBlendModeCopy
                    alpha:1.];
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return croppedImage;
}

- (CGRect) TransformCGRectForUIImageOrientation: (CGRect) source: (UIImageOrientation) orientation: (CGSize) imageSize {
    
    switch (orientation) {
        case UIImageOrientationLeft: { // EXIF #8
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(
                                                                             imageSize.height, 0.0);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,
                                                                   M_PI_2);
            return CGRectApplyAffineTransform(source, txCompound);
        }
        case UIImageOrientationDown: { // EXIF #3
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(
                                                                             imageSize.width, imageSize.height);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,
                                                                   M_PI);
            return CGRectApplyAffineTransform(source, txCompound);
        }
        case UIImageOrientationRight: { // EXIF #6
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(
                                                                             0.0, imageSize.width);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,
                                                                   M_PI + M_PI_2);
            return CGRectApplyAffineTransform(source, txCompound);
        }
        case UIImageOrientationUp: // EXIF #1 - do nothing
        default: // EXIF 2,4,5,7 - ignore
            return source;
    }
}


#pragma mark - Area of interest UITableView

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *Cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(Cell==nil){
        Cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
    }
    Cell.textLabel.text=[interestArray objectAtIndex:indexPath.row];
    Cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    Cell.textLabel.textColor = [UIColor redColor];
    
    Cell.backgroundColor=[UIColor lightGrayColor];
    Cell.accessoryType = UITableViewCellAccessoryNone;
    for(int i=0;i<selectedIndexArray.count;i++){
        if([[selectedIndexArray objectAtIndex:i] isEqualToString:[NSString stringWithFormat:@"%i",indexPath.row]]){
            
            
            Cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
    }
    
    
    return Cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return interestArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if((indexPath.row==0) && (selectedIndexArray.count ==interestArray.count)){
        [selectedIndexArray removeAllObjects];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"HorseBuzz" message:@"Select atleast one interest" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if(indexPath.row==0){
        [selectedIndexArray removeAllObjects];
        for(int i=0;i<interestArray.count;i++){
            [selectedIndexArray addObject:[NSString stringWithFormat:@"%i",i]];
        }
        // Scroll the cell cell to the middle of the tableview
        [tableView setContentOffset:CGPointMake(0, tableView.rowHeight * (interestArray.count - 3)) animated:YES];

    }
    else{
        BOOL checkPrevious=FALSE;
        for(int i=0;i<selectedIndexArray.count;i++){
            
            if([[selectedIndexArray objectAtIndex:i] isEqualToString:[NSString stringWithFormat:@"%i",indexPath.row]]){
                [selectedIndexArray removeObjectAtIndex:i];
                checkPrevious=TRUE;
                for(int j=0;j<selectedIndexArray.count;j++){
                    if([[selectedIndexArray objectAtIndex:j]isEqualToString:@"0"]){
                        [selectedIndexArray removeObject:@"0"];
                        break;
                    }
                }
                // Scroll the cell cell to the middle of the tableview
                [tableView setContentOffset:CGPointMake(0, tableView.rowHeight * (indexPath.row)) animated:YES];
                break;
            }
        }
        
        if(!checkPrevious){
            [selectedIndexArray addObject:[NSString stringWithFormat:@"%i",indexPath.row]];
            if(selectedIndexArray.count ==interestArray.count-1){
                [selectedIndexArray addObject:@"0"];
            }
            // Scroll the cell cell to the middle of the tableview
            [tableView setContentOffset:CGPointMake(0, tableView.rowHeight * (indexPath.row -1)) animated:YES];
        }
    }
    
    
    [interestTable reloadData];
    
    
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDecelerating:(UITableView *)tableView {
    int co = ((int)tableView.contentOffset.y % (int)tableView.rowHeight);
    if (co < tableView.rowHeight / 2)
        [tableView setContentOffset:CGPointMake(0, tableView.contentOffset.y - co) animated:YES];
    else
        [tableView setContentOffset:CGPointMake(0, tableView.contentOffset.y + (tableView.rowHeight - co)) animated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDragging:(UITableView *)scrollView willDecelerate:(BOOL)decelerate {
    if(decelerate)
        return;
    [self scrollViewDidEndDecelerating:scrollView];
}




#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    
    
    [profileBttn setImage:croppedImage forState:UIControlStateNormal];
    profileBttn.selected=YES;
    profileBttn.layer.borderColor = [UIColor clearColor].CGColor;
    
    pickedImage = croppedImage;
    
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
}
- (IBAction)openEditor:(id)sender
{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = pickedImage;
    
    controller.toolbarHidden =YES;
    controller.keepingCropAspectRatio =YES;
    
    UIImage *image = pickedImage;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void)imagePickerController:(UIImagePickerController *) Picker

didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor:nil];
    }];
    pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
}

-(void)showTermsAndCondition{
    self.title =@"Terms and Conditions";
    termsAndConditionView.hidden=NO;
}

-(void)removeTermsAndCondition{
    self.title = @"Create an account";
    termsAndConditionView.hidden=YES;
}

- (IBAction)genderSelectionTap:(UITapGestureRecognizer *)sender {
    UILabel *selectedLabel = (UILabel *)[sender view];
    if (selectedLabel.tag == 0) {
       //Male
    }
    else{
        //Female
    }
}

@end