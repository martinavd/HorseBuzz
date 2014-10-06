//
//  ChatNewViewController.m
//  HorseBuzz
//
//  Created by Welcome on 03/09/14.
//  Copyright (c) 2014 ggau. All rights reserved.
//

#import "ChatNewViewController.h"

#import "GAI.h"
#import "NSString+Utils.h"
#import "CMLNetworkManager.h"
#import "SBJsonWriter.h"
#import "AppDelegate.h"

@interface ChatNewViewController ()


@end

@implementation ChatNewViewController

@synthesize isNeededToRemoveNavBar;


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
    [tracker trackView:@"Horse Buzz - Chat view"];
    // google tracking code end
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
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
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
