#import "AddParticipantViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AddBuddiesCell.h"
#import "HTTPURLRequest.h"
#import "HorseBuzzDataManager.h"
#import "CMLNetworkManager.h"
#import "MBProgressHUD.h"
#import "HorseBuzzConfig.h"
#import "checkNullString.h"
#import "SetInvisibleUser.h"
#import "EGORefreshTableHeaderView.h"
#import "GAI.h"
#import "GroupProfileViewController.h"




@interface AddParticipantViewController ()
{
    BOOL checkSearch;
    NSMutableArray *responseArray;
    MBProgressHUD *mbProgressHUD;
    BOOL checkONLoad;
    UIButton *eyeButton;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    BOOL IsCreateGroup;
    NSMutableArray *selectedIndexes;
    NSMutableArray *selectedParticipants;
}
@end

@implementation AddParticipantViewController
@synthesize groupName;
@synthesize selectionTarget;
@synthesize profileImage;
@synthesize participantlist;
@synthesize groupId;

@synthesize _searchBar;

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
 
    selectedIndexes = [[NSMutableArray alloc] init];
    selectedParticipants = [[NSMutableArray alloc] init];

    UIButton *btnNext = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    [btnNext setTitle:@"Add" forState:UIControlStateNormal];
    [btnNext addTarget:self action:@selector(goGroupSummary) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarbutton = [[UIBarButtonItem alloc] initWithCustomView:btnNext];
    self.navigationItem.rightBarButtonItem = rightBarbutton;
    
    
    if(participantlist){
        selectedIndexes=participantlist;
    }
}

-(void)goGroupSummary
{
    if([groupId isEqualToString:@""] || (groupId == nil))
    {
        if(selectedIndexes.count==0)
        {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"HorseBuzz" message: @"Select aleast one participant name!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
        }
    }
    
    GroupProfileViewController *groupsummarycontroller=[[GroupProfileViewController alloc]initWithNibName:@"GroupProfileViewController" bundle:nil];
    
    groupsummarycontroller.getGroupName = groupName;
    groupsummarycontroller.getProfileImage=profileImage;
    groupsummarycontroller.getParticipant=selectedIndexes;
    
    if([groupId isEqualToString:@""] || (groupId == nil)){
        groupsummarycontroller.buttonText=@"Create";
    }
    else{
        groupsummarycontroller.getGroupId=groupId;
        groupsummarycontroller.buttonText=@"Update";
    }
    [self.navigationController pushViewController:groupsummarycontroller animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Table view handler

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([responseArray count]>0)
        return responseArray.count;
    else
        return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *groupMembers=@"Participants";
    
    return groupMembers;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
   
    @try{
        
      
        if(responseArray.count>0)
        {
//            if(participantlist){
//                [responseArray removeObjectsInArray:participantlist];
//            }
            AddBuddiesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddBuddiesCell"];
            NSString *currentparticpant=[[responseArray objectAtIndex:indexPath.row] valueForKey:@"userid"];
            
           if (!cell)
            {
                //[tableView registerNib:[UINib nibWithNibName:@"SearchResultCell" bundle:nil] forCellReuseIdentifier:@"SearchResultCell"];
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AddBuddiesCell" owner:nil options:nil];
                for(id someObj in nib){
                    if([someObj isKindOfClass:[AddBuddiesCell class]])
                    {
                        cell = someObj;
                        break;
                    }
                }
            }
            
            if(selectedParticipants)
            {
                for(int i=0;i<[selectedParticipants count];i++)
                {
                    NSString *checked=[selectedParticipants objectAtIndex:i];
                    
                    if ([currentparticpant isEqualToString:checked])
                    {
                        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                    }
                }
            }

            
            cell.Fullname.text = [NSString  stringWithFormat:@"%@ %@"
                                  ,[[responseArray objectAtIndex:indexPath.row] valueForKey:@"firstname"]
                                  ,[[responseArray objectAtIndex:indexPath.row] valueForKey:@"lastname"]
                                  ];
            checkNullString *nullCheck=[[checkNullString alloc]init];
            UIImageView *refImage =(UIImageView *)[cell.profileImage viewWithTag: 0];
            
            refImage.layer.cornerRadius = 5.0;
            refImage.layer.masksToBounds = YES;
            refImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
            refImage.layer.borderWidth = 2.0;
            
            if([nullCheck checkString:[[responseArray objectAtIndex:indexPath.row] valueForKey:@"imagepath"]].length > 0){
                __block UIActivityIndicatorView *activityIndicator;
                __weak UIImageView *brandImageView = cell.profileImage ;
                
                [refImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMGURL,[[responseArray objectAtIndex:indexPath.row]valueForKey:@"imagepath" ]]] placeholderImage:[UIImage imageNamed:@"noimage"] options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize)
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
               // UIImageView *tempImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TblSearch.png"]];
               // [tempImageView setFrame:self.tableView.frame];
                //self.tableView.backgroundView=tempImageView;
                //[tempImageView reloadInputViews];
                
             cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotFound"];
            //cell.textLabel.text = @"No data found to show!";
              
            }
            return cell;
        }
    }
    @catch (NSException * e){
        
        //NSLog(@"Exception: %@", e);
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([selectedCell accessoryType] == UITableViewCellAccessoryNone) {
        [selectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [selectedIndexes addObject:responseArray[indexPath.row]];
        [selectedParticipants addObject:[responseArray [indexPath.row]valueForKey :@"userid"]];
        participantlist=selectedIndexes;
    } else {
        [selectedCell setAccessoryType:UITableViewCellAccessoryNone];
        [selectedIndexes removeObject:responseArray[indexPath.row]];
        [selectedParticipants removeObject:[responseArray [indexPath.row] valueForKey:@"userid"]];
         participantlist=selectedIndexes;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}



#pragma -
#pragma mark - UrlConnection methods

-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
    
}
-(void)getResponsedata:(NSDictionary *)data{
    
    [self doneLoadingTableViewData];
    [mbProgressHUD hide:YES];
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    
    if (IsCreateGroup) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    NSString * code = [data objectForKey:@"code"];
    if (status) {
        responseArray=[[NSMutableArray alloc]initWithArray:[data objectForKey:@"nearestfriends"]];
        for(int i=0;i<[participantlist count];i++)
        {
            NSString *addedrecepiant=[[participantlist objectAtIndex:i] valueForKey:@"userid"];
            for(int j=0;j<[responseArray count];j++)
            {
                NSString *currentparticpant=[[responseArray objectAtIndex:j] valueForKey:@"userid"];
                if ([currentparticpant isEqualToString:addedrecepiant])
                {
                    [responseArray removeObjectAtIndex:j];
                }
            }
        }
        [self.tableView reloadData];
        
    }else if ([code intValue] == 2){
        [responseArray removeAllObjects];
        [self.tableView reloadData];
    }
    
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
    
    //selectionTarget = target;
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
