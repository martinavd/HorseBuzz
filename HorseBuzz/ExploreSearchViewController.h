//
//  ExploreSearchViewController.h
//  HorseBuzz
//
//  Created by Welcome on 23/08/14.
//  Copyright (c) 2014 ggau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPURLRequest.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ExploreSearchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,HTTPURLRequestDelegate,UIBarPositioningDelegate,UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableString *selectionTarget;
@property (strong, nonatomic) IBOutlet UISearchBar *_searchBar;

@end
