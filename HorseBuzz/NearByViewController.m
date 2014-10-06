//
//  NearByViewController.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 16/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "NearByViewController.h"
#import "PeopleCell.h"
#import "CMLNetworkManager.h"
#import "HorseBuzzDataManager.h"
#import "HorseBuzzConfig.h"
#import "MBProgressHUD.h"
#import "LocationManager.h"
#import "checkNullString.h"
#import "ChatViewController.h"
#import "InterestKeys.h"
#import "SetInvisibleUser.h"
#import "GridCell.h"
#import "userProfileDeatil.h"
#import "EGORefreshTableHeaderView.h"
#import "AppDelegate.h"
#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "GAI.h"

@interface NavToolbar : UIToolbar
@end

@implementation NavToolbar
- (void) layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
}
- (void) drawRect:(CGRect)rect
{
}
@end

@interface NearByViewController ()<EGORefreshTableHeaderDelegate, UIAlertViewDelegate>{
    MBProgressHUD *mbProgressHUD;
    NSMutableArray *responseArray;
    BOOL checkONLoad;
    NSMutableArray *interestArray;
    NSTimer *timeInterval;
    UIButton *eyeButton;
    UIButton *filter;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    
}
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *nearByList;
@property (nonatomic, retain) NSArray *peopleList;


@end

@implementation NearByViewController
@synthesize mapView;
@synthesize nearByList;
@synthesize peopleList;
@synthesize popoverController;
@synthesize filterBttn;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title = @"Near By";
        //set the image icon for the tab
        self.tabBarItem.image = [UIImage imageNamed:@"tab_nearby"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_nearby"];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_nearby"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_nearby"]];
        
    }
    return self;
}

- (void)viewDidLoad
{
    responseArray = [NSMutableArray array];
    // google tracking code
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLEANALITICSCODE];
    //[tracker trackView:@"Horse Buzz - Nearby view"];
    [tracker set:@"ScreenName" value:@"Horse Buzz - Nearby view" ];
    // google tracking code end
    
    [super viewDidLoad];
    
    checkONLoad=TRUE;
    mbProgressHUD = [[MBProgressHUD alloc]initWithView:self.view];
    [mbProgressHUD setMode:MBProgressHUDModeIndeterminate];
    
    [self.view addSubview:mbProgressHUD];
    
    // Do any additional setup after loading the view from its nib.
    UIView *backGroundView = [[UIView alloc]initWithFrame:CGRectZero];
    backGroundView.backgroundColor = [UIColor colorWithRed:218/255.0f green:218/255.0f blue:218/255.0f alpha:1.0f];
    nearByList.backgroundColor = nil;
    nearByList.backgroundView = backGroundView;
    nearByList.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.nearByList.bounds.size.height, self.view.frame.size.width, self.nearByList.bounds.size.height)];
		view.delegate = self;
		[self.nearByList addSubview:view];
		_refreshHeaderView = view;
	}
    
    
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
    
    filter = [UIButton buttonWithType:UIButtonTypeCustom];
    filter.frame = CGRectMake(0, 10, 26, 26);
    [filter addTarget:self action:@selector(filterBy) forControlEvents:UIControlEventTouchUpInside];
    [filter setBackgroundImage:[UIImage imageNamed:@"filtericon"] forState:UIControlStateNormal];
    UIBarButtonItem *filterButtonItem = [[UIBarButtonItem alloc] initWithCustomView:filter];
    
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flexible1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    NSArray *items = [NSArray arrayWithObjects:flexible,eyeButtonItem,flexible1,filterButtonItem, nil];
    
    UIToolbar* toolBar = [[NavToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 44.01f)];
    toolBar.barStyle = self.navigationController.navigationBar.barStyle;
    toolBar.tintColor = self.navigationController.navigationBar.tintColor;
    toolBar.items = items;
    float version = [[[UIDevice currentDevice] systemVersion]floatValue];
    BOOL isLatestVersion = FALSE;
    if (version >= 7.0) {
        isLatestVersion = TRUE;
    }
    UIView *rightview = [[UIView alloc] initWithFrame:CGRectMake(0,0,isLatestVersion?82:90,44)];
    [rightview addSubview:eyeButton];
    [rightview addSubview:filter];
    
    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:rightview];
    // Create UIToolbar to add two buttons in the right
    self.navigationItem.rightBarButtonItem= customItem;
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    self.peopleList = [[NSArray alloc]init];
    self.mapView.showsUserLocation = TRUE;
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

-(void)viewWillAppear:(BOOL)animated{
    [self callService];
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
-(void)openSettings{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate setSettings];
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
        if (responseArray.count % 3 == 0) {
            return responseArray.count/3;
        }
        
        else
            return responseArray.count/3 + 1;
    }
    
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(responseArray.count ==0 ){
        PeopleCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if(cell==nil){
            NSArray *nib;
            nib = [[NSBundle mainBundle] loadNibNamed:@"PeopleCell" owner:self options:nil];
            cell = [nib objectAtIndex:1];
        }
        return cell;
        
    }
    else{
        GridCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if(cell==nil){
//            //NSLog(@"Nil");
            
            NSArray *nib;
            nib = [[NSBundle mainBundle] loadNibNamed:@"GridCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            
            for (int i = 0; i<3; i++) {
                if (responseArray.count > (indexPath.row*3)+i) {
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
        checkNullString *nullCheck=[[checkNullString alloc]init];
        
        for (int i = 0; i<3; i++) {
            UIImageView *refImage =(UIImageView *)[cell.contentView viewWithTag:i+1];
            refImage.contentMode = UIViewContentModeScaleAspectFit;
            UIImageView *onlineStaus =(UIImageView *)[cell.contentView viewWithTag:i+5];
            if (responseArray.count > (indexPath.row*3)+i) {
                if([nullCheck checkString:[[responseArray objectAtIndex:(indexPath.row*3)+i]valueForKey:@"imagepath"]].length > 0){
                    
//                    //NSLog(@"imagepath=%@",[[responseArray objectAtIndex:(indexPath.row*3)+i]valueForKey:@"imagepath"]);
                    
                    __block UIActivityIndicatorView *activityIndicator;
                    __weak UIImageView *brandImageView = cell.profile1;
                    [refImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMGURL,[[responseArray objectAtIndex:(indexPath.row*3)+i]valueForKey:@"imagepath" ]]] placeholderImage:[UIImage imageNamed:@"noimage"] options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize)
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
                    
                }
                else{
                    if (indexPath.row == 0 && i ==0) {
                        refImage.image = [UIImage imageNamed:@"myprofile"];
                    }
                    else{
                        refImage.image = [UIImage imageNamed:@"noimage"];
                    }
                }
                if([[[responseArray objectAtIndex:indexPath.row]valueForKey:@"login_status"] isEqualToString:@"online"]){
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
    if (indexPath.row == 0 && positon == 0) {
        ProfileViewController *profileViewController = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil ];
        profileViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
    else{
        userProfileDeatil *profile=[[userProfileDeatil alloc]initWithNibName:nil bundle:nil VisitUserID:[[responseArray objectAtIndex:positon]objectForKey:@"userid"]];
        //NSLog(@"responseArray%@",responseArray);
        profile.distanceString = [[responseArray objectAtIndex:positon]objectForKey:@"distance"];
        [responseArray removeObjectAtIndex:0];
        profile.selectedIndex = positon-1;
        profile.dataArray = responseArray;
        profile.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:profile animated:YES];
    }
}


-(void)filterBy{
    
    if(interestArray.count > 0) {
        
        WEPopoverContentViewController *contentViewController = [[WEPopoverContentViewController alloc]initwithArray:interestArray];
        contentViewController.delegate = self;
        
        self.popoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
        self.popoverController.delegate =self;
        if ([self.popoverController respondsToSelector:@selector(setContainerViewProperties:)]) {
            [self.popoverController setContainerViewProperties:[self improvedContainerViewProperties]];
        }
        
        [self.popoverController presentPopoverFromRect:CGRectMake(290,-5, 0, 0)
                                                inView:self.view
                              permittedArrowDirections:UIPopoverArrowDirectionUp
                                              animated:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
	self.popoverController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return YES;
}
- (WEPopoverContainerViewProperties *)improvedContainerViewProperties {
	
	WEPopoverContainerViewProperties *props = [WEPopoverContainerViewProperties alloc];
	NSString *bgImageName = nil;
	CGFloat bgMargin = 0.0;
	CGFloat bgCapSize = 0.0;
	CGFloat contentMargin = 4.0;
	
	bgImageName = @"popoverBg.png";
	
	// These constants are determined by the popoverBg.png image file and are image dependent
	bgMargin = 13; // margin width of 13 pixels on all sides popoverBg.png (62 pixels wide - 36 pixel background) / 2 == 26 / 2 == 13
	bgCapSize = 31; // ImageSize/2  == 62 / 2 == 31 pixels
	
	props.leftBgMargin = bgMargin;
	props.rightBgMargin = bgMargin;
	props.topBgMargin = bgMargin;
	props.bottomBgMargin = bgMargin;
	props.leftBgCapSize = bgCapSize;
	props.topBgCapSize = bgCapSize;
	props.bgImageName = bgImageName;
	props.leftContentMargin = contentMargin;
	props.rightContentMargin = contentMargin - 1; // Need to shift one pixel for border to look correct
	props.topContentMargin = contentMargin;
	props.bottomContentMargin = contentMargin;
	
	props.arrowMargin = 4.0;
	
	props.upArrowImageName = @"popoverArrowUp.png";
	props.downArrowImageName = @"popoverArrowDown.png";
	props.leftArrowImageName = @"popoverArrowLeft.png";
	props.rightArrowImageName = @"popoverArrowRight.png";
	return props;
}

-(void)selectioDidFinishWithInterest:(NSMutableArray *)interestArrays
{
    [[NSUserDefaults standardUserDefaults] setObject:interestArrays forKey:@"selectedInterestArrays"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [popoverController dismissPopoverAnimated:YES];
    
    if([interestArrays containsObject:@"0"]){
        [interestArrays removeObject:@"0"];
    }
    NSString *interestString =@"";
    for(int i=0;i<interestArrays.count;i++){
        NSString  *indexPos= [[InterestKeys sharedInstance].interestIDArray objectAtIndex:[[interestArrays objectAtIndex:i]intValue]];
        interestString=[interestString stringByAppendingString:[NSString stringWithFormat:@"%@,",indexPos]];
    }
    if(interestString.length >0){
        interestString = [interestString substringToIndex:[interestString length] - 1];
        [mbProgressHUD show:YES];
        if([[CMLNetworkManager sharedInstance] hasConnectivity]){
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            if ([[LocationManager sharedInstance]CheckLocation]) {
                [timeInterval invalidate];
                [dictionary setObject:[LocationManager sharedInstance].latitude forKey:@"latitude"];
                [dictionary setObject:[LocationManager sharedInstance].longitude forKey:@"longitude"];
                [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
                [dictionary setObject:interestString forKey:@"areaintrest"];
                
//                //NSLog(@"[LocationManager sharedInstance].latitude%@",[LocationManager sharedInstance].latitude);
//                //NSLog(@"[LocationManager sharedInstance].latitude%@",[LocationManager sharedInstance].longitude);
//                //NSLog(@"[LocationManager sharedInstance].latitude%@",[HorseBuzzDataManager sharedInstance].userId);
                
                HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
                request.delegate=self;
                [request initwithurl:BASE_URL requestStr:NEARBY requestType:POST input:YES inputValues:dictionary];
            }
            
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

#pragma mark - UIAlertView methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 101 && buttonIndex!= alertView.cancelButtonIndex) {
        ProfileViewController *profileViewController = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil ];
        profileViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}

#pragma mark - UrlConnection methods
-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
    
}
-(void)getResponsedata:(NSDictionary *)data{
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"user_registered"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"user_registered"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:@"Do you want to add more photos to your profile?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert setTag:101];
        [alert show];
    }

//    //NSLog(@"++++++++++++++++++++++++++  %@",data);
    checkONLoad=FALSE;
    interestArray=[NSMutableArray arrayWithArray:[InterestKeys sharedInstance].interestArray];
    [mbProgressHUD hide:YES];
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    NSString * code = [data objectForKey:@"code"];
    if (status) {
        responseArray=[[NSMutableArray alloc]initWithArray:[data objectForKey:@"nearestfriends"]];
        
        NSDictionary *myData = [NSDictionary dictionaryWithObjectsAndKeys:[HorseBuzzDataManager sharedInstance].myImage,@"imagepath",[HorseBuzzDataManager sharedInstance].userId,@"userid",@"online",@"login_status",nil];
        [responseArray insertObject:myData atIndex:0];
        
    }else if ([code intValue] == 2){
        [responseArray removeAllObjects];
    }
    [self doneLoadingTableViewData];
    [nearByList reloadData];
    
    timeInterval= [NSTimer scheduledTimerWithTimeInterval:10*60 target:self selector:@selector(callService) userInfo:nil repeats:NO];
}


-(void)callService{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
//    if ([responseArray count] <= 0) {
        [mbProgressHUD show:YES];
//    }
    if([[CMLNetworkManager sharedInstance] hasConnectivity]){
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        if ([[LocationManager sharedInstance]CheckLocation]) {
            [timeInterval invalidate];
            
            [dictionary setObject:[LocationManager sharedInstance].latitude forKey:@"latitude"];
            [dictionary setObject:[LocationManager sharedInstance].longitude forKey:@"longitude"];
            [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
            
//            //NSLog(@"[LocationManager sharedInstance].latitude%@",[LocationManager sharedInstance].latitude);
//            //NSLog(@"[LocationManager sharedInstance].latitude%@",[LocationManager sharedInstance].longitude);
//            //NSLog(@"[LocationManager sharedInstance].latitude%@",[HorseBuzzDataManager sharedInstance].userId);
            
            NSArray *selectedInterestArrays = [[NSUserDefaults standardUserDefaults]objectForKey:@"selectedInterestArrays"];
            
            if (selectedInterestArrays.count > 0) {
                
                NSString *interestString =@"";
                for(int i=0;i<selectedInterestArrays.count;i++){
                    NSString  *indexPos= [selectedInterestArrays objectAtIndex:i];
                    interestString=[interestString stringByAppendingString:[NSString stringWithFormat:@"%@,",indexPos]];
                }
                interestString = [interestString substringToIndex:[interestString length] - 1];
                
                [dictionary setObject:interestString forKey:@"areaintrest"];
            }
            
            HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
            request.delegate=self;
            [request initwithurl:BASE_URL requestStr:NEARBY requestType:POST input:YES inputValues:dictionary];
        }
        
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:nil cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
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
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.nearByList];
	
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
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

- (void)hideTabBar:(UITabBarController *) tabbarcontroller
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, 480, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 480)];
        }
    }
    
    [UIView commitAnimations];
}

- (void)showTabBar:(UITabBarController *) tabbarcontroller
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    for(UIView *view in tabbarcontroller.view.subviews)
    {
//        //NSLog(@"%@", view);
        
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, 431, view.frame.size.width, view.frame.size.height)];
            
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 431)];
        }
    }
    
    [UIView commitAnimations];
}


@end
