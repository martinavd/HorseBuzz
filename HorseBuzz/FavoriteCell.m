//
//  FavoriteCell.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 22/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "FavoriteCell.h"

@implementation FavoriteCell
@synthesize personImage,personLocation,personName,personOnlineStatus,favButton,errorLabel,statusImg;

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
