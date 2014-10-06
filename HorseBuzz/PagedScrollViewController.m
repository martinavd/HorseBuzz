//
//  ProfileViewController.h
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 04/03/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)

#import "PagedScrollViewController.h"
#import "ImageData.h"
#import "MyImage.h"
#import "GAI.h"
#import "HorseBuzzConfig.h"

@interface PagedScrollViewController ()
@property (nonatomic, strong) NSMutableArray *pageViews;

- (void)loadVisiblePages;
- (void)loadPage:(NSInteger)page;
- (void)purgePage:(NSInteger)page;
@end

@implementation PagedScrollViewController
@synthesize delegate;
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize selectedIndex;
@synthesize pageImages = _pageImages;
@synthesize pageViews = _pageViews;
@synthesize showBarButton;
#pragma mark -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadVisiblePages {
    // First, determine which page is currently visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
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
        [self loadPage:i];
    }
    for (NSInteger i=lastPage+1; i<self.pageImages.count; i++) {
        [self purgePage:i];
    }
}

- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= self.pageImages.count) {
        // If it's outside the range of what we have to display, then do nothing
        return;
    }
    
    // Load an individual page, first seeing if we've already loaded it
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        NSDictionary *dict =[self.pageImages objectAtIndex:page];
        ImageData *imageData = [dict objectForKey:[NSNumber numberWithInt:page+1]];
        UIImageView *newPageView;
        __block UIActivityIndicatorView *activityIndicator;
        
        if ([imageData.imageType isEqualToString:@"url"]) {
            newPageView = [[UIImageView alloc] init];
            __weak UIImageView *brandImageView = newPageView;
            [newPageView setImageWithURL:[NSURL URLWithString:imageData.imgaeUrl] placeholderImage:[UIImage imageNamed:@"noimage"] options:SDWebImageProgressiveDownload progress:^(NSUInteger receivedSize, long long expectedSize)
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
                 brandImageView.contentMode = UIViewContentModeScaleAspectFit;
                 [activityIndicator removeFromSuperview];
                 activityIndicator = nil;
             }];
        }
        else{
            newPageView = [[UIImageView alloc] initWithImage:imageData.image];
            
        }
        
        newPageView.contentMode = UIViewContentModeScaleAspectFit;
        newPageView.frame = CGRectMake(frame.size.width * page, 0, 320, self.view.frame.size.height);
        [self.scrollView addSubview:newPageView];
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


#pragma mark -

- (void)viewDidLoad {
    
    // google tracking code
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:GOOGLEANALITICSCODE];
    //[tracker trackView:@"Horse Buzz - Pages scroll view"];
    [tracker set:@"ScreenName" value:@"Horse Buzz - Pages scroll view" ];
    // google tracking code end
    
    [super viewDidLoad];
    
    self.title = @"Photos";
    float version = [[[UIDevice currentDevice] systemVersion]floatValue];
    if (version >= 7.0) {
        self.navigationItem.hidesBackButton =FALSE;
    }else{
        UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0,0,70,20);
        [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
        [backButton setTitle:@" Profile" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(moveBack) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarButton =[[UIBarButtonItem alloc]initWithCustomView:backButton];
        self.navigationItem.leftBarButtonItem = backBarButton;
    }
    // Set up the image we want to scroll & zoom and add it to the scroll view
    if (self.showBarButton) {
        UIButton *setAsProfile = [UIButton buttonWithType:UIButtonTypeCustom];
        setAsProfile.frame = CGRectMake(0, 0, 20, 20);
        [setAsProfile addTarget:self action:@selector(setProfile) forControlEvents:UIControlEventTouchUpInside];
        [setAsProfile setImage:[UIImage imageNamed:@"set_profile"] forState:UIControlStateNormal];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:setAsProfile];
        self.navigationItem.rightBarButtonItem = barButton;
    }
    
    NSInteger pageCount = self.pageImages.count;
    
    // Set up the page control
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = pageCount;
    
    // Set up the array to hold the views for each page
    self.pageViews = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pageCount; ++i) {
        [self.pageViews addObject:[NSNull null]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set up the content size of the scroll view
    CGSize pagesScrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * self.pageImages.count, pagesScrollViewSize.height-100);
    self.scrollView.bounces = NO;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.alwaysBounceHorizontal = NO;
    // Load the initial set of pages that are on screen
    
    if (self.selectedIndex == 0) {
        [self loadVisiblePages];
    }
    else{
        [self.scrollView scrollRectToVisible:CGRectMake(self.scrollView.frame.size.width * self.selectedIndex, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) animated:YES];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.scrollView = nil;
    self.pageControl = nil;
    self.pageImages = nil;
    self.pageViews = nil;
}
-(void)moveBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)setProfile{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    NSDictionary *dict =[self.pageImages objectAtIndex:page];
    ImageData *imd = [dict objectForKey:[NSNumber numberWithInt:page+1]];
    [self.delegate setProfileImageWithSelctionImageData:imd];
    
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Load the pages which are now on screen
    
    [self loadVisiblePages];
}

@end
