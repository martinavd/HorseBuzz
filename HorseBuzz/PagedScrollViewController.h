//
//  ProfileViewController.h
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 04/03/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "ImageData.h"

@class PagedScrollViewController;
@protocol PagedScrollDelegate

-(void)setProfileImageWithSelctionImageData:(ImageData*)data;

@end


@interface PagedScrollViewController : UIViewController <UIScrollViewDelegate>
@property(nonatomic,strong)id<PagedScrollDelegate>delegate;
@property (nonatomic, strong) NSArray *pageImages;
@property (nonatomic, readwrite) int selectedIndex;;
@property (nonatomic, assign) BOOL showBarButton;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
- (void)loadPage:(NSInteger)page;

@end
