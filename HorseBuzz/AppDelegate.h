//
//  AppDelegate.h
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 15/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "PersonalDetail.h"
#import "InterestKeys.h"
#import "MyUITabBarController.h"
#import "NearByViewController.h"
#import "ExploreViewController.h"
#import "ExploreListViewController.h"
#import "ExploreSearchViewController.h"
#import "FavoritesViewController.h"
#import "MessagesViewController.h"
#import "BuzzViewController.h"
#import "Token.h"
#import "Facebook.h"
#import <AVFoundation/AVFoundation.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate,FBSessionDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) PersonalDetail *personalDetails;
@property (strong, nonatomic) MyUITabBarController *tabBarController;
@property (strong, nonatomic) NearByViewController *nearByController;
@property (strong, nonatomic) ExploreViewController *exploreController;
@property (strong, nonatomic) ExploreSearchViewController *exploreSearchController;
@property (strong, nonatomic) MessagesViewController *messagesController;
@property (strong, nonatomic) FavoritesViewController *favoritesController;
@property (strong, nonatomic) BuzzViewController *buzzController;
@property(nonatomic,strong)Facebook *facebook;
@property(nonatomic,strong)    NSArray *permissions;
@property(nonatomic,strong)Token *token;
@property(nonatomic,strong)AVAudioPlayer *notificationAlert;

-(void)setRootView;
-(void)setSplashView;
-(void)setSettings;
-(void)removeSettings;

-(void)touched :(NSDictionary *)userInfo ;
@end
