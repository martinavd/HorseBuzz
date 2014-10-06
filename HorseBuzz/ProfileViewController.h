//
//  ProfileViewController.h
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 20/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import  <MobileCoreServices/MobileCoreServices.h>
#import "HTTPURLRequest.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIButton+WebCache.h>

@interface ProfileViewController : UIViewController<UITextViewDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate,HTTPURLRequestDelegate> {
}
@property(nonatomic,weak)IBOutlet UIScrollView *scrollView;
@property(nonatomic,weak)IBOutlet UILabel *placeHolder;
@property(nonatomic,weak)IBOutlet UITextView *statusTextView;
@property(nonatomic,weak)IBOutlet UIImageView *profileImage;
@property(nonatomic,weak)IBOutlet UILabel *moodLabel;
@property(nonatomic,weak)IBOutlet UILabel *nameLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isMenuView:(BOOL)isMenu;
-(IBAction)setProfilePic:(id)sender;
-(IBAction)addPic:(id)sender;
-(IBAction)sendPost:(id)sender;
-(IBAction)DeletePic:(id)sender;
-(IBAction)ChangePic:(id)sender;

@end
