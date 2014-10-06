//
//  ExploreListViewController.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 11/03/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "ExploreListViewController.h"
#import "PeopleCell.h"
#import "GridCell.h"
#import "userProfileDeatil.h"
#import "HTTPURLRequest.h"
#import "HorseBuzzDataManager.h"
#import "CMLNetworkManager.h"
#import "MBProgressHUD.h"
#import "HorseBuzzConfig.h"
#import "checkNullString.h"
#import "SetInvisibleUser.h"
#import "EGORefreshTableHeaderView.h"
#import "GAI.h"

@interface ExploreListViewController ()<HTTPURLRequestDelegate,EGORefreshTableHeaderDelegate>
{
    
    BOOL checkSearch;
    NSMutableArray *responseArray;
    MBProgressHUD *mbProgressHUD;
    BOOL checkONLoad;
    UIButton *eyeButton;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
}
@end

@implementation ExploreListViewController
@synthesize latitude,longitude,distance;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title = @"Explore";
        //set the image icon for the tab
        self.tabBarItem.image = [UIImage imageNamed:@"tab_explore"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_explore"];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_explore"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_explore"]];
    }
    return self;
}

- (void)viewDidLoad
{
    // google tracking code
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLEANALITICSCODE];
    //[tracker trackView:@"Horse Buzz - Explore list view"];
    [tracker set:@"ScreenName" value:@"Horse Buzz - Explore list view"];
    // google tracking code end
    
    [super viewDidLoad];
    
    mbProgressHUD = [[MBProgressHUD alloc]initWithView:self.view];
    [mbProgressHUD setMode:MBProgressHUDModeIndeterminate];
    [self.view addSubview:mbProgressHUD];
    
    UIView *backGroundView = [[UIView alloc]initWithFrame:CGRectZero];
    backGroundView.backgroundColor = [UIColor colorWithRed:218/255.0f green:218/255.0f blue:218/255.0f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor redColor];
    
    if (_refreshHeaderView == nil) {
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
    eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    eyeButton.frame = CGRectMake(0, 0, 19, 19);
    [eyeButton addTarget:self action:@selector(setVisibilty) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *eyeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:eyeButton];
    self.navigationItem.rightBarButtonItem = eyeButtonItem;
    float version = [[[UIDevice currentDevice] systemVersion]floatValue];
    if (version >= 7.0) {
        self.navigationItem.hidesBackButton =FALSE;
    }else{
        UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0,60, 20);
        [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
        [backButton setTitle:@" Back" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(moveBack) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarButton =[[UIBarButtonItem alloc]initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButton;
    }
    
    [self callService];
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
-(void)callService{
    
    if([[CMLNetworkManager sharedInstance] hasConnectivity]){
        [mbProgressHUD show:YES];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        
        self.latitude = @"-33.863400";
        self.longitude= @"151.211000";
        
        [dictionary setObject:[NSString stringWithFormat:@"%f",[self.latitude floatValue]] forKey:@"latitude"];
        [dictionary setObject:[NSString stringWithFormat:@"%f",[self.longitude floatValue]] forKey:@"longitude"];
        [dictionary setObject:[NSString stringWithFormat:@"%f",[self.distance floatValue]] forKey:@"distance"];
        [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
        
        NSString *keyWord = @"ma";
        [dictionary setObject:[NSString stringWithString:keyWord] forKey:@"searchKey"];
        
        HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
        request.delegate=self;
        [request initwithurl:BASE_URL requestStr:SEARCHBUDDIES requestType:POST input:YES inputValues:dictionary];}
}
#pragma mark - TableView Delegate methods.
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
//    //  return self.peopleList.count;
//    if(checkONLoad){
//        return 0;
//    }
//    else if(responseArray.count >0){
//        if (responseArray.count % 3 == 0) {
//            return responseArray.count/3;
//        }
//        
//        else
//            return responseArray.count/3 + 1;
//    }
//    else{
//        return 1;
//    }
    return 1;
    
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
            NSArray *nib;
            nib = [[NSBundle mainBundle] loadNibNamed:@"GridCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
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
            UIImageView *onlineStaus =(UIImageView *)[cell.contentView viewWithTag:i+5];
            if (responseArray.count > (indexPath.row*3)+i) {
                if([nullCheck checkString:[[responseArray objectAtIndex:(indexPath.row*3)+i]valueForKey:@"imagepath"]].length > 0){
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
                    refImage.image = [UIImage imageNamed:@"noimage"];
                }
                if([[[responseArray objectAtIndex:indexPath.row]valueForKey:@"login_status"] isEqualToString:@"online"]){
                    onlineStaus.image=[UIImage imageNamed:@"online_icon"];
                }
                else{
                    onlineStaus.image=[UIImage imageNamed:@""];
                }
            }else{
                refImage.image =  nil;
            }
            refImage.contentMode=UIViewContentModeScaleToFill;
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
    
    
    
    userProfileDeatil *profile=[[userProfileDeatil alloc]initWithNibName:nil bundle:nil VisitUserID:[[responseArray objectAtIndex:positon]objectForKey:@"userid"]];
    profile.distanceString = [[responseArray objectAtIndex:positon]objectForKey:@"distance"];
    profile.selectedIndex = positon;
    profile.dataArray = responseArray;
    profile.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:profile animated:YES];
}


#pragma mark - UrlConnection methods
-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
    
}
-(void)getResponsedata:(NSDictionary *)data{
    [self doneLoadingTableViewData];
    [mbProgressHUD hide:YES];
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    NSString * code = [data objectForKey:@"code"];
    if (status) {
        responseArray=[[NSMutableArray alloc]initWithArray:[data objectForKey:@"nearestfriends"]];
        [self.tableView reloadData];
        
    }else if ([code intValue] == 2){
        [responseArray removeAllObjects];
        [self.tableView reloadData];
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
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
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

@end
