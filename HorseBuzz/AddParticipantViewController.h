//
//  AddParticipantViewController.h
//  HorseBuzz
//
//  Created by Welcome on 10/09/14.
//  Copyright (c) 2014 ggau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPURLRequest.h"

@interface AddParticipantViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,HTTPURLRequestDelegate,UIBarPositioningDelegate,UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *_searchBar;

@property (strong, nonatomic) NSMutableString *selectionTarget;
@property(strong,nonatomic)NSString *groupId;
@property(strong,nonatomic)NSString *groupName;
@property(assign,nonatomic)UIImage *profileImage;
@property(strong,nonatomic)NSMutableArray *participantlist;
@end
