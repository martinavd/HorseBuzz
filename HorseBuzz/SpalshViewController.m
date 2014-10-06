//
//  SpalshViewController.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 15/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "SpalshViewController.h"
#import "LogInViewController.h"
#import "RegisterViewController.h"
#import "LocationManager.h"
#import "GAI.h"
#import "HorseBuzzConfig.h"

@interface SpalshViewController ()

@end

@implementation SpalshViewController

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
    //[tracker trackView:@"Horse Buzz - Spalsh view"];
    [tracker set:@"ScreenName" value: @"Horse Buzz - Spalsh view"];
    // google tracking code end
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [LocationManager sharedInstance];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    self.navigationController.navigationBarHidden = YES;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Instance methods
-(void)ShowlogIn:(id)sender{
    LogInViewController *logInViewController = [[LogInViewController alloc]initWithNibName:@"LogInViewController" bundle:nil ];
    [self.navigationController pushViewController:logInViewController animated:YES];
    
}
-(void)ShowRegestration:(id)sender{
    RegisterViewController *registerViewController = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil ];
    [self.navigationController pushViewController:registerViewController animated:NO];
    
}

@end