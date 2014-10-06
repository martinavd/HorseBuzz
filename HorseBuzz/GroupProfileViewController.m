#import "GroupProfileViewController.h"
#import "AddParticipantViewController.h"
#import "HorseBuzzConfig.h"
#import "HTTPURLRequest.h"
#import "HorseBuzzDataManager.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AddBuddiesCell.h"
#import "EGORefreshTableHeaderView.h"
#import "GAI.h"
#import "CMLNetworkManager.h"
#import "MBProgressHUD.h"
#import "SetInvisibleUser.h"

@interface GroupProfileViewController (){
    BOOL checkSearch;
    NSMutableArray *responseArray;
    MBProgressHUD *mbProgressHUD;
    BOOL checkONLoad;
    UIButton *eyeButton;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    BOOL IsCreateGroup;
    
    UIButton *btnCreate;
    UIImagePickerController *pickerCtrl;
    NSString *GroupAdmin;
    NSString *loggedUser;
}
@end



@implementation GroupProfileViewController
@synthesize getGroupId;
@synthesize getGroupName;
@synthesize getProfileImage;
@synthesize getParticipant;
@synthesize participants;
@synthesize buttonText;

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
    
    _groupName.text=getGroupName;
    //_profileImage.image=getProfileImage;
    [_profileImage setImage:getProfileImage];
    UITapGestureRecognizer *newTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectProfileImage:)];
    [_profileImage setUserInteractionEnabled:YES];
    [_profileImage addGestureRecognizer:newTap];
    GroupAdmin=[[getParticipant objectAtIndex:0] valueForKey:@"groupAdmin"];
    loggedUser=[HorseBuzzDataManager sharedInstance].userId;
    
    [super setEditing:YES animated:NO];
    [participants setEditing:YES animated:NO];
    btnCreate = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [btnCreate setTitle:buttonText forState:UIControlStateNormal];
    [btnCreate addTarget:self action:@selector(CreateGroup) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarbutton = [[UIBarButtonItem alloc] initWithCustomView:btnCreate];
    self.navigationItem.rightBarButtonItem = rightBarbutton;
    
    
    UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(CancelGroupCreation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarbutton=[[UIBarButtonItem alloc] initWithCustomView:btnCancel];
    self.navigationItem.leftBarButtonItem = leftBarbutton;
    
    if([GroupAdmin isEqualToString:loggedUser] || !GroupAdmin){
        _btnParticipant.hidden=NO;
    }
    else{
        _btnParticipant.hidden=YES;
        [btnCreate setHidden:YES];
    }
    if([buttonText isEqualToString:@"Create"]){
        _btnDeleteExitGroup.hidden=YES;
    }
    
    mbProgressHUD = [[MBProgressHUD alloc]initWithView:self.view];
    [mbProgressHUD setMode:MBProgressHUDModeIndeterminate];
    [self.view addSubview:mbProgressHUD];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
  
}

-(void)selectProfileImage:(UITapGestureRecognizer *)gr{
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:@"Choose your image SourceType." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Picture",@"Camera", nil];
    [alert show];
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
            
        }
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
        //isChangePic = FALSE;
    }
}


#pragma mark - UIImagePicker delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        _profileImage.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        getProfileImage=_profileImage.image;
    }
}

#pragma mark -
#pragma mark - Tableview

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *groupMembers=@"Participants";
    
    return groupMembers;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([getParticipant count]>0)
        return getParticipant.count;
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@%d", simpleTableIdentifier,indexPath.row]];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%@%d", simpleTableIdentifier,indexPath.row]];
    }
    
    NSArray *viewsToRemove = [cell.contentView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    NSString *groupAdmin=[[getParticipant objectAtIndex:indexPath.row] valueForKey:@"groupAdmin"];
    NSString *userID=[[getParticipant objectAtIndex:indexPath.row] valueForKey:@"id"];
    
    UILabel *participantNamelabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0,145,50)];
    participantNamelabel.text=[NSString  stringWithFormat:@"%@ %@"
                               ,[[getParticipant objectAtIndex:indexPath.row] valueForKey:@"firstname"]
                               ,[[getParticipant objectAtIndex:indexPath.row] valueForKey:@"lastname"]
                               ];;
    //participantNamelabel.textAlignment=UITextAlignmentCenter;
    participantNamelabel.font=[UIFont systemFontOfSize:17.0];
    
    
    //participantNamelabel.textColor=[UIColor blackColor];
    
    
    [cell.contentView addSubview:participantNamelabel];

    
    if([groupAdmin isEqualToString:userID])
    {
        UILabel *grpAdminLabel=[[UILabel alloc] initWithFrame:CGRectMake(190, 10,70,25)];
        grpAdminLabel.text=@"Admin";
        grpAdminLabel.textAlignment=UITextAlignmentCenter;
        grpAdminLabel.font=[UIFont boldSystemFontOfSize:9.0];
        grpAdminLabel.layer.cornerRadius=6;
        grpAdminLabel.layer.borderColor=[UIColor colorWithRed:0.0/255 green:128.0/255 blue:0.0/255 alpha:1].CGColor;
        grpAdminLabel.textColor=[UIColor colorWithRed:0.0/255 green:128.0/255 blue:0.0/255 alpha:1];
        grpAdminLabel.layer.borderWidth=1.0;       
       
        [cell.contentView addSubview:grpAdminLabel];
    }
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
   
    NSString *userID=[[getParticipant objectAtIndex:indexPath.row] valueForKey:@"id"];
    
    if([GroupAdmin isEqualToString:userID])
    {
        return UITableViewCellEditingStyleNone;
      
    }
    if([GroupAdmin isEqualToString:loggedUser])
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
        
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle==UITableViewCellEditingStyleDelete){
        [self.getParticipant removeObjectAtIndex:indexPath.row];
        
        [self.participants reloadData];
    }
    
}

#pragma mark -
#pragma mark - Button Events

- (BOOL)checkImage:(UIImage *)image1 isEqualTo:(UIImage *)image2
{
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    //NSLog(@"%@",[data1 isEqual:data2]?@"YES":@"NO");
    return [data1 isEqual:data2];
}

- (void)CreateGroup
{
    [btnCreate setEnabled:NO];
    
    if ([self checkImage:getProfileImage isEqualTo:[UIImage imageNamed:@"pro-thumb"]]) {
        getProfileImage = [UIImage imageNamed:@"noimage"];
    }
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
    if([buttonText isEqual:@"Update"])
    {
        [dictionary setObject:getGroupId forKey:@"id"];
    }
    [dictionary setObject:getGroupName forKey:@"group_name"];
    [dictionary setObject:@"1" forKey:@"is_group"];
    if(getProfileImage){
        CGFloat quality = 0.85;
        NSData *jpegdata = UIImageJPEGRepresentation(getProfileImage,quality);
        NSString * encodedImage=[jpegdata base64Encoding];
        [dictionary setObject:encodedImage forKey:@"profileImage"];
        }
    
            NSMutableArray *buddieslist = [[NSMutableArray alloc]init];
            for (NSDictionary *selectedUser in getParticipant) {
                NSMutableDictionary *recepient = [[NSMutableDictionary alloc] init];
                [recepient setObject:[selectedUser objectForKey:@"userid"] forKey:@"user_id"];
                [buddieslist addObject:recepient];
            }
            [dictionary setObject:buddieslist forKey:@"buddieslist"];
            IsCreateGroup = YES;
    
    
    [mbProgressHUD show:YES];
    HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
    request.delegate=self;
    if([buttonText isEqual:@"Update"])
    {
         [request initwithurl:BASE_URL requestStr:UPDATEGROUP requestType:POST input:YES inputValues:dictionary];
    }
    else{
     [request initwithurl:BASE_URL requestStr:CREATGROUP requestType:POST input:YES inputValues:dictionary];
    }
   
}

-(void)CancelGroupCreation{

    //[self doneLoadingTableViewData];
    [mbProgressHUD hide:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)btnParticipant:(id)sender {
     AddParticipantViewController *addparticipantcontroller=[[AddParticipantViewController alloc]initWithNibName:@"AddParticipantViewController" bundle:nil];
    
    addparticipantcontroller.groupName=_groupName.text;
    addparticipantcontroller.profileImage=_profileImage.image;
    addparticipantcontroller.participantlist=getParticipant;
    if([buttonText isEqual:@"Update"])
    {
        addparticipantcontroller.groupId=getGroupId;
    }
    [self.navigationController pushViewController:addparticipantcontroller animated:YES];
}

- (IBAction)btnDeleteExitGroup:(id)sender
{
    [mbProgressHUD show:YES];
    HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
    request.delegate=self;
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    IsCreateGroup=YES;
    if([GroupAdmin isEqualToString:loggedUser])
    {
        [dictionary setObject:getGroupId forKey:@"id"];
        [request initwithurl:BASE_URL requestStr:DELETEGROUP requestType:POST input:YES inputValues:dictionary];
    }
    else{
        [dictionary setObject:loggedUser forKey:@"user_id"];
        [dictionary setObject:getGroupId forKey:@"user_group_id"];
        [request initwithurl:BASE_URL requestStr:UNJOINGROUP requestType:POST input:YES inputValues:dictionary];
        
    }

    
}



-(void)getResponsedata:(NSDictionary *)data{
    [self doneLoadingTableViewData];
    [mbProgressHUD hide:YES];
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    
    if (IsCreateGroup) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    NSString * code = [data objectForKey:@"code"];
    if (status) {
        responseArray=[[NSMutableArray alloc]initWithArray:[data objectForKey:@"nearestfriends"]];
        [self.participants reloadData];
        
    }else if ([code intValue] == 2){
        [responseArray removeAllObjects];
        [self.participants reloadData];
    }

    
}
- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.participants];
}
-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
    
}
@end


