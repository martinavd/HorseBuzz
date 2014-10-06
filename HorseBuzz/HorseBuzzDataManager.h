//
//  HorseBuzzDataManager.h
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 28/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPRequestHandler.h"

@interface HorseBuzzDataManager : NSObject

@property(nonatomic,retain)NSString *userId;
@property(nonatomic,retain)NSString *deviceToken;
@property(nonatomic,strong)NSString *myImage;
@property(nonatomic,strong)NSMutableDictionary *dictMedia;
@property(nonatomic,strong)HTTPRequestHandler *requestHandler;

+ (HorseBuzzDataManager*)sharedInstance;


@end
