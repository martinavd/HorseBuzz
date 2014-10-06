//
//  BuzzViewController.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 20/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "BuzzViewController.h"
#import "PeopleCell.h"
#import "ChatViewController.h"
#import "HorseBuzzDataManager.h"
#import "HorseBuzzConfig.h"
#import "CMLNetworkManager.h"
#import "MBProgressHUD.h"
#import "LocationManager.h"
#import "checkNullString.h"
#import "SetInvisibleUser.h"
#import "GridCell.h"
#import "userProfileDeatil.h"
#import "SettingsViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "AppDelegate.h"
#import "GAI.h"

@interface BuzzViewController ()<EGORefreshTableHeaderDelegate>
{
    MBProgressHUD *mbProgressHUD;
    NSMutableArray *dataArray;
    BOOL checkONLoad;
    UIButton *eyeButton;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL  _reloading ;
}
@end

@implementation BuzzViewController
@synthesize onlineUsersList;
@synthesize segmentControl;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title = @"Buzz";
        //set the image icon for the tab
        self.tabBarItem.image = [UIImage imageNamed:@"tab_buzz"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_buzz"];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_buzz"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_buzz"]];
    }
    return self;
}

- (void)viewDidLoad
{
    
    // google tracking code
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLEANALITICSCODE];
    //[tracker trackView:@"Horse Buzz - Buzz view"];
   [tracker set:@"ScreenName" value:@"Horse Buzz - Buzz view"];
    // google tracking code end
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIView *backGroundView = [[UIView alloc]initWithFrame:CGRectZero];
    backGroundView.backgroundColor = [UIColor colorWithRed:218/255.0f green:218/255.0f blue:218/255.0f alpha:1.0f];
    onlineUsersList.backgroundColor = nil;
    onlineUsersList.backgroundView = backGroundView;
    onlineUsersList.frame = CGRectMake(0,55, self.view.frame.size.width, self.view.frame.size.height-55);
    
    self.view.backgroundColor = [UIColor colorWithRed:218/255.0f green:218/255.0f blue:218/255.0f alpha:1.0f];
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.onlineUsersList.bounds.size.height, self.view.frame.size.width, self.onlineUsersList.bounds.size.height)];
		view.delegate = self;
		[self.onlineUsersList addSubview:view];
		_refreshHeaderView = view;
	}
    //  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    checkONLoad=TRUE;
    mbProgressHUD = [[MBProgressHUD alloc]initWithView:self.view];
    [mbProgressHUD setMode:MBProgressHUDModeIndeterminate];
    [self.view addSubview:mbProgressHUD];
    
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 21, 20);
    [menuButton addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    UIImage *image = [UIImage imageNamed:@"logo"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    eyeButton.frame = CGRectMake(0, 0, 19, 19);
    [eyeButton addTarget:self action:@selector(setVisibilty) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *eyeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:eyeButton];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    self.navigationItem.rightBarButtonItem = eyeButtonItem;
    [self.segmentControl setSelectedSegmentIndex:0];
    
    self.segmentControl.selectedSegmentIndex = 0;
    //moved the below lines to the viewDidLoad from viewWillAppear, to persist the segment selection.
    [self callService];
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"isInvisible"]){
        [eyeButton setImage:[UIImage imageNamed:@"eye-show"] forState:UIControlStateNormal];
    }
    else{
        [eyeButton setImage:[UIImage imageNamed:@"eye-hide"] forState:UIControlStateNormal];
    }
    [segmentController setSelectedSegmentIndex:0];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)openSettings{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate setSettings];
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
-(void)callService{
    if(segmentControl.selectedSegmentIndex==0){
        [self.segmentControl setSelectedSegmentIndex:0];
        
        if([[CMLNetworkManager sharedInstance] hasConnectivity]){
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
            if ([[LocationManager sharedInstance]CheckLocation]) {
                [dictionary setObject:[LocationManager sharedInstance].latitude forKey:@"latitude"];
                [dictionary setObject:[LocationManager sharedInstance].longitude forKey:@"longitude"];
                [dictionary setObject:@"1" forKey:@"visit_status"];
            }
            [mbProgressHUD show:YES];
            HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
            request.delegate=self;
            [request initwithurl:BASE_URL requestStr:BUZZ requestType:POST input:YES inputValues:dictionary];
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else{
        [self.segmentControl setSelectedSegmentIndex:1];
        if([[CMLNetworkManager sharedInstance] hasConnectivity]){
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
            if ([[LocationManager sharedInstance]CheckLocation]) {
                [dictionary setObject:[LocationManager sharedInstance].latitude forKey:@"latitude"];
                [dictionary setObject:[LocationManager sharedInstance].longitude forKey:@"longitude"];
                
            }
            [mbProgressHUD show:YES];
            HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
            request.delegate=self;
            [request initwithurl:BASE_URL requestStr:BUZZ requestType:POST input:YES inputValues:dictionary];
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
}

#pragma mark - TableView Delegate methods.
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(checkONLoad){
        return 0;
    }
    else if(dataArray.count ==0 ){
        return 1;
    }
    else{
        if (dataArray.count % 3 == 0) {
            return dataArray.count/3;
        }
        
        else
            return dataArray.count/3 + 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    checkNullString *nullCheck=[[checkNullString alloc]init];
    
    if(dataArray.count ==0 ){
        PeopleCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if(cell==nil){
            NSArray *nib;
            nib = [[NSBundle mainBundle] loadNibNamed:@"PeopleCell" owner:self options:nil];
            cell = [nib objectAtIndex:1];
            if(segmentController.selectedSegmentIndex==0){
                cell.errorLabel.text=@"No new Rider found near to you";
            }
            else{
                cell.errorLabel.text=@"You have no Profile Viewers";
            }
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            
        }
        return cell;
        
    }
    else{
        GridCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        if(cell==nil){
            NSArray *nib;
            nib = [[NSBundle mainBundle] loadNibNamed:@"GridCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            for (int i = 0; i<3; i++) {
                if (dataArray.count > (indexPath.row*3)+i) {
                    UIImageView *refImage =(UIImageView *)[cell.contentView viewWithTag:i+1];
                    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                                         initWithTarget:self
                                                         action:@selector(actionHandleTapOnImageView:)];
                    
                    [singleTap setNumberOfTapsRequired:1];
                    refImage.userInteractionEnabled = YES;
                    [refImage addGestureRecognizer:singleTap];
                }
            }
            
        }
        
        
        for (int i = 0; i<3; i++) {
            UIImageView *refImage =(UIImageView *)[cell.contentView viewWithTag:i+1];
            UIImageView *onlineStaus =(UIImageView *)[cell.contentView viewWithTag:i+5];
            if (dataArray.count > (indexPath.row*3)+i) {
                if([nullCheck checkString:[[dataArray objectAtIndex:(indexPath.row*3)+i]valueForKey:@"imagepath"]].length > 0){
                    __block UIActivityIndicatorView *activityIndicator;
                    __weak UIImageView *brandImageView = cell.profile1;
                    
                    [refImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMGURL,[[dataArray objectAtIndex:(indexPath.row*3)+i]valueForKey:@"imagepath" ]]] placeholderImage:[UIImage imageNamed:@"noimage"] options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize)
                     {
                         if (!activityIndicator)
                         {
                             [brandImageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
                             activityIndicator.center = brandImageView.center;
                             [brandImageView bringSubviewToFront:activityIndicator];
                             [activityIndicator startAnimating];
                         }
                     }
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
                     {
                         [activityIndicator removeFromSuperview];
                         activityIndicator = nil;
                     }];
                    
                    
                    
                }
                else{
                    refImage.image = [UIImage imageNamed:@"noimage"];
                }
                
                if([[[dataArray objectAtIndex:indexPath.row]valueForKey:@"login_status"] isEqualToString:@"online"]){
                    onlineStaus.image=[UIImage imageNamed:@"online_icon"];
                }
                else{
                    onlineStaus.image=[UIImage imageNamed:@""];
                }
                
                refImage.contentMode=UIViewContentModeScaleToFill;
            }else{
                refImage.image =  nil;
                
            }
            
        }
        return cell;
        
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


-(void)actionHandleTapOnImageView:(id)sender
{
    
    UIGestureRecognizer *recognizer = (UIGestureRecognizer*)sender;
    UIImageView *imageView = (UIImageView *)recognizer.view;
    UIView *parentCell = recognizer.view.superview;
    while (![parentCell isKindOfClass:[UITableViewCell class]]) {   // iOS 7 onwards the table cell hierachy has changed.
        parentCell = parentCell.superview;
    }
    
    UIView *parentView = parentCell.superview;
    
    while (![parentView isKindOfClass:[UITableView class]]) {   // iOS 7 onwards the table cell hierachy has changed.
        parentView = parentView.superview;
    }
    
    
    UITableView *tableView = (UITableView *)parentView;
    NSIndexPath *indexPath = [tableView indexPathForCell:(UITableViewCell *)parentCell];
    
    int positon = (indexPath.row * 3) + imageView.tag - 1;
    
    userProfileDeatil *profile=[[userProfileDeatil alloc]initWithNibName:nil bundle:nil VisitUserID:[[dataArray objectAtIndex:positon]objectForKey:@"userid"]];
    profile.distanceString = [[dataArray objectAtIndex:positon]objectForKey:@"distance"];
    profile.selectedIndex = positon;
    profile.dataArray = dataArray;
    profile.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:profile animated:YES];

    
    
    
}

#pragma mark - UrlConnection methods
-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
    
}
-(void)getResponsedata:(NSDictionary *)data{
//    //NSLog(@"+++++++++++++++++  %@",data);
    checkONLoad=FALSE;
    [mbProgressHUD hide:YES];
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    NSString * code = [data objectForKey:@"code"];
    if (status) {
        dataArray = [[NSMutableArray alloc]initWithArray:[data objectForKey:@"nearestfriends"]];
        checkONLoad=FALSE;
        
        
    }else if ([code intValue] == 2){
        [dataArray removeAllObjects];
    }
    [self doneLoadingTableViewData];
    [onlineUsersList reloadData];
}

-(void)changeSegment:(UISegmentedControl *)sender{
    [self callService];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    [self callService];
    _reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.onlineUsersList];
    _reloading = NO;
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

@end