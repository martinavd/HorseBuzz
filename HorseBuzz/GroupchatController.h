//
//  GroupchatController.h
//  HorseBuzz
//
//  Created by Welcome on 05/09/14.
//  Copyright (c) 2014 ggau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "HTTPURLRequest.h"
#import "WEPopoverContentViewControllers.h"
#import "WEPopoverController.h"
#import "PECropViewController.h"

#import "HorseBuzzConfig.h"
@interface GroupchatController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,PECropViewControllerDelegate,HTTPURLRequestDelegate>
{
      UIImagePickerController *pickerCtrl;
      UIImage *pickedImage;
      BOOL  IsImageUpload;
    IBOutlet UIButton *addImage;
}
@property (strong, nonatomic) IBOutlet UITextField *groupName;

-(IBAction)next:(id)sender;
@property(nonatomic,retain) UIButton *takePictureButton;
@property(nonatomic,retain) UIButton *selectFromCameraRollButton;

@end
