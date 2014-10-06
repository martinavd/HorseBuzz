//
//  MyUITabBarController.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 04/03/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "MyUITabBarController.h"

@interface MyUITabBarController ()

@end

@implementation MyUITabBarController

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
    
    //create a custom view for the tab bar

    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIFont systemFontOfSize:13.0], UITextAttributeFont,
                                                       [UIColor whiteColor], UITextAttributeTextColor,
                                                       [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 0.0f)],
                                                       UITextAttributeTextShadowOffset,[UIColor whiteColor],UITextAttributeTextShadowColor
                                                       ,nil] forState:UIControlStateNormal];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"active_bg"]];
    [[UITabBar appearance]setBackgroundImage:[UIImage imageNamed:@"menubg"]];
    self.tabBarController.tabBar.selectedImageTintColor=[UIColor whiteColor];
    //set the tab bar title appearance for normal state
    [[UITabBarItem appearance]
     setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor whiteColor],
                              UITextAttributeFont:[UIFont systemFontOfSize:12.0f]}
     forState:UIControlStateNormal];
    
    //set the tab bar title appearance for selected state
    
    [[UITabBarItem appearance]
     setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor whiteColor],
                               UITextAttributeFont:[UIFont systemFontOfSize:12.0f]}
     forState:UIControlStateHighlighted];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end