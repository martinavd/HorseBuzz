//
//  MyImage.h
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 13/03/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface MyImage : NSObject

+ (UIImage*)imageWithImage:(UIImage *)image convertToWidth:(float)width covertToHeight:(float)height;
+ (UIImage*)imageWithImage:(UIImage *)image convertToHeight:(float)height;
+ (UIImage*)imageWithImage:(UIImage *)image convertToWidth:(float)width;
+ (UIImage*)imageWithImage:(UIImage *)image fitInsideWidth:(float)width fitInsideHeight:(float)height;
+ (UIImage*)imageWithImage:(UIImage *)image fitOutsideWidth:(float)width fitOutsideHeight:(float)height;
+ (UIImage*)imageWithImage:(UIImage *)image cropToWidth:(float)width cropToHeight:(float)height;

@end