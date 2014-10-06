//
//  SettingsViewController.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 20/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "ProfileViewController.h"
#import "AccountViewController.h"
#import "FilterSettingViewController.h"
#import "FeedbackViewController.h"
#import "AppInfoViewController.h"
#import "SetInvisibleUser.h"
#import "updateUserProfile.h"
#import "SBJSON.h"
#import "GAI.h"
#import "HorseBuzzConfig.h"

@interface SettingsViewController (){
    UIButton *eyeButton;
    AppDelegate *appdel;
    BOOL isAppStoreURL;
    NSString *AppStoreURL;
}
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSArray *menuImages;
@end

@implementation SettingsViewController
@synthesize settingsList,menuItems,menuImages;

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
    //[tracker trackView:@"Horse Buzz - Settings view"];
    [tracker set:@"ScreenName" value:@"Horse Buzz - Settings view" ];
    // google tracking code end
    
    [super viewDidLoad];
    
//    isAppStoreURL=TRUE;
    //get App store url for this product
//    HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
//    request.delegate=self;
//    [request initwithurl:BASE_URL requestStr:APPSETTINGS requestType:GET input:NO inputValues:nil];
    
    AppStoreURL = @"https://itunes.apple.com/us/app/horse-buzz/id871088313?ls=1&mt=8";
    
    // Do any additional setup after loading the view from its nib.
    self.title = @"Settings";
    
    //declare appdelegate
    appdel = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"menu_icon.png"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 24, 17);
    [menuButton addTarget:self action:@selector(DismisSttings) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    eyeButton.frame = CGRectMake(0, 0, 19, 19);
    [eyeButton addTarget:self action:@selector(setVisibilty) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *eyeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:eyeButton];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    self.navigationItem.rightBarButtonItem = eyeButtonItem;
    menuItems = [NSArray arrayWithObjects:@"Profile",@"Account",@"Filters",@"Update Profile",@"App Share",@"AppInfo",@"Feedback",@"Logout", nil];
    menuImages=[NSArray arrayWithObjects:@"profile_sett",@"account-set-icon",@"filter-set-icon",@"profile_sett",@"share-icon",@"appinfo_sett",@"feedback",@"logout",nil];
    if ([settingsList respondsToSelector:@selector(setSeparatorInset:)]) {
        [settingsList setSeparatorInset:UIEdgeInsetsZero];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"isInvisible"]){
        [eyeButton setImage:[UIImage imageNamed:@"eye-show"] forState:UIControlStateNormal];
    }
    else{
        [eyeButton setImage:[UIImage imageNamed:@"eye-hide"] forState:UIControlStateNormal];
    }
}
-(void)DismisSttings{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate removeSettings];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
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
#pragma mark - TableView Delegate methods.
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    //  return self.peopleList.count;
    return [self.menuItems count];
    
    
    
    
    
    
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"newCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView * accessoryView  =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"leftmenu_arrow"]];
        accessoryView.frame = CGRectMake(290, 15, 7, 12);
        [cell.contentView addSubview:accessoryView];
    }
    cell.textLabel.text = [self.menuItems objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[self.menuImages objectAtIndex:indexPath.row]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"indexPath.row%d",indexPath.row);
    switch (indexPath.row) {
        case 0:{
            ProfileViewController *profileViewController = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil ];
            [self.navigationController pushViewController:profileViewController animated:YES];
        }
            break;
        case 1:{
            AccountViewController *accountViewController = [[AccountViewController alloc]initWithNibName:@"AccountViewController" bundle:nil ];
            [self.navigationController pushViewController:accountViewController animated:YES];
        }
            break;
        case 2:{
            FilterSettingViewController *profileViewController = [[FilterSettingViewController alloc]initWithNibName:@"FilterSettingViewController" bundle:nil ];
            [self.navigationController pushViewController:profileViewController animated:YES];
        }
            break;
        case 3:{
            updateUserProfile *update = [[updateUserProfile alloc]initWithNibName:@"updateUserProfile" bundle:nil ];
            [self.navigationController pushViewController:update animated:YES];
        }
            break;
        case 4:{
            shareView.hidden = NO;
            [self.view addSubview:shareView];
        }
            break;
        case 5:{
            AppInfoViewController *appInfo = [[AppInfoViewController alloc]initWithNibName:@"AppInfoViewController" bundle:nil ];
            [self.navigationController pushViewController:appInfo animated:YES];
        }
            break;
        case 6:{
            FeedbackViewController *profileViewController = [[FeedbackViewController alloc]initWithNibName:@"FeedbackViewController" bundle:nil ];
            [self.navigationController pushViewController:profileViewController animated:YES];
        }
            break;
        case 7:{
            UIAlertView *Alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Are you sure you want to log out?" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil];
            Alert.tag=100;
            [Alert show];
        }
            break;
            
        default:
            break;
    }
    
}
#pragma mark - UrlConnection methods
-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
    
}
-(void)getResponsedata:(NSDictionary *)data{
    
    if (isAppStoreURL) {
        AppStoreURL = [NSString stringWithFormat:@"%@",[data objectForKey:@"appURL"]];
    }
    
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    NSString * code = [data objectForKey:@"code"];
    if (status) {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"isLogin"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        AppDelegate *delagate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delagate setSplashView];
    }else if ([code intValue] == 2){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:[NSString stringWithFormat:@"%@",[data objectForKey:@"errors"]] delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==100 && buttonIndex==0){
        if([[CMLNetworkManager sharedInstance] hasConnectivity]){
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
            
            isAppStoreURL=FALSE;
            HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
            request.delegate=self;
            [request initwithurl:BASE_URL requestStr:LOGOUT requestType:POST input:YES inputValues:dictionary];
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

-(IBAction)facebookButton:(id)sender {
    
    float version =  [[[UIDevice currentDevice] systemVersion]floatValue];
    if (version < 6.0) {
        if (![appdel.facebook isSessionValid]) {
            [appdel.facebook authorize:appdel.permissions];
            appdel.facebook.sessionDelegate = self;
        }
        else {
            [self postInFacebook];
        }
    }
    
    else{
        
        SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        {
            SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
                
                [fbController dismissViewControllerAnimated:YES completion:nil];
                
                switch(result){
                    case SLComposeViewControllerResultCancelled:
                    default:
                    {
                        //NSLog(@"Cancelled.....");
                        
                    }
                        break;
                    case SLComposeViewControllerResultDone:
                    {
                        //NSLog(@"Posted....");
                    }
                        break;
                }};
            
            [fbController addImage:[UIImage imageNamed:@"AppIcon76x76@2x.png"]];
            [fbController setInitialText:@""];
            //app itunes url
            [fbController addURL:[NSURL URLWithString:AppStoreURL]];
            [fbController setInitialText:@"Horse Buzz is the newest way to enjoy social networking with others who share your passion for the love of the horse!             \n\nPlease visit us at http://app.horsebuzz.com/ to learn more\n\n"];
            [fbController setCompletionHandler:completionHandler];
            [self presentViewController:fbController animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Sorry"
                                      message:@"You can't send a post right now, make sure your device has an internet connection and you have at least one Facebook account setup"
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
}

-(IBAction)twitterButton:(id)sender {
    
    if ([TWTweetComposeViewController canSendTweet]){
        
        TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
        [tweetSheet addImage:[UIImage imageNamed:@"AppIcon76x76@2x.png"]];
        
        //Apple itunes link
//        [tweetSheet addURL:[NSURL URLWithString:AppStoreURL]];
        [tweetSheet setInitialText:@"HorseBuzz is the new way to share your passion for the love of the horse. Visit http://app.horsebuzz.com to learn more."];

        tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result){
            [self dismissModalViewControllerAnimated:YES];
        };
        
        [self presentModalViewController:tweetSheet animated:YES];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

-(IBAction)emailButton:(id)sender {
    
    [mailComposer setMailComposeDelegate:self];
    if ([MFMailComposeViewController canSendMail]) {
        mailComposer = [[MFMailComposeViewController alloc]init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setSubject:@"Horse Buzz"];
        [mailComposer setToRecipients:[NSArray arrayWithObject:@""]];
        [mailComposer setMessageBody:@"Horse Buzz is the newest way to enjoy social networking with others who share your passion for the love of the horse!             \nPlease visit us at http://app.horsebuzz.com/ to learn more. \n" isHTML:NO];
        [self presentModalViewController:mailComposer animated:YES];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    if (result) {
        //NSLog(@"Result : %d",result);
    }
    if (error) {
        //NSLog(@"Error : %@",error);
    }
    [self dismissModalViewControllerAnimated:YES];
    
}


- (void)postInFacebook{
    NSString *name = @"Horse Buzz";
    NSString *href = AppStoreURL;
    NSString *description = @"Avoid that devastating feeling of having your iPhone/iPad stolen! ";
    NSString *imageSource = AppStoreURL;
    
    NSString *imageHref = AppStoreURL;
    NSString *linkTitle = @"Download at";
    NSString *linkText = AppStoreURL;
    NSString *linkHref = AppStoreURL;
    SBJSON *jsonWriter = [SBJSON new] ;
    
    NSString *att  = [NSString stringWithFormat:@"{ \"name\":\"%@\","
                      "\"href\":\"%@\","
                      "\"description\":\"%@\","
                      "\"media\":[{\"type\":\"image\","
                      "\"src\":\"%@\","
                      "\"href\":\"%@\"}],"
                      "\"properties\":{\" %@\":{\"text\":\"%@\",\"href\":\"%@\"}, \"\":\"!\"}}", name, href, description, imageSource, imageHref, linkTitle, linkText,linkHref];
    NSMutableDictionary *attachment = [NSMutableDictionary dictionaryWithObject:att forKey:@"attachment"];
    [jsonWriter stringWithObject:att];
    [appdel.facebook dialog:@"facebook.stream.publish" andParams:attachment andDelegate:self];
}

-(IBAction)closeButton:(id)sender {
    shareView.hidden = YES;
}

@end
