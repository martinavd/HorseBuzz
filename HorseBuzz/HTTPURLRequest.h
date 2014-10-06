//
//  HTTPURLRequest.h
//  Bimbadgen
//
//  Created by  on 13/03/13.
//  Copyright (c) 2013 Santhosh Raj Sundaram. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HTTPURLRequest;
@protocol HTTPURLRequestDelegate

-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status;
-(void)getResponsedata:(NSDictionary *)data;

@end


@interface HTTPURLRequest : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>{
    id <HTTPURLRequestDelegate>delegate;
    NSMutableData *responseData;
    NSString *urlPath;
    NSURLConnection *connection;
}
@property(nonatomic,strong)id <HTTPURLRequestDelegate>delegate;

-(void)initwithurl:(NSString *)urlStr requestStr:(NSString *)requestStr requestType:(NSString *)postType input:(BOOL)isInput inputValues:(NSMutableDictionary *)values;
-(void)cancelRequest;
@end

/*
@interface HTTPURLRequest : NSObject

@end
*/