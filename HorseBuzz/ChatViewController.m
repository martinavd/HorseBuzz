    //
//  ChatViewController.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 29/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//



#define MESSAGE_SENT_DATE_LABEL_TAG          100
#define MESSAGE_BACKGROUND_IMAGE_VIEW_TAG    101
#define PROFILE_IMAGE_VIEW_TAG               103
#define MESSAGE_TEXT_LABEL_TAG               102
#define ARROW_IMAGE_VIEW_TAG                 104
#define TIME_STAMP_TAG                       105

#define SentDateFontSize                     13
#define MESSAGE_SENT_DATE_LABEL_HEIGHT       (SentDateFontSize+7)
#define MessageFontSize                      13
#import "ChatViewController.h"
#import "HorseBuzzConfig.h"
#import "HorseBuzzDataManager.h"
#import "CMLNetworkManager.h"
#import "SBJsonWriter.h"
#import "AppDelegate.h"
#import "userProfileDeatil.h"
#import "MyImage.h"
#import "MBProgressHUD.h"
#import "SetInvisibleUser.h"
#import "PersonalDetail.h"
#import "userProfileDeatil.h"
#import "GAI.h"
#import "NSString+Utils.h"
#import "EmotionsViewController.h"
#import "mediaViewController.h"
#import "ImageData.h"
#import "GroupProfileViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "GKImagePicker.h"
#import "RoundProgress/CERoundProgressView.h"

@interface UIImage (TPAdditions)
- (UIImage*)imageScaledToSize:(CGSize)size ;
@end

@implementation UIImage (TPAdditions)
- (UIImage*)imageScaledToSize:(CGSize)size {
    
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height) cornerRadius:25.0]addClip];
    // Draw your image
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // Get the image, here setting the UIImageView image
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    return roundedImage;
    
}
@end


@interface ChatViewController ()
{
    CGSize maximumLabelSize;
    NSMutableArray *dataArray;
    UIImage *_messageBubbleRed;
    UIImage *_messageBubbleWhite;
    UIImage *_messageArrowRed;
    UIImage *_messageArrowWhite;
    CGFloat animatedDistance;
    NSTimer *timer;
    BOOL firstTime;
    MBProgressHUD *mbProgressHUD;
    UIImage *profileImage;
    UIButton *eyeButton;
    
    BOOL shouldShowLoadButton;
    int chatPageNumber;
    BOOL fromLoadMoreButton;
    
    UIImagePickerController *pickerCtrl;
    NSString *uploadImagePath;
    UIImage *pickedImage;
    BOOL  IsImageUpload;
    
    NSString *cellIdentifier;
    BOOL *IsCustomKeyboard;
    EmotionsViewController *emotionsTable;
    NSString  *documentsDirectory;
    
    UITapGestureRecognizer *tap;
    CGRect prevFrame;
    BOOL IsFullscreen;
    UIImageView *imageView;
    
    
    //ImageData     *imageData;
    //NSMutableDictionary *dictMedia;
    BOOL IsPendingActivityLoaded;
    
    GKImagePicker *imagePicker;
    UIPopoverController *popoverController1;
    
  
}

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *timeStampFormatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter2;


@end

@implementation ChatViewController
@synthesize placeHolder,messageView;
@synthesize buzzList;
@synthesize receiverId;
@synthesize receiverImageUrl;
@synthesize popoverController;
@synthesize receiverImage,myProfileImage;
@synthesize profileImageButton,name,nameString,isNeededToRemoveNavBar;
@synthesize isFromMessage;
@synthesize isNotified;
@synthesize InputImage;
@synthesize myTable;
@synthesize IsGroup;
@synthesize messageData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        shouldShowLoadButton = NO;
        chatPageNumber = 1;
        fromLoadMoreButton = NO;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    self.timeStampFormatter  = [[NSDateFormatter alloc] init];
    [self.timeStampFormatter   setDateFormat:@"dd/MM/yyyy hh:mm a"];
    [self.timeStampFormatter  setAMSymbol:@"AM"];
    [self.timeStampFormatter  setPMSymbol:@"PM"];
    
    self.dateFormatter2 = [[NSDateFormatter alloc] init];
    [self.dateFormatter2 setDateFormat:@"MM/dd/yyyy"];

    // google tracking code
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLEANALITICSCODE];
    //[tracker trackView:@"Horse Buzz - Chat view"];
    [tracker set:@"ScreenName" value:@"Horse Buzz - Chat view"];
    // google tracking code end
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    
    if (![HorseBuzzDataManager sharedInstance].requestHandler)
        [HorseBuzzDataManager sharedInstance].requestHandler = [[HTTPRequestHandler alloc] init];
    
    [super viewDidLoad];
    
    float version = [[[UIDevice currentDevice] systemVersion]floatValue];
    if (version >= 7.0) {
        self.navigationItem.hidesBackButton =FALSE;
        if (isNeededToRemoveNavBar) {
            UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            backButton.frame = CGRectMake(0, 0,60, 20);
            [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
            [backButton setTitle:@" Back" forState:UIControlStateNormal];
            [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [backButton addTarget:self action:@selector(moveBack2) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *backBarButton =[[UIBarButtonItem alloc]initWithCustomView:backButton];
            self.navigationItem.leftBarButtonItem = backBarButton;
        }
    }else{
        //do stuff when the controller directly comes from the notification click event
        if (isNeededToRemoveNavBar) {
            UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            backButton.frame = CGRectMake(0, 0,60, 20);
            [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
            [backButton setTitle:@" Back" forState:UIControlStateNormal];
            [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [backButton addTarget:self action:@selector(moveBack2) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *backBarButton =[[UIBarButtonItem alloc]initWithCustomView:backButton];
            self.navigationItem.leftBarButtonItem = backBarButton;
        } else {
            UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            backButton.frame = CGRectMake(0, 0,60, 20);
            [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
            [backButton setTitle:@" Back" forState:UIControlStateNormal];
            [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [backButton addTarget:self action:@selector(moveBack) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *backBarButton =[[UIBarButtonItem alloc]initWithCustomView:backButton];
            self.navigationItem.leftBarButtonItem = backBarButton;
        }
    }
    
    //
    if (!IsGroup) {
        [self setIsGroup:@"0"];}
    
    
    firstTime=TRUE;
    // Do any additional setup after loading the view from its nib.
    _messageBubbleRed = [[UIImage imageNamed:@"receive-bgwitoutarrow"] stretchableImageWithLeftCapWidth:23 topCapHeight:15];
    _messageBubbleWhite = [[UIImage imageNamed:@"send-bgwitoutarrow"] stretchableImageWithLeftCapWidth:10 topCapHeight:0.0];
    
    _messageArrowRed = [UIImage imageNamed:@"red_arrow"];
    _messageArrowWhite = [UIImage imageNamed:@"white_arrow"];
    
    maximumLabelSize = CGSizeMake(210, 1000);
    dataArray = [[NSMutableArray alloc]init];
    
    
    if(!isFromMessage){
        [self setReceiverImage];
    }
    
    if (self.isNotified) {
        [self getReceiverImage];
    }else{
        self.receiverImage = [self.receiverImage imageScaledToSize:CGSizeMake(50.0, 50.0)];
        [self.profileImageButton setBackgroundImage:self.receiverImage forState:UIControlStateNormal];
    }
    [self.profileImageButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *backGroundView = [[UIView alloc]initWithFrame:CGRectZero];
    backGroundView.backgroundColor = [UIColor colorWithRed:218/255.0f green:218/255.0f blue:218/255.0f alpha:1.0f];
    buzzList.backgroundColor = nil;
    buzzList.backgroundView = backGroundView;
    if (dataArray.count > 0) {
        [buzzList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dataArray.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    self.name.text=self.nameString;
    
    //Prakash
    name.userInteractionEnabled=YES;
    UIGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGroupSummary)];
    [name addGestureRecognizer:tapGesture];
    
    mbProgressHUD = [[MBProgressHUD alloc]initWithView:self.view];
    [mbProgressHUD setMode:MBProgressHUDModeIndeterminate];
    [self.view addSubview:mbProgressHUD];
    if([[CMLNetworkManager sharedInstance] hasConnectivity]){
        [mbProgressHUD show:YES];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        [dictionary setObject:self.receiverId  forKey:@"receiver_id"];
        [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
        [dictionary setObject:@"1" forKey:@"pagination"];
        [dictionary setObject:IsGroup forKey:@"is_group"];
        
        HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
        request.delegate=self;
        [request initwithurl:BASE_URL requestStr:GETCONVENSATION requestType:POST input:YES inputValues:dictionary];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
    
    
    eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    eyeButton.frame = CGRectMake(0, 0, 24, 24);
    [eyeButton addTarget:self action:@selector(setVisibilty) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *eyeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:eyeButton];
    
    
    self.navigationItem.rightBarButtonItem = eyeButtonItem;
    //buzzList.backgroundColor=[UIColor lightGrayColor];
    
    
}

-(void)showMsg:(NSString *) msg{
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Debug" message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    
    [alert show];
}

-(void)moveBack{
    [self.navigationController popViewControllerAnimated:YES];
//    MessagesViewController *messageViewCtrl = [[MessagesViewController alloc]initWithNibName:@"MessagesViewController" bundle:nil];
//    [self.navigationController pushViewController:messageViewCtrl animated:YES];
}

-(void)moveBack2{
    AppDelegate *delagate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delagate setRootView];
    [delagate.tabBarController setSelectedIndex:2];
    
    //MessagesViewController *messageViewCtrl = [[MessagesViewController alloc]initWithNibName:@"MessagesViewController" bundle:nil];
    //[self.navigationController pushViewController:messageViewCtrl animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
//Prakash
-(void)showGroupSummary
{
    if([IsGroup isEqualToString:@"1"])
    {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
    [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"sender_id"];
    [dictionary setObject:receiverId forKey:@"receiver_id"];
    
    HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
    request.delegate=self;
        [request initwithurl:BASE_URL requestStr:GETGROUPPARTICIPANT requestType:POST input:YES inputValues:dictionary];
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



-(void)viewWillDisappear:(BOOL)animated{
    [timer invalidate];
    timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
//    if ([HorseBuzzDataManager sharedInstance].dictMedia ) {
//        NSArray *keys = [[HorseBuzzDataManager sharedInstance].dictMedia allKeys];
//        for (id key in [HorseBuzzDataManager sharedInstance].dictMedia) {
//           
//            NSDictionary *dict = [[HorseBuzzDataManager sharedInstance].dictMedia objectForKey:key];
//            [(ASIFormDataRequest *)[dict objectForKey:@"requestObject"] removeUploadProgressSoFar];
//        }
//    }
}
-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewMessages) name:@"NewMessageReceived" object:nil];
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
-(CGSize)expectedSizeWithString:(NSString *)string{
    CGSize ts = [string sizeWithFont:[UIFont systemFontOfSize:13.0] constrainedToSize:CGSizeMake(220, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    return ts;
}

-(void)setReceiverImage{
    
    UIImageView *refView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,0.0,0.0)];
    [self.view addSubview:refView];
    
    __block UIActivityIndicatorView *activityIndicator;
    __weak UIImageView *brandImageView = refView;
    [refView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMGURL,self.receiverImageUrl]] placeholderImage:[UIImage imageNamed:@"noimage"] options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize)
     {
         if (!activityIndicator)
         {
             [brandImageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
             activityIndicator.center = brandImageView.center;
             [activityIndicator startAnimating];
         }
     }
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
     {
         self.receiverImage = brandImageView.image;
         self.receiverImage = [self.receiverImage imageScaledToSize:CGSizeMake(50.0, 50.0)];
         [self.profileImageButton setBackgroundImage:self.receiverImage forState:UIControlStateNormal];
         
         [buzzList reloadData];
         [activityIndicator removeFromSuperview];
         activityIndicator = nil;
     }];
}

-(void)setMyProfileImage{
    
    
    AppDelegate *delagate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIImageView *refView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,0.0,0.0)];
    [self.view addSubview:refView];
    
    __block UIActivityIndicatorView *activityIndicator;
    if(delagate.personalDetails.ProfileImageUrl){
        __weak UIImageView *brandImageView = refView;
        [refView setImageWithURL:[NSURL URLWithString:delagate.personalDetails.ProfileImageUrl] placeholderImage:[UIImage imageNamed:@"noimage"] options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize)
         {
             if (!activityIndicator)
             {
                 [brandImageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
                 activityIndicator.center = brandImageView.center;
                 [activityIndicator startAnimating];
             }
             
         }
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
         {
             self.myProfileImage = brandImageView.image;
             self.myProfileImage = [self.myProfileImage imageScaledToSize:CGSizeMake(50.0, 50.0)];
             [buzzList reloadData];
             [activityIndicator removeFromSuperview];
             activityIndicator = nil;
         }];
    }
    
}
-(void)getReceiverImage{
    UIImageView *refView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,0.0,0.0)];
    [self.view addSubview:refView];
    
    __block UIActivityIndicatorView *activityIndicator;
    if(self.imageUrl){
        __weak UIImageView *brandImageView = refView;
        [refView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMGURL,self.imageUrl]] placeholderImage:[UIImage imageNamed:@"noimage"] options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize)
         {
             if (!activityIndicator)
             {
                 [brandImageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
                 activityIndicator.center = brandImageView.center;
                 [activityIndicator startAnimating];
             }
             
         }
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
         {
             self.receiverImage = brandImageView.image;
             
             self.receiverImage = [self.receiverImage imageScaledToSize:CGSizeMake(50.0, 50.0)];
             [self.profileImageButton setBackgroundImage:self.receiverImage forState:UIControlStateNormal];
             //NSLog(@"receiverImage%@",receiverImage);
             [buzzList reloadData];
             [activityIndicator removeFromSuperview];
             activityIndicator = nil;
         }];
    }
    
    
}

- (void)getNewMessages {
    
    if([[CMLNetworkManager sharedInstance] hasConnectivity]){
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId  forKey:@"sender_id"];
        [dictionary setObject:self.receiverId forKey:@"receiver_id"];
        [dictionary setObject:IsGroup forKey:@"is_group"];
        //        [dictionary setObject:@"1" forKey:@"pagination"];
        HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
        request.delegate=self;
        [request initwithurl:BASE_URL requestStr:RECEIVEMESSAGE requestType:POST input:YES inputValues:dictionary];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)sendMessage:(id)sender{
    
    //NSString *message = self.messageView.text;
    NSString *uniText = [NSString stringWithUTF8String:[self.messageView.text UTF8String]];
    NSData *msgData = [uniText dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *message = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding] ;
    
    //NSLog(@"message%@",message);
    if (message.length > 0) {
        NSDictionary *dict  = [NSDictionary dictionaryWithObjectsAndKeys:message,@"message",[HorseBuzzDataManager sharedInstance].userId,@"userId", [self.dateFormatter stringFromDate:[NSDate date]], @"timestamp", nil];
        //NSLog(@"dataArray%@",dataArray);
        [dataArray addObject:dict];
        //NSLog(@"dictis%@",dict);
        
        [buzzList reloadData];
        [buzzList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dataArray.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        if([[CMLNetworkManager sharedInstance] hasConnectivity]){
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            
            [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"sender_id"];
            [dictionary setObject:self.receiverId forKey:@"receiver_id"];
            [dictionary setObject:message forKey:@"message"];
            [dictionary setObject:IsGroup forKey:@"is_group"];
            //[self.messageView performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:1.0];
            
            [self.messageView resignFirstResponder];
            NSOperationQueue *mainQueue = [[NSOperationQueue alloc] init];
            [mainQueue setMaxConcurrentOperationCount:5];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                            init];
            
            if ([IsGroup isEqualToString:@"1"]) {
                [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL,SENDMESSAGEGROUP]]];
            }
            else{
                [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL,SENDMESSAGE]]];
            }
            
            [request setHTTPMethod:@"POST"];
            
            SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
            NSString *jsonRequest = [jsonWriter stringWithObject:dictionary];
            
            NSData *requestData = [NSData dataWithBytes:[jsonRequest UTF8String] length:[jsonRequest length]];
           
            
            [request setValue:@"application/text" forHTTPHeaderField:@"Content-Type"];
            [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
            [request setHTTPBody: requestData];
            
            //            __block UITextView *message = self.messageView;
            [NSURLConnection sendAsynchronousRequest:request queue:mainQueue completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
                if (!error) {
                    //NSLog(@"Status Code: %li %@", (long)urlResponse.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:urlResponse.statusCode]);
                    //NSLog(@"Response Body: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                }
                else {
                    //NSLog(@"An error occured, Status Code: %i", urlResponse.statusCode);
                    //NSLog(@"Description: %@", [error localizedDescription]);
                    //NSLog(@"Response Body: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                }
                //                [message resignFirstResponder];
            }];
            
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    self.messageView.text =@"";
    
     //NSLog(@"messagesss%@",message);
    
    //MAR
    messageView.inputView = nil;
    [InputImage setImage:[UIImage imageNamed:@"smiley.png"] forState:UIControlStateNormal];
    
    [self getNewMessages];
    
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.placeHolder.hidden = YES;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(hideKeyBoard)];
    
    [self.view addGestureRecognizer:tapGesture];
    
   return YES;
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if(self.messageView.text.length == 0)
        self.placeHolder.hidden = NO;
    [self.messageView resignFirstResponder];
    return YES;
}
-(void) textViewDidChange:(UITextView *)textView
{
    if(self.messageView.text.length == 0){
        self.placeHolder.hidden = NO;
        [self.messageView resignFirstResponder];
    }
}

-(BOOL)checkThePreviousIdAtIndex:(int)row{
    if (dataArray.count > 1 && row != 0) {
        NSString* currentId = [[dataArray objectAtIndex:row]objectForKey:@"userId"];
        NSString* PrevId = [[dataArray objectAtIndex:row-1]objectForKey:@"userId"];
        if ([currentId isEqualToString:PrevId]) {
            return YES;
        }}
    return NO;
}


#pragma mark - TableView Delegate methods.
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    //  return self.peopleList.count;
    return dataArray.count+1;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row == 0) {
        if (shouldShowLoadButton) {
            return 35.0;
        } else {
            return 0;
        }
    }
    
    NSString *msgString = [[dataArray objectAtIndex:indexPath.row-1]objectForKey:@"message"];
    
    if ([msgString hasPrefix:@":IMG-"]) {
        return 220;
    }
    
    if ([msgString hasPrefix:@":MOV-"]) {
        return 220;
    }
    
    if (indexPath.row == dataArray.count) {
        CGFloat height = [self expectedSizeWithString:msgString].height ;
        if (height <= 35) {
            return 35.0+20.0+15;
        }
        return height+20.0f+15;
        
    }
    
    if ([self checkThePreviousIdAtIndex:indexPath.row] == FALSE) {
        CGFloat height = [self expectedSizeWithString:msgString].height+10 ;
        if (height <= 35.0) {
            return 50.0;
        }
        return height+35+15;
    }else{
        CGFloat height = [self expectedSizeWithString:msgString].height ;
        return height+30+15;
    }
    
    
}

- (void)loadMore{
    if([[CMLNetworkManager sharedInstance] hasConnectivity]){
        chatPageNumber ++ ;
        fromLoadMoreButton = YES;
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        [dictionary setObject:self.receiverId  forKey:@"receiver_id"];
        [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
        [dictionary setObject:[NSString stringWithFormat:@"%d", chatPageNumber] forKey:@"pagination"];
        HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
        request.delegate=self;
        [request initwithurl:BASE_URL requestStr:GETCONVENSATION requestType:POST input:YES inputValues:dictionary];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0)
    {
        [tableView clearsContextBeforeDrawing];
        UITableViewCell *firstCell = [tableView dequeueReusableCellWithIdentifier:@"FirstCell"];
        if (!firstCell) {
            firstCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FirstCell"];
            firstCell.selectionStyle = UITableViewCellSelectionStyleNone;
            firstCell.backgroundColor = nil;
            
            UIButton *loadMore = [UIButton buttonWithType:UIButtonTypeSystem];
            [loadMore addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
            [loadMore setTitle:@"Load More" forState:UIControlStateNormal];
            [loadMore setFrame:CGRectInset(firstCell.frame, 50, 5)];
            [firstCell addSubview:loadMore];
        }
        if (shouldShowLoadButton) {
            return firstCell;
        }else{
            return [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        }
    }
    else
    {
        cellIdentifier = @"cell";
        cellIdentifier = [NSString stringWithFormat:@"%@%d",cellIdentifier,indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell) {
            return cell;
        }
        
        //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
        NSMutableDictionary *dict = [dataArray objectAtIndex:indexPath.row-1];
        if(cell==nil){
            //cell = [[UITableViewCell  alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell = [[UITableViewCell  alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell setBackgroundColor:nil];
        }
        
        if ([[dict objectForKey:@"userId"] isEqualToString:[HorseBuzzDataManager sharedInstance].userId])
        {
            //cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
            //cell.contentView.autoresizesSubviews = YES;
            [self LoadSentMessages:&cell withData:dict];
        }
        else
        {
            [self LoadReceivedMessages:&cell withData:dict forRowIndex:indexPath];
        }
    
        return cell;
    
    }
    
}


- (NSString *)decodeMessage:(NSString *)msgStr{
    
    const char *jsonString = [msgStr UTF8String];
    NSData *jsonData = [NSData dataWithBytes:jsonString length:strlen(jsonString)];
    msgStr = [[NSString alloc] initWithData:jsonData encoding:NSNonLossyASCIIStringEncoding];
    return msgStr;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)newTapMethod:(UITapGestureRecognizer *)gr{
    UIImageView *theTappedImageView;
     if(!IsFullscreen){
         theTappedImageView = (UIImageView *)gr.view;
         mediaViewController *mediaView = [[mediaViewController alloc] init];
         mediaView.tappedImage = theTappedImageView;
         mediaView.filepath = theTappedImageView.accessibilityValue;
         mediaView.senderViewController = self;
         //[self.view.window.rootViewController presentViewController:mediaView animated:YES completion:nil];
         [self.navigationController pushViewController:mediaView animated:YES];
    }
    else{
        [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
            [imageView setFrame:prevFrame];
            
        } completion:^(BOOL finished) {
            [imageView removeFromSuperview];
            [theTappedImageView setFrame:prevFrame];
            prevFrame = CGRectZero;
            IsFullscreen =false;
            
        }];
    }

    
}

-(void)PlayBack: (UITapGestureRecognizer *)gr{
    
    // pick a video from the documents directory
    //NSURL *video = nsurl;
    UIImageView *theTappedImageView = (UIImageView *)gr.view;
    // create a movie player view controller
    MPMoviePlayerViewController * controller = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL fileURLWithPath:theTappedImageView.accessibilityValue]];
    [controller.moviePlayer prepareToPlay];
    [controller.moviePlayer play];
    
    // and present it
    [self presentMoviePlayerViewControllerAnimated:controller];
}

-(NSString *)GetMessageTime:(NSString *)dateString{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //initialize format
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate          *formattedDate = [dateFormatter dateFromString:dateString];
    //set time format
    [dateFormatter setDateFormat:@"dd MMM hh:mm a"];
    return [dateFormatter stringFromDate:formattedDate];
}

-(UIImage *)GetFormattedImage:(NSString *) localfilePath{
    
    UIImage *originalImage = [UIImage imageWithContentsOfFile:localfilePath];
    CGSize destinationSize = CGSizeMake(200, 260);
    
//    //UIGraphicsBeginImageContext(destinationSize);
//    //[originalImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
//    UIGraphicsBeginImageContextWithOptions(destinationSize, false, [originalImage scale]);
//    [originalImage drawAtPoint:CGPointMake(20, 20)];
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    CGSize size = [originalImage size];
    int padding = 20;
    int pictureSize = destinationSize.width;
    //int startCroppingPosition = 100;
    int startCroppingPosition = size.width/4;
    if (size.height > size.width) {
        pictureSize = size.width - (2.0 * padding);
        startCroppingPosition = (size.height - pictureSize) / 2.0;
    } else {
        pictureSize = size.height - (2.0 * padding);
        startCroppingPosition = (size.width - pictureSize) / 2.0;
    }
    // WTF: Don't forget that the CGImageCreateWithImageInRect believes that
    // the image is 180 rotated, so x and y are inverted, same for height and width.
    CGRect cropRect = CGRectMake(startCroppingPosition, padding, pictureSize, pictureSize);
    CGImageRef imageRef = CGImageCreateWithImageInRect([originalImage CGImage], cropRect);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:originalImage.imageOrientation];

    
    return newImage;
}


-(UIImage *)generatePhotoThumbnail:(UIImage *)image withSide:(CGFloat)ratio
{
    // Create a thumbnail version of the image for the event object.
    CGSize size = image.size;
    CGSize croppedSize;
    
    CGFloat offsetX = 0.0;
    CGFloat offsetY = 0.0;
    
    // check the size of the image, we want to make it
    // a square with sides the size of the smallest dimension.
    // So clip the extra portion from x or y coordinate
    if (size.width > size.height) {
        offsetX = (size.height - size.width) / 2;
        croppedSize = CGSizeMake(size.height, size.height);
    } else {
        offsetY = (size.width - size.height) / 2;
        croppedSize = CGSizeMake(size.width, size.width);
    }
    
    // Crop the image before resize
    CGRect clippedRect = CGRectMake(offsetX * -1, offsetY * -1, croppedSize.width, croppedSize.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
    // Done cropping
    
    // Resize the image
    CGRect rect = CGRectMake(0.0, 0.0, ratio, ratio);
    
    UIGraphicsBeginImageContext(rect.size);
    [[UIImage imageWithCGImage:imageRef] drawInRect:rect];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // Done Resizing
    
    return thumbnail;
}

-(void)LoadSentMessages:(UITableViewCell **)cell withData:(NSMutableDictionary *)dict {
    
    @try {
    BOOL            IsImageContent = false;
    NSString        *message = [self decodeMessage:[dict objectForKey:@"message"]];
    NSString        *msgtimestamp = [self GetMessageTime:[dict objectForKey:@"timestamp"]];
    CGRect          cellFrame;
  
    NSLog(@"****** dataArray.count = %d :::: message = %@  ****************", dataArray.count, message );
    
    if([message hasPrefix:@":IMG"])
        IsImageContent = true;
    
    CGFloat nRed=240.0/255.0;
    CGFloat nBlue=255.0/255.0;
    CGFloat nGreen=255.0/255.0;
    UIColor *myColor=[[UIColor alloc]initWithRed:nRed green:nBlue blue:nGreen alpha:1];
    //NSString *backArrowString = @"\U000025C0\U0000FE0E";
    NSString *arrowString = @"\U000025B6\U0000FE0E";
    
    // create arrow label
    UILabel *arrowlabel = [[UILabel alloc] initWithFrame:CGRectZero];
    arrowlabel.lineBreakMode = NSLineBreakByWordWrapping;
    arrowlabel.numberOfLines = 0;
    arrowlabel.font = [UIFont systemFontOfSize:MessageFontSize];
    arrowlabel.textColor = myColor;
    arrowlabel.text = arrowString;
    arrowlabel.frame = CGRectMake(305, 2, 30, 30);
    [[*cell contentView] addSubview:arrowlabel];
    
    // Create messageBackgroundImageView.
    UIImageView *messageBackgroundImageView;
    messageBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    messageBackgroundImageView.tag = MESSAGE_BACKGROUND_IMAGE_VIEW_TAG;
    //messageBackgroundImageView.image = _messageBubbleWhite;
    [messageBackgroundImageView setBackgroundColor:myColor];
    //messageBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [[*cell contentView] addSubview:messageBackgroundImageView];
    UILabel *lbltimestamp = [[UILabel alloc] init];
    lbltimestamp.text = msgtimestamp;
    [lbltimestamp setFont:[UIFont boldSystemFontOfSize:10.0]];
    [lbltimestamp setTextColor:[UIColor brownColor]];
    [[*cell contentView] addSubview: lbltimestamp];
    //load images when message text starts with :IMG
    if([message hasPrefix:@":IMG"]){
        
        NSString *imagefile = [message substringFromIndex:5];
        UIImageView *sharedImage;
        NSString  *localfilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, imagefile];
        
        if ([imagefile isEqualToString:@"sending"]) {
            sharedImage = [[UIImageView alloc] initWithFrame:CGRectZero];
            sharedImage.image = [self generatePhotoThumbnail:[dict objectForKey:@"pickedImage"] withSide:200.0f] ;
            sharedImage.frame = CGRectMake(self.view.bounds.size.width-210,10,200, 200);
            localfilePath = [dict objectForKey:@"localfilepath"];
            ASIFormDataRequest *req = [[HorseBuzzDataManager sharedInstance].requestHandler.activeRequests objectForKey:localfilePath];
            
            if (req && !req.uploadProgressDelegate)
            {
                CERoundProgressView *progressIndicator = [[CERoundProgressView alloc] initWithFrame:CGRectMake(68, 68, 64, 64)];
                UIColor *tintColor = [UIColor orangeColor];
                [[CERoundProgressView appearance] setTintColor:tintColor];
                progressIndicator.trackColor = [UIColor colorWithWhite:0.80 alpha:1.0];
                progressIndicator.startAngle = (3.0*M_PI)/2.0;
                [sharedImage addSubview:progressIndicator];
                
                [req setUploadProgressDelegate:progressIndicator];
                //[req setUploadProgressDelegate:[HorseBuzzDataManager sharedInstance].requestHandler];
                
                if (dataArray.count >0)
                    [buzzList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dataArray.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
            else if (req && req.uploadProgressDelegate)
            {
                [sharedImage addSubview:req.uploadProgressDelegate];
            }
            
            
//            [(ImageData *)[dict objectForKey:@"imageData"] setImageView:sharedImage];
//            
//            //Save image data into localfile
//            localfilePath = [NSString stringWithFormat:@"%@//%@",documentsDirectory,[dict objectForKey:@"filename"]];
//            CGFloat quality = 0.85;
//            NSData *jpegdata = UIImageJPEGRepresentation([dict objectForKey:@"pickedImage"],quality);
//            [jpegdata writeToFile:localfilePath atomically:YES];
            
            UITapGestureRecognizer *newTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(newTapMethod:)];
            [sharedImage setAccessibilityValue:localfilePath];
            [sharedImage setUserInteractionEnabled:YES];
            [sharedImage addGestureRecognizer:newTap];
        }
        else{
            
            NSString *sharedImageURL =[NSString stringWithFormat:@"%@%@", CHATIMGURL, imagefile];
            sharedImage = [[UIImageView alloc] initWithFrame:CGRectZero];
            sharedImage.tag = ARROW_IMAGE_VIEW_TAG;
            sharedImage.frame = CGRectMake(self.view.bounds.size.width-210,10,200, 200);
            sharedImage.image = [UIImage imageNamed:@"noimage"] ;
            //sharedImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:sharedImageURL]]];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:localfilePath]) {
//                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
//                [dictionary setObject:sharedImageURL forKey:@"imageURL"];
//                [dictionary setObject:sharedImage forKey:@"sharedImage"];
//                [dictionary setObject:imagefile forKey:@"filename"];
//                
//                ImageData *imageData = [[ImageData alloc] init];
//                imageData.resourceURL = sharedImageURL;
//                imageData.filename = imagefile;
//                imageData.localfilepath = localfilePath;
//                imageData.imageView = sharedImage;
//                imageData.thisAction = HTTPReciveMedia;
//                
//                if (![[HorseBuzzDataManager sharedInstance].dictMedia objectForKey:sharedImageURL]) {
//                    [[HorseBuzzDataManager sharedInstance].dictMedia setObject:imageData forKey:sharedImageURL];
//                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:sharedImageURL]];
//                    // Create url connection and fire request
//                    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//                }

                
            }
            else{
                
                //sharedImage.image = [UIImage imageWithContentsOfFile:localfilePath];
                //[sharedImage setImage:[self GetFormattedImage:localfilePath]];
                //sharedImage.frame = CGRectMake(self.view.bounds.size.width-210,10,200, 200);
                [sharedImage setImage:[self generatePhotoThumbnail:[UIImage imageWithContentsOfFile:localfilePath] withSide:200.0f]];
                //sharedImage.image = [UIImage imageWithContentsOfFile:localfilePath];
                
                UITapGestureRecognizer *newTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(newTapMethod:)];
                [sharedImage setAccessibilityValue:localfilePath];
                [sharedImage setUserInteractionEnabled:YES];
                [sharedImage addGestureRecognizer:newTap];
                            }
        }
        [[*cell contentView] addSubview:sharedImage];
        [[*cell contentView] setFrame:sharedImage.frame];
        cellFrame = sharedImage.frame;
        //[buzzList setContentOffset:CGPointMake(0.0f, -buzzList.contentInset.bottom) animated:YES];
    }
    else if ([message hasPrefix:@":MOV"])
    {
        
        NSString *mediafile = [message substringFromIndex:5];
        NSString *sharedMediaURL =[NSString stringWithFormat:@"%@%@", CHATIMGURL, [message substringFromIndex:5]];
        UIImageView *sharedImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [sharedImage setFrame: CGRectMake(self.view.bounds.size.width-210,10,200, 200)];
        
  
        NSString  *localfilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, mediafile];
        
        if ([mediafile isEqualToString:@"sending"]) {

            [sharedImage setImage:[dict objectForKey:@"pickedImage"]];
            localfilePath = [dict objectForKey:@"localfilepath"];
            //ASIFormDataRequest *req = (ASIFormDataRequest *)[dict objectForKey:@"requestObject"];
            ASIFormDataRequest *req = [[HorseBuzzDataManager sharedInstance].requestHandler.activeRequests objectForKey:localfilePath];
            
            if (req && !req.uploadProgressDelegate)
            {
                CERoundProgressView *progressIndicator = [[CERoundProgressView alloc] initWithFrame:CGRectMake(68, 68, 64, 64)];
                UIColor *tintColor = [UIColor orangeColor];
                [[CERoundProgressView appearance] setTintColor:tintColor];
                progressIndicator.trackColor = [UIColor colorWithWhite:0.80 alpha:1.0];
                progressIndicator.startAngle = (3.0*M_PI)/2.0;
                [sharedImage addSubview:progressIndicator];
                
                [req setUploadProgressDelegate:progressIndicator];
                //[req setUploadProgressDelegate:[HorseBuzzDataManager sharedInstance].requestHandler];
                
                if (dataArray.count >0)
                    [buzzList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dataArray.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
            else if (req && req.uploadProgressDelegate)
            {
                [sharedImage addSubview:req.uploadProgressDelegate];
            }
        }
        else
        {
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:localfilePath]) {
            
                //TODO: download missing file
                sharedImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-210,10,200, 200)];
                [sharedImage setImage:[UIImage imageNamed:@"noimage"]];
                
            }
            else
            {
                sharedImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-210,10,200, 200)];
                UIImage *thumbnail = [self getThumbNail:localfilePath];
                [sharedImage setImage:thumbnail];
                [self setMediaTapGesture:sharedImage withLocalFilePath:localfilePath];

            }
        }
        
        [[*cell contentView] addSubview:sharedImage];
        [[*cell contentView] setFrame:sharedImage.frame];
        cellFrame = sharedImage.frame;
        //set timestamp frame
        //cellFrame = CGRectMake(0, 0, sharedImage.frame.size.width, sharedImage.frame.size.height);
        
    }else{
    // Create message label
    UILabel *messagelabel = [[UILabel alloc] initWithFrame:CGRectZero];
    messagelabel.lineBreakMode = NSLineBreakByWordWrapping;
    messagelabel.numberOfLines = 0;
    messagelabel.font = [UIFont systemFontOfSize:MessageFontSize];
    //messagelabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    messagelabel.text = [message substituteEmotions];
    [[*cell contentView] addSubview:messagelabel];
    
    int W =(int) [self expectedSizeWithString:message].width + 10;
    int H =(int) [self expectedSizeWithString:message].height;
    W = (W>38)?W:38;
    
    messagelabel.frame = CGRectMake(320-W-8, 10, W, H +10);
    messageBackgroundImageView.frame = CGRectMake(messagelabel.frame.origin.x -5
                                                  , 5
                                                  , messagelabel.frame.size.width + 3
                                                  , messagelabel.frame.size.height +10);
   
        //set timestamp frame
        cellFrame = messageBackgroundImageView.frame;
    }
    
    
    [lbltimestamp setFrame:CGRectMake(230, cellFrame.size.height + 2 , 100, 26)];
    [[*cell contentView] bringSubviewToFront:lbltimestamp];
    
    }
    @catch (NSException *exception) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"HorseBuzz" message:exception.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
    @finally {
       
    }
}

-(void)LoadReceivedMessages:(UITableViewCell **)cell withData:(NSDictionary *)dict forRowIndex:(NSIndexPath *)rowIndexPath {
    BOOL IsImageContent = false;
    NSString *message = [self decodeMessage:[dict objectForKey:@"message"]];
    NSString *isGroup = [dict objectForKey:@"is_group"];
    NSString        *msgtimestamp = [self GetMessageTime:[dict objectForKey:@"timestamp"]];
    CGRect          cellFrame;

    
    if([message hasPrefix:@":IMG"])
        IsImageContent = true;
    
    
    
    CGFloat nRed=250.0/255.0;
    CGFloat nBlue=240.0/255.0;
    CGFloat nGreen=230.0/255.0;
    UIColor *myColor=[[UIColor alloc]initWithRed:nRed green:nBlue blue:nGreen alpha:1];
    NSString *arrowString = @"\U000025C0\U0000FE0E";
    //NSString *arrowString = @"\U000025B6\U0000FE0E";
    
    // create arrow label
    UILabel *arrowlabel = [[UILabel alloc] initWithFrame:CGRectZero];
    arrowlabel.lineBreakMode = NSLineBreakByWordWrapping;
    arrowlabel.numberOfLines = 0;
    arrowlabel.font = [UIFont systemFontOfSize:MessageFontSize];
    arrowlabel.textColor = myColor;
    arrowlabel.text = arrowString;
    arrowlabel.frame = CGRectMake(2, 5, 30, 30);
    [[*cell contentView] addSubview:arrowlabel];
    
    // Create messageBackgroundImageView.
    UIImageView *messageBackgroundImageView;
    messageBackgroundImageView = [[UIImageView alloc] init];
    messageBackgroundImageView.tag = MESSAGE_BACKGROUND_IMAGE_VIEW_TAG;
    messageBackgroundImageView.backgroundColor=myColor;
    //messageBackgroundImageView.image = _messageBubbleRed;
    //messageBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [[*cell contentView] addSubview:messageBackgroundImageView];
    UILabel *lbltimestamp = [[UILabel alloc] init];
    lbltimestamp.text = msgtimestamp;
    [lbltimestamp setFont:[UIFont boldSystemFontOfSize:10.0]];
    [lbltimestamp setTextColor:[UIColor brownColor]];
    [[*cell contentView] addSubview: lbltimestamp];
    
    if([message hasPrefix:@":IMG"]){
        
        NSString *imagefile = [message substringFromIndex:5];
        NSString *sharedImageURL =[NSString stringWithFormat:@"%@%@", CHATIMGURL, [message substringFromIndex:5]];
        UIImageView *sharedImage;
        sharedImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        sharedImage.tag = ARROW_IMAGE_VIEW_TAG;
        sharedImage.frame = CGRectMake(12,10,200, 200);
        sharedImage.image = [UIImage imageNamed:@"noimage"] ;
        
        //sharedImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:sharedImageURL]]];
        
        NSString  *localfilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, imagefile];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:localfilePath]) {
            
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setObject:sharedImage forKey:@"sharedImage"];
            [dictionary setObject:localfilePath forKey:@"localfilepath"];
            [dictionary setObject:rowIndexPath forKey:@"rowIndexPath"];
            __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:sharedImageURL]];
            [request setDownloadDestinationPath:localfilePath];
            [request setUserInfo:dictionary];
            [request setCompletionBlock:^{
                
                NSDictionary *dict = [request userInfo];
                NSString *localfilepath = [dict objectForKey:@"localfilepath"];
                UIImage *newImage = [self generatePhotoThumbnail:[UIImage imageWithContentsOfFile:localfilepath] withSide:200.0f];
                NSIndexPath *path = (NSIndexPath *)[dict objectForKey:@"rowIndexPath"];
                UITableViewCell *celltoUpdate = [buzzList cellForRowAtIndexPath:path];
                UIImageView *viewtoUpdate = [dict objectForKey:@"sharedImage"];
                NSArray *viewsToRemove = [viewtoUpdate subviews];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (newImage) {
                        [self removeSubviews:viewtoUpdate];
                        [viewtoUpdate setImage:newImage];
                        [viewtoUpdate setNeedsLayout];
                        UITapGestureRecognizer *newTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(newTapMethod:)];
                        [viewtoUpdate setAccessibilityValue:localfilePath];
                        [viewtoUpdate setUserInteractionEnabled:YES];
                        [viewtoUpdate addGestureRecognizer:newTap];
                    }
                });
                

//                [buzzList beginUpdates];
//                [buzzList reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
//                [buzzList endUpdates];
                //[buzzList reloadData];
                
            }];
            CERoundProgressView *progressIndicator = [[CERoundProgressView alloc] initWithFrame:CGRectMake(68, 68, 64, 64)];
            UIColor *tintColor = [UIColor orangeColor];
            [[CERoundProgressView appearance] setTintColor:tintColor];
            progressIndicator.trackColor = [UIColor colorWithWhite:0.80 alpha:1.0];
            progressIndicator.startAngle = (3.0*M_PI)/2.0;
            [sharedImage addSubview:progressIndicator];
            
            [request setDownloadProgressDelegate:progressIndicator];
            [request startAsynchronous];
            
        }
        else{
            
            //sharedImage.image = [UIImage imageWithContentsOfFile:localfilePath];
            //[sharedImage setImage:[self GetFormattedImage:localfilePath]];
            //sharedImage.frame = CGRectMake(0,0,200, 200);
            
            sharedImage = [[UIImageView alloc] initWithFrame:CGRectMake(12,10,200, 200)];
            [sharedImage setImage:[self generatePhotoThumbnail:[UIImage imageWithContentsOfFile:localfilePath] withSide:200.0f]];
            [sharedImage setNeedsLayout];
            UITapGestureRecognizer *newTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(newTapMethod:)];
            [sharedImage setAccessibilityValue:localfilePath];
            [sharedImage setUserInteractionEnabled:YES];
            [sharedImage addGestureRecognizer:newTap];
        }

        [[*cell contentView] addSubview:sharedImage];
        [[*cell contentView] setFrame:sharedImage.frame];
        cellFrame = sharedImage.frame;
        //[buzzList setContentOffset:CGPointMake(0.0f, -buzzList.contentInset.bottom) animated:YES];
    }
    else if ([message hasPrefix:@":MOV"])
    {
        
            NSString *mediafile = [message substringFromIndex:5];
            NSString *sharedMediaURL =[NSString stringWithFormat:@"%@%@", CHATIMGURL, [message substringFromIndex:5]];
            UIImageView *sharedImage = [[UIImageView alloc] initWithFrame:CGRectZero];
            sharedImage.tag = ARROW_IMAGE_VIEW_TAG;
            sharedImage.frame = CGRectMake(12,10,200, 200);
            sharedImage.image = [UIImage imageNamed:@"noimage"] ;
            NSString  *localfilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, mediafile];
            
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:localfilePath]) {
           
            UIImageView *vwdownload = [[UIImageView alloc] initWithFrame:CGRectMake(68, 68, 64, 64)];
            [vwdownload setImage:[UIImage imageNamed:@"download-icon"]];
            [sharedImage addSubview:vwdownload];
            UITapGestureRecognizer *newTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downloadMediafile:)];
            [sharedImage setAccessibilityValue:mediafile];
            [sharedImage setUserInteractionEnabled:YES];
            [sharedImage addGestureRecognizer:newTap];
            
            
//            if (![[HorseBuzzDataManager sharedInstance].dictMedia objectForKey:sharedMediaURL]) {
//                ImageData *imageData = [[ImageData alloc] init];
//                imageData.resourceURL = sharedMediaURL;
//                imageData.filename = mediafile;
//                imageData.localfilepath = localfilePath;
//                imageData.imageView = sharedImage;
//                imageData.thisAction = HTTPReciveMedia;
//                imageData.mediaType = MEDIATypeVedioFile;
//                [[HorseBuzzDataManager sharedInstance].dictMedia setObject:imageData forKey:sharedMediaURL];
//                //
//                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:sharedMediaURL]];
//                // Create url connection and fire request
//                NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//            }
//            else{
//                
//                ImageData *imageData =  [[HorseBuzzDataManager sharedInstance].dictMedia objectForKey:sharedMediaURL];
//                [imageData.progressView removeFromSuperview];
//                [imageData.lblProgress removeFromSuperview];
//                [imageData.imageView removeFromSuperview];
//                imageData.imageView = sharedImage;
//            }
            
    
        }
        else
        {
            [sharedImage setImage:[self getThumbNail:localfilePath]];
            [self setMediaTapGesture:sharedImage withLocalFilePath:localfilePath];
            
        }
        
        [[*cell contentView] addSubview:sharedImage];
        [[*cell contentView] setFrame:sharedImage.frame];
        cellFrame = sharedImage.frame;
    }
    else{
        
        // Create message label
        UILabel *messagelabel = [[UILabel alloc] init];
        messagelabel.lineBreakMode = NSLineBreakByWordWrapping;
        messagelabel.numberOfLines = 0;
        messagelabel.font = [UIFont systemFontOfSize:MessageFontSize];
        if (!isGroup || [isGroup isEqual:@"0"])
            messagelabel.text = [message substituteEmotions];
        else{
            NSString *senderName = [NSString stringWithFormat:@"%@ %@", [dict objectForKey:@"firstname"],[dict objectForKey:@"lastname"]];
            messagelabel.attributedText = [self formatMessage:[message substituteEmotions] addUsername:senderName];
            message = [NSString stringWithFormat:@"%@\r\n%@", senderName, message];
        }
        
        //[[*cell contentView] addSubview:messagelabel];
        
        float W = [self expectedSizeWithString:message].width;
        float H = [self expectedSizeWithString:message].height;
        CGRect senderframe = CGRectMake (5, 5, W +5 , H+5);
        CGRect backgroundframe = CGRectMake(10, 10, senderframe.size.width + 10, senderframe.size.height + 10);
        //set the frame for text and backgroud bubble
        [messagelabel setFrame:senderframe];
        [messageBackgroundImageView setFrame:backgroundframe];
        
        [messageBackgroundImageView addSubview:messagelabel];
        [[*cell contentView] addSubview:messageBackgroundImageView];
        cellFrame = messageBackgroundImageView.frame;
        
    }
    
    [lbltimestamp setFrame:CGRectMake(10, cellFrame.size.height + 4 , 100, 26)];
    [[*cell contentView] bringSubviewToFront:lbltimestamp];
    
}


-(void)downloadMediafile:(UITapGestureRecognizer *)gr{
    __block UIImageView *theTappedImageView;
    theTappedImageView = (UIImageView *)gr.view;
    NSString *mediafile = theTappedImageView.accessibilityValue;
    NSString *sharedMediaURL =[NSString stringWithFormat:@"%@%@", CHATIMGURL, mediafile];
    __block NSString  *localfilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, mediafile];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:sharedMediaURL]];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    [dictionary setObject:localfilePath forKey:@"localfilepath"];

    [request setDownloadDestinationPath:localfilePath];
    [request setUserInfo:dictionary];
    [request setCompletionBlock:^{
        
        UIImage *newImage = [self getThumbNail:localfilePath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (newImage) {
                [theTappedImageView setImage:[self getThumbNail:localfilePath]];
                [theTappedImageView setNeedsLayout];
                [self removeSubviews:theTappedImageView];
                [self setMediaTapGesture:theTappedImageView withLocalFilePath:localfilePath];
            }
        });
        
        
    }];
    
    CERoundProgressView *progressIndicator = [[CERoundProgressView alloc] initWithFrame:CGRectMake(68, 68, 64, 64)];
    UIColor *tintColor = [UIColor orangeColor];
    [[CERoundProgressView appearance] setTintColor:tintColor];
    progressIndicator.trackColor = [UIColor colorWithWhite:0.80 alpha:1.0];
    progressIndicator.startAngle = (3.0*M_PI)/2.0;
    [theTappedImageView addSubview:progressIndicator];
    
    [request setDownloadProgressDelegate:progressIndicator];
    
    [request startAsynchronous];
    
    
}

-(void)removeSubviews:(UIView *)source{
    
    NSArray *viewsToRemove = [source subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }

}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation{

}

-(void)setMediaTapGesture:(UIImageView *)sharedImage withLocalFilePath:(NSString *)localfilePath{
    
    [self setMediaTapGesture:sharedImage withLocalFilePath:localfilePath withThumnail:ActionThumnailPlay];
}

-(void)setMediaTapGesture:(UIImageView *)sharedImage withLocalFilePath:(NSString *)localfilePath withThumnail:(ActionThumbnail)thumbnail{
   
    UIImageView *actionbutton;
    
    switch (thumbnail) {
        case 1:
            actionbutton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_icon"]];
            break;
        case 2:
            actionbutton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"upload-icon"]];
            break;
        case 3:
            actionbutton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_icon"]];
            break;
            
        default:
            actionbutton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_icon"]];
            break;
    }
    
    //UIImageView *playbutton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_icon"]];
    
    [actionbutton setFrame:CGRectMake(70, 70, 64, 64)];
    [sharedImage addSubview:actionbutton];
    [actionbutton bringSubviewToFront:sharedImage];
    UITapGestureRecognizer *newTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(PlayBack:)];
    [sharedImage setAccessibilityValue:localfilePath];
    [sharedImage setUserInteractionEnabled:YES];
    [sharedImage addGestureRecognizer:newTap];
}


-(NSMutableAttributedString *)formatMessage:(NSString *)message addUsername:(NSString *)userName{
    
    const CGFloat fontSize = 12;
    UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
    UIColor *foregroundColor = [UIColor blackColor];
    
    // Create the attributes
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           regularFont, NSFontAttributeName,
                           foregroundColor, NSForegroundColorAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              boldFont, NSFontAttributeName, nil];
    
    const NSRange range = NSMakeRange(0, userName.length); // range of " 2012/10/14 ". Ideally this should not be hardcoded
    
    message = [NSString stringWithFormat:@"%@\r\n%@", userName, message];
    
    // Create the attributed string (text + attributes)
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:message
                                           attributes:attrs];
    [attributedText setAttributes:subAttrs range:range];
    
    return attributedText;
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
	viewFrame.origin.y -= animatedDistance+10;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	
	[self.view setFrame:viewFrame];
    [UIView commitAnimations];
    
}


-(void)textViewDidEndEditing:(UITextView *)textView{
    CGRect viewFrame = self.view.frame;
	viewFrame.origin.y += animatedDistance+10;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	[self.view setFrame:viewFrame];
    [UIView commitAnimations];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    textView.text = [textView.text substituteEmotions];
    
    return YES;
}

#pragma mark - UrlConnection methods
-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
    
}



-(void)getResponsedata:(NSDictionary *)data{
    //NSLog(@"data%@",data);
    
    [self setMyProfileImage];
    [mbProgressHUD hide:YES];
    
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    NSString * code = [data objectForKey:@"code"];
    NSString * errors = [data objectForKey:@"errors"];
    
//    if ([errors isEqualToString:@"No New Messages"]) {
//        [self setCallback];
//        return;
//    }
    
    
    //Prakash
    if([code intValue] == 5){
        GroupProfileViewController *groupsummarycontroller=[[GroupProfileViewController alloc]initWithNibName:@"GroupProfileViewController" bundle:nil];
        
        groupsummarycontroller.getGroupId=receiverId;
        groupsummarycontroller.getGroupName = name.text;
        groupsummarycontroller.getProfileImage=receiverImage;
        NSMutableArray *array=[[NSMutableArray alloc]initWithArray:[NSMutableArray arrayWithArray:[data objectForKey:@"recepients"]]];
        groupsummarycontroller.getParticipant=array;
        groupsummarycontroller.buttonText=@"Update";
        [timer invalidate];
        [self.navigationController pushViewController:groupsummarycontroller animated:YES];
        
    }
    
    if (firstTime || fromLoadMoreButton) {
        shouldShowLoadButton = status;
    }
    
    if (status) {
        if (fromLoadMoreButton) {
            fromLoadMoreButton = NO;
            NSMutableArray *newMessages = [[NSMutableArray alloc] init];
            NSMutableArray *array=[[NSMutableArray alloc]initWithArray:[NSMutableArray arrayWithArray:[data objectForKey:@"convenstationMessage"]]];
            for(int i=0;i<array.count;i++){
                NSDictionary *dict  = [NSDictionary dictionaryWithObjectsAndKeys:[[array objectAtIndex:i]valueForKey:@"message"],@"message",[[array objectAtIndex:i]valueForKey:@"sender_id"],@"userId", [[array objectAtIndex:i]valueForKey:@"created_date"],@"timestamp", nil];
                
                [newMessages addObject:dict];
            }
            
            [[[newMessages reverseObjectEnumerator] allObjects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [dataArray insertObject:obj atIndex:0];
            }];
            
            NSMutableArray *newIndexes = [[NSMutableArray alloc]init];
            [newMessages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [newIndexes addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
            }];
            [buzzList insertRowsAtIndexPaths:newIndexes withRowAnimation:UITableViewRowAnimationTop];
            //            [buzzList reloadData];
            
        } else {
            if(firstTime){
                firstTime=FALSE;
                
                NSMutableArray *array=[[NSMutableArray alloc]initWithArray:[NSMutableArray arrayWithArray:[data objectForKey:@"convenstationMessage"]]];
                for(int i=0;i<array.count;i++){
                    
                    NSDictionary *dict  = [NSDictionary dictionaryWithObjectsAndKeys:[[array objectAtIndex:i]valueForKey:@"message"],@"message",[[array objectAtIndex:i]valueForKey:@"sender_id"],@"userId", [[array objectAtIndex:i]valueForKey:@"created_date"],@"timestamp",[[array objectAtIndex:i]valueForKey:@"is_group"],@"is_group",[[array objectAtIndex:i]valueForKey:@"firstname"],@"firstname",[[array objectAtIndex:i]valueForKey:@"lastname"],@"lastname", nil];
                    [dataArray addObject:dict];
                }
                if ([dataArray count] < 30) {
                    shouldShowLoadButton = NO;
                }
            }
            else{
                NSDictionary *dict  = [NSDictionary dictionaryWithObjectsAndKeys:[[[data objectForKey:@"messages"]objectAtIndex:0]objectForKey:@"message"],@"message",[[[data objectForKey:@"messages"]objectAtIndex:0]objectForKey:@"sender_id"],@"userId", [[[data objectForKey:@"messages"]objectAtIndex:0] objectForKey:@"created_date"],@"timestamp",[[[data objectForKey:@"is_group"]objectAtIndex:0]objectForKey:@"is_group"],@"is_group",[[[data objectForKey:@"firstname"]objectAtIndex:0]objectForKey:@"firstname"],@"firstname",[[[data objectForKey:@"lastname"]objectAtIndex:0]objectForKey:@"lastname"],@"lastname", nil];
                if(dict.count > 0)
                    [dataArray addObject:dict];
                
                
                
            }
            
            [buzzList reloadData];
            if (dataArray.count > 1) {
                [buzzList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dataArray.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
            
            
            int count =[[data objectForKey:@"messagecount"]integerValue];
            int badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
            
            //NSLog(@"count=%d",count);
            //NSLog(@"badgeCount=%d",badgeCount);
            
            AppDelegate *delagate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            UIViewController *viewController = [delagate.tabBarController.viewControllers objectAtIndex:2];
            if (badgeCount >0) {
                [UIApplication sharedApplication].applicationIconBadgeNumber = badgeCount;
                viewController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",badgeCount];
            }
            else{
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                viewController.tabBarItem.badgeValue = nil;
            }
        }
        
    }else if ([code intValue] == 2){
        
        
    }
    
    if (firstTime || fromLoadMoreButton) {
        if (!status)
            [buzzList reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    }
    
    if (IsPendingActivityLoaded==NO && [HorseBuzzDataManager sharedInstance].requestHandler.activeRequests.count>0) {
        NSLog(@"Loading pending media : %d", [HorseBuzzDataManager sharedInstance].requestHandler.activeRequests.count);
        NSDictionary *pendingDict = [[HorseBuzzDataManager sharedInstance].requestHandler getPendingUploadsforUserID:[HorseBuzzDataManager sharedInstance].userId toReciverId:receiverId];
        for (id key in pendingDict) {
            NSObject *obj = [pendingDict objectForKey:key];
            if([NSStringFromClass([obj class]) isEqualToString:@"ASIFormDataRequest"]){
                NSDictionary *dict = ((ASIFormDataRequest *)obj).userInfo;
                if (![dataArray containsObject:dict])
                    [dataArray addObject:dict];
            }
        }
        [buzzList reloadData];
        [buzzList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dataArray.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        IsPendingActivityLoaded = YES;
        
    }

    //    [buzzList reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    
    [self setCallback];
    
}
-(void)setCallback{
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                [self methodSignatureForSelector: @selector(timerCallback)]];
    [invocation setTarget:self];
    [invocation setSelector:@selector(timerCallback)];
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                         invocation:invocation repeats:NO];
}


- (void)timerCallback {
    [timer invalidate];
    timer = nil;
    [self getNewMessages];
}

-(void)showMenu{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - image upload/share methods
- (IBAction)sendPicture:(id)sender {
    
     //UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:@"Choose your image SourceType." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send Picture", @"Send Video",@"Camera", nil];
    //[alert show];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share & Enjoy" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Share an Image", @"Share a Video", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.alpha=1;
	actionSheet.tag = 1;
	[actionSheet showInView:self.view];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
        if (buttonIndex == 1) {

            imagePicker = [[GKImagePicker alloc] init];
            imagePicker.cropSize = CGSizeMake(296, 300);
            imagePicker.delegate = self;
            imagePicker.resizeableCropArea = YES;
            
            [self presentModalViewController:imagePicker.imagePickerController animated:YES];
            
        }
        else if (buttonIndex == 2)
        {
            pickerCtrl = [[UIImagePickerController alloc] init];
            pickerCtrl.delegate = self;
            pickerCtrl.allowsEditing = NO;
            //pickerCtrl.mediaTypes = [NSArray arrayWithObjects:
            //                         (NSString *) kUTTypeMovie,
            //                         nil];
            pickerCtrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            pickerCtrl.mediaTypes =[[NSArray alloc] initWithObjects: (NSString *)kUTTypeMovie,nil];

            
            [self presentModalViewController:pickerCtrl animated:YES];
        }
        else if (buttonIndex == 3){
            pickerCtrl = [[UIImagePickerController alloc] init];
            pickerCtrl.delegate = self;
            //[[UIDevice currentDevice] setOrientation:UIInterfaceOrientationLandscapeRight];
            pickerCtrl.allowsEditing = NO;
            
            if( [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront ])
            {
                pickerCtrl.sourceType = UIImagePickerControllerCameraDeviceFront;
                pickerCtrl.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                pickerCtrl.sourceType = UIImagePickerControllerSourceTypeCamera;
                pickerCtrl.cameraDevice = UIImagePickerControllerSourceTypeCamera;
            }
            
            // Hide the controls
            pickerCtrl.showsCameraControls = YES;
            pickerCtrl.navigationBarHidden = YES;
            
            // Make camera view full screen
            pickerCtrl.wantsFullScreenLayout = YES;
            
            [self presentModalViewController:pickerCtrl animated:YES];
        }else{
            isChangePic = FALSE;
        }
    }
    

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
        
        imagePicker = [[GKImagePicker alloc] init];
        imagePicker.cropSize = CGSizeMake(296, 300);
        imagePicker.delegate = self;
        imagePicker.resizeableCropArea = YES;
        
        [self presentModalViewController:imagePicker.imagePickerController animated:YES];
        
    }
    else if (buttonIndex == 2)
    {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        pickerCtrl = [[UIImagePickerController alloc] init];
        pickerCtrl.delegate = self;
        pickerCtrl.allowsEditing = NO;
        pickerCtrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerCtrl.mediaTypes =[[NSArray alloc] initWithObjects: (NSString *)kUTTypeMovie,nil];
        
        
        [self presentModalViewController:pickerCtrl animated:YES];
    }
    else if (buttonIndex == 0){
        pickerCtrl = [[UIImagePickerController alloc] init];
        pickerCtrl.delegate = self;
        //[[UIDevice currentDevice] setOrientation:UIInterfaceOrientationLandscapeRight];
        pickerCtrl.allowsEditing = NO;
        
        if( [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront ])
        {
            pickerCtrl.sourceType = UIImagePickerControllerCameraDeviceFront;
            pickerCtrl.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            pickerCtrl.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickerCtrl.cameraDevice = UIImagePickerControllerSourceTypeCamera;
        }
        
        // Hide the controls
        pickerCtrl.showsCameraControls = YES;
        pickerCtrl.navigationBarHidden = YES;
        
        // Make camera view full screen
        pickerCtrl.wantsFullScreenLayout = YES;
        
        [self presentModalViewController:pickerCtrl animated:YES];
    }else{
        isChangePic = FALSE;
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    BOOL IsMediaType = NO;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    NSString *uploadServiceURL = [NSString stringWithFormat:@"%@%@",BASE_URL, CHATUPLOAD];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    else {
        IsMediaType = YES;
        pickedImage = [info objectForKey:UIImagePickerControllerMediaType];
    }
    
        
        if (pickedImage && !IsMediaType)
        {
            NSString *localfilePath = [self saveImageToTemp:pickedImage];
            [self uploadselectedImageFile:localfilePath];
//            NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
//            
//            __block NSString *localfilePath = nil;
//            
//            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//            [library assetForURL:assetURL resultBlock:^(ALAsset *asset)  {
//                
//                localfilePath = [asset.defaultRepresentation filename];
//                ImageData *imageData = [[ImageData alloc] init];
//                [imageData setMediaType:MEDIATypeImageFile];
//                [imageData setThisAction:HTTPSendMedia];
//                [imageData setLocalfilepath:localfilePath];
//                [imageData setImage:pickedImage];
//                [[HorseBuzzDataManager sharedInstance].dictMedia setObject:imageData forKey:uploadServiceURL];
//                
//                [self uploadselectedImageFile:localfilePath];
//               
//            } failureBlock:nil];
        }
        else
        {
            
            NSURL *videoURL = (NSURL*)[info objectForKey:@"UIImagePickerControllerMediaURL"];
            [self uploadselectedVideoFile:videoURL];
            
        }
}

-(void)uploadselectedImageFile1:(NSString *)imageFilename withImageData:(ImageData *)imageData{
    
    NSURLConnection *conn;
    NSString *uploadServiceURL = [NSString stringWithFormat:@"%@%@",BASE_URL, CHATUPLOAD];
    
    if([[CMLNetworkManager sharedInstance] hasConnectivity])
    {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        
        [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"sender_id"];
        [dictionary setObject:self.receiverId forKey:@"receiver_id"];
        //[dictionary setObject:@"jpg" forKey:@"imagetype"];
        [dictionary setObject:IsGroup forKey:@"is_group"];
        
        CGFloat quality = 0.85;
        NSData *jpegdata = UIImageJPEGRepresentation(pickedImage,quality);
        NSString * encodedImage=[jpegdata base64Encoding];
        [dictionary setObject:@"jpg" forKey:@"imagetype"];
        [dictionary setObject:encodedImage forKey:@"imagecontent"];
        //NSLog(@"dictionarydictionary%@",dictionary);
        //NSLog(@"encodedImage%@",encodedImage);
        
        //[dictionary setObject:@"testing!!" forKey:@"message"];
        NSDictionary *dict  = [NSDictionary dictionaryWithObjectsAndKeys:@":IMG-sending",@"message",[HorseBuzzDataManager sharedInstance].userId,@"userId", [self.dateFormatter stringFromDate:[NSDate date]], @"timestamp",
                               pickedImage,@"pickedImage",imageFilename,@"filename", imageData, @"imageData", nil];
    
        //NSLog(@"dataArray%@",dict);
        [dataArray addObject:dict];
        //NSLog(@"dictis%@",dict);
        
        
        [buzzList reloadData];
        [buzzList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dataArray.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:uploadServiceURL]];
        // Create url connection and fire request
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        //[request setValue:[NSString stringWithFormat:@"%d", [dictionary length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody: [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:NULL]];
        //
        conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

-(void)uploadselectedImageFile:(NSString *)localfilepath{
    
    NSString *uploadServiceURL = [NSString stringWithFormat:@"%@%@",BASE_URL, CHATUPLOAD];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:uploadServiceURL]];
    
    if([[CMLNetworkManager sharedInstance] hasConnectivity])
    {
        NSDictionary *dict  = [NSDictionary dictionaryWithObjectsAndKeys:@":IMG-sending",@"message",[HorseBuzzDataManager sharedInstance].userId,@"userId",receiverId, @"receiverId", [self.dateFormatter stringFromDate:[NSDate date]], @"timestamp", pickedImage,@"pickedImage",@"jpg",@"mediatype",localfilepath,@"localfilepath", request, @"requestObject", self,@"source", nil];
        
        [dataArray addObject:dict];
       
        [buzzList reloadData];
        [buzzList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dataArray.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
        
        [request setDelegate:[HorseBuzzDataManager sharedInstance].requestHandler];
        [request setUserInfo:dict];
        
        [[HorseBuzzDataManager sharedInstance].requestHandler addRequest:request forKey:localfilepath];
        
        [request setPostValue:[HorseBuzzDataManager sharedInstance].userId  forKey:@"sender_id"];
        [request setPostValue:self.receiverId forKey:@"receiver_id"];
        [request setPostValue:@"img" forKey:@"mediatype"];
        [request setPostValue:@"jpg" forKey:@"filetype"];        
        [request setPostValue:IsGroup forKey:@"is_group"];
        
        NSError *error = nil;
        NSData *imagedata = [NSData dataWithContentsOfFile:localfilepath options:NSDataReadingUncached error:&error];
        [request addData:imagedata withFileName:@"image.jpg" andContentType:@"image/jpeg" forKey:@"imagecontent"];
        [request setNumberOfTimesToRetryOnTimeout:5];
        [request setTimeOutSeconds:30];
        [request setShouldAttemptPersistentConnection:NO];
        [request startAsynchronous];
        
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
}


-(void)uploadselectedVideoFile: (NSURL *)videoURL
{
    NSString *uploadServiceURL = [NSString stringWithFormat:@"%@%@",BASE_URL, CHATUPLOADMEDIA];
    NSString *localfilepath = [videoURL path];
    pickedImage = [self getThumbNail:localfilepath];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:uploadServiceURL]];
    //[[HorseBuzzDataManager sharedInstance].requestHandler setDelegate:request forKey:localfilepath];
    
    NSDictionary *dict  = [NSDictionary dictionaryWithObjectsAndKeys:@":MOV-sending",@"message",[HorseBuzzDataManager sharedInstance].userId,@"userId", receiverId, @"receiverId", [self.dateFormatter stringFromDate:[NSDate date]], @"timestamp",
                           pickedImage,@"pickedImage", @"mov",@"mediatype", localfilepath,@"localfilepath", request, @"requestObject", self,@"source", nil];
    [dataArray addObject:dict];
    [request setUserInfo:dict];
    
    [buzzList reloadData];
    [buzzList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dataArray.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    //[request setUploadProgressDelegate:progressIndicator];
    [request setDelegate:[HorseBuzzDataManager sharedInstance].requestHandler];
    [[HorseBuzzDataManager sharedInstance].requestHandler addRequest:request forKey:localfilepath];
    [request setPostValue:[HorseBuzzDataManager sharedInstance].userId  forKey:@"sender_id"];
    [request setPostValue:self.receiverId forKey:@"receiver_id"];
    [request setPostValue:@"mov" forKey:@"mediatype"];
    [request setPostValue:@"mp4" forKey:@"filetype"];
    [request setPostValue:IsGroup forKey:@"is_group"];
    
    NSError *error = nil;
    NSData *videodata = [NSData dataWithContentsOfFile:[videoURL path] options:NSDataReadingUncached error:&error];
    [request addData:videodata withFileName:@"video.mov" andContentType:@"image/jpeg" forKey:@"imagecontent"];
    [request setNumberOfTimesToRetryOnTimeout:5];
    [request setTimeOutSeconds:30];
    [request setShouldAttemptPersistentConnection:NO];
    [request startAsynchronous];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

}

-(void)uploadselectedVideoFile1: (NSURL *)videoURL
{
    
    NSURLConnection *conn;
    NSString *uploadServiceURL = [NSString stringWithFormat:@"%@%@",BASE_URL, CHATUPLOAD];
    
    if([[CMLNetworkManager sharedInstance] hasConnectivity])
    {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        
        [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"sender_id"];
        [dictionary setObject:self.receiverId forKey:@"receiver_id"];
        //[dictionary setObject:@"jpg" forKey:@"imagetype"];
        [dictionary setObject:IsGroup forKey:@"is_group"];
        NSError *error = nil;
        //NSData *videodata = [NSData dataWithContentsOfFile:[videoURL path] options:NSDataReadingMappedAlways error:&error];
        NSData *videodata = [NSData dataWithContentsOfFile:[videoURL path] options:NSDataReadingUncached error:&error];
        
        if(videodata == nil && error!=nil) {
            //Print error description
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Horsebuzz" message:[NSString stringWithFormat:@"%@%@",@"Error uploading",error.description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        else
        {
            pickedImage = [self getThumbNail:[videoURL path]];
            
            
             NSString * encodedData=[videodata base64Encoding];
            [dictionary setObject:@"mov" forKey:@"imagetype"];
            //[dictionary setObject:encodedData forKey:@"imagecontent"];
           
            ImageData *imageData = [[ImageData alloc] init];
            NSString *localfilePath = [videoURL absoluteString];
            [imageData setLocalfilepath:localfilePath];
            [imageData setMediaType:MEDIATypeVedioFile];
            [imageData setThisAction:HTTPSendMedia];
            [[HorseBuzzDataManager sharedInstance].dictMedia setObject:imageData forKey:uploadServiceURL];
            
            NSDictionary *dict  = [NSDictionary dictionaryWithObjectsAndKeys:@":MOV-sending",@"message",[HorseBuzzDataManager sharedInstance].userId,@"userId", [self.dateFormatter stringFromDate:[NSDate date]], @"timestamp",
                                   pickedImage,@"pickedImage",[NSNumber numberWithInteger:[HorseBuzzDataManager sharedInstance].dictMedia.count-1],@"mediaIndex", nil];
            [dataArray addObject:dict];
            
            
            [buzzList reloadData];
            [buzzList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dataArray.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
            //Create message data and append media base64 content
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:NULL];
            NSData *mediaData = [encodedData dataUsingEncoding:NSUTF8StringEncoding];
            messageData = [jsonData mutableCopy];
            [messageData appendData:[[@"MEDIA_CONTENT" dataUsingEncoding:NSUTF8StringEncoding] mutableCopy]];
            [messageData appendData:[mediaData mutableCopy]];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:uploadServiceURL]];
            // Create url connection and fire request
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            //[request setValue:[NSString stringWithFormat:@"%d", [dictionary length]] forHTTPHeaderField:@"Content-Length"];
            [request setHTTPBody:messageData];
            //
            //[request setHTTPBody: [encodedData dataUsingEncoding:NSUTF8StringEncoding]];
            //
            conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            imageData.connection = conn;
            [conn start];
            
        }
    }
}

- (void)downloadImageAndSave:(NSMutableDictionary *)dict{
    
    //download the file in a seperate thread.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //NSLog(@"Downloading Started");
        NSURL  *url = [NSURL URLWithString:[dict valueForKey:@"imageURL"]];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if ( urlData )
        {
            NSString  *localfilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [dict valueForKey:@"filename"]];
            //saving is done on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [urlData writeToFile:localfilePath atomically:YES];
                //UIImageWriteToSavedPhotosAlbum([[UIImage alloc] initWithData:urlData], nil, nil, nil);
                UIImageView *sharedImage = [dict valueForKey:@"sharedImage"];
                sharedImage.image = [UIImage imageWithContentsOfFile:localfilePath] ;
                //NSLog(@"File Saved !");
            });
        }
        
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  [self dismissViewControllerAnimated:YES completion:nil ];
}

-(void)sendSharedImageURL:(NSDictionary *)data{
    IsImageUpload = false;
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    //NSString * code = [data objectForKey:@"code"];
    uploadImagePath = nil;
    
    if (status) {
      
        uploadImagePath = [data objectForKey:@"imagepath"];
    }
    //
    
    
}

- (IBAction)ToggleKeyboard:(id)sender {

    IsCustomKeyboard = (IsCustomKeyboard==YES)?NO:YES;
    
    
    if (IsCustomKeyboard) {
        [messageView resignFirstResponder];
        self.placeHolder.hidden = YES;
        //EmotionsViewController *keyboardView = [[EmotionsViewController alloc] init];
        emotionsTable = [[EmotionsViewController alloc] init];
        [self.view addSubview:emotionsTable.view];
        [emotionsTable setMessageView:messageView];
        messageView.inputView = emotionsTable.view;
        [InputImage setImage:[UIImage imageNamed:@"keyboard.png"] forState:UIControlStateNormal];
        [messageView becomeFirstResponder];
        
    }
    else{
        [emotionsTable removeFromParentViewController];
        [messageView resignFirstResponder];
        messageView.inputView = nil;
        [InputImage setImage:[UIImage imageNamed:@"smiley.png"] forState:UIControlStateNormal];
        [messageView becomeFirstResponder];
        
    }
   

}

-(void)hideKeyBoard {
    [messageView resignFirstResponder];
}

-(UIImage *)getThumbNail:(NSString*)stringPath
{
    NSURL *videoURL = [NSURL fileURLWithPath:stringPath];
    
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    
    UIImage *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    
    //Player autoplays audio on init
    [player stop];
    // [player release];
    return [self generatePhotoThumbnail:thumbnail withSide:200.0f];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // A response has been received, this is where we initialize the instance var you created
    ImageData *imageData = (ImageData *)[[HorseBuzzDataManager sharedInstance].dictMedia  objectForKey:[connection.currentRequest.URL absoluteString]];
    if (imageData) {
       imageData.expectedContentLength = response.expectedContentLength;
        imageData.responseData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    ImageData *imageData = (ImageData *)[[HorseBuzzDataManager sharedInstance].dictMedia  objectForKey:[connection.currentRequest.URL absoluteString]];
    [imageData.responseData appendData:data];
   
    
//    NSArray *viewsToRemove = [imageData.imageView subviews];
//    for (UIView *v in viewsToRemove) {
//        [v removeFromSuperview];
//    }
    
    if (imageData.imageView.subviews.count<=0) {
        imageData.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [imageData.imageView addSubview:imageData.progressView];
        imageData.progressView.center = imageData.imageView.center;
        imageData.lblProgress = [[UILabel alloc] initWithFrame:CGRectMake(130, 70, 60, 30)];
        [imageData.lblProgress setTextColor:[UIColor greenColor]];
        [imageData.imageView addSubview:imageData.lblProgress];
        [imageData.imageView bringSubviewToFront:imageData.progressView];
        [imageData.imageView bringSubviewToFront:imageData.lblProgress];
    }
    
    
    [imageData.progressView setProgress:((100.0/ imageData.expectedContentLength)* imageData.responseData.length)/100 animated:YES];
    imageData.lblProgress.text = [NSString stringWithFormat:@"%.0f %%",(((100.0/ imageData.expectedContentLength)* imageData.responseData.length)/100)*100];
    if (imageData.progressView.progress == 1) {
        [imageData.progressView removeFromSuperview];
        [imageData.lblProgress removeFromSuperview];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    //[mbProgressHUD hide:YES];

    @try {
    
        ImageData *imageData = (ImageData *)[[HorseBuzzDataManager sharedInstance].dictMedia  objectForKey:[connection.currentRequest.URL absoluteString]];
        //
        if (imageData.thisAction == HTTPReciveMedia)
            [imageData.responseData writeToFile:imageData.localfilepath atomically:YES];
        else if (imageData.thisAction == HTTPSendMedia && imageData.mediaType == MEDIATypeImageFile)
        {
            id response = [NSJSONSerialization JSONObjectWithData:imageData.responseData options:0 error:nil];
            NSString *filename =  [response objectForKey:@"imagepath"];
            //NSLog(@"%@/%@",documentsDirectory,filename);
            CGFloat quality = 0.85;
            NSData *jpegdata = UIImageJPEGRepresentation(imageData.image,quality);
            [jpegdata writeToFile:[NSString stringWithFormat:@"%@//%@",documentsDirectory,filename] atomically:YES];
            imageData.localfilepath =[NSString stringWithFormat:@"%@//%@",documentsDirectory,filename];
        }
        else if (imageData.thisAction == HTTPSendMedia && imageData.mediaType == MEDIATypeVedioFile)
        {
            //NSLog(@"%@", imageData.responseData);
            if (imageData.responseData) {
              id response = [NSJSONSerialization JSONObjectWithData:imageData.responseData options:0 error:nil];
                NSString *filename =  [response objectForKey:@"imagepath"];
                //NSLog(@"%@/%@",documentsDirectory,filename);
                NSError* error=nil;
                NSString *newfilepath = [NSString stringWithFormat:@"%@/%@",documentsDirectory,filename];
                NSString *prefixToRemove = @"file://";
                NSString *tempFile = [[imageData.localfilepath substringFromIndex:[prefixToRemove length]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [[NSFileManager defaultManager] copyItemAtPath:tempFile toPath:newfilepath error:&error];
                [self setMediaTapGesture:imageData.imageView withLocalFilePath:newfilepath];
                //[dataArray removeObjectAtIndex:dataArray.count-1];
                
                    NSDictionary *dict  = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@":MOV-%@",filename],@"message",[HorseBuzzDataManager sharedInstance].userId,@"userId", [self.dateFormatter stringFromDate:[NSDate date]], @"timestamp",
                                           pickedImage,@"pickedImage",imageData.imageView,@"shareImageView", nil];
                    [dataArray replaceObjectAtIndex:dataArray.count-1 withObject:dict];
            }
        }
        
        //remove subviews
        NSArray *viewsToRemove = [imageData.imageView subviews];
        for (UIView *v in viewsToRemove) {
            [v removeFromSuperview];
        }
        //remove from media array
        [[HorseBuzzDataManager sharedInstance].dictMedia removeObjectForKey:[connection.currentRequest.URL absoluteString]];
        [self setCallback];
    }
    @catch (NSException *exception) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:[NSString stringWithFormat:@"Error connecting to server: %@",exception.description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    @finally {
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:[NSString stringWithFormat:@"Connection to Server failed: %@",error.localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    
    //NSLog(@"%@ %d %d %.2f",[connection.currentRequest.URL absoluteString], totalBytesWritten, totalBytesExpectedToWrite, ((float)totalBytesWritten/(float)totalBytesExpectedToWrite)*100.00f );
    
    float dataUploaded = ((float)totalBytesWritten/(float)totalBytesExpectedToWrite);
    [self performSelectorOnMainThread:@selector(UpdateProgressBar:) withObject:[NSArray arrayWithObjects:[connection.currentRequest.URL absoluteString], [NSNumber numberWithFloat:dataUploaded], nil] waitUntilDone:YES];
    
}


-(void)UpdateProgressBar:(NSArray *) params{
    
    ImageData *imageData = (ImageData *)[[HorseBuzzDataManager sharedInstance].dictMedia  objectForKey: [params objectAtIndex:0]];
    
    if (imageData.imageView.subviews.count<=0) {
        imageData.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [imageData.progressView setFrame:CGRectMake(30, 110, 150, 30)];
        imageData.lblProgress = [[UILabel alloc] initWithFrame:CGRectMake(90, 80, 60, 30)];
        //[imageData.lblProgress setBackgroundColor:[UIColor grayColor]];
        [imageData.lblProgress setTextColor:[UIColor greenColor]];
        
        [imageData.imageView addSubview:imageData.progressView];
        //imageData.progressView.center = imageData.imageView.center;
        [imageData.imageView addSubview:imageData.lblProgress];
        [imageData.imageView bringSubviewToFront:imageData.progressView];
        [imageData.imageView bringSubviewToFront:imageData.lblProgress];
    }
    
    
    
    if (imageData.imageView) {
        float nProgressValue = [[params objectAtIndex:1] floatValue];
        [imageData.progressView setProgress:nProgressValue animated:YES];
        [imageData.lblProgress setText:[NSString stringWithFormat:@"%.0f %%", nProgressValue * 100]];
    }
    
    if (imageData.progressView.progress == 1) {
        imageData.progressView.hidden = YES;
    } else {
        imageData.progressView.hidden = NO;
    }
    
}


# pragma mark -
# pragma mark GKImagePicker Delegate Methods

- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image{
    
    //CGImageRef cgRef = image.CGImage;
    //image = [[UIImage alloc] initWithCGImage:cgRef scale:1.0 orientation:UIImageOrientationUp];
    pickedImage = image;
    
    [self hideImagePicker];
    NSString *localfilepath = [self saveImageToTemp:pickedImage];
    [self uploadselectedImageFile:localfilepath];
    
}


- (void)hideImagePicker{
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        
        [self.popoverController dismissPopoverAnimated:YES];
        
    } else {
        
        [imagePicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
        
    }
}

-(void)UploadCompleted: (UIView *)targetView withOldData:(NSDictionary *)oldDict withNewData:(NSDictionary *) newDict{
    [dataArray removeObject:oldDict];
    [dataArray addObject:newDict];
    
    if (dataArray.count > 0)
        [buzzList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dataArray.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [self setCallback];
}

-(void)UploadCompleted: (UIView *)targetView withOldData:(NSDictionary *)oldDict withNewData:(NSDictionary *) newDict withThumbnail:(ActionThumbnail)thumbnail{
    
    //[dataArray removeObject:oldDict];
    [self setMediaTapGesture:(UIImageView *)targetView withLocalFilePath:[NSString stringWithFormat:@"%@/%@",documentsDirectory, [newDict objectForKey:@"filename"]]  withThumnail:thumbnail];
    //[dataArray replaceObjectAtIndex:[dataArray indexOfObject:oldDict] withObject:newDict];
    [dataArray removeObject:oldDict];
    [dataArray addObject:newDict];
    
    if (dataArray.count > 0)
        [buzzList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:dataArray.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [self setCallback];
}


- (void)saveImage:(UIImage *)image withName:(NSString *)filename {
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:filename];
    [fileManager createFileAtPath:fullPath contents:data attributes:nil];
}

- (NSString *)saveImageToTemp:(UIImage *)image{
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    //NSString *fullPath = [NSString stringWithFormat:@"%@%@%@", [tmpDirURL absoluteString],[self randomStringWithLength:9],@".jpg"];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",[self randomStringWithLength:9],@".jpg"]];

    //[fileManager createFileAtPath:fullPath contents:data attributes:nil];
    [data writeToFile:fullPath atomically:YES];
    return fullPath;
}

- (UIImage *)loadImage:(NSString *)filename {
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:filename];
    UIImage *img = [UIImage imageWithContentsOfFile:fullPath];
    
    return img;
}


-(NSString *) randomStringWithLength: (int) len {

    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length]) % [letters length]]];
    }
    
    return randomString;
}

@end
