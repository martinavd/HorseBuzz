//
//  AccountViewController.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 20/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "AccountViewController.h"
#import "ChangePassword.h"
#import "BlockedViewController.h"
#import "SetInvisibleUser.h"
#import "CMLNetworkManager.h"
#import "AppDelegate.h"
#import "HorseBuzzConfig.h"
#import "HorseBuzzDataManager.h"
#import "GAI.h"

@interface AccountViewController (){
    NSArray *menuItems;
    NSArray *menuImages;
    UIButton *eyeButton;
}

@end

@implementation AccountViewController

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
    //[tracker trackView:@"Horse Buzz - Register view"];
    [tracker set:@"ScreenName" value:@"Horse Buzz - Register view"];
    // google tracking code end
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Account";
    
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
    
    menuImages = [NSArray arrayWithObjects:@"change-pass",@"block",@"remove_clr", nil];
    menuItems = [NSArray arrayWithObjects:@"Change Password",@"Blocked List",@"Delete Profile", nil];
    
    eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    eyeButton.frame = CGRectMake(0, 0, 19, 19);
    [eyeButton addTarget:self action:@selector(setVisibilty) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *eyeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:eyeButton];
    
    
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)moveBack{
    //[self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - TableView Delegate methods.
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [menuItems count];
    
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
    cell.textLabel.text = [menuItems objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[menuImages objectAtIndex:indexPath.row]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        ChangePassword *password = [[ChangePassword alloc]initWithNibName:@"ChangePassword" bundle:nil ];
        [self.navigationController pushViewController:password animated:YES];
    }
    else if (indexPath.row==1){
        BlockedViewController *blocked = [[BlockedViewController alloc]initWithNibName:@"BlockedViewController" bundle:nil ];
        [self.navigationController pushViewController:blocked animated:YES];
    }else if (indexPath.row == 2){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"HorseBUzz" message:@"Are you sure you want to delete your profile? This will remove your data and you will no longer be able to login unless you create a fresh profile." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Cancel", nil ];
        alert.tag=100;
        [alert show];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==100 && buttonIndex==0){
        if([[CMLNetworkManager sharedInstance] hasConnectivity]){
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
            
            HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
            request.delegate=self;
            [request initwithurl:BASE_URL requestStr:DELETEUSER requestType:POST input:YES inputValues:dictionary];
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}
-(void)getResponsedata:(NSDictionary *)data{
    
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

-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
}

@end
