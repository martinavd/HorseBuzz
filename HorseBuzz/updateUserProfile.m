//
//  updateUserProfile.m
//  HorseBuzz
//
//  Created by Ritheesh Koodalil on 28/03/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "updateUserProfile.h"
#import "HorseBuzzDataManager.h"
#import "CMLNetworkManager.h"
#import "MBProgressHUD.h"
#import "HorseBuzzConfig.h"
#import "GAI.h"

@interface updateUserProfile (){
    NSString *gender;
    CGFloat animatedDistance;
    UITextView *selTextView;
    UITextField *selTextField;
    NSMutableArray *textArray;
    MBProgressHUD *mbProgressHUD;
    NSMutableDictionary *profileDetailArray;
    BOOL isUpdateStatus;
}
@property(nonatomic,strong) UIToolbar *keyBoardBar;
@property(nonatomic,strong) UIDatePicker *datePicker;
@end

@implementation updateUserProfile
@synthesize maleSel,femaleSel;
@synthesize firstNameField,lastNameFiled,dobFiled;
@synthesize datePicker;

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
    //[tracker trackView:@"Horse Buzz - Update profile view"];
    [tracker set:@"ScreenName" value:@"Horse Buzz - Update profile view" ];
    // google tracking code end
    
    self.title=@"Update Profile";
    textArray = [[NSMutableArray alloc]init];
    for(int i = 1 ; i < 6 ; i++){
        UITextField *reffield = (UITextField *)[self.view viewWithTag:i];
        [textArray addObject:reffield];
    }
    [self setupKeyBoard];
    
    
    float version = [[[UIDevice currentDevice] systemVersion]floatValue];
    if (version >= 7.0) {
        self.navigationItem.hidesBackButton =FALSE;
    }else{
        UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0,85,20);
        [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
        [backButton setTitle:@" Settings" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(moveBack) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarButton =[[UIBarButtonItem alloc]initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButton;
    }
    
    /*datePicker = [[UIDatePicker alloc] init];
     datePicker.datePickerMode = UIDatePickerModeDate;
     NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
     NSDate * currentDate = [NSDate date];
     NSDateComponents * comps = [[NSDateComponents alloc] init];
     [comps setYear: -13];
     NSDate * maxDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
     
     [ datePicker setMaximumDate:maxDate];
     [comps setYear: -100];
     NSDate * minDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
     
     [datePicker setMinimumDate:minDate];
     //[datePicker setDate:[NSDate date] animated:YES];
     //datePicker.date = [NSDate date];
    
     [datePicker addTarget:self
     action:@selector(changeDateInLabel:)
     forControlEvents:UIControlEventValueChanged];*/
    
    mbProgressHUD = [[MBProgressHUD alloc]initWithView:self.view];
    [mbProgressHUD setMode:MBProgressHUDModeIndeterminate];
    [self.view addSubview:mbProgressHUD];
    if([[CMLNetworkManager sharedInstance] hasConnectivity]){
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        ;
        [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
        
        
        [mbProgressHUD show:YES];
        HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
        request.delegate=self;
        [request initwithurl:BASE_URL requestStr:PROFILEDETAILS requestType:POST input:YES inputValues:dictionary];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)moveBack{
    [self.navigationController popViewControllerAnimated:YES];
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

-(IBAction)MaleSelection:(id)sender{
    UIButton *refButton = (UIButton *)sender;
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
    if (refButton.selected) {
        refButton.selected = NO;
    }else{
        refButton.selected = YES;
        maleSel.selected = NO;
        gender = @"female";
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
    
    
    if ([selTextField isEqual:dobFiled]) {
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
        
        if ([selTextField isEqual:dobFiled]) {
            [self changeDateInLabel:nil];
        }
        [selTextField resignFirstResponder];
    }
}

- (void)changeDateInLabel:(id)sender{
    
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
    
//	//Use NSDateFormatter to write out the date in a friendly format
//    NSDate *date = datePicker.date;
//	NSDateFormatter *df = [[NSDateFormatter alloc] init];
//	df.dateStyle = NSDateFormatterMediumStyle;
//    [df setDateFormat:@"dd-MMM-yyyy"];
//    
//    NSDate *today = [NSDate date];
//    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
//                                                        fromDate:today
//                                                          toDate:date
//                                                         options:0];
//    if ((long)[components day] != 0) {
//        dobFiled.text = [df stringFromDate:date];
//    }
}


-(void)getResponsedata:(NSDictionary *)data{
    
    [mbProgressHUD hide:YES];
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    NSString * code = [data objectForKey:@"code"];
    if (status) {
        if(isUpdateStatus){
            isUpdateStatus = FALSE;
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Your details are updated" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
        } else {
            profileDetailArray=[[NSMutableDictionary alloc]initWithDictionary:data];
            [self setupProfilePage];
        }
    }else if ([code intValue] == 2){
        isUpdateStatus = FALSE;
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:[NSString stringWithFormat:@"%@",[data objectForKey:@"errors"]] delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
}


-(void)setupProfilePage{
    firstNameField.text =[[profileDetailArray objectForKey:@"userDetails"]valueForKey:@"firstname"];
    lastNameFiled.text =[[profileDetailArray objectForKey:@"userDetails"]valueForKey:@"lastname"];
    emailField.text =[[profileDetailArray objectForKey:@"userDetails"] valueForKey:@"email"];

    NSString *DateString =[[profileDetailArray objectForKey:@"userDetails"]valueForKey:@"dob"];;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSDate *date =[dateFormatter dateFromString:DateString];
    [dateFormatter setDateFormat:@"dd-MMM-yyyy"];
    NSString *genders =[[profileDetailArray objectForKey:@"userDetails"]valueForKey:@"gender"];
    
    datePicker = [[UIDatePicker alloc] init];
	datePicker.datePickerMode = UIDatePickerModeDate;
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDate * currentDate = [NSDate date];
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    [comps setYear: -13];
    NSDate * maxDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    
    //[ datePicker setMaximumDate:maxDate];
    [comps setYear: -100];
    NSDate * minDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    
    [datePicker setMinimumDate:minDate];
	datePicker.date = date;
    
	[datePicker addTarget:self
                   action:@selector(changeDateInLabel:)
         forControlEvents:UIControlEventValueChanged];
    
    if ([genders isEqualToString:@"male"]) {
        maleSel.selected = YES;
        femaleSel.selected = NO;
        gender = @"male";
        
    }
    else{
        femaleSel.selected = YES;
        maleSel.selected = NO;
        gender = @"female";
        
        
    }
    
    self.dobFiled.text=[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
    _aboutMeTextView.text=[[profileDetailArray objectForKey:@"userDetails"]valueForKey:@"about_me"];
}

-(void)updateAccount:(id)sender{
    
    if ([self validateFeilds]) {
        if([[CMLNetworkManager sharedInstance] hasConnectivity]){
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setObject:self.firstNameField.text forKey:@"firstname"];
            [dictionary setObject:self.lastNameFiled.text forKey:@"lastname"];
            
            //NSLog(@"++++++++++++++++++++++  %@",self.dobFiled.text);
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd-MMM-yyyy"];
            NSDate *orignalDate = [dateFormatter dateFromString:self.dobFiled.text];
            
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString *finalDOB = [dateFormatter stringFromDate:orignalDate];
            
            //NSLog(@"++++++++++++++++++++++finalDOB  %@",finalDOB);
            [dictionary setObject:finalDOB forKey:@"dob"];
            [dictionary setObject:gender forKey:@"gender"];
            [dictionary setObject:emailField.text forKey:@"email"];

            [dictionary setObject:self.aboutMeTextView.text forKey:@"about_me"];
            if ([HorseBuzzDataManager sharedInstance].deviceToken) {
                [dictionary setObject:[HorseBuzzDataManager sharedInstance].deviceToken forKey:@"device_token"];
            }
            [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
            [mbProgressHUD show:YES];
            isUpdateStatus=YES;
            HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
            request.delegate=self;
            [request initwithurl:BASE_URL requestStr:UPDATEPROFILDETAILS requestType:POST input:YES inputValues:dictionary];
        }
        else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }
}

- (IBAction)showCalender:(id)sender {
    [dobFiled becomeFirstResponder];
}


-(BOOL)checkStringByRemovingSpaces:(NSString*)string{
    NSString * checkString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (checkString.length < 1)
        return FALSE;
    else
        return TRUE;
}

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

-(BOOL)validateFeilds{
    
    BOOL valid;
    int count = 0;
    for (int i = 0; i < textArray.count; i++) {
        
        UITextField *refField = [textArray objectAtIndex:i];
        refField.layer.borderWidth = 1.0;
        NSString *checkString = refField.text;
        if ([refField isEqual:emailField]) {
            valid = [self validateEmailWithString:checkString];
            if (valid) {
                count++;
                refField.layer.borderColor = [UIColor clearColor].CGColor;
            }
            else{
                count --;
                refField.layer.borderColor = [UIColor redColor].CGColor;
            }
        }
        else{
            if (checkString.length > 0 && [self checkStringByRemovingSpaces:checkString]) {
                valid = TRUE;
                if (valid) {
                    count++;
                    refField.layer.borderColor = [UIColor clearColor].CGColor;
                }
                else{
                    count --;
                    refField.layer.borderColor = [UIColor redColor].CGColor;
                }
            }
            else {
                refField.layer.borderColor = [UIColor redColor].CGColor;
                valid = FALSE;
                count--;
            }
        }
        
    }
    if (count == textArray.count) {
        return TRUE;
    }
    
    return FALSE;
}

@end
