//
//  MessagesViewController.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 20/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "MessagesViewController.h"
#import "MessageCell.h"
#import "MBProgressHUD.h"
#import "CMLNetworkManager.h"
#import "HorseBuzzConfig.h"
#import "HorseBuzzDataManager.h"
#import "ChatViewController.h"
#import "SetInvisibleUser.h"
#import "EGORefreshTableHeaderView.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "GAI.h"
#import "GroupchatController.h"

@interface MessagesViewController ()<EGORefreshTableHeaderDelegate>
{
    MBProgressHUD *mbProgressHUD;
    UIButton *eyeButton;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    int badgeCount;
}

@property (weak, nonatomic) IBOutlet UITableView *nearByList;
@property (nonatomic, retain) NSMutableArray *peopleList;

@end

@implementation MessagesViewController
@synthesize peopleList;
@synthesize nearByList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title = @"Chats";
        //set the image icon for the tab
        self.tabBarItem.image = [UIImage imageNamed:@"chat"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"chat"];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"chat"] withFinishedUnselectedImage:[UIImage imageNamed:@"chat"]];
    }
    return self;
}

- (void)viewDidLoad
{
    // google tracking code
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLEANALITICSCODE];
    //[tracker trackView:@"Horse Buzz - Messages view"];
    [tracker set:@"ScreenName" value: @"Horse Buzz - Messages view"];
    // google tracking code end
    
    [super viewDidLoad];
    
    UIView *backGroundView = [[UIView alloc]initWithFrame:CGRectZero];
    backGroundView.backgroundColor = [UIColor colorWithRed:218/255.0f green:218/255.0f blue:218/255.0f alpha:1.0f];
    nearByList.backgroundColor = nil;
    nearByList.backgroundView = backGroundView;
    nearByList.frame = CGRectMake(0, 36, self.view.frame.size.width, self.view.frame.size.height);
    // Do any additional setup after loading the view from its nib.
    
    
	if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.nearByList.bounds.size.height, self.view.frame.size.width, self.nearByList.bounds.size.height)];
		view.delegate = self;
		[self.nearByList addSubview:view];
		_refreshHeaderView = view;
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
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
    //    self.navigationItem.rightBarButtonItem = eyeButtonItem;
    //    self.navigationItem.rightBarButtonItem = addButtonItem;
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:eyeButtonItem, nil]];
    
    mbProgressHUD = [[MBProgressHUD alloc]initWithView:self.view];
    [mbProgressHUD setMode:MBProgressHUDModeIndeterminate];
    [self.view addSubview:mbProgressHUD];
    
}

-(void)viewWillAppear:(BOOL)animated{
    badgeCount = 0;
    [self callService];
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"isInvisible"]){
        [eyeButton setImage:[UIImage imageNamed:@"eye-show"] forState:UIControlStateNormal];
    }
    else{
        [eyeButton setImage:[UIImage imageNamed:@"eye-hide"] forState:UIControlStateNormal];
    }
    [super viewWillAppear:animated];
}

-(void)openSettings{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate setSettings];
}
-(void)callService {
    
    //NSLog(@"service called");
    
    if([[CMLNetworkManager sharedInstance] hasConnectivity]){
        [mbProgressHUD show:YES];
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
        HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
        request.delegate=self;
        [request initwithurl:BASE_URL requestStr:MESSAGEHISTORY requestType:POST input:YES inputValues:dictionary];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
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
- (IBAction)SearchBuddies:(id)sender {
    
    ExploreSearchViewController *searchController=[[ExploreSearchViewController alloc]initWithNibName:@"ExploreSearchViewController" bundle:nil];
    [searchController setSelectionTarget:@"Chat"];
    [self.navigationController pushViewController:searchController animated:YES];
}

- (IBAction)AddNewGroup:(id)sender {
    GroupchatController *groupChat=[[GroupchatController alloc]initWithNibName:@"GroupchatController" bundle:nil];
    [self.navigationController pushViewController:groupChat animated:YES];
}

-(void)log:(NSDictionary *)dict{
    ChatViewController *chatView = [[ChatViewController alloc]initWithNibName:@"ChatViewController" bundle:nil];
    chatView.receiverId = [dict objectForKey:@"senderid"];
    chatView.imageUrl = [dict objectForKey:@"image"];
    chatView.nameString =[dict objectForKey:@"name"];
    chatView.isNotified = TRUE;
    
    [self.navigationController pushViewController:chatView animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - HTTP request delegate methods
-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
    
}
-(void)getResponsedata:(NSDictionary *)data{
    
    //NSLog(@"responsed called");
    [mbProgressHUD hide:YES];
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    NSString * code = [data objectForKey:@"code"];
    if (status) {
        peopleList=[NSMutableArray arrayWithArray:[data objectForKey:@"Messagehistory"]];
        [nearByList reloadData];
        if (peopleList.count >0) {
            for (NSDictionary *dict in peopleList) {
                int count = [[dict objectForKey:@"messagecount"]intValue];
                //NSLog(@"count+count=%d",count);
                if (count<1) {
                    badgeCount = badgeCount+count;
                } else {
                    badgeCount = count;
                }
                //badgeCount = badgeCount+count;
            }
            AppDelegate *delagate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            UIViewController *viewController = [delagate.tabBarController.viewControllers objectAtIndex:2];
            if (badgeCount >0) {
                [UIApplication sharedApplication].applicationIconBadgeNumber = badgeCount;
                viewController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",badgeCount];
            }
            else{
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                viewController.tabBarItem.badgeValue = nil;
            }
            
        }
        
    }else if ([code intValue] == 2){
        
        
    }else{
        
    }
    [self doneLoadingTableViewData];
}
#pragma mark - TableView Delegate methods.
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(peopleList.count==0){
        return 1;
    }
    else{
        return peopleList.count;
    }
    
    
}
-(NSString *)getMessageTime :(NSString *)dateString{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //initialize format
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate          *formattedDate = [dateFormatter dateFromString:dateString];
    //set time format
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //get current date
    NSDate          *currentDate=[NSDate date];
    //get yesterday
    NSDate          *yesterday=[currentDate dateByAddingTimeInterval:-86400.0];
    //convert date format as string for comparsion with message date
    NSString        *strcurrentdate=[dateFormatter stringFromDate:(currentDate)];
    NSString        *stryesterday=[dateFormatter stringFromDate:(yesterday)];
    NSString        *strmessagedate=[dateFormatter stringFromDate:formattedDate];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    if([strcurrentdate isEqualToString:strmessagedate])
    {
      // [dateFormatter setDateFormat:@"hh:mm a"];
     // return [dateFormatter stringFromDate:formattedDate];
       return @"Today";
    }
    else if ([stryesterday isEqualToString:strmessagedate]){
        
        return @"Yesterday";
    }
    
    [dateFormatter setDateFormat:@"dd-MMM"];
    return [dateFormatter stringFromDate:formattedDate];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell *cell=[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if(cell==nil){
        if(peopleList.count==0){
            NSArray *nib;
            nib = [[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:nil];
            cell = [nib objectAtIndex:1];
            return cell;
        }
        else{
            NSArray *nib;
            nib = [[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            cell.personName.text=[NSString stringWithFormat:@"%@ %@",[[peopleList objectAtIndex:indexPath.row]valueForKey:@"firstname" ],[[peopleList objectAtIndex:indexPath.row]valueForKey:@"lastname" ]];
            checkNullString *nullCheck=[[checkNullString alloc]init];
            cell.message.text=[NSString stringWithFormat:@"%@",[[peopleList objectAtIndex:indexPath.row]valueForKey:@"latestmessage" ]];
            
            //MAR - decode message string
            const char *jsonString = [cell.message.text UTF8String];
            NSData *jsonData = [NSData dataWithBytes:jsonString length:strlen(jsonString)];
            cell.message.text = [[NSString alloc] initWithData:jsonData encoding:NSNonLossyASCIIStringEncoding];
            
            if ([cell.message.text hasPrefix:@":IMG"]) {
                cell.message.text = @"Image";
            }
            if ([cell.message.text hasPrefix:@":MOV"]) {
                cell.message.text = @"Video";
            }
            if([nullCheck checkString:[[peopleList objectAtIndex:indexPath.row]valueForKey:@"imagepath" ]].length > 0){
                __block UIActivityIndicatorView *activityIndicator;
                __weak UIImageView *brandImageView = cell.personImage;
                [cell.personImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMGURL,[[peopleList objectAtIndex:indexPath.row]valueForKey:@"imagepath" ]]] placeholderImage:[UIImage imageNamed:@"noimage"] options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize)
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
                int count = [[[peopleList objectAtIndex:indexPath.row]objectForKey:@"messagecount"]intValue];
                if (count == 0) {
                    cell.time.text=[self getMessageTime:[[peopleList objectAtIndex:indexPath.row]valueForKey:@"created_date"]];
                }
            }
            
            int count = [[[peopleList objectAtIndex:indexPath.row]objectForKey:@"messagecount"]intValue];
            if (count > 0) {
                UIView *view = [[UIView alloc]initWithFrame:CGRectMake(270, 30, 30, 20) ];
                view.layer.cornerRadius = 10.0f;
                view.backgroundColor = [UIColor colorWithRed:228/255.0 green:61/255.0 blue:64/255.0 alpha:1.0];
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(3,0,24, 20) ];
                label.backgroundColor = [UIColor clearColor];
                [view addSubview:label];
                label.text = [NSString stringWithFormat:@"%d",count];
                label.textColor = [UIColor whiteColor];
                label.textAlignment = UITextAlignmentCenter;
                label.font = [UIFont boldSystemFontOfSize:12.0];
                [cell addSubview:view];
            }
            
        }
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(peopleList.count>0){
        
        int count = [[[peopleList objectAtIndex:indexPath.row]objectForKey:@"messagecount"]intValue];
        badgeCount = badgeCount- count;
        AppDelegate *delagate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        UIViewController *viewController = [delagate.tabBarController.viewControllers objectAtIndex:2];
        if (badgeCount >0) {
            [UIApplication sharedApplication].applicationIconBadgeNumber = badgeCount;
            viewController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",badgeCount];
        }
        else{
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            viewController.tabBarItem.badgeValue = nil;
        }
        ChatViewController *chatView = [[ChatViewController alloc]initWithNibName:@"ChatViewController" bundle:nil];
        chatView.receiverId = [[peopleList objectAtIndex:indexPath.row]objectForKey:@"userid"];
        MessageCell *cell = (MessageCell*)[tableView cellForRowAtIndexPath:indexPath];
        chatView.receiverImage = cell.personImage.image;
        chatView.nameString =[[peopleList objectAtIndex:indexPath.row]objectForKey:@"username"];
        chatView.receiverImageUrl=[[peopleList objectAtIndex:indexPath.row]objectForKey:@"imagetype"];
        chatView.isFromMessage=TRUE;
        chatView.hidesBottomBarWhenPushed = YES;
        chatView.IsGroup = [[peopleList objectAtIndex:indexPath.row] objectForKey:@"IsGroup"];
        [self.navigationController pushViewController:chatView animated:YES];
        
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


@end
