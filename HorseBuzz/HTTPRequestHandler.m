//
//  HTTPRequestHandler.m
//  HorseBuzz
//
//  Created by Welcome on 27/09/14.
//  Copyright (c) 2014 ggau. All rights reserved.
//

#import "HTTPRequestHandler.h"
#import "HorseBuzzDataManager.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ChatViewController.h"
#import "RoundProgress/CERoundProgressView.h"

@implementation HTTPRequestHandler
@synthesize activeRequests;

-(void)addRequest:(ASIFormDataRequest *)request forKey:(NSString *)key{
    if (!activeRequests)
        activeRequests = [[NSMutableDictionary alloc] init];
    [activeRequests setObject:request forKey:key];
}
    

-(void)setDelegate:(ASIFormDataRequest *)request forKey:(NSString *)key{
    [request setDelegate:self];
    if (!activeRequests)
        activeRequests = [[NSMutableDictionary alloc] init];
    [activeRequests setObject:request forKey:key];
}

-(UIView *)getProgressDelegate:(ASIFormDataRequest *)request {
    
    CERoundProgressView *progressIndicator = [[CERoundProgressView alloc] initWithFrame:CGRectMake(68, 68, 64, 64)];
    UIColor *tintColor = [UIColor orangeColor];
    [[CERoundProgressView appearance] setTintColor:tintColor];
    progressIndicator.trackColor = [UIColor colorWithWhite:0.80 alpha:1.0];
    progressIndicator.startAngle = (3.0*M_PI)/2.0;
    [request setUploadProgressDelegate:progressIndicator];
    return (UIView *)progressIndicator;
}

-(NSDictionary *)getPendingUploadsforUserID:(NSString *)UserId toReciverId:(NSString *)receiverId{
    
    for (id key in activeRequests) {
        //
        NSDictionary *dict = ((ASIFormDataRequest *)[activeRequests objectForKey:key]).userInfo;
        if ([(NSString *)[dict objectForKey:@"userId"] isEqualToString:UserId] && [(NSString *)[dict objectForKey:@"receiverId"] isEqualToString: receiverId]) {
            
            return dict;
        }
    }
    
    return nil;
}


#pragma mark ASIHTTPRequestDelegate Delegate Methods
- (void)requestFinished:(ASIHTTPRequest *)request {
	
	//NSString *respose = [request responseString];
    NSMutableDictionary *response = [NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingMutableContainers error:nil];

    NSDictionary *dict = request.userInfo;
    ASIFormDataRequest *req = [dict objectForKey:@"requestObject"];
    NSString *filename = [response objectForKey:@"imagepath"];
    
    if (filename) {
        //[request removeUploadProgressSoFar];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *newfilepath = [NSString stringWithFormat:@"%@/%@",documentsDirectory,filename];
        NSString *tempFile = [dict objectForKey:@"localfilepath"];
        NSString *imagetype = [dict objectForKey:@"mediatype"];
        NSError* error=nil;
        [[NSFileManager defaultManager] copyItemAtPath:tempFile toPath:newfilepath error:&error];
        
        
        UIView *targetView = [req.uploadProgressDelegate superview];
        if ([imagetype  isEqual: @"mov"]) {
            NSDictionary *newdict  = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@":MOV-%@",filename],@"message",[dict objectForKey:@"userId"],@"userId", [dict objectForKey:@"timestamp"] , @"timestamp", filename,@"filename", nil];
            [(ChatViewController *)[dict objectForKey:@"source"] UploadCompleted:targetView withOldData:dict withNewData:newdict withThumbnail:ActionThumnailPlay];
            
            
        }
        else{
            NSDictionary *newdict  = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@":IMG-%@",filename],@"message",[dict objectForKey:@"userId"],@"userId", [dict objectForKey:@"timestamp"] , @"timestamp", filename,@"filename", nil];
            
            [(ChatViewController *)[dict objectForKey:@"source"] UploadCompleted:targetView withOldData:dict withNewData:newdict];
            
        }

        [activeRequests removeObjectForKey:tempFile];
    }
    else
    {
        NSString *respose = [request responseString];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"HorseBuzz" message:respose delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];

    }
    [req.uploadProgressDelegate removeFromSuperview];

    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
}
- (void)requestFailed:(ASIHTTPRequest *)request {
	
	NSString *receivedString = [request responseString];
    if (!receivedString)
        receivedString = @"No data connection, uploading media cancelled";
    
	UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Message" message:receivedString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alertView show];
    
    NSDictionary *dict = request.userInfo;
    ASIFormDataRequest *req = [dict objectForKey:@"requestObject"];
    
    NSString *tempFile = [dict objectForKey:@"localfilepath"];
   //[activeRequests removeObjectForKey:tempFile];
    
    UIView *targetView = [req.uploadProgressDelegate superview];
    [req.uploadProgressDelegate removeFromSuperview];
    
    NSDictionary *newdict  = [NSDictionary dictionaryWithObjectsAndKeys:@":MOV-sending",@"message",[dict objectForKey:@"userId"],@"userId", [dict objectForKey:@"timestamp"] , @"timestamp", tempFile,@"filename", nil];
    [(ChatViewController *)[dict objectForKey:@"source"] UploadCompleted:targetView withOldData:dict withNewData:newdict withThumbnail:ActionThumnailUpload];
    
    [request removeUploadProgressSoFar];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

}

- (void)setProgress:(float)newProgress{
    
}

@end
