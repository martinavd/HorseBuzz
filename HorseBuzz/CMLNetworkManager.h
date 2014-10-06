//
//  CMLNetworkManager.h
//  CleanMe
//
//  Created by Balasubramanian Sundarasamy on 15/11/12.
//  Copyright (c) 2012 Ardhika Software Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMLNetworkManager : NSObject
+(CMLNetworkManager *) sharedInstance;

-(BOOL) hasConnectivity;
@end
