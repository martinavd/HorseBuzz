//
//  ExploreViewController.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 20/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "ExploreViewController.h"
#import "PeopleCell.h"
#import "SBJSON.h"
#import "HorseBuzzConfig.h"
#import "HorseBuzzDataManager.h"
#import "MBProgressHUD.h"
#import "CMLNetworkManager.h"
#import "checkNullString.h"
#import "ChatViewController.h"
#import "SetInvisibleUser.h"
#import "GridCell.h"
#import "userProfileDeatil.h"
#import "AppDelegate.h"
#import "ExploreListViewController.h"
#import "LocationManager.h"
#import "GAI.h"

@interface NToolbar : UIToolbar
@end

@implementation NToolbar
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

@interface ExploreViewController (){
    CGFloat animatedDistance;
    MBProgressHUD *mbProgressHUD;
    NSMutableArray *responseArray;
    NSMutableArray *mapAnnotationArray;
    BOOL checkONLoad;
    BOOL checkSearch;
    UIButton *eyeButton;
    NSString *lat;
    NSString *lon;
    NSString *distance;
    int personCount;
    NSMutableArray *pinAnnotationarray;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property IBOutlet UISearchBar *searchBar;


@property (nonatomic, retain) NSArray *peopleList;
@property(nonatomic,strong) UIToolbar *keyBoardBar;

@end

@implementation ExploreViewController
@synthesize mapView;
@synthesize peopleList;
@synthesize keyBoardBar;
@synthesize searchBar;

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
    //[tracker trackView:@"Horse Buzz - Explore view"];
    [tracker set:@"ScreenName" value:@"Horse Buzz - Explore view" ];
    // google tracking code end
    
    pinAnnotationarray=[[NSMutableArray alloc]init];
    [super viewDidLoad];
    checkONLoad=TRUE;
    // Do any additional setup after loading the view from its nib.
    
    
    UIView *backGroundView = [[UIView alloc]initWithFrame:CGRectZero];
    backGroundView.backgroundColor = [UIColor colorWithRed:218/255.0f green:218/255.0f blue:218/255.0f alpha:1.0f];
    
    self.view.backgroundColor = [UIColor colorWithRed:218/255.0f green:218/255.0f blue:218/255.0f alpha:1.0f];
    
    mbProgressHUD = [[MBProgressHUD alloc]initWithView:self.view];
    [mbProgressHUD setMode:MBProgressHUDModeIndeterminate];
    [self.view addSubview:mbProgressHUD];
    
    mapView.showsUserLocation = TRUE;
    mapView.delegate=self;
    mapView.zoomEnabled = YES;
    MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude =[[LocationManager sharedInstance].latitude floatValue] ;
    region.center.longitude =[[LocationManager sharedInstance].longitude floatValue];;
    region.span.longitudeDelta = 0.15f;
    region.span.latitudeDelta = 0.15f;
    [mapView setRegion:region animated:YES];
    MKUserTrackingBarButtonItem *buttonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:mapView];
    self.navigationItem.rightBarButtonItem = buttonItem;
    lat = [LocationManager sharedInstance].latitude ;
    lon = [LocationManager sharedInstance].longitude ;
    
    [searchBar setShowsScopeBar:NO];
    [searchBar sizeToFit];
    
    UIImage *image = [UIImage imageNamed:@"logo"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setBackgroundImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    menuButton.frame = CGRectMake(0, 0, 21, 20);
    [menuButton addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    
    
    // Create UIToolbar to add two buttons in the right
    
    eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    eyeButton.frame = CGRectMake(0, 0, 24, 24);
    [eyeButton setBackgroundImage:[UIImage imageNamed:@"worldwide-location"] forState:UIControlStateNormal];
    [eyeButton addTarget:self action:@selector(launchExplorerSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *eyeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:eyeButton];
    
    
    UIButton *location = [UIButton buttonWithType:UIButtonTypeCustom];
    [location setBackgroundImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    location.frame = CGRectMake(40, 0, 19, 22);
    [location addTarget:self action:@selector(pointToCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *locationButtonItem = [[UIBarButtonItem alloc] initWithCustomView:location];
    
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:eyeButtonItem,locationButtonItem, nil]];
    
//    UIBarButtonItem *flexible = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    UIBarButtonItem *flexible1 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    NSArray *items = [NSArray arrayWithObjects:flexible,locationButtonItem,flexible1,eyeButtonItem, nil];
    
//    UIToolbar* toolBar = [[NToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 70.0f, 44.01f)];
//    toolBar.barStyle = self.navigationController.navigationBar.barStyle;
//    toolBar.tintColor = self.navigationController.navigationBar.tintColor;
//    toolBar.items = items;
//    float version = [[[UIDevice currentDevice] systemVersion]floatValue];
//    BOOL isLatestVersion = FALSE;
//    if (version >= 7.0) {
//        isLatestVersion = TRUE;
//    }
//    UIView *rightview = [[UIView alloc] initWithFrame:CGRectMake(0,0,isLatestVersion?82:90,44)];
//    [rightview addSubview:eyeButton];
//    [rightview addSubview:location];
//   
//    
//    UIBarButtonItem *customItem = [[UIBarButtonItem alloc] initWithCustomView:rightview];
//    
//    self.navigationItem.leftBarButtonItem = revealButtonItem;
//    self.navigationItem.rightBarButtonItem = customItem;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(dismissKeyboard)];
//    
//    [self.view addGestureRecognizer:tap];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)launchExplorerSearch{
    
    ExploreSearchViewController *searchController = [[ExploreSearchViewController alloc]initWithNibName:@"ExploreSearchViewController" bundle:nil];
    [self.navigationController pushViewController:searchController animated:YES];
//    elv.latitude =lat;
//    elv.longitude =lon;
//    elv.distance = distance;
//    [self.navigationController pushViewController:elv animated:YES];
}

-(void)openSettings{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate setSettings];
}
-(void)pointToCurrentLocation{
    [mapView removeAnnotations:[mapView annotations]];
    self.searchBar.text = @"";
    mapView.showsUserLocation = TRUE;
    
    MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude =[[LocationManager sharedInstance].latitude floatValue];
    region.center.longitude =[[LocationManager sharedInstance].longitude floatValue];
    region.span.longitudeDelta = 0.15f;
    region.span.latitudeDelta = 0.15f;
    [mapView setRegion:region animated:YES];
    lat=[LocationManager sharedInstance].latitude;
    lon=[LocationManager sharedInstance].longitude;
    
}
-(void)action{
    
}

-(void)dismissKeyboard {
    [searchBar resignFirstResponder];
}



#pragma mark - UrlConnection methods
-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
    
}
-(void)getResponsedata:(NSDictionary *)data{
    
    [mapAnnotationArray removeAllObjects];
    //NSLog(@"+++++++++++++++++  %@",data);
    [mbProgressHUD hide:YES];
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    int code = [[data objectForKey:@"code"] intValue];
    
    if (status) {
        if(checkSearch){
            checkSearch=FALSE;
            personCount=0;
            mapAnnotationArray=[[NSMutableArray alloc]initWithArray:[data objectForKey:@"nearestfriends"]];
            [self setMapAnnotation];
        }
    }
    else if (code == 2){
        
        [mapAnnotationArray removeAllObjects];
        [pinAnnotationarray removeAllObjects];
        [self setMapAnnotation];
        
        //NSLog(@"lat%@",lat);
        //NSLog(@"lon%@",lon);
        //NSLog(@"distance%@",distance);
        
        if ([lat intValue] != 0 || [lon intValue] != 0 || [distance intValue] != 0) {
            
            MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
            region.center.latitude = [lat doubleValue];
            region.center.longitude = [lon doubleValue];
            region.span.longitudeDelta = 2.15f;
            region.span.latitudeDelta = 2.15f;
            
            self.mapView.region = region;
        } else {
            self.searchBar.text = @"";
            MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
            region.center.latitude = [[LocationManager sharedInstance].latitude floatValue];
            region.center.longitude = [[LocationManager sharedInstance].longitude floatValue];
            region.span.longitudeDelta = 0.15f;
            region.span.latitudeDelta = 0.15f;
            
            self.mapView.region = region;
        }
    } else {
        //NSLog(@"else ");
    }
}

-(void)setMapAnnotation{
    [pinAnnotationarray removeAllObjects];
    for (int i=0; i<[mapAnnotationArray count]; i++)
    {
        CLLocationCoordinate2D theCoordinate1;
        checkNullString *check = [[checkNullString alloc]init];
        
        //NSLog(@"mapAnnotationArray iss%@",mapAnnotationArray);
        
        NSString *latitude = [[mapAnnotationArray objectAtIndex:i]valueForKey:@"latitude"];
        NSString *longitude = [[mapAnnotationArray objectAtIndex:i]valueForKey:@"longitude"];
        if ([[check checkString:latitude] isEqualToString:@""]) {
            latitude = @"";
        }
        if ([[check checkString:longitude] isEqualToString:@""]) {
            longitude = @"";
        }
        
        theCoordinate1.latitude  = [latitude floatValue];
        theCoordinate1.longitude = [longitude floatValue];
        
        MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
        annotationPoint.coordinate=theCoordinate1;
        NSString *nameString=[NSString stringWithFormat:@"%@ %@",[[mapAnnotationArray objectAtIndex:i]valueForKey:@"firstname" ],[[mapAnnotationArray objectAtIndex:i]valueForKey:@"lastname" ]];
        
        annotationPoint.title = nameString;
        [pinAnnotationarray addObject:annotationPoint];
        [mapView addAnnotation:annotationPoint];
    }
    
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in mapView.annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y,0, 0);
        if (MKMapRectIsNull(zoomRect)) {
            zoomRect = pointRect;
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    [mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapViews viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];

    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoDark];
    NSInteger annotationValue = [pinAnnotationarray indexOfObject:annotation];
    annotationView.tag=  annotationValue;
    return annotationView;
}

-(void)mapView:(MKMapView *)mapViews annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{
    //NSLog(@"-------------------  %i",view.tag);
    
    if (control == view.rightCalloutAccessoryView)
    {
        //NSLog(@"calloutAccessoryControlTapped: annotation = %@", view.annotation);
        NSString * selUserID =[NSString stringWithFormat:@"%@",[[mapAnnotationArray objectAtIndex:view.tag]valueForKey:@"userid" ]];
        //NSLog(@"----------------------  %@",selUserID);
        //NSLog(@"calloutAccessoryControlTapped: control=RIGHT");
        
        userProfileDeatil *profile=[[userProfileDeatil alloc]initWithNibName:nil bundle:nil VisitUserID:[[mapAnnotationArray objectAtIndex:view.tag]objectForKey:@"userid"]];
        profile.distanceString = [[mapAnnotationArray objectAtIndex:view.tag]objectForKey:@"distance"];
        profile.selectedIndex = view.tag;
        profile.dataArray = [NSArray arrayWithArray:mapAnnotationArray];
        
        profile.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:profile animated:YES];
        
    }
    
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    
    id<MKAnnotation> myAnnotation = [self.mapView.annotations objectAtIndex:0];
    if ([myAnnotation isKindOfClass:[MKUserLocation class]]) {
        [self.mapView selectAnnotation:myAnnotation animated:YES];
    }
}



#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    //Remove all objects first.
    
    
    // [self.tblContentList reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)loationsSearchBar {
    //NSLog(@"Cancel clicked");
    [loationsSearchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)loationsSearchBar {
    [mbProgressHUD show:YES];
    mapView.showsUserLocation = NO;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:searchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        //Error checking
        [searchBar resignFirstResponder];
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        
        
        [mapView removeAnnotations:[mapView annotations]];
        if([[CMLNetworkManager sharedInstance] hasConnectivity]){
            checkSearch=TRUE;
            
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setObject:[NSString stringWithFormat:@"%f",placemark.region.center.latitude] forKey:@"latitude"];
            [dictionary setObject:[NSString stringWithFormat:@"%f",placemark.region.center.longitude] forKey:@"longitude"];
            [dictionary setObject:[NSString stringWithFormat:@"%f",(placemark.region.radius/1000)] forKey:@"distance"];
            //NSLog(@"userid is%@",[HorseBuzzDataManager sharedInstance].userId);
            [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
            
            HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
            request.delegate=self;
            [request initwithurl:BASE_URL requestStr:NEARESTDISTANCEBUDDIES requestType:POST input:YES inputValues:dictionary];
            
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
            [alert show];
        }
        
        if (!placemark.locality && !placemark.administrativeArea ) {
            if (placemark.country != NULL) {
                searchBar.text =[NSString stringWithFormat:@"%@",placemark.country] ;
            }
        }else if (!placemark.locality){
            searchBar.text =[NSString stringWithFormat:@"%@,%@",placemark.administrativeArea,placemark.country] ;
        }else{
            searchBar.text =[NSString stringWithFormat:@"%@,%@,%@",placemark.locality,placemark.administrativeArea,placemark.country] ;
        }
        
        lat = [NSString stringWithFormat:@"%.5f",placemark.location.coordinate.latitude];
        lon = [NSString stringWithFormat:@"%.5f",placemark.location.coordinate.longitude];
        distance = [NSString stringWithFormat:@"%f",(placemark.region.radius/1000)];
    }];
}
@end