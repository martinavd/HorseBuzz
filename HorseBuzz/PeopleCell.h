//
//  PeopleCell.h
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 21/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeopleCell : UITableViewCell
@property(nonatomic,retain)IBOutlet UIImageView *personImage;
@property(nonatomic,retain)IBOutlet UILabel *personName;
@property(nonatomic,retain)IBOutlet UILabel *personLocation;
@property(nonatomic,retain)IBOutlet UILabel *personOnlineStatus;
@property(nonatomic,retain)IBOutlet UIImageView *statusImg;
@property(nonatomic,retain)IBOutlet UILabel *errorLabel;


@end
