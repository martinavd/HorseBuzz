//
//  MyImage.m
//  HorseBuzz
//
//  Created by Madhusudhan Rao Palem on 13/03/14.
//  Copyright (c) 2014 Madhusudhan Rao Palem. All rights reserved.
//
#import "MyImage.h"

@implementation MyImage

+ (UIImage*)imageWithImage:(UIImage *)image convertToWidth:(float)width covertToHeight:(float)height {
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimage;
}

+ (UIImage*)imageWithImage:(UIImage *)image convertToHeight:(float)height {
    float ratio = image.size.height / height;
    float width = image.size.width / ratio;
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimage;
}

+ (UIImage*)imageWithImage:(UIImage *)image convertToWidth:(float)width {
    float ratio = image.size.width / width;
    float height = image.size.height / ratio;
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimage;
}

+ (UIImage*)imageWithImage:(UIImage *)image fitInsideWidth:(float)width fitInsideHeight:(float)height {
    if (image.size.height >= image.size.width) {
        return [MyImage imageWithImage:image convertToWidth:width];
    } else {
        return [MyImage imageWithImage:image convertToHeight:height];
    }
}

+ (UIImage*)imageWithImage:(UIImage *)image fitOutsideWidth:(float)width fitOutsideHeight:(float)height {
    if (image.size.height >= image.size.width) {
        return [MyImage imageWithImage:image convertToHeight:height];
    } else {
        return [MyImage imageWithImage:image convertToWidth:width];
    }
}

+ (UIImage*)imageWithImage:(UIImage *)image cropToWidth:(float)width cropToHeight:(float)height {
    CGSize size = [image size];
    CGRect rect = CGRectMake(((size.width-width) / 2.0f), ((size.height-height) / 2.0f), width, height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage * img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return img;
}

@end