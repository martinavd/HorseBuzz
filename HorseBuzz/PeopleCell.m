//
//  PeopleCell.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 21/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "PeopleCell.h"

@implementation PeopleCell
@synthesize personImage,personLocation,personName,personOnlineStatus,errorLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
