//
//  FilterSettingViewController.h
//  HorseBuzz
//
//  Created by Ritheesh Koodalil on 20/02/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPURLRequest.h"

@interface FilterSettingViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,HTTPURLRequestDelegate,UIAlertViewDelegate>{
    IBOutlet UITableView *interestTable;
    
}

-(IBAction)subMitInterest:(id)sender;

@end
