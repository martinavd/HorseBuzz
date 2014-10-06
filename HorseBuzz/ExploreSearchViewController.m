//
//  ExploreSearchViewController.m
//  HorseBuzz
//
//  Created by Welcome on 23/08/14.
//  Copyright (c) 2014 ggau. All rights reserved.
//

#import "ExploreSearchViewController.h"
#import "AppDelegate.h"
#import "ChatViewController.h"
#import "MessageCell.h"
#import "userProfileDeatil.h"
#import "PeopleCell.h"
#import "SearchResultCell.h"
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


@interface ExploreSearchViewController ()<HTTPURLRequestDelegate,EGORefreshTableHeaderDelegate, UISearchBarDelegate>
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

@implementation ExploreSearchViewController
@synthesize _searchBar;
@synthesize selectionTarget;

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
    // Do any additional setup after loading the view from its nib.
    if(![selectionTarget isEqualToString:@"Chat"])
    {
        UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:14.0];
        titleView.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        titleView.shadowOffset = CGSizeMake(0.0f, 1.0f);
        titleView.textColor = [UIColor whiteColor];
        titleView.text = @"People search";
        self.navigationItem.titleView = titleView;
        [titleView sizeToFit];
//        
//        UIImage *image = [UIImage imageNamed:@"logo"];
//        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
        
//        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [menuButton setBackgroundImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
//        menuButton.frame = CGRectMake(0, 0, 21, 20);
//        [menuButton addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
//        self.navigationItem.leftBarButtonItem = revealButtonItem;
        
    }
    
    eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    eyeButton.frame = CGRectMake(0, 0, 19, 19);
    [eyeButton addTarget:self action:@selector(setVisibilty) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *eyeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:eyeButton];
    
    self.navigationItem.rightBarButtonItem = eyeButtonItem;
    
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"isInvisible"]){
        [eyeButton setImage:[UIImage imageNamed:@"eye-show"] forState:UIControlStateNormal];
    }
    else{
        [eyeButton setImage:[UIImage imageNamed:@"eye-hide"] forState:UIControlStateNormal];
    }
    
    
    //[self callService];
    
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

-(void)openSettings{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate setSettings];
}


-(void)callService{
    
    if([[CMLNetworkManager sharedInstance] hasConnectivity]){
        [mbProgressHUD show:YES];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        
        NSString *latitude = @"-33.863400";
        NSString *longitude= @"151.211000";
        NSString *distance= @"44.126054";
        NSString *keyWord = _searchBar.text;
        
        [dictionary setObject:[NSString stringWithFormat:@"%f",[latitude floatValue]] forKey:@"latitude"];
        [dictionary setObject:[NSString stringWithFormat:@"%f",[longitude floatValue]] forKey:@"longitude"];
        [dictionary setObject:[NSString stringWithFormat:@"%f",[distance floatValue]] forKey:@"distance"];
        [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
        
        
        [dictionary setObject:[NSString stringWithString:keyWord] forKey:@"searchKey"];
        
        HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
        request.delegate=self;
        [request initwithurl:BASE_URL requestStr:SEARCHBUDDIES requestType:POST input:YES inputValues:dictionary];}
}

-(void)SetSelectionTarget:(NSString *)target{
    
    selectionTarget = target;
}

#pragma mark -
#pragma mark Table view handler

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([responseArray count]>0)
        return responseArray.count;
    else
        return 1;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    @try{
    if(responseArray.count>0)
    {
        SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];
        if (!cell)
        {
//            //[tableView registerNib:[UINib nibWithNibName:@"SearchResultCell" bundle:nil] forCellReuseIdentifier:@"SearchResultCell"];
//            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UsersSearchResultCell" owner:nil options:nil];
//            for(id someObj in nib){
//                if([someObj isKindOfClass:[SearchResultCell class]])
//                {
//                    cell = someObj;
//                    break;
//                }
//            }
            
            NSArray *nib;
            nib = [[NSBundle mainBundle] loadNibNamed:@"UsersSearchResultCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            
        }

        cell.Fullname.text = [NSString  stringWithFormat:@"%@ %@"
                              ,[[responseArray objectAtIndex:indexPath.row] valueForKey:@"firstname"]
                              ,[[responseArray objectAtIndex:indexPath.row] valueForKey:@"lastname"]
                              ];
        
        NSString *moodMsg=[[responseArray objectAtIndex:indexPath.row] valueForKey:@"mood_message"];
        
        if (moodMsg == (NSString *)[NSNull null])
            cell.Location.text =@"";
        else
            cell.Location.text =moodMsg;
        
        checkNullString *nullCheck=[[checkNullString alloc]init];
        UIImageView *refImage =(UIImageView *)[cell.ProfileImage viewWithTag: 0];
        UIImageView *onlineStaus =(UIImageView *)[cell.StatusImage viewWithTag:1];

        refImage.layer.cornerRadius = 5.0;
        refImage.layer.masksToBounds = YES;
        refImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
        refImage.layer.borderWidth = 2.0;
        
        NSString *imagePath = [[responseArray objectAtIndex:indexPath.row] valueForKey:@"imagepath"];
        if(![nullCheck IsEmptyOrNull:imagePath] ){
            __block UIActivityIndicatorView *activityIndicator;
            __weak UIImageView *brandImageView = cell.ProfileImage ;
            
            [refImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMGURL,imagePath]] placeholderImage:[UIImage imageNamed:@"noimage"] options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize)
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
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotFound"];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotFound"];
            cell.textLabel.text = @"";//@"No data found to show!";
        }
        return cell;
    }
    }
    @catch (NSException *e){
    
        //NSLog(@"Exception: %@", e);
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell && [cell.textLabel.text isEqualToString:@""])
        return;
        
    
    if(![selectionTarget isEqualToString:@"Chat"]){
    userProfileDeatil *profile=[[userProfileDeatil alloc]initWithNibName:nil bundle:nil VisitUserID:[[responseArray objectAtIndex:indexPath.row]objectForKey:@"userid"]];
    profile.distanceString = [[responseArray objectAtIndex:indexPath.row]objectForKey:@"distance"];
    profile.selectedIndex = indexPath.row;
    profile.dataArray = responseArray;
    profile.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:profile animated:YES];
    }
    else{
        
        ChatViewController *chatView = [[ChatViewController alloc]initWithNibName:@"ChatViewController" bundle:nil];
        chatView.receiverId = [[responseArray objectAtIndex:indexPath.row]objectForKey:@"userid"];
        SearchResultCell *cell = (SearchResultCell*)[tableView cellForRowAtIndexPath:indexPath];
        chatView.receiverImage = cell.ProfileImage.image;
        chatView.nameString =[[responseArray objectAtIndex:indexPath.row]objectForKey:@"username"];
        chatView.receiverImageUrl=[[responseArray objectAtIndex:indexPath.row]objectForKey:@"imagetype"];
        chatView.isFromMessage=TRUE;
        chatView.hidesBottomBarWhenPushed = YES;
        chatView.isNeededToRemoveNavBar = TRUE;
        [self.navigationController pushViewController:chatView animated:YES];
    
    }
    
}


#pragma mark -
#pragma mark Search Methods

// called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{

    [self callService];
    [searchBar resignFirstResponder]; // keyBoard is hide
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

#pragma -
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
