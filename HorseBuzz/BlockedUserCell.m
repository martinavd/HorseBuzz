//
//  BlockedUserCell.m
//  HorseBuzz
//
//  Created by Ritheesh Koodalil on 20/02/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "BlockedUserCell.h"

@implementation BlockedUserCell
@synthesize personImage,personLocation,personName,unBlockBttn;
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
