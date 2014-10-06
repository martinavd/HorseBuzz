//
//  SetInvisibleUser.m
//  HorseBuzz
//
//  Created by Ritheesh Koodalil on 21/02/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "SetInvisibleUser.h"
#import "HorseBuzzConfig.h"
#import "HorseBuzzDataManager.h"
#import "CMLNetworkManager.h"

@implementation SetInvisibleUser

-(void)setVisibilty{
    if([[CMLNetworkManager sharedInstance] hasConnectivity]){
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        ;
        [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
        if([[NSUserDefaults standardUserDefaults]boolForKey:@"isInvisible"]){
            [dictionary setObject:@"invisible" forKey:@"status"];
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"isInvisible"];
        }
        else{
            [dictionary setObject:@"online" forKey:@"status"];
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isInvisible"];
        }
        HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
        request.delegate=self;
        [request initwithurl:BASE_URL requestStr:CHANGELOGINSTATUS requestType:POST input:YES inputValues:dictionary];
    }

}

-(void)getResponsedata:(NSDictionary *)data{
}

-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
}

@end
