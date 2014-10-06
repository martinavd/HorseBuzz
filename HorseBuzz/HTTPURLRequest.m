//
//  HTTPURLRequest.m
//  Bimbadgen
//
//  Created by  on 13/03/13.
//  Copyright (c) 2013 Santhosh Raj Sundaram. All rights reserved.
//

#import "HTTPURLRequest.h"
#import "SBJSON.h"


@implementation HTTPURLRequest
@synthesize delegate;
-(void)initwithurl:(NSString *)urlStr requestStr:(NSString *)requestStr requestType:(NSString *)postType input:(BOOL)isInput inputValues:(NSMutableDictionary *)values {
    responseData =[[NSMutableData alloc ]init];
    urlStr=[NSString stringWithFormat:@"%@%@",urlStr,requestStr];
    //NSLog(@"urlStrurlStrurlStr iss%@",urlStr);
   NSMutableURLRequest* request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlStr ]];
    [request setHTTPMethod:postType];
    if(isInput){
        SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
        NSString *jsonRequest = [jsonWriter stringWithObject:values];
       //NSLog(@"+++++++++++++++++++++++++++++++  %@",jsonRequest);
        NSData *requestData = [NSData dataWithBytes:[jsonRequest UTF8String] length:[jsonRequest length]];
        
        //NSLog(@"requestDatais%@",requestData);
        [request setValue:@"application/text" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody: requestData];
    }
    connection = [[NSURLConnection alloc]initWithRequest:request delegate:self ];
 //NSLog(@"request data+++++%@",request);
}


-(void)cancelRequest{
    [connection cancel];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [delegate getUrlConnectionStatus:error State:NO];
   
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [responseData  appendData:data];
    //NSLog(@"receive data%@",data);
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [responseData setLength:0];
    //NSLog(@"receive response%@",responseData);
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *responseStr=[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//    //NSLog(@"+++++++++++++++++  %@",responseStr);
    SBJsonParser *jsonData=[[SBJsonParser  alloc]init];
    NSMutableDictionary *dic=[jsonData  objectWithString:responseStr];
    [delegate getResponsedata:dic];
        
}


@end
