//
//  InterestKeys.m
//  HorseBuzz
//
//  Created by Ritheesh Koodalil on 13/02/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "InterestKeys.h"
#import "CMLNetworkManager.h"
#import "HorseBuzzDataManager.h"

@implementation InterestKeys
@synthesize interestArray;
@synthesize interestIDArray;

+(InterestKeys *)sharedInstance{
    static InterestKeys *sharedSingleton = nil;
    if(!sharedSingleton) {
        @synchronized(sharedSingleton) {
            sharedSingleton = [[super alloc]init];
        }
    }
    
    return sharedSingleton;
    
}

-(void)getInterestKey{
    
    if([[CMLNetworkManager sharedInstance] hasConnectivity]){
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
        request.delegate=self;
        [request initwithurl:BASE_URL requestStr:GETINTERESTLIST requestType:POST input:NO inputValues:dictionary];
        //NSLog(@"+++++++++++++++  %@",request);
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
}

-(void)getResponsedata:(NSDictionary *)data{
    
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
    
    if (status) {
        interestArray=[[NSMutableArray alloc]initWithObjects:@"All", nil];
        interestIDArray=[[NSMutableArray alloc]initWithObjects:@"100", nil];
        NSMutableArray *responseArray=[[NSMutableArray alloc]initWithArray:[data valueForKey:@"intrestList"]];
        for(int i=0;i<responseArray.count;i++){
            [interestArray addObject:[[responseArray objectAtIndex:i ]valueForKey:@"area_intrest"]];
            [interestIDArray addObject:[[responseArray objectAtIndex:i ] valueForKey:@"id"]];
        }
        
        RegisterViewController *regustration=[[RegisterViewController alloc]init];
        [regustration.interestTable  reloadData];
    }
}

-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
}
@end
