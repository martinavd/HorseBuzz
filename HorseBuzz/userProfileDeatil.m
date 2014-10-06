//
//  userProfileDeatil.m
//  HorseBuzz
//
//  Created by Ritheesh Koodalil on 13/02/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "userProfileDeatil.h"
#import "HorseBuzzConfig.h"
#import "MBProgressHUD.h"
#import "HorseBuzzDataManager.h"
#import "CMLNetworkManager.h"
#import "NSDataAdditions.h"
#import "NSData+Base64.h"
#import "AppDelegate.h"
#import "InterestKeys.h"
#import "SetInvisibleUser.h"
#import "ChatViewController.h"
#import "PagedScrollViewController.h"
#import "MyImage.h"
#import "GAI.h"

@interface userProfileDeatil (){
    CGFloat  animatedDistance;
    UIImagePickerController *picker;
    UIImage *pickedImage;
    int tag;
    int otherImagesCount ;
    NSString *dob;
    
    BOOL checkValidation;
    BOOL isBlockedUser;
    MBProgressHUD *mbProgressHUD;
    NSMutableDictionary *profileDetailArray;
    NSString *userIdString;
    UIButton *eyeButton;
    PagedScrollViewController *psc;
    NSMutableArray *imageDataArray;
    int currentIndex;
}
@property (nonatomic, strong) NSMutableArray *pageViews;
@end

@implementation userProfileDeatil
@synthesize placeHolder,statusTextView;
@synthesize profileImage;
@synthesize moodLabel;
//@synthesize nameLabel;
@synthesize sexLabel;
@synthesize aboutMeLabel;
@synthesize areaOfInterest;
@synthesize favoriteBttn;
@synthesize aboutView,photosView;
@synthesize distance;
@synthesize distanceString;
@synthesize pageViews = _pageViews;
@synthesize pageControl = _pageControl;
@synthesize pageImages = _pageImages;
@synthesize dataArray;
@synthesize profileView;
@synthesize selectedIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil VisitUserID:(NSString *)userId{
    self = [super init];
    if (self) {
        
        userIdString=userId;
    }
    return self;
    
}

- (void)viewDidLoad
{
    
    // google tracking code
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLEANALITICSCODE];
    //[tracker trackView:@"Horse Buzz - User Profile"];
    [tracker set:@"ScreenName" value:@"Horse Buzz - User Profile"];
    // google tracking code end
    
    [super viewDidLoad];
    self.profileView.hidden = FALSE;
    // Do any additional setup after loading the view from its nib.
    
    mbProgressHUD = [[MBProgressHUD alloc]initWithView:self.view];
    [mbProgressHUD setMode:MBProgressHUDModeIndeterminate];
    [self.view addSubview:mbProgressHUD];
    cns = [[checkNullString alloc]init];
    
    self.title = @"Profile";
    
    float version = [[[UIDevice currentDevice] systemVersion]floatValue];
    if (version >= 7.0) {
        self.navigationItem.hidesBackButton =FALSE;
    }else{
        UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0,60, 20);
        [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
        // [backButton setTitleEdgeInsets:UIEdgeInsetsMake(70.0, -150.0, 5.0, 5.0)];
        [backButton setTitle:@" Back" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(moveBack) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarButton =[[UIBarButtonItem alloc]initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButton;
    }
    
    
    eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    eyeButton.frame = CGRectMake(0, 0, 19, 19);
    [eyeButton addTarget:self action:@selector(setVisibilty) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *eyeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:eyeButton];
    self.navigationItem.rightBarButtonItem = eyeButtonItem;
    
    self.scrollView.contentSize = CGSizeMake(320.0f,699.0f);
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfile:)];
    
    // prevents the scroll view from swallowing up the touch event of child buttons
    tapGesture.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer:tapGesture];
    self.scrollView.scrollEnabled = YES;
    
    imageDataArray = [[NSMutableArray alloc]init];
    
    self.profileView.hidden = FALSE;
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [self.listView scrollToItemAtIndex:self.selectedIndex atScrollPosition:JTListViewScrollPositionCenter animated:YES];
    [self.listView setPagingEnabled:TRUE];
    self.listView.showsHorizontalScrollIndicator = FALSE;
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"isInvisible"]){
        [eyeButton setImage:[UIImage imageNamed:@"eye-show"] forState:UIControlStateNormal];
    }
    else{
        [eyeButton setImage:[UIImage imageNamed:@"eye-hide"] forState:UIControlStateNormal];
    }
}

-(void)showPics:(id)sender{
    UIButton *refButton = (UIButton *)sender;
    
    psc = [[PagedScrollViewController alloc]initWithNibName:@"PagedScrollViewController" bundle:nil];
    psc.pageImages = imageDataArray;
    psc.showBarButton = FALSE;
    
    psc.selectedIndex = refButton.tag-1;
    [self.navigationController pushViewController:psc animated:YES];
}

-(void)moveBack{
    [self.navigationController popViewControllerAnimated:YES];
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

-(void)beginChat:(UIButton *)sender{
    
    ChatViewController *chatView = [[ChatViewController alloc]initWithNibName:@"ChatViewController" bundle:nil];
    chatView.receiverId = [[self.dataArray objectAtIndex:currentIndex]objectForKey:@"userid"];
    chatView.receiverImageUrl=[self.pageImages objectAtIndex:0];
    chatView.nameString = [NSString stringWithFormat:@"%@ %@",[[self.dataArray objectAtIndex:currentIndex]valueForKey:@"firstname"],[[self.dataArray objectAtIndex:currentIndex]valueForKey:@"lastname"]];
    chatView.receiverImage = self.profileImage.image;
    [self.navigationController pushViewController:chatView animated:YES];
    
    
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
    
    //NSLog(@"data%@",data);
    [mbProgressHUD hide:YES];
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    NSString * code = [data objectForKey:@"code"];
    if (status) {
        if(isBlockedUser){
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else{
//            profileDetailArray=[[NSMutableDictionary alloc]initWithDictionary:data];
//            [self setupProfilePage];
        }
        
    }else if ([code intValue] == 2){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:[NSString stringWithFormat:@"%@",[data objectForKey:@"errors"]] delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
    self.profileView.hidden = FALSE;
}



- (void)loadVisiblePages:(UIScrollView *)currentView  {
    // First, determine which page is currently visible
    CGFloat pageWidth = currentView.frame.size.height;
    NSInteger page = (NSInteger)floor((currentView.contentOffset.y * 2.0f + pageWidth) / (pageWidth * 2.0f));
    // Update the page control
    self.pageControl.currentPage = page;
    
    // Work out which pages we want to load
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 1;
    // Purge anything before the first page
    for (NSInteger i=0; i<firstPage; i++) {
        [self purgePage:i];
    }
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        [self loadPage:i inView:currentView];
    }
    for (NSInteger i=lastPage+1; i<self.pageImages.count; i++) {
        [self purgePage:i];
    }
}

- (void)loadPage:(NSInteger)page inView:(UIScrollView *)currentView{
    if (page < 0 || page >= self.pageImages.count) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    //NSLog(@"++++++++++++++++++++ called ");
    // Load an individual page, first seeing if we've already loaded it
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        CGRect frame = currentView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        
        __block UIActivityIndicatorView *activityIndicator;
        UIImageView *newPageView = [[UIImageView alloc] init];
        newPageView.contentMode = UIViewContentModeScaleAspectFit;
        __weak UIImageView *brandImageView = newPageView;
        brandImageView.backgroundColor =[UIColor lightGrayColor];
        [newPageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMGURL,[self.pageImages objectAtIndex:page]]] placeholderImage:[UIImage imageNamed:@"noimage"] options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize)
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
        
        newPageView.frame = CGRectMake(0,frame.size.height * page, 320, self.view.frame.size.height);
        [currentView addSubview:newPageView];

        [self.pageViews replaceObjectAtIndex:page withObject:newPageView];
        
    }
}

- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= self.pageImages.count) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [self.pageViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}


- (void)showProfile:(UITapGestureRecognizer *)recognizer {
    
    //[self.listView reloadItemsAtIndexes:[NSIndexSet indexSetWithIndex:currentIndex]];
    if (self.profileView.hidden) {
        self.profileView.hidden = FALSE;
    }else{
        CGPoint location = [recognizer locationInView:[recognizer.view superview]];
        if(location.y < self.view.frame.size.height-150){
            self.profileView.hidden = TRUE;
        }
    }
    
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.tag != 100) {
        if (scrollView.contentOffset.x/320 != currentIndex) {
            UIScrollView *imageScroll = (UIScrollView *)[scrollView viewWithTag:100];
            CGPoint currentOffset = imageScroll.contentOffset;
            [self.listView reloadData];
            
            UIView *view = [self.listView viewForItemAtIndex:currentIndex];
            imageScroll = (UIScrollView *)[view viewWithTag:100];
            [imageScroll setContentOffset:currentOffset];
            
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Load the pages which are now on screen
    if (scrollView.tag == 100) {
        [self loadVisiblePages:scrollView];
        
    }
}


-(void)setupProfilePage1{
    moodLabel.text=[[profileDetailArray objectForKey:@"userDetails"]valueForKey:@"mood_message"];
    sexLabel.text=[[profileDetailArray objectForKey:@"userDetails"]valueForKey:@"gender"];
    aboutMeLabel.text=[[profileDetailArray objectForKey:@"userDetails"]valueForKey:@"about_me"];
    
    CGSize maximumLabelSize = CGSizeMake(210,9999);
    CGRect newFrame;
    
    CGSize expectedLabelSize;
    
    NSMutableArray *interestarray=[NSMutableArray arrayWithArray:[[[profileDetailArray objectForKey:@"userDetails"]valueForKey:@"area_intrest"] componentsSeparatedByString:@","]];
    NSString *interestString=@"";
    for(int i=0;i<interestarray.count;i++){
        NSString *interest=[[InterestKeys sharedInstance].interestArray objectAtIndex:[[interestarray objectAtIndex:i]intValue]];
        interestString=[interestString stringByAppendingString:[NSString stringWithFormat:@"%@ , ",interest]];
    }
    
    if(interestString.length >0){
        interestString =[interestString substringToIndex:interestString.length-3];
    }
    
    areaOfInterest.text=interestString;
    expectedLabelSize = [areaOfInterest.text sizeWithFont:areaOfInterest.font
                                        constrainedToSize:maximumLabelSize
                                            lineBreakMode:areaOfInterest.lineBreakMode];
    newFrame = areaOfInterest.frame;
    newFrame.size.height = expectedLabelSize.height;
    areaOfInterest.frame = newFrame;
    
    for(int i=otherImagesCount+1; i<=8;i++){
        UIButton *refButton = (UIButton*)[self.view viewWithTag:i];
        refButton.hidden =TRUE;
    }
    
    newFrame = aboutMeLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    aboutMeLabel.frame = newFrame;
    
    BOOL isFavorite=[[profileDetailArray valueForKey:@"Favourite"]boolValue];
    if(isFavorite){
        favoriteBttn.selected=YES;
        [favoriteBttn setImage:[UIImage imageNamed:@"fav_icon"] forState:UIControlStateNormal];
    }
    else{
        favoriteBttn.selected=NO;
        [favoriteBttn setImage:[UIImage imageNamed:@"white_hrt"] forState:UIControlStateNormal];
    }
}

-(void)setFavorites:(UIButton *)sender{
    if([[CMLNetworkManager sharedInstance] hasConnectivity]){
        if(!favoriteBttn.selected){
            favoriteBttn.selected=YES;
            
            //NSLog(@"favoriteBttn.selected");
            [favoriteBttn setImage:[UIImage imageNamed:@"fav_icon"] forState:UIControlStateNormal];
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setObject:[[self.dataArray objectAtIndex:currentIndex]objectForKey:@"userid"] forKey:@"favourite_user_id"];
            [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
            [dictionary setObject:@"0" forKey:@"is_deleted"];
            
            HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
            [request initwithurl:BASE_URL requestStr:ADDFAVOURITE requestType:POST input:YES inputValues:dictionary];
            
        }
        else{
            [favoriteBttn setImage:[UIImage imageNamed:@"white_hrt"] forState:UIControlStateNormal];
            favoriteBttn.selected=NO;
            
            //NSLog(@"favoriteBttn.selected");
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            ;
            [dictionary setObject:[[self.dataArray objectAtIndex:currentIndex]objectForKey:@"userid"] forKey:@"favourite_user_id"];
            [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
            [dictionary setObject:@"1" forKey:@"is_deleted"];
            
            HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
            [request initwithurl:BASE_URL requestStr:ADDFAVOURITE requestType:POST input:YES inputValues:dictionary];
        }
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)blockThisUser{
    if([[CMLNetworkManager sharedInstance] hasConnectivity]){
        isBlockedUser =YES;
        [mbProgressHUD show:YES];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        [dictionary setObject:[[self.dataArray objectAtIndex:currentIndex]objectForKey:@"userid"] forKey:@"block_user_id"];
        [dictionary setObject:@"0" forKey:@"is_deleted"];
        [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
        HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
        request.delegate=self;
        [request initwithurl:BASE_URL requestStr:BLOCKUSER requestType:POST input:YES inputValues:dictionary];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
}
#pragma mark - JTListViewDataSource

- (NSUInteger)numberOfItemsInListView:(JTListView *)listView
{
    return self.dataArray.count;
}
- (UIView *)listView:(JTListView *)listView viewForItemAtIndex:(NSUInteger)index
{
    UIView *view = nil;
    UIScrollView *cellScroll = nil;
    UIPageControl *pageControl = nil;
    UIView *bottomView =nil;
    UILabel *nameLabel= nil;
    UIButton *chat= nil;
    UIButton *favourite= nil;
    UIButton *block= nil;
    UILabel *distanceLbl= nil;
    UILabel *moodLblText= nil;
    UILabel *moodLbl= nil;
    UILabel *aboutLblText= nil;
    UILabel *aboutLbl= nil;
    UILabel *ageLblText= nil;
    UILabel *ageLbl= nil;
    UILabel *interestLbl= nil;
    UILabel *interestsLbl= nil;
    
    //NSLog(@"indexselected%i",index);
    
    currentIndex  = index;
    [self visitProfile];
    
    if (!view) {
        
        view = [[UIView alloc]initWithFrame:self.view.bounds];
        
        
        cellScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
        cellScroll.backgroundColor = [UIColor clearColor];
        CGSize pagesScrollViewSize = cellScroll.frame.size;
        cellScroll.showsVerticalScrollIndicator = FALSE;
        cellScroll.tag = 100;
        cellScroll.pagingEnabled = true;
        NSArray *imagesArray;
        NSString *imagesString = [cns checkString:[[self.dataArray objectAtIndex:index]valueForKey:@"images"]];
        if ([imagesString rangeOfString:@","].location == NSNotFound) {
            imagesArray = [NSArray arrayWithObject:imagesString];
        }else{
            imagesArray = [NSArray arrayWithArray:[[[self.dataArray objectAtIndex:index]valueForKey:@"images"]componentsSeparatedByString:@"," ]] ;
        }
        
        
        self.pageImages = imagesArray;
        
        NSInteger pageCount = imagesArray.count;
        //NSLog(@"count is %d",pageCount);
        // Set up the page control
        
        
        // Set up the array to hold the views for each page
        self.pageViews = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < pageCount; ++i) {
            [self.pageViews addObject:[NSNull null]];
        }
        
        cellScroll.contentSize = CGSizeMake(pagesScrollViewSize.width , pagesScrollViewSize.height*self.pageImages.count );
        [self loadVisiblePages:cellScroll];
        cellScroll.delegate = self;
        [view addSubview:cellScroll];
        
        CGSize maximumLabelSize = CGSizeMake(310,9999);
        CGRect newFrame;
        
        
        pageControl = [[UIPageControl alloc] init];
        pageControl.frame = CGRectMake(10,50,200,100);
        pageControl.currentPage = 0;
        pageControl.numberOfPages = pageCount;
        pageControl.transform = CGAffineTransformMakeRotation(M_PI/2.0);
        CGRect pageControlFrame = pageControl.frame;
        pageControlFrame.origin.x = 250;
        pageControlFrame.origin.y = -40;
        pageControl.center = CGPointMake(250, 50);
        pageControl.frame = pageControlFrame;
        pageControl.numberOfPages = self.pageViews.count;
        pageControl.currentPageIndicatorTintColor =  [UIColor colorWithRed:228/255.0 green:61/255.0 blue:64/255.0 alpha:1.0];
        pageControl.pageIndicatorTintColor = [UIColor grayColor];
        pageControl.currentPage = 0;
        self.pageControl = pageControl;
        
        
        bottomView = [[UIView alloc]initWithFrame:CGRectMake(0,0, 320, 200) ];
        bottomView.backgroundColor = [UIColor clearColor];
        //bottomView.backgroundColor = [UIColor redColor];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,-6,150,50)];
        nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = [UIFont systemFontOfSize:16.0];
        nameLabel.textAlignment = UITextAlignmentLeft;
        nameLabel.tag = 2;
        
        distanceLbl = [[UILabel alloc] initWithFrame:CGRectMake(240,-8,80,50)];
        distanceLbl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        distanceLbl.backgroundColor = [UIColor clearColor];
        distanceLbl.textColor = [UIColor whiteColor];
        distanceLbl.font = [UIFont systemFontOfSize:13.0];
        distanceLbl.textAlignment = UITextAlignmentLeft;
        distanceLbl.tag = 2;
        checkNullString *check = [[checkNullString alloc]init];
        NSString *distanceStr = [[self.dataArray objectAtIndex:index]valueForKey:@"distance"];
//        if ([[check checkString:distanceStr] isEqualToString:@""]) {
//            distanceStr = @"Unknown";
//        }
        if ([[check checkString:distanceStr] doubleValue] <= 0) {
            distanceStr = @"Unknown";
        }
        else{
            if ([[check checkString:distanceStr] doubleValue] < 1) {
                distanceStr = [NSString stringWithFormat:@"%1.0f m", [[check checkString:distanceStr] doubleValue]*1000];
            }else{
                distanceStr = [NSString stringWithFormat:@"%1.2f Km", [[check checkString:distanceStr] doubleValue]];
            }
        }
        //        distanceLbl.text = [NSString stringWithFormat:@"%.2f Km",[[[self.dataArray objectAtIndex:index]valueForKey:@"distance"]floatValue]] ;
        distanceLbl.text = distanceStr;
        
        
        moodLblText = [[UILabel alloc] initWithFrame:CGRectMake(5,25,60,30)];
        moodLblText.backgroundColor = [UIColor clearColor];
        moodLblText.textColor = [UIColor whiteColor];
        moodLblText.font = [UIFont boldSystemFontOfSize:14.0];
        moodLblText.textAlignment = UITextAlignmentLeft;
        moodLblText.text = @"Status: ";
        moodLblText.tag = 2;
        
        moodLbl = [[UILabel alloc] initWithFrame:CGRectMake(56,27,260,30)];
        moodLbl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        moodLbl.backgroundColor = [UIColor clearColor];
        moodLbl.textColor = [UIColor whiteColor];
        moodLbl.font = [UIFont systemFontOfSize:13.0];
        moodLbl.textAlignment = UITextAlignmentLeft;
        moodLbl.tag = 2;
        
        aboutLblText = [[UILabel alloc] initWithFrame:CGRectMake(5,35,310,50)];
        aboutLblText.backgroundColor = [UIColor clearColor];
        aboutLblText.textColor = [UIColor whiteColor];
        aboutLblText.font = [UIFont boldSystemFontOfSize:14.0];
        aboutLblText.textAlignment = UITextAlignmentLeft;
        aboutLblText.text = @"About me:";
        aboutLblText.tag = 2;
        
        aboutLbl = [[UILabel alloc] initWithFrame:CGRectMake(5,70,310,50)];
        aboutLbl.backgroundColor = [UIColor clearColor];
        aboutLbl.userInteractionEnabled=NO;
        aboutLbl.numberOfLines =10;
        aboutLbl.textColor = [UIColor whiteColor];
        aboutLbl.font = [UIFont systemFontOfSize:13.0];
        aboutLbl.textAlignment = UITextAlignmentLeft;
        aboutLbl.tag = 2;
        aboutLbl.text = [NSString stringWithFormat:@"%@",[[self.dataArray objectAtIndex:index]valueForKey:@"about_me"]];
        
        CGSize expectedLabelSize = [aboutLbl.text sizeWithFont:aboutLbl.font
                                             constrainedToSize:maximumLabelSize
                                                 lineBreakMode:aboutLbl.lineBreakMode];
        newFrame = aboutLbl.frame;
        newFrame.size.height = expectedLabelSize.height;
        aboutLbl.frame = newFrame;
        
        float nextHeight = newFrame.size.height;
        
        ageLbl = [[UILabel alloc] initWithFrame:CGRectMake(5,(newFrame.origin.y+nextHeight)+5,50,20)];
        ageLbl.backgroundColor = [UIColor clearColor];
        ageLbl.textColor = [UIColor whiteColor];
        ageLbl.font = [UIFont boldSystemFontOfSize:14.0];
        ageLbl.textAlignment = UITextAlignmentLeft;
        ageLbl.text = @"Age: ";
        ageLbl.tag = 2;
        
        ageLblText = [[UILabel alloc] initWithFrame:CGRectMake(40,(newFrame.origin.y+nextHeight)+7,50,20)];
        ageLblText.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        ageLblText.backgroundColor = [UIColor clearColor];
        ageLblText.textColor = [UIColor whiteColor];
        ageLblText.font = [UIFont systemFontOfSize:13.0];
        ageLblText.textAlignment = UITextAlignmentLeft;
        ageLblText.tag = 2;
        
        interestLbl = [[UILabel alloc] initWithFrame:CGRectMake(5,(ageLblText.frame.origin.y +ageLblText.frame.size.height)+5,310,20)];
        interestLbl.backgroundColor = [UIColor clearColor];
        interestLbl.textColor = [UIColor whiteColor];
        interestLbl.font = [UIFont boldSystemFontOfSize:14.0];
        interestLbl.textAlignment = UITextAlignmentLeft;
        interestLbl.text = @"Area of interest:";
        interestLbl.tag = 2;
        
        interestsLbl = [[UILabel alloc] initWithFrame:CGRectMake(5,(interestLbl.frame.origin.y +interestLbl.frame.size.height),310,50)];
        interestsLbl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        interestsLbl.numberOfLines = 4;
        interestsLbl.backgroundColor = [UIColor clearColor];
        interestsLbl.textColor = [UIColor whiteColor];
        interestsLbl.font = [UIFont systemFontOfSize:13.0];
        interestsLbl.textAlignment = UITextAlignmentLeft;
        interestsLbl.tag = 2;
        NSMutableArray *interestarray=[NSMutableArray arrayWithArray:[[[self.dataArray objectAtIndex:index]valueForKey:@"area_intrest"]componentsSeparatedByString:@"," ]];
        NSString *interestString=@"";
        for(int i=0;i<interestarray.count;i++) {
            
            if(interestarray.count == 1) {
                NSString *interest=[[InterestKeys sharedInstance].interestArray objectAtIndex:[[interestarray objectAtIndex:i]intValue]];
                interestString=[interestString stringByAppendingString:[NSString stringWithFormat:@"%@",interest]];
            } else if (interestarray.count > 1 && i == interestarray.count-1) {
                NSString *interest=[[InterestKeys sharedInstance].interestArray objectAtIndex:[[interestarray objectAtIndex:i]intValue]];
                interestString=[interestString stringByAppendingString:[NSString stringWithFormat:@"and %@",interest]];
            } else if (interestarray.count > 1 && i == interestarray.count-2) {
                NSString *interest=[[InterestKeys sharedInstance].interestArray objectAtIndex:[[interestarray objectAtIndex:i]intValue]];
                interestString=[interestString stringByAppendingString:[NSString stringWithFormat:@"%@ ",interest]];
            } else {
                NSString *interest=[[InterestKeys sharedInstance].interestArray objectAtIndex:[[interestarray objectAtIndex:i]intValue]];
                interestString=[interestString stringByAppendingString:[NSString stringWithFormat:@"%@, ",interest]];
            }
        }
        
        interestsLbl.text=interestString;
        
        CGSize expectedLabelSize2 = [interestsLbl.text sizeWithFont:interestsLbl.font
                                                  constrainedToSize:maximumLabelSize
                                                      lineBreakMode:interestsLbl.lineBreakMode];
        CGRect newFrame1 = interestsLbl.frame;
        newFrame1.size.height = expectedLabelSize2.height;
        interestsLbl.frame = newFrame1;
        
        
        
        
        chat = [UIButton buttonWithType:UIButtonTypeCustom];
        [chat addTarget:self
                 action:@selector(beginChat:)
       forControlEvents:UIControlEventTouchUpInside];
        [chat setImage:[UIImage imageNamed:@"pro-chat"] forState:UIControlStateNormal];
        chat.frame = CGRectMake(145.0,-2, 42.0, 40.0);
        
        favourite = [UIButton buttonWithType:UIButtonTypeCustom];
        [favourite addTarget:self
                      action:@selector(setFavorites:)
            forControlEvents:UIControlEventTouchUpInside];
        [favourite setImage:[UIImage imageNamed:@"white_hrt"] forState:UIControlStateNormal];
        favourite.frame = CGRectMake(182.0, 4, 30.0,25.0 );
        favoriteBttn = favourite;
        block = [UIButton buttonWithType:UIButtonTypeCustom];
        [block addTarget:self
                  action:@selector(blockThisUser)
        forControlEvents:UIControlEventTouchUpInside];
        [block setImage:[UIImage imageNamed:@"unblock"] forState:UIControlStateNormal];
        block.frame = CGRectMake(212.0, 4, 30.0,25.0 );
        
        [bottomView addSubview:nameLabel];
        [bottomView addSubview:distanceLbl];
        [bottomView addSubview:aboutLblText];
        [bottomView addSubview:aboutLbl];
        [bottomView addSubview:ageLbl];
        [bottomView addSubview:ageLblText];
        [bottomView addSubview:interestLbl];
        [bottomView addSubview:interestsLbl];
        [bottomView addSubview:chat];
        [bottomView addSubview:moodLblText];
        [bottomView addSubview:moodLbl];
        [bottomView addSubview:favourite];
        [bottomView addSubview:block];
        
        UIScrollView *scrollContent = [[UIScrollView alloc]initWithFrame:CGRectMake(0, view.frame.size.height - 160, 320, 160)];
        [scrollContent addSubview:bottomView];
        
        scrollContent.contentSize=CGSizeMake(320, (newFrame1.origin.y + newFrame1.size.height)+20);
        scrollContent.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pro_bg"]];
        scrollContent.alpha = 1.0;
        [view addSubview:scrollContent];
        
        //MAR - Fix for profile visible without tap
        //scrollContent.hidden = YES;
        scrollContent.hidden = NO;
        self.profileView = scrollContent;
        
        [view addSubview:pageControl];
        [view bringSubviewToFront:pageControl];
    }
    nameLabel.text = [NSString stringWithFormat:@"%@ %@",[[self.dataArray objectAtIndex:index]valueForKey:@"firstname"],[[self.dataArray objectAtIndex:index]valueForKey:@"lastname"]];
    
    
    // age calculations
    dob  = [NSString stringWithFormat:@"%@",[[self.dataArray objectAtIndex:index]valueForKey:@"dob"]];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *profiledob = [dateFormatter dateFromString:dob];
    
    NSDate *today = [NSDate date];
    NSDateComponents *ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:profiledob
                                       toDate:today
                                       options:0];
    ageLblText.text = [NSString stringWithFormat:@"%d", ageComponents.year];
    //NSLog(@"%@",dob);
    // end age calculations
    
    moodLbl.text = [NSString stringWithFormat:@"%@",[[self.dataArray objectAtIndex:index]valueForKey:@"mood_message"]];
    
    BOOL isFavorite=[[[self.dataArray objectAtIndex:index] valueForKey:@"Favourite"]boolValue];
    
    //NSLog(@"isFavorite%d",isFavorite);
    
    //NSLog(@"dataArray%@",[[self.dataArray objectAtIndex:index] valueForKey:@"id"]);
    
    if(isFavorite){
        favourite.selected=YES;
        [favourite setImage:[UIImage imageNamed:@"fav_icon"] forState:UIControlStateNormal];
    }
    else{
        favourite.selected=NO;
        [favourite setImage:[UIImage imageNamed:@"white_hrt"] forState:UIControlStateNormal];
    }
    
    
    
    return view;
}


-(void)visitProfile {
    if([[CMLNetworkManager sharedInstance] hasConnectivity]){
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        
//        //NSLog(@"self.dataArray=%@",self.dataArray );
        
        //NSLog(@"currentIndex=%i",currentIndex);
        
        //NSLog(@"userIdString%@",userIdString);
        
        [dictionary setObject:[[self.dataArray objectAtIndex:currentIndex]objectForKey:@"userid"] forKey:@"visit_user_id"];
        
        [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
        HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
        [request initwithurl:BASE_URL requestStr:VISITPROFILE requestType:POST input:YES inputValues:dictionary];
        //NSLog(@"request%@",request);
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
}


#pragma mark - JTListViewDelegate

- (CGFloat)listView:(JTListView *)listView widthForItemAtIndex:(NSUInteger)index
{
    return 320.0;
}

- (CGFloat)listView:(JTListView *)listView heightForItemAtIndex:(NSUInteger)index
{
    return 80;
}

@end