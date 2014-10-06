//
//  AppDelegate.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 15/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "AppDelegate.h"
#import "SpalshViewController.h"
#import "NearByViewController.h"
#import "LocationManager.h"
#import "HorseBuzzDataManager.h"
#import "InterestKeys.h"
#import "SettingsViewController.h"
#import "HTTPURLRequest.h"
#import "CMLNetworkManager.h"
#import "HorseBuzzDataManager.h"
#import "GAI.h"
#import "LogInViewController.h"
#import "OTNotification.h"
#import "ChatViewController.h"
#import "MessagesViewController.h"

@interface AppDelegate()<HTTPURLRequestDelegate> {
    NSObject *senderInfo;
    NSDictionary *userInfoTemp;
}
@end

@implementation AppDelegate
@synthesize personalDetails;
@synthesize tabBarController,nearByController,exploreController,exploreSearchController,messagesController,favoritesController,buzzController;
@synthesize token;
@synthesize facebook;
@synthesize permissions;
@synthesize notificationAlert;
static NSString *FBAppId = @"426755740802263";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *soundFlip = [[NSBundle mainBundle] pathForResource:@"notification-received"
                                                          ofType:@"mp3"];
    NSURL *soundFlipURL = [NSURL fileURLWithPath:soundFlip];
    
    notificationAlert = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFlipURL
                                                               error:nil];
    [notificationAlert prepareToPlay];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    [[InterestKeys sharedInstance]getInterestKey];
    [[LocationManager sharedInstance]StartUpdatingLocation];
    [SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"HorseBuzz"];
    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"firstTime"]){
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"firstTime"];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"isLogin"];
        
        // first time login message show
        [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:@"guideVisitedStatus"];
        // first time login message show end
        
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    //[[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    // google tracking code
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLEANALITICSCODE];
    //[tracker trackView:@"Horse Buzz - App delegate view"];
    [tracker set:@"ScreenName" value:@"Horse Buzz - App delegate view"];
    // google tracking code end
    
    facebook=[[Facebook alloc]initWithAppId:FBAppId andDelegate:self];
    permissions = [[NSArray alloc] initWithObjects:@"read_stream",@"publish_stream",@"publish_checkins",@"offline_access",nil];
    
    personalDetails=[[PersonalDetail alloc]init];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    float version = [[[UIDevice currentDevice] systemVersion]floatValue];
    if (version >= 7.0) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbg_64"] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
        
    }else{
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"splashlogin_bg"] forBarMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance]setTintColor:[UIColor colorWithHue:0.6 saturation:0.33 brightness:0.69 alpha:0]];
    }
    
    //NSLog(@"test view%d",[[NSUserDefaults standardUserDefaults] boolForKey:@"guideVisitedStatus"]);
    
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"isLogin"]){
        //Check if the user is 
        HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
        request.delegate=self;
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        [dictionary setObject:[[NSUserDefaults standardUserDefaults]valueForKey:@"userID"] forKey:@"user_id"];
        [request initwithurl:BASE_URL requestStr:CHECKUSER requestType:POST input:YES inputValues:dictionary];

        //first time login condition
        /*if([[NSUserDefaults standardUserDefaults] boolForKey:@"guideVisitedStatus"] != 1) {
         
         LogInViewController *loginView = [[LogInViewController alloc]initWithNibName:@"LogInViewController" bundle:nil ];
         UINavigationController *navigation =[[UINavigationController alloc]initWithRootViewController:loginView];
         self.window.rootViewController = navigation;
         } else {
         [self setRootView];
         }*/
        
        [self setRootView];
        
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isInvisible"];
        int badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
        
        //condition added when the app is terminated from background
        //to direct when user received notification go the the respective chat page
        NSDictionary *params = [[launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] objectForKey:@"aps"];
        if (params) {
            [personalDetails getPrefilDetail];
            ChatViewController *chatView = [[ChatViewController alloc]initWithNibName:@"ChatViewController" bundle:nil];
            chatView.receiverId = [params objectForKey:@"senderid"];
            chatView.imageUrl = [params objectForKey:@"image"];
            chatView.nameString = [params objectForKey:@"name"];
            chatView.isNotified = TRUE;
            chatView.isNeededToRemoveNavBar = TRUE;
            chatView.isFromMessage=TRUE;
            
            UINavigationController *navigation =[[UINavigationController alloc]initWithRootViewController:chatView];
            self.window.rootViewController = navigation;
        }
        else if (badgeCount >0) {
            [[[[self.tabBarController tabBar] items]
              objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%d",badgeCount]];
        }
        else{
            [[[[self.tabBarController tabBar] items]
              objectAtIndex:2] setBadgeValue:nil];
        }
    }
    else{
        SpalshViewController *spalshViewController = [[SpalshViewController alloc]initWithNibName:@"SpalshViewController" bundle:nil ];
        UINavigationController *navigation =[[UINavigationController alloc]initWithRootViewController:spalshViewController];
        self.window.rootViewController = navigation;
    }
    
    
    [self.window makeKeyAndVisible];
    
    return YES;
}


-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    NSString *tokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    [HorseBuzzDataManager sharedInstance].deviceToken = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
}
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    
}

-(void)getResponsedata:(NSDictionary *)data{
    
//    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    NSString * code = [data objectForKey:@"code"];
//    if (status) {
//        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"isLogin"];
//        [[NSUserDefaults standardUserDefaults]synchronize];
//        [self setSplashView];
//    }
    if ([[NSString stringWithFormat:@"%@", code] isEqualToString:@"6"]) {
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"isLogin"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [self setSplashView];
    }
}

-(void)setRootView{
    
    [HorseBuzzDataManager sharedInstance].userId =[[NSUserDefaults standardUserDefaults]valueForKey:@"userID"];
    [personalDetails getPrefilDetail];
    self.nearByController = [[NearByViewController alloc]initWithNibName:@"NearByViewController" bundle:nil];
    self.exploreController = [[ExploreViewController alloc]initWithNibName:@"ExploreViewController" bundle:nil];
    
    self.exploreSearchController = [[ExploreSearchViewController alloc]initWithNibName:@"ExploreSearchViewController" bundle:nil];
    
    self.buzzController = [[BuzzViewController alloc]initWithNibName:@"BuzzViewController" bundle:nil];
    self.messagesController = [[MessagesViewController alloc]initWithNibName:@"MessagesViewController" bundle:nil];
    self.favoritesController = [[FavoritesViewController alloc]initWithNibName:@"FavoritesViewController" bundle:nil];
    
    UINavigationController *firstTabNav = [[UINavigationController alloc] initWithRootViewController: self.nearByController];
    
    UINavigationController *secondTabNav = [[UINavigationController alloc] initWithRootViewController: self.buzzController];
    UINavigationController *thirdTabNav = [[UINavigationController alloc] initWithRootViewController: self.messagesController];
    
    UINavigationController *fourthTabNav = [[UINavigationController alloc] initWithRootViewController: self.exploreController];
    //UINavigationController *fourthTabNav = [[UINavigationController alloc] initWithRootViewController: self.exploreSearchController];
    
    UINavigationController *fifthTabNav = [[UINavigationController alloc] initWithRootViewController: self.favoritesController];
    
    
    
    NSArray *myViewControllers = [[NSArray alloc] initWithObjects:
                                  firstTabNav,secondTabNav,thirdTabNav,fourthTabNav,fifthTabNav,
                                  nil];
    
    //initialize the tab bar controller
    self.tabBarController = [[MyUITabBarController alloc] init];
    
    //set the view controllers for the tab bar controller
    [self.tabBarController setViewControllers:myViewControllers];
    
    
    //add the tab bar controllers view to the window
    self.window.rootViewController=tabBarController;
    
    //set the window background color and make it visible
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [self.tabBarController setSelectedIndex:1];
    [self.tabBarController setSelectedIndex:0];
}
-(void)setSplashView{
    SpalshViewController *spalshViewController = [[SpalshViewController alloc]initWithNibName:@"SpalshViewController" bundle:nil ];
    UINavigationController *navigation =[[UINavigationController alloc]initWithRootViewController:spalshViewController];
    self.window.rootViewController = navigation;
    [self.window makeKeyAndVisible];
}
-(void)setSettings{
    SettingsViewController *settings = [[SettingsViewController alloc]
                                        initWithNibName:@"SettingsViewController"
                                        bundle:[NSBundle mainBundle]];
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:settings];
    [self.tabBarController presentViewController:settingsNav
                                        animated:YES
                                      completion:NULL];
}
-(void)removeSettings{
    [self.tabBarController dismissModalViewControllerAnimated:YES];
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    if(![[NSUserDefaults standardUserDefaults]boolForKey:@"isLogin"]){
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        return;
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[[[userInfo objectForKey:@"aps"]objectForKey:@"badge"]intValue]];
    
    //NSLog(@"badge count%d",[[[userInfo objectForKey:@"aps"]objectForKey:@"badge"]intValue]);
    
    if (application.applicationState == UIApplicationStateActive) {
        
        //NSLog(@"userInfo%@", userInfo);
        userInfoTemp = userInfo;
        
        OTNotificationManager *notificationManager = [OTNotificationManager defaultManager];
        OTNotificationMessage *notificationMessage = [[OTNotificationMessage alloc] init];
        notificationMessage.title = @"Horse Buzz";
        notificationMessage.message = [[userInfo objectForKey:@"aps"]valueForKey:@"alert"];
        notificationMessage.otNotificationTouchTarget = self;
        notificationMessage.otNotificationTouchSelector = @selector(touched);
        [notificationMessage setIconImage:[UIImage imageNamed:@"AppIcon29x29.png"]];
        [notificationManager postNotificationMessage:notificationMessage];
        MessagesViewController *msvc = [[MessagesViewController alloc]init];
        [msvc callService];
        //play notification sound when app is in foreground
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [notificationAlert play];
        
        senderInfo = [userInfo objectForKey:@"aps"];
        
        if ([[[userInfo objectForKey:@"aps"]objectForKey:@"badge"]intValue] > 0) {
            
            [[[[self.tabBarController tabBar] items]
              objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%d",[[[userInfo objectForKey:@"aps"]objectForKey:@"badge"]intValue]]];
        }
        else{
            [[[[self.tabBarController tabBar] items]objectAtIndex:2] setBadgeValue:nil];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewMessageReceived" object:self userInfo:userInfo];
    }
    else{
        
        ChatViewController *chatView = [[ChatViewController alloc]initWithNibName:@"ChatViewController" bundle:nil];
        UINavigationController *navigation =[[UINavigationController alloc]initWithRootViewController:chatView];
        
        chatView.receiverId = [[userInfo objectForKey:@"aps"]objectForKey:@"senderid"];
        chatView.imageUrl = [[userInfo objectForKey:@"aps"]objectForKey:@"image"];
        chatView.nameString = [[userInfo objectForKey:@"aps"]objectForKey:@"name"];
        chatView.isNotified = TRUE;
        chatView.isNeededToRemoveNavBar = TRUE;
        chatView.isFromMessage=TRUE;
        
        self.window.rootViewController = navigation;
        /*[[[[self.tabBarController tabBar] items]
         objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%d",[[[userInfo objectForKey:@"aps"]objectForKey:@"badge"]intValue]]];
         [self.tabBarController setSelectedIndex:2];
         UITabBarController *tbc = (UITabBarController *) self.window.rootViewController;
         UINavigationController *statusNav = (UINavigationController *) [tbc.viewControllers objectAtIndex:2];
         MessagesViewController *msg =[[MessagesViewController alloc]initWithNibName:@"MessagesViewController" bundle:nil];
         
         [statusNav setViewControllers:[NSArray arrayWithObject:msg]  animated:NO];*/
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    int badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
    
    if (badgeCount >0) {
        [[[[self.tabBarController tabBar] items]
          objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%d",badgeCount]];
    }
    else{
        [[[[self.tabBarController tabBar] items]
          objectAtIndex:2] setBadgeValue:nil];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    [SDWebImageManager.sharedManager.imageCache clearDisk];
}

-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
}

-(void)touched {
    /* ChatViewController *chatView = [[ChatViewController alloc]initWithNibName:@"ChatViewController" bundle:nil];
     chatView.receiverId = [senderInfo valueForKey:@"senderid"];
     chatView.receiverImageUrl=[senderInfo valueForKey:@"image"];
     chatView.nameString = [senderInfo valueForKey:@"name"];
     
     [self.tabBarController.navigationController pushViewController:chatView animated:YES];*/
    
    //[self.tabBarController setSelectedIndex:2];
    
    ChatViewController *chatView = [[ChatViewController alloc]initWithNibName:@"ChatViewController" bundle:nil];
    UINavigationController *navigation =[[UINavigationController alloc]initWithRootViewController:chatView];
    
    chatView.receiverId = [[userInfoTemp objectForKey:@"aps"]objectForKey:@"senderid"];
    chatView.imageUrl = [[userInfoTemp objectForKey:@"aps"]objectForKey:@"image"];
    chatView.nameString = [[userInfoTemp objectForKey:@"aps"]objectForKey:@"name"];
    chatView.isNotified = TRUE;
    chatView.isNeededToRemoveNavBar = TRUE;
    self.window.rootViewController = navigation;
    
    //UITabBarController *tbc = (UITabBarController *) self.window.rootViewController;
    // UINavigationController *statusNav = (UINavigationController *) [tbc.viewControllers objectAtIndex:2];
    //MessagesViewController *msg =[[MessagesViewController alloc]initWithNibName:@"MessagesViewController" bundle:nil];
    
    //[statusNav setViewControllers:[NSArray arrayWithObject:msg]  animated:NO];
    //UINavigationController *navigation=[[UINavigationController alloc]initWithRootViewController:chatView];
    //self.window.rootViewController = navigation;
}

- (bool)isAudioEnabled {
    UInt32 cfRouteSize = sizeof (CFStringRef);
    CFStringRef cfRoute;
    NSString* nsRoute;
    
    AudioSessionGetProperty(
                            kAudioSessionProperty_AudioRoute,
                            &cfRouteSize,
                            &cfRoute);
    
    nsRoute = (__bridge NSString*)cfRoute;
    
    return ([nsRoute length] == 0);
}

@end
