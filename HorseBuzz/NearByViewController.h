//
//  NearByViewController.h
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 16/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "HTTPURLRequest.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "WEPopoverContentViewController.h"
#import "WEPopoverController.h"


@interface NearByViewController : UIViewController<MKMapViewDelegate,MKAnnotation,UITableViewDataSource,UITableViewDelegate,HTTPURLRequestDelegate,WEPopoverControllerDelegate,WEPopoverContentDelegate>{
    IBOutlet UIView *guideView;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic, strong) WEPopoverController *popoverController;
@property(nonatomic,retain)IBOutlet UIButton *filterBttn;
-(IBAction)showFilter;
@end
