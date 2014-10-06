//
//  ProfileViewController.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 20/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "ProfileViewController.h"
#import "HorseBuzzConfig.h"
#import "MBProgressHUD.h"
#import "HorseBuzzDataManager.h"
#import "CMLNetworkManager.h"
#import "NSDataAdditions.h"
#import "NSData+Base64.h"
#import "AppDelegate.h"
#import "SetInvisibleUser.h"
#import "ImageData.h"
#import "PagedScrollViewController.h"
#import "MyImage.h"
#import "PECropViewController.h"
#import "GAI.h"

#import <SDWebImage/UIButton+WebCache.h>

@interface ProfileViewController ()<PagedScrollDelegate,PECropViewControllerDelegate>
{
    CGFloat  animatedDistance;
    UIImagePickerController *picker;
    UIImage *pickedImage;
    int tag,deleteID,changeID;
    BOOL checkValidation,checkValidation1;
    MBProgressHUD *mbProgressHUD;
    NSMutableDictionary *profileDetailArray;
    UIButton *eyeButton;
    BOOL isMenuView,isChangePic,isDeleted,isUpdateStatus,isAddingPic;
    BOOL profileImageAvailable;
    NSMutableArray *imageDataArray;
    PagedScrollViewController *psc;
}
@end

@implementation ProfileViewController
@synthesize scrollView;
@synthesize placeHolder,statusTextView;
@synthesize profileImage;
@synthesize moodLabel;
@synthesize nameLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isMenuView:(BOOL)isMenu
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isMenuView=isMenu;
    }
    return self;
}


- (void)viewDidLoad
{
    
    
    // google tracking code
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLEANALITICSCODE];
    //[tracker trackView:@"Horse Buzz - Profile view"];
    [tracker set:@"ScreenName" value: @"Horse Buzz - Profile view"];
    // google tracking code end
    
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden=NO;
    
    mbProgressHUD = [[MBProgressHUD alloc]initWithView:self.view];
    [mbProgressHUD setMode:MBProgressHUDModeIndeterminate];
    [self.view addSubview:mbProgressHUD];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Profile";
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
    
    
    
    eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    eyeButton.frame = CGRectMake(0, 0, 19, 19);
    [eyeButton addTarget:self action:@selector(setVisibilty) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *eyeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:eyeButton];
    self.navigationItem.rightBarButtonItem = eyeButtonItem;
    
    imageDataArray  = [[NSMutableArray alloc]init];
    scrollView.contentSize = CGSizeMake(320.0f, 580.0f);
    if([[CMLNetworkManager sharedInstance] hasConnectivity]){
        tag=10;
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        ;
        [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
        
        
        [mbProgressHUD show:YES];
        HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
        request.delegate=self;
        [request initwithurl:BASE_URL requestStr:PROFILEDETAILS requestType:POST input:YES inputValues:dictionary];
        
        AppDelegate *appdel=(AppDelegate *)[[UIApplication sharedApplication]delegate];
        
        [appdel.personalDetails getPrefilDetail];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
    
    if(isMenuView){
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton setBackgroundImage:[UIImage imageNamed:@"menu_icon.png"] forState:UIControlStateNormal];
        menuButton.frame = CGRectMake(0, 0, 24, 17);
        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
        self.navigationItem.leftBarButtonItem = revealButtonItem;
    }
    profileImage.clipsToBounds = YES;
    profileImage.contentMode = UIViewContentModeScaleAspectFit;
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
-(void)setProfilePic:(id)sender{
    tag=0;
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:@"Choose your image SourceType." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Album",@"Camera", nil];
    alert.tag = 101;
    [alert show];
}

-(void)DeletePic:(id)sender{
    UIButton *refButton = (UIButton*)sender;
    UIView *refView  = [(UIView *)[refButton superview]superview];
    deleteID = refView.tag;
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:@"Do you want to delete this picture." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    alert.tag = 102;
    [alert show];
}
-(void)ChangePic:(id)sender{
    
    UIButton *refButton = (UIButton*)sender;
    UIView *refView  = [(UIView *)[refButton superview]superview];
    tag = refView.tag;
    isChangePic = TRUE;
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:@"Choose your image SourceType." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Album",@"Camera", nil];
    alert.tag = 101;
    [alert show];
}


-(IBAction)addPic:(id)sender{
    UIButton *refButton = (UIButton*)sender;
    UIView *refView  = (UIView *)[refButton superview];
    tag = refView.tag;
    
    if (imageDataArray.count >= tag && imageDataArray.count != 0) {
        psc = [[PagedScrollViewController alloc]initWithNibName:@"PagedScrollViewController" bundle:nil];
        psc.delegate = self;
        psc.showBarButton = TRUE;
        psc.pageImages = imageDataArray;
        psc.selectedIndex = tag-1;
        [self.navigationController pushViewController:psc animated:YES];
        
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:@"Choose your image SourceType." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Album",@"Camera", nil];
        alert.tag = 101;
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.mediaTypes = [NSArray arrayWithObjects:
                                 (NSString *) kUTTypeImage,
                                 nil];
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            [self presentModalViewController:picker animated:YES];
        }else if (buttonIndex == 2){
            picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            
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
            isChangePic = FALSE;
        }
    }
    else if (alertView.tag == 102){
        if (buttonIndex == 1) {
            
            NSDictionary *dict =[imageDataArray objectAtIndex:deleteID-1];
            ImageData *imageData = [dict objectForKey:[NSNumber numberWithInt:deleteID]];
            [imageDataArray removeObjectAtIndex:deleteID-1];
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
            [dictionary setObject:imageData.imageID forKey:@"image_id"];
            isDeleted = TRUE;
            HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
            request.delegate=self;
            [request initwithurl:BASE_URL requestStr:@"Deleteimages" requestType:POST input:YES inputValues:dictionary];
        }
    }
}

-(void)reloadViews{
    
    for (int i =deleteID; i < 9 ; i++) {
        UIView *refView  = (UIView *)[self.view viewWithTag:i];
        UIButton *refButton =(UIButton *)[refView viewWithTag:10];
        
        if (i < imageDataArray.count) {
            NSDictionary *dict =[imageDataArray objectAtIndex:i-1];
            ImageData *imageData = [dict objectForKey:[NSNumber numberWithInt:i+1]];
            //NSLog(@"image type is %@",imageData.imageType);
            if ([imageData.imageType isEqualToString:@"url"]) {
                [refButton setBackgroundImageWithURL:[NSURL URLWithString:imageData.imgaeUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"pro-thumb"]];
            }
            else{
                [refButton setBackgroundImage:imageData.image forState:UIControlStateNormal];
            }
            
        }
        else{
            [refButton setBackgroundImage:[UIImage imageNamed:@"pro-thumb.png"] forState:UIControlStateNormal];
            for (UIView *view in refView.subviews) {
                if ([view isMemberOfClass:[UIView class]]) {
                    view .hidden =TRUE;
                }
            }
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker {
    
   [picker dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)imageSelectionDidFinishWithImage:(UIImage *)image{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    
    
    if (tag == 0) {
        self.profileImage.image = croppedImage;
    }else{
        
        UIView *refView = (UIView*)[self.view viewWithTag:tag];
        UIButton *refButton =(UIButton *)[refView viewWithTag:10];
        [refButton setBackgroundImage:croppedImage forState:UIControlStateNormal];
    }
    
    dispatch_queue_t concurrentQueue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if([[CMLNetworkManager sharedInstance] hasConnectivity]){
                
                CGFloat quality = 0.85;
                NSData *jpegdata = UIImageJPEGRepresentation(croppedImage,quality);
                NSString * encodedImage=[jpegdata base64Encoding];
                
                isAddingPic = TRUE;
                if(profileImageAvailable  && tag==0){
                    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
                    ;
                    [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
                    [dictionary setObject:@"profile" forKey:@"imagetype"];
                    [dictionary setObject:encodedImage forKey:@"imagecontent"];
                    [dictionary setObject:[[[profileDetailArray objectForKey:@"userImages"]objectAtIndex:0]valueForKey:@"id"] forKey:@"id"];
                    HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
                    request.delegate=self;
                    [request initwithurl:BASE_URL requestStr:UPDATEIMAGES requestType:POST input:YES inputValues:dictionary];
                }
                else if( tag >0){
                    
                    UIView *refView = (UIView*)[self.view viewWithTag:tag];
                    UIButton *refButton =(UIButton *)[refView viewWithTag:10];
                    
                    if(refButton.selected){
                        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
                        [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
                        [dictionary setObject:@"photo" forKey:@"imagetype"];
                        [dictionary setObject:encodedImage forKey:@"imagecontent"];
                        [dictionary setObject:[[[profileDetailArray objectForKey:@"userImages"]objectAtIndex:tag]valueForKey:@"id"] forKey:@"id"];
                        
                        HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
                        request.delegate=self;
                        [request initwithurl:BASE_URL requestStr:UPDATEIMAGES requestType:POST input:YES inputValues:dictionary];
                        
                    }
                    else{
                        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
                        ;
                        [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
                        [dictionary setObject:@"photo" forKey:@"imagetype"];
                        [dictionary setObject:encodedImage forKey:@"imagecontent"];
                        
                        HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
                        request.delegate=self;
                        [request initwithurl:BASE_URL requestStr:UPLOADIMAGES requestType:POST input:YES inputValues:dictionary];
                    }
                    
                }
                else{
                    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
                    ;
                    [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
                    if (tag == 0) {
                        [dictionary setObject:@"profile" forKey:@"imagetype"];
                    }
                    else{
                        [dictionary setObject:@"photo" forKey:@"imagetype"];
                    }
                    
                    [dictionary setObject:encodedImage forKey:@"imagecontent"];
                    
                    HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
                    request.delegate=self;
                    [request initwithurl:BASE_URL requestStr:UPLOADIMAGES requestType:POST input:YES inputValues:dictionary];
                }
                
            }else{
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
                [alert show];
            }
        });
    });
    
    
    
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



- (void)imagePickerController:(UIImagePickerController *) Picker

didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor:nil];
    }];
    pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
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
    if ((textView.text.length + text.length) < 90){
        return YES;
    }
    else{
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
    if(self.statusTextView.text.length == 0)
        self.placeHolder.hidden = NO;
    [self.statusTextView resignFirstResponder];
    return YES;
}
-(void) textViewDidChange:(UITextView *)textView
{
    if(self.statusTextView.text.length == 0){
        self.placeHolder.hidden = NO;
        [self.statusTextView resignFirstResponder];
    }
}

#pragma mark - UrlConnection methods
-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
    
    
}
-(void)getResponsedata:(NSDictionary *)data{
    [mbProgressHUD hide:YES];
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    NSString * code = [data objectForKey:@"code"];
    if (status) {
        if(isUpdateStatus){
            isUpdateStatus = FALSE;
            moodLabel.text=self.statusTextView.text;
            self.statusTextView.text=@"";
            self.placeHolder.hidden = NO;
        }else if (isAddingPic){
            AppDelegate *appdel=(AppDelegate *)[[UIApplication sharedApplication]delegate];
            
            [appdel.personalDetails getPrefilDetail];
            profileDetailArray=[[NSMutableDictionary alloc]initWithDictionary:data];
            [self showPics];
            //NSLog(@"pic added or edited");
        }
        else if (isDeleted){
            profileDetailArray=[[NSMutableDictionary alloc]initWithDictionary:data];
            [self showPics];
        } else {
            profileDetailArray=[[NSMutableDictionary alloc]initWithDictionary:data];
            [self setupProfilePage];
        }
    }else if ([code intValue] == 2){
        isUpdateStatus = FALSE;
        isDeleted = FALSE;
        isAddingPic = FALSE;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:[NSString stringWithFormat:@"%@",[data objectForKey:@"errors"]] delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)showPics{
    
    checkValidation1 = FALSE;
    for (int i =1; i<8; i++) {
        UIView *refView = (UIView*)[self.view viewWithTag:i];
        UIButton *refButton =(UIButton *)[refView viewWithTag:10];
        refButton.selected=NO;
        [refButton setBackgroundImage:[UIImage imageNamed:@"pro-thumb.png"] forState:UIControlStateNormal];
        for (UIView *view in refView.subviews) {
            if ([view isMemberOfClass:[UIView class]]) {
                view .hidden =TRUE;
            }
        }
    }
    __block UIActivityIndicatorView *activityIndicator;
    NSMutableArray *imageArray=[[NSMutableArray alloc]initWithArray:[profileDetailArray objectForKey:@"userImages"]];
    [imageDataArray removeAllObjects];
    for(int i=0;i<imageArray.count;i++){
        if([[[imageArray objectAtIndex:i] valueForKey:@"imagetype"] isEqualToString:@"profile"]){
            NSString *brandimgURl=[NSString stringWithFormat:@"%@%@",IMGURL,[[imageArray objectAtIndex:i] valueForKey:@"imagepath"]];
            checkValidation1=TRUE;
            
            __weak UIImageView *brandImageView = self.profileImage;
            [self.profileImage setImageWithURL:[NSURL URLWithString:brandimgURl] placeholderImage:[UIImage imageNamed:@"noimage"] options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize)
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
                 [activityIndicator removeFromSuperview];
                 activityIndicator = nil;
             }];
            profileImage.clipsToBounds = YES;
            profileImage.contentMode = UIViewContentModeScaleAspectFit;
            profileImageAvailable = TRUE;
        }
        else{
            ImageData *imageData = [[ImageData alloc]init];
            NSString *brandimgURl=[NSString stringWithFormat:@"%@%@",IMGURL,[[imageArray objectAtIndex:i] valueForKey:@"imagepath"]];
            int imgTag;
            imgTag = (checkValidation1 ==TRUE )?  i : i+1;
            UIView *refView = (UIView*)[self.view viewWithTag:imgTag];
            UIButton *refButton =(UIButton *)[refView viewWithTag:10];
            refButton.selected=YES;
//            [refButton setBackgroundImageWithURL:[NSURL URLWithString:brandimgURl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"pro-thumb"]];
            
            //MAR - Fixed for loading profile additional images
            NSURL *url = [NSURL URLWithString:brandimgURl];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:data];
            [refButton setBackgroundImage:image forState:UIControlStateNormal];
            
            
            for (UIView *view in refView.subviews) {
                if ([view isMemberOfClass:[UIView class]]) {
                    view .hidden =FALSE;
                }
            }
            imageData.hasImage = TRUE;
            imageData.imgaeUrl = brandimgURl;
            imageData.imageID = [[imageArray objectAtIndex:i]objectForKey:@"id"];
            imageData.image = nil;
            imageData.imageType = @"url";
            
            NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:imageData,[NSNumber numberWithInt:imgTag], nil ];
            [imageDataArray addObject:dict];
            
        }
    }
}


-(void)setupProfilePage{
    __block UIActivityIndicatorView *activityIndicator;
    moodLabel.text=[[profileDetailArray objectForKey:@"userDetails"]valueForKey:@"mood_message"];
    nameLabel.text=[NSString stringWithFormat:@"%@ %@",[[profileDetailArray objectForKey:@"userDetails"]valueForKey:@"firstname"],[[profileDetailArray objectForKey:@"userDetails"]valueForKey:@"lastname"]];
    NSMutableArray *imageArray=[[NSMutableArray alloc]initWithArray:[profileDetailArray objectForKey:@"userImages"]];
    
    for(int i=0;i<imageArray.count;i++){
        
        if([[[imageArray objectAtIndex:i] valueForKey:@"imagetype"] isEqualToString:@"profile"]){
            if (!checkValidation) {
                NSString *brandimgURl=[NSString stringWithFormat:@"%@%@",[profileDetailArray objectForKey:@"imagebaseurl"],[[imageArray objectAtIndex:i] valueForKey:@"imagepath"]];
                checkValidation=TRUE;
                
                __weak UIImageView *brandImageView = self.profileImage;
                [self.profileImage setImageWithURL:[NSURL URLWithString:brandimgURl] placeholderImage:[UIImage imageNamed:@"noimage"] options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize)
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
                     self.profileImage.image = [MyImage imageWithImage:self.profileImage.image convertToWidth:320 covertToHeight:250];
                     self.profileImage.contentMode = UIViewContentModeScaleAspectFit;
                     [activityIndicator removeFromSuperview];
                     activityIndicator = nil;
                 }];
                profileImage.clipsToBounds = YES;
                profileImage.contentMode = UIViewContentModeScaleAspectFit;
                profileImageAvailable = TRUE;
            }
        }
        else{
            
            
            NSString *brandimgURl=[NSString stringWithFormat:@"%@%@",[profileDetailArray objectForKey:@"imagebaseurl"],[[imageArray objectAtIndex:i] valueForKey:@"imagepath"]];
            int imgTag;
            imgTag = (checkValidation ==TRUE )?  i : i+1;
            
            ImageData *imageData = [[ImageData alloc]init];
            imageData.hasImage = TRUE;
            imageData.imgaeUrl = brandimgURl;
            imageData.imageID = [[imageArray objectAtIndex:i]objectForKey:@"id"];
            imageData.image = nil;
            imageData.imageType = @"url";
            
            NSDictionary *dict = [[NSDictionary alloc]initWithObjectsAndKeys:imageData,[NSNumber numberWithInt:imgTag], nil ];
            [imageDataArray addObject:dict];
            

            
            UIView *refView = (UIView*)[self.view viewWithTag:imgTag];
            
            for (UIView *view in refView.subviews) {
                if ([view isMemberOfClass:[UIView class]]) {
                    view .hidden =FALSE;
                    //[view setBackgroundColor:[UIColor redColor]];
                }
            }
            
            
            UIButton *refButton =(UIButton *)[refView viewWithTag:10];
            refButton.selected=YES;
//            [refButton setBackgroundImageWithURL:[NSURL URLWithString:brandimgURl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"pro-thumb"]];
//            
            //MAR - Fixed for loading profile additional images
            NSURL *url = [NSURL URLWithString:brandimgURl];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:data];
            [refButton setBackgroundImage:image forState:UIControlStateNormal];
        }
    }
    
}

-(void)sendPost:(id)sender{
    [self.statusTextView resignFirstResponder];
    if((self.statusTextView.text.length == 0 ) || ![self checkStringByRemovingSpaces:self.statusTextView.text]){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Status message should not be empty" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else{
        if([[CMLNetworkManager sharedInstance] hasConnectivity]){
            isUpdateStatus = TRUE;
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            ;
            [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
            [dictionary setObject:self.statusTextView.text forKey:@"mood_message"];
            
            [mbProgressHUD show:YES];
            HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
            request.delegate=self;
            [request initwithurl:BASE_URL requestStr:UPDATEMOODMESSAGE requestType:POST input:YES inputValues:dictionary];
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

-(BOOL)checkStringByRemovingSpaces:(NSString*)string{
    NSString * checkString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (checkString.length < 1)
        return FALSE;
    else
        return TRUE;
}
#pragma mark - PSV delegate
-(void)setProfileImageWithSelctionImageData:(ImageData *)data{
    
    [psc.navigationController popViewControllerAnimated:YES];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
    [dictionary setObject:data.imageID forKey:@"image_id"];
    isAddingPic = TRUE;
    HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
    request.delegate=self;
    [request initwithurl:BASE_URL requestStr:@"Setprofileimage" requestType:POST input:YES inputValues:dictionary];
    
    
}

@end
