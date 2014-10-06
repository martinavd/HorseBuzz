//
//  GroupchatController.m
//  HorseBuzz
//
//  Created by Welcome on 05/09/14.
//  Copyright (c) 2014 ggau. All rights reserved.
//

#import "GroupchatController.h"
#import "AddParticipantViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "HorseBuzzConfig.h"
#import "HorseBuzzDataManager.h"
#import "CMLNetworkManager.h"
#import "SBJsonWriter.h"
#import "AppDelegate.h"
#import "MyImage.h"
#import "MBProgressHUD.h"
#import "SetInvisibleUser.h"
#import "PersonalDetail.h"
#import "GAI.h"
#import "ImageData.h"
#import "NSString+Utils.h"
#import "AddParticipantViewController.h"

@interface GroupchatController ()
{
    BOOL isChangePic;
}
@end

@implementation GroupchatController
@synthesize groupName;

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
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    UIButton *btnCreate = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    [btnCreate setTitle:@"Next" forState:UIControlStateNormal];
    [btnCreate addTarget:self action:@selector(doNext) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarbutton = [[UIBarButtonItem alloc] initWithCustomView:btnCreate];
    self.navigationItem.rightBarButtonItem = rightBarbutton;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)doNext
{
    if (groupName.text.length==0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"HorseBuzz" message: @"Group name can't be empty!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
//    if ([addImage.currentImage isEqual:[UIImage imageNamed:@"pro-thumb.png"]]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"HorseBuzz" message: @"Group profile image can't be empty!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//        return;
//    }
    AddParticipantViewController *addParticipantscontroller=[[AddParticipantViewController alloc]initWithNibName:@"AddParticipantViewController" bundle:nil];
    
    if (addImage.imageView.image) {
        addParticipantscontroller.profileImage = addImage.imageView.image;
        
    }
    addParticipantscontroller.groupName = groupName.text;
    [self.navigationController pushViewController:addParticipantscontroller animated:YES];
    
}

-(IBAction)next:(id)sender
{
     AddParticipantViewController *addParticipantscontroller=[[AddParticipantViewController alloc]initWithNibName:@"AddParticipantViewController" bundle:nil];
    
    if (addImage.imageView.image) {
         addParticipantscontroller.profileImage = addImage.imageView.image;
        
    }
    addParticipantscontroller.groupName = groupName.text;
    [self.navigationController pushViewController:addParticipantscontroller animated:YES];
}

-(IBAction)addPic:(id)sender{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:@"Choose your image SourceType." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Album",@"Camera", nil];
    alert.tag = 101;
    [alert show];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
   
    if (buttonIndex == 1) {
        pickerCtrl = [[UIImagePickerController alloc] init];
        pickerCtrl.delegate = self;
        pickerCtrl.allowsEditing = NO;
        pickerCtrl.mediaTypes = [NSArray arrayWithObjects:
                                 (NSString *) kUTTypeImage,
                                 nil];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            pickerCtrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            pickerCtrl.allowsImageEditing = YES;
           
        }
        [self presentModalViewController:pickerCtrl animated:YES];
    }else if (buttonIndex == 2){
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
-(void)imagePickerController:(UIImagePickerController *)picker
      didFinishPickingImage : (UIImage *)image
                 editingInfo:(NSDictionary *)editingInfo
{
[addImage setImage:image forState:UIControlStateNormal];
		[picker dismissModalViewControllerAnimated:YES];
}


@end
