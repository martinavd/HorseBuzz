//
//  HorseBuzzDataManager.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 28/01/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "HorseBuzzDataManager.h"


@implementation HorseBuzzDataManager
@synthesize userId;
@synthesize deviceToken;
@synthesize myImage;
@synthesize dictMedia;
@synthesize requestHandler;

+ (HorseBuzzDataManager*)sharedInstance{
    static HorseBuzzDataManager *sharedSingleton ;
    if(!sharedSingleton) {
        @synchronized(sharedSingleton) {
            sharedSingleton = [[super alloc]init];
        }
    }
    return sharedSingleton;
}



@end
