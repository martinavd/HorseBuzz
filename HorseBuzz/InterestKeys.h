//
//  InterestKeys.h
//  HorseBuzz
//
//  Created by Ritheesh Koodalil on 13/02/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPURLRequest.h"
#import "HorseBuzzConfig.h"
#import "RegisterViewController.h"

@interface InterestKeys : NSObject  <HTTPURLRequestDelegate>
@property(nonatomic,retain)NSMutableArray *interestArray;
@property(nonatomic,retain)NSMutableArray *interestIDArray;

-(void)getInterestKey;
+(InterestKeys *)sharedInstance;
@end

