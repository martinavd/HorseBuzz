//
//  PersonalDetail.m
//  HorseBuzz
//
//  Created by Ritheesh Koodalil on 09/02/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import "PersonalDetail.h"
#import "CMLNetworkManager.h"
#import "HorseBuzzDataManager.h"

@implementation PersonalDetail 
@synthesize profileDetailArray;
@synthesize ProfileImageUrl;

-(void)getPrefilDetail{
    
    if([[CMLNetworkManager sharedInstance] hasConnectivity]){
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        ;
        [dictionary setObject:[HorseBuzzDataManager sharedInstance].userId forKey:@"user_id"];
        HTTPURLRequest *request=[[HTTPURLRequest alloc]init];
        request.delegate=self;
        [request initwithurl:BASE_URL requestStr:PROFILEDETAILS requestType:POST input:YES inputValues:dictionary];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:PRODUCT_NAME message:CONNECTION_MESSAGE delegate:self cancelButtonTitle:ALERT_OK otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)getResponsedata:(NSDictionary *)data{
        
    BOOL status = [[data objectForKey:SUCCESS]boolValue];
   
    if (status) {
        profileDetailArray=[[NSMutableDictionary alloc]initWithDictionary:data];
         NSMutableArray *imageArray=[[NSMutableArray alloc]initWithArray:[profileDetailArray  objectForKey:@"userImages"]];
        for(int i=0;i<imageArray.count;i++){
            if([[[imageArray objectAtIndex:i] valueForKey:@"imagetype"] isEqualToString:@"profile"]){
                NSString *brandimgURl=[NSString stringWithFormat:@"%@%@",[profileDetailArray  objectForKey:@"imagebaseurl"],[[imageArray objectAtIndex:i] valueForKey:@"imagepath"]];
                self.ProfileImageUrl = brandimgURl;
                [HorseBuzzDataManager sharedInstance].myImage = [[imageArray objectAtIndex:i] valueForKey:@"imagepath"];
                
            }
    }
}
}
-(void)getUrlConnectionStatus:(NSError *)str State:(BOOL)status{
    
}
@end
