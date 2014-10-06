//
//  MessageCell.h
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 22/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell
@property(nonatomic,retain)IBOutlet UIImageView *personImage;
@property(nonatomic,retain)IBOutlet UILabel *personName;
@property(nonatomic,retain)IBOutlet UILabel *message;
@property(nonatomic,retain)IBOutlet UILabel *time;
@end
