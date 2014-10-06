//
//  BlockedViewController.h
//  HorseBuzz
//
//  Created by Ritheesh Koodalil on 20/02/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPURLRequest.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface BlockedViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,HTTPURLRequestDelegate>{
    IBOutlet UITableView *blockeTableView;
}

@end
