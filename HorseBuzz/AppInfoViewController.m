//
//  AppInfoViewController.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 20/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "AppInfoViewController.h"
#import "SetInvisibleUser.h"
#import "GAI.h"
#import "HorseBuzzConfig.h"

@interface AppInfoViewController (){
    UIButton *eyeButton;
}

@end

@implementation AppInfoViewController
@synthesize infoView;
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
    //[tracker trackView:@"Horse Buzz - Appinfo view"];
    [tracker set:@"ScreenName" value:@"Horse Buzz - Appinfo view"];
    // google tracking code end
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"App Info";
    self.infoView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"appinfo-bg"]];
    float version = [[[UIDevice currentDevice] systemVersion]floatValue];
    if (version >= 7.0) {
        self.navigationItem.hidesBackButton =FALSE;
    }else{
        UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0,85, 20);
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
    
    UILabel *aboutLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 299, 20)];
    aboutLabel.text = @"About";
    aboutLabel.textAlignment = UITextAlignmentCenter;
    aboutLabel.backgroundColor=[UIColor clearColor];
    aboutLabel.textColor = [UIColor whiteColor];
    aboutLabel.font=[UIFont systemFontOfSize:18];
    
    [appInfoScrollView addSubview:aboutLabel];
    
    UITextView *textView=[[UITextView alloc]initWithFrame:CGRectMake(5, 20, 299, 210)];
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor whiteColor];
    textView.font = [UIFont systemFontOfSize:14];
    textView.editable=NO;
    textView.userInteractionEnabled=NO;
    
    textView.text = @"When signing up with Horse Buzz, you are joining one of the largest Equestrian communities in the world.\n\nYou can chat to friends, upload photos & explore other countries making contact with fellow equestrian enthusiasts.\n\nHorse Buzz is the newest way to enjoy social networking with others who share your passion for the love of the horse!\n";
    [appInfoScrollView addSubview:textView];
    
    float heightOfText=textView.contentSize.height+20;
    
    UILabel *knowYourApp = [[UILabel alloc]initWithFrame:CGRectMake(5, heightOfText, 299, 20)];
    knowYourApp.text = @"Know your App";
    knowYourApp.textAlignment = UITextAlignmentCenter;
    knowYourApp.backgroundColor=[UIColor clearColor];
    knowYourApp.textColor = [UIColor whiteColor];
    knowYourApp.font=[UIFont systemFontOfSize:18];
    
    [appInfoScrollView addSubview:knowYourApp];
    
    heightOfText=(knowYourApp.frame.origin.y+20);
    
    UILabel *homeLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, heightOfText, 299, 20)];
    homeLabel.text = @"Home Screen";
    homeLabel.textAlignment = UITextAlignmentLeft;
    homeLabel.backgroundColor=[UIColor clearColor];
    homeLabel.textColor = [UIColor whiteColor];
    homeLabel.font=[UIFont systemFontOfSize:16];
    [appInfoScrollView addSubview:homeLabel];
    
    NSMutableArray *arrayDecription = [[NSMutableArray alloc]initWithObjects:@"New? Sign Up – Lets you sign up as a new user for the app",@"Sign in – Registered user can sign in with his/her credentials", nil];
    NSMutableArray *arrayImage = [[NSMutableArray alloc]initWithObjects:@"create_ac@2x",@"login_icon@2x", nil];
    
    heightOfText = homeLabel.frame.origin.y + 20;
    float heightOfFullText =0;
    
    for (int i=0; i < 2; i++) {
        
        float height1 = (heightOfText+18)+(i*60);
        float height2 = heightOfText+(i*60);
        
        UIImageView *imgForLbl = [[UIImageView alloc]initWithFrame:CGRectMake(10, height1, 26, 26)];
        imgForLbl.image = [UIImage imageNamed:[arrayImage objectAtIndex:i]];
        imgForLbl.contentMode = UIViewContentModeScaleAspectFit;
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(50, height2, 245, 60)];
        lbl.text = [arrayDecription objectAtIndex:i];
        lbl.textAlignment = UITextAlignmentLeft;
        lbl.backgroundColor=[UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.font=[UIFont systemFontOfSize:14];
        lbl.numberOfLines = 10;
        lbl.lineBreakMode = NO;
        
        [appInfoScrollView addSubview:imgForLbl];
        [appInfoScrollView addSubview:lbl];
        
        heightOfFullText = lbl.frame.size.height + lbl.frame.origin.y;
    }
    
    UILabel *topMenuLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, heightOfFullText, 299, 20)];
    topMenuLabel.text = @"Top Menu";
    topMenuLabel.textAlignment = UITextAlignmentLeft;
    topMenuLabel.backgroundColor=[UIColor clearColor];
    topMenuLabel.textColor = [UIColor whiteColor];
    topMenuLabel.font=[UIFont systemFontOfSize:16];
    [appInfoScrollView addSubview:topMenuLabel];
    
    NSMutableArray *arrayDecription1 = [[NSMutableArray alloc]initWithObjects:@"Settings icon – Lets you manage all your app and user settings",@"Eye icon – Turn yourself visible",@"Eye icon – Turn yourself invisible",@"Filter icon – Search for users based on your interests/preferences", nil];
    NSMutableArray *arrayImage1 = [[NSMutableArray alloc]initWithObjects:@"setting@2x",@"eye-show@2x",@"eye-hide@2x",@"filtericon@2x", nil];
    
    heightOfText = heightOfFullText + 20;
    
    for (int i=0; i < 4; i++) {
        
        float height1 = (heightOfText+18)+(i*60);
        float height2 = heightOfText+(i*60);
        
        UIImageView *imgForLbl = [[UIImageView alloc]initWithFrame:CGRectMake(10, height1, 26, 26)];
        imgForLbl.image = [UIImage imageNamed:[arrayImage1 objectAtIndex:i]];
        imgForLbl.contentMode = UIViewContentModeScaleAspectFit;
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(50, height2, 245, 60)];
        lbl.text = [arrayDecription1 objectAtIndex:i];
        lbl.textAlignment = UITextAlignmentLeft;
        lbl.backgroundColor=[UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.font=[UIFont systemFontOfSize:14];
        lbl.numberOfLines = 10;
        lbl.lineBreakMode = NO;
        
        [appInfoScrollView addSubview:imgForLbl];
        [appInfoScrollView addSubview:lbl];
        
        heightOfFullText = lbl.frame.size.height + lbl.frame.origin.y;
    }
    
    UILabel *bottomMenuLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, heightOfFullText, 299, 20)];
    bottomMenuLabel.text = @"Bottom Menu";
    bottomMenuLabel.textAlignment = UITextAlignmentLeft;
    bottomMenuLabel.backgroundColor=[UIColor clearColor];
    bottomMenuLabel.textColor = [UIColor whiteColor];
    bottomMenuLabel.font=[UIFont systemFontOfSize:16];
    [appInfoScrollView addSubview:bottomMenuLabel];
    
    NSMutableArray *arrayDecription2 = [[NSMutableArray alloc]initWithObjects:@"Near By – This lists all the users, with your profile displaying first and the other users, starting with the person closest to you",@"Buzz – Displays ‘New Riders’, who have recently joined the app, and ‘Who viewed my profile’, with users who have viewed your profile",@"Chats – Displays the recent chats. Click on the user to start chatting",@"Current location icon – Takes to back to your current location",@"Favourites - Lists your favourites", nil];
    NSMutableArray *arrayImage2 = [[NSMutableArray alloc]initWithObjects:@"tab_nearby@2x",@"tab_buzz@2x",@"pro-chat@2x",@"location@2x",@"favorite@2x", nil];
    
    heightOfText = heightOfFullText + 20;
    
    for (int i=0; i < 5; i++) {
        
        float height1 = (heightOfText+18)+(i*60);
        float height2 = heightOfText+(i*60);
        
        UIImageView *imgForLbl = [[UIImageView alloc]initWithFrame:CGRectMake(10, height1, 26, 26)];
        imgForLbl.image = [UIImage imageNamed:[arrayImage2 objectAtIndex:i]];
        imgForLbl.contentMode = UIViewContentModeScaleAspectFit;
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(50, height2, 245, 60)];
        lbl.text = [arrayDecription2 objectAtIndex:i];
        lbl.textAlignment = UITextAlignmentLeft;
        lbl.backgroundColor=[UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.font=[UIFont systemFontOfSize:14];
        lbl.numberOfLines = 10;
        lbl.lineBreakMode = NO;
        
        [appInfoScrollView addSubview:imgForLbl];
        [appInfoScrollView addSubview:lbl];
        
        heightOfFullText = lbl.frame.size.height + lbl.frame.origin.y;
    }
    
    UILabel *profileViewLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, heightOfFullText, 299, 20)];
    profileViewLabel.text = @"Profile Screen";
    profileViewLabel.textAlignment = UITextAlignmentLeft;
    profileViewLabel.backgroundColor=[UIColor clearColor];
    profileViewLabel.textColor = [UIColor whiteColor];
    profileViewLabel.font=[UIFont systemFontOfSize:16];
    [appInfoScrollView addSubview:profileViewLabel];
    
    NSMutableArray *arrayDecription3 = [[NSMutableArray alloc]initWithObjects:@"Scroll up/down to see images of the user",@"Scroll left/right to see other user profiles",@"Click on the profile image to see details of user", nil];
    
    heightOfText = heightOfFullText + 20;
    
    for (int i=0; i < 3; i++) {
        
        float height2 = heightOfText+(i*40);
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(15, height2, 245, 40)];
        lbl.text = [arrayDecription3 objectAtIndex:i];
        lbl.textAlignment = UITextAlignmentLeft;
        lbl.backgroundColor=[UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.font=[UIFont systemFontOfSize:14];
        lbl.numberOfLines = 10;
        lbl.lineBreakMode = NO;
        
        [appInfoScrollView addSubview:lbl];
        
        heightOfFullText = lbl.frame.size.height + lbl.frame.origin.y;
    }
    
    NSMutableArray *arrayDecription4 = [[NSMutableArray alloc]initWithObjects:@"Chat icon – Lets you chat with the user",@"Favourites icon – Lets you add the user to your favourites list",@"Block icon – Lets you block the user", nil];
    NSMutableArray *arrayImage4 = [[NSMutableArray alloc]initWithObjects:@"pro-chat@2x",@"favorite@2x",@"white_block@2x", nil];
    
    heightOfText = heightOfFullText;
    
    for (int i=0; i < 3; i++) {
        
        float height1 = (heightOfText+18)+(i*60);
        float height2 = heightOfText+(i*60);
        
        UIImageView *imgForLbl = [[UIImageView alloc]initWithFrame:CGRectMake(10, height1, 26, 26)];
        imgForLbl.image = [UIImage imageNamed:[arrayImage4 objectAtIndex:i]];
        imgForLbl.contentMode = UIViewContentModeScaleAspectFit;
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(50, height2, 245, 60)];
        lbl.text = [arrayDecription4 objectAtIndex:i];
        lbl.textAlignment = UITextAlignmentLeft;
        lbl.backgroundColor=[UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.font=[UIFont systemFontOfSize:14];
        lbl.numberOfLines = 10;
        lbl.lineBreakMode = NO;
        
        [appInfoScrollView addSubview:imgForLbl];
        [appInfoScrollView addSubview:lbl];
        
        heightOfFullText = lbl.frame.size.height + lbl.frame.origin.y;
    }
    
    UILabel *settingsScreenLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, heightOfFullText, 299, 20)];
    settingsScreenLabel.text = @"Settings screen";
    settingsScreenLabel.textAlignment = UITextAlignmentLeft;
    settingsScreenLabel.backgroundColor=[UIColor clearColor];
    settingsScreenLabel.textColor = [UIColor whiteColor];
    settingsScreenLabel.font=[UIFont systemFontOfSize:16];
    [appInfoScrollView addSubview:settingsScreenLabel];
    
    NSMutableArray *arrayDecription5 = [[NSMutableArray alloc]initWithObjects:@"Settings-> Profile screen\nLets you see your profile, add photos and set your mood message Click on any of your photos. You will get a Photos Screen",@"Settings-> Account screen",@"Settings-> Account screen-> Change password – Lets you modify your password",@"Account screen-> Blocked List – Shows list of blocked users. You can unblock from here",@"Account screen-> Delete Profile – Lets you delete your profile completely and exit. This action is irreversible",@"Settings-> Filters screen - Lets you update your areas of interest",@"Settings-> Update Profile screen - Lets you update your personal details",@"Settings-> App Share screen - You can share your app via facebook, twitter or email",@"Settings-> App info screen - Gives you information about the app",@"Settings-> Feedback screen - Lets you give feedback about the app",@"Settings -> Logout - Logout of the application", nil];
    NSMutableArray *arrayImage5 = [[NSMutableArray alloc]initWithObjects:@"profile_white@2x",@"update_white@2x",@"change-pass-white@2x",@"white_block@2x",@"remove_white@2x",@"filtericon@2x",@"profile_white@2x",@"share_white@2x",@"appinfo_white@2x",@"feedback_white@2x",@"menu_log@2x", nil];
    
    heightOfText = heightOfFullText + 20;
    
    for (int i=0; i < 11; i++) {
        
        float height1 = (heightOfText+18)+(i*60);
        float height2 = heightOfText+(i*60);
        
        UIImageView *imgForLbl = [[UIImageView alloc]initWithFrame:CGRectMake(10, height1, 25, 25)];
        imgForLbl.image = [UIImage imageNamed:[arrayImage5 objectAtIndex:i]];
        imgForLbl.contentMode = UIViewContentModeScaleAspectFit;
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(50, height2, 245, 60)];
        lbl.text = [arrayDecription5 objectAtIndex:i];
        lbl.textAlignment = UITextAlignmentLeft;
        lbl.backgroundColor=[UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.font=[UIFont systemFontOfSize:14];
        lbl.numberOfLines = 10;
        lbl.lineBreakMode = NO;
        
        [appInfoScrollView addSubview:imgForLbl];
        [appInfoScrollView addSubview:lbl];
        
        heightOfFullText = lbl.frame.size.height + lbl.frame.origin.y;
    }
    
    appInfoScrollView.contentSize=CGSizeMake(299, heightOfFullText);
    
    self.navigationItem.rightBarButtonItem = eyeButtonItem;
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
-(void)moveBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
