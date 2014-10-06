//
//  BlockedUserCell.h
//  HorseBuzz
//
//  Created by Ritheesh Koodalil on 20/02/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlockedUserCell : UITableViewCell
@property(nonatomic,retain)IBOutlet UIImageView *personImage;
@property(nonatomic,retain)IBOutlet UILabel *personName;
@property(nonatomic,retain)IBOutlet UILabel *personLocation;
@property(nonatomic,retain)IBOutlet UIButton *unBlockBttn;
@end
