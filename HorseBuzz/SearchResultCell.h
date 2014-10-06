//
//  SearchResultCell.h
//  HorseBuzz
//
//  Created by Welcome on 24/08/14.
//  Copyright (c) 2014 ggau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *Fullname;
@property (strong, nonatomic) IBOutlet UILabel *Location;

@property (strong, nonatomic) IBOutlet UIImageView *ProfileImage;

@property (strong, nonatomic) IBOutlet UIImageView *StatusImage;


@end
