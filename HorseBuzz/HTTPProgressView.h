//
//  HTTPProgressView.h
//  HorseBuzz
//
//  Created by Welcome on 28/09/14.
//  Copyright (c) 2014 ggau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequest/ASIFormDataRequest.h"
#import "RoundProgress/CERoundProgressView.h"

@interface HTTPProgressView : UIView <ASIProgressDelegate>

@property(nonatomic, retain)CERoundProgressView *progressIndicator;

@end
