//
//  PersonalDetail.h
//  HorseBuzz
//
//  Created by Ritheesh Koodalil on 09/02/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPURLRequest.h"
#import "HorseBuzzConfig.h"

@interface PersonalDetail : NSObject  <HTTPURLRequestDelegate>
@property(nonatomic,retain)NSMutableDictionary *profileDetailArray;
@property(nonatomic,retain)NSString *ProfileImageUrl;

-(void)getPrefilDetail;

@end
