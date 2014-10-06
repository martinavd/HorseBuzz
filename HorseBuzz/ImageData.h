//
//  ImageData.h
//  HorseBuzz
//
//  Created by Welcome on 14/09/14.
//  Copyright (c) 2014 ggau. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    HTTPSendMedia = 1,
    HTTPReciveMedia = 2
} HTTPActivity;

typedef enum {
    MEDIATypeVedioFile = 1,
    MEDIATypeImageFile = 2
} MEDIAType;


@interface ImageData : NSObject
{
    
}

@property(nonatomic,assign)BOOL hasImage;
@property(nonatomic,assign)NSString *imageType;
@property(nonatomic,strong)NSString *imgaeUrl;
@property(nonatomic,strong)UIImage *image;
@property(nonatomic,strong)NSString *imageID;

//MAR - some extened attributes
@property(nonatomic,retain)     NSString            *resourceURL;
@property(nonatomic,retain)     NSString            *filename;
@property(nonatomic,retain)     UIImageView         *imageView;
@property(nonatomic,retain)     NSString            *localfilepath;
@property(nonatomic,retain)     NSMutableData       *responseData;
@property (nonatomic, strong)   UIProgressView      *progressView;
@property(nonatomic,retain)     UILabel             *lblProgress;
@property(nonatomic,assign)     long  long          expectedContentLength;
@property(nonatomic,assign)     HTTPActivity        thisAction;
@property(nonatomic,assign)     MEDIAType           mediaType;
@property(retain,strong)        NSURLConnection     *connection;
@end
