//
//  userProfileDeatil.h
//  HorseBuzz
//
//  Created by Ritheesh Koodalil on 13/02/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import  <MobileCoreServices/MobileCoreServices.h>
#import "HTTPURLRequest.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIButton+WebCache.h>
#import "JTListView.h"
#import "checkNullString.h"
@interface userProfileDeatil : JTListViewController <UIActionSheetDelegate,UIScrollViewDelegate,HTTPURLRequestDelegate,UIScrollViewDelegate>{
    UIView *columnView;
    checkNullString *cns;
    
}
@property(nonatomic,strong)IBOutlet UIScrollView *scrollView;
@property(nonatomic,weak)IBOutlet UILabel *placeHolder;
@property(nonatomic,weak)IBOutlet UITextView *statusTextView;
@property(nonatomic,weak)IBOutlet UIImageView *profileImage;
@property(nonatomic,weak)IBOutlet UILabel *moodLabel;
//@property(nonatomic,weak)IBOutlet UILabel *nameLabel;
@property(nonatomic,weak)IBOutlet UILabel *sexLabel;
@property(nonatomic,weak)IBOutlet UILabel *aboutMeLabel;
@property(nonatomic,weak)IBOutlet UILabel *areaOfInterest;
@property(nonatomic,weak)IBOutlet UILabel *distance;
@property(nonatomic,weak)IBOutlet UIButton *favoriteBttn;
@property(nonatomic,weak)IBOutlet UIView *aboutView;
@property(nonatomic,weak)IBOutlet UIView *photosView;
@property (nonatomic, strong) NSArray *pageImages;

@property (nonatomic, strong) UIPageControl *pageControl;
@property(nonatomic,strong) UIView *profileView;

@property(nonatomic,strong) NSString *distanceString;

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) int selectedIndex;


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil VisitUserID:(NSString *)userId;
-(IBAction)setFavorites:(UIButton *)sender;
-(IBAction)blockThisUser;
-(IBAction)beginChat:(UIButton *)sender;
-(IBAction)showPics:(UIButton *)sender;

@end
