//
//  ChatViewController.h
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 29/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "HTTPURLRequest.h"
#import "WEPopoverContentViewControllers.h"
#import "WEPopoverController.h"
#import "ASIFormDataRequest.h"
@import MediaPlayer;

typedef enum {
    ActionThumnailPlay = 1,
    ActionThumnailUpload = 2,
    ActionThumbnailDownload = 3
} ActionThumbnail;


@interface ChatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,HTTPURLRequestDelegate,WEPopoverControllerDelegate,WEPopoverContentDelegates, UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate, UIGestureRecognizerDelegate,UIActionSheetDelegate>
{
    BOOL isChangePic;
}
@property(weak,nonatomic)IBOutlet UILabel *placeHolder;
@property(weak,nonatomic)IBOutlet UITextView *messageView;
@property(weak,nonatomic)IBOutlet UITableView *buzzList;
@property(retain,nonatomic)NSString *receiverId;
@property(retain,nonatomic)NSString *receiverImageUrl;
@property(retain,nonatomic)UIImage *receiverImage;
@property(retain,nonatomic)UIImage *myProfileImage;
@property(retain,nonatomic)IBOutlet UIButton *profileImageButton;
@property(retain,nonatomic)IBOutlet UILabel *name;
@property(retain,nonatomic)NSString *nameString;
@property(assign,nonatomic)BOOL isFromMessage;
@property(assign,nonatomic)BOOL isNotified;
@property(strong,nonatomic)NSString *imageUrl;
@property(assign,nonatomic)BOOL isNeededToRemoveNavBar;
@property(retain,nonatomic)NSString *IsGroup;

@property (strong, nonatomic) IBOutlet UIButton *InputImage;
@property (strong, nonatomic) IBOutlet UITableView *myTable;
@property (nonatomic, strong) WEPopoverController *popoverController;
@property (retain, strong) NSMutableData *messageData;

- (IBAction)ToggleKeyboard:(id)sender;
-(IBAction)sendMessage:(id)sender;
- (IBAction)sendPicture:(id)sender;

-(void)UploadCompleted: (UIView *)targetView withOldData:(NSDictionary *)oldDict withNewData:(NSDictionary *) newDict;
-(void)UploadCompleted: (UIView *)targetView withOldData:(NSDictionary *)oldDict withNewData:(NSDictionary *) newDict withThumbnail:(ActionThumbnail)thumbnail;

@end
