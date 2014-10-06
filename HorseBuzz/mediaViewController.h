//
//  mediaViewController.h
//  HorseBuzz
//
//  Created by Welcome on 15/09/14.
//  Copyright (c) 2014 ggau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface mediaViewController : UIViewController 


@property (nonatomic,retain) UIImageView            *tappedImage;
@property (nonatomic,retain) NSString               *filepath;
@property (nonatomic,retain) UIViewController       *senderViewController;

- (IBAction)doDone:(id)sender;

@end
