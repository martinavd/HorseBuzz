//
//  BlockedViewController.m
//  HorseBuzz
//
//  Created by Ritheesh Koodalil on 20/02/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "BlockedViewController.h"
#import "MBProgressHUD.h"
#import "CMLNetworkManager.h"
#import "HorseBuzzDataManager.h"
#import "HorseBuzzConfig.h"
#import "BlockedUserCell.h"
#import "checkNullString.h"
#import "SetInvisibleUser.h"
#import "GAI.h"

@interface BlockedViewController (){
    MBProgressHUD *mbProgressHUD;
    BOOL checkONLoad;
    BOOL checkUnlock;
    NSMutableArray *responseArray;
    UIButton *eyeButton;
}

@end

@implementation BlockedViewController

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
    //[tracker trackView:@"Horse Buzz - Blocked view"];
    [tracker set:@"ScreenName" value:@"Horse Buzz - Blocked view"];
    // google tracking code end
    
    self.title=@"Blocked User";
    
    float version = [[[UIDevice currentDevice] systemVersion]floatValue];
    if (version >= 7.0) {
        self.navigationItem.hidesBackButton =FALSE;
    }else{
        UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0,85, 20);
        [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
        [backButton setTitle:@" Account" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(moveBack) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarButton =[[UIBarButtonItem alloc]initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButton;
    }
    
    checkONLoad=TRUE;
    mbProgressHUD = [[MBProgressHUD alloc]initWithView:self.view];
    [mbProgressHUD setMode:MBProgressHUDModeIndeterminate];
    [self.view addSubview:mbProgressHUD];
    [mbProgressHUD show:YES];
    if([[CMLNetworkManager sharedInstance] hasConnectivity]){
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
        
        HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
        request.delegate=self;
        [request initwithurl:BASE_URL requestStr:BLOCKUSERLIST requestType:POST input:YES inputValues:dictionary];
        
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
    
    eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    eyeButton.frame = CGRectMake(0, 0, 19, 19);
    [eyeButton addTarget:self action:@selector(setVisibilty) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *eyeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:eyeButton];
    self.navigationItem.rightBarButtonItem = eyeButtonItem;
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

#pragma mark - UrlConnection methods
-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
    
}
-(void)getResponsedata:(NSDictionary *)data{
    checkONLoad=FALSE;
    [mbProgressHUD hide:YES];
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    NSString * code = [data objectForKey:@"code"];
    if (status) {
        responseArray=[[NSMutableArray alloc]initWithArray:[data objectForKey:@"BlockedUsers"]];
    }else if ([code intValue] == 2){
        [responseArray removeAllObjects];
    }
    [blockeTableView reloadData];
}

#pragma mark - TableView Delegate methods.
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    //  return self.peopleList.count;
    if(checkONLoad){
        return 0;
    }
    else if(responseArray.count ==0 ){
        return 1;
    }
    else{
        return responseArray.count;
    }
    
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BlockedUserCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if(responseArray.count ==0 ){
        if(cell==nil){
            NSArray *nib;
            nib = [[NSBundle mainBundle] loadNibNamed:@"BlockedUserCell" owner:self options:nil];
            cell = [nib objectAtIndex:1];
            
        }
    }
    else{
        if(cell==nil){
            NSArray *nib;
            nib = [[NSBundle mainBundle] loadNibNamed:@"BlockedUserCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            
        }
        NSArray *locationArray=[[[responseArray objectAtIndex:indexPath.row]valueForKey:@"location_name" ] componentsSeparatedByString:@","];
        cell.personLocation.text =[locationArray objectAtIndex:0];
        cell.personName.text=[NSString stringWithFormat:@"%@ %@",[[responseArray objectAtIndex:indexPath.row]valueForKey:@"firstname" ],[[responseArray objectAtIndex:indexPath.row]valueForKey:@"lastname" ]];
        [cell.unBlockBttn addTarget:self action:@selector(unBlockUser:) forControlEvents:UIControlEventTouchUpInside];
        cell.unBlockBttn.tag=indexPath.row;
        checkNullString *nullCheck=[[checkNullString alloc]init];
        
        
        if([nullCheck checkString:[[responseArray objectAtIndex:indexPath.row]valueForKey:@"imagepath" ]].length > 0){
            __block UIActivityIndicatorView *activityIndicator;
            __weak UIImageView *brandImageView = cell.personImage;
            [cell.personImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMGURL,[[responseArray objectAtIndex:indexPath.row]valueForKey:@"imagepath" ]]] placeholderImage:[UIImage imageNamed:@"noimage"] options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize)
             {
                 if (!activityIndicator)
                 {
                     [brandImageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
                     activityIndicator.center = brandImageView.center;
                     [activityIndicator startAnimating];
                 }
             }
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
             {
                 [activityIndicator removeFromSuperview];
                 activityIndicator = nil;
             }];
            cell.personImage.contentMode=UIViewContentModeScaleAspectFit;
        }
        
        
        
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)unBlockUser:(UIButton *)bttn{
    checkUnlock=TRUE;
    
    if([[CMLNetworkManager sharedInstance] hasConnectivity]){
        [mbProgressHUD show:YES];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        [dictionary setObject:[[responseArray objectAtIndex:bttn.tag]valueForKey:@"block_user_id" ] forKey:@"block_user_id"];
        [dictionary setObject:@"1" forKey:@"is_deleted"];
        [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
        HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
        request.delegate=self;
        [request initwithurl:BASE_URL requestStr:BLOCKUSER requestType:POST input:YES inputValues:dictionary];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

@end
