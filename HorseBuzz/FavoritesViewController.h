//
//  FavoritesViewController.h
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 20/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPURLRequest.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface FavoritesViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,HTTPURLRequestDelegate>

@end
