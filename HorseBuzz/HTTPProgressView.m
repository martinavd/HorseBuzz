//
//  HTTPProgressView.m
//  HorseBuzz
//
//  Created by Welcome on 28/09/14.
//  Copyright (c) 2014 ggau. All rights reserved.
//

#import "HTTPProgressView.h"

@implementation HTTPProgressView
@synthesize progressIndicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setProgress:(float)newProgress{
    
    [progressIndicator progress];
}

@end
