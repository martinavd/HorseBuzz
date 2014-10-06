//
//  HTTPRequestHandler.h
//  HorseBuzz
//
//  Created by MARTIN on 27/09/14.
//  Copyright (c) 2014 ggau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequest/ASIFormDataRequest.h"

@interface HTTPRequestHandler : NSObject<ASIHTTPRequestDelegate, ASIProgressDelegate>

@property(nonatomic,retain)NSMutableDictionary *activeRequests;

-(void)addRequest:(ASIFormDataRequest *)request forKey:(NSString *)key;
-(void)setDelegate:(ASIFormDataRequest *)request forKey:(NSString *)key;
-(UIView *)getProgressDelegate:(ASIFormDataRequest *)request;
-(NSDictionary *)getPendingUploadsforUserID:(NSString *)UserId toReciverId:(NSString *)receiverId;
@end
