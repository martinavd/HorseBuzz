//
//  mediaViewController.m
//  HorseBuzz
//
//  Created by Welcome on 15/09/14.
//  Copyright (c) 2014 ggau. All rights reserved.
//

#import "mediaViewController.h"

@interface mediaViewController ()
{
    UIImageView *imageView;
    UIImage *originalImage;
    UIPinchGestureRecognizer *twoFingerPinch;
}


@end

@implementation mediaViewController

@synthesize filepath;
@synthesize tappedImage;
@synthesize senderViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    [self.navigationController setNavigationBarHidden:YES];
    
    UIView *topView=[[UIView alloc]initWithFrame:CGRectMake(0,0,320,60)];
    topView.backgroundColor=[UIColor clearColor];
    topView.tintColor =[UIColor clearColor];
    topView.opaque = NO;
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    UIButton *btnDone = [[UIButton alloc] initWithFrame:CGRectMake(230, 20, 100, 30)];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(doDone) forControlEvents:UIControlEventTouchUpInside];
    //UIBarButtonItem *rightBarbutton = [[UIBarButtonItem alloc] initWithCustomView:btnDone];
    //self.navigationItem.rightBarButtonItem = rightBarbutton;
    [topView addSubview:btnDone];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(rotationChanged:)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    UIImage *image = [UIImage imageWithContentsOfFile:filepath];
    originalImage = image;
    image = [self imageWithImage:image scaledToSize:screenBound.size];
    [imageView setImage:image];
    imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
    imageView.center = self.view.center;
    
    twoFingerPinch = [[UIPinchGestureRecognizer alloc]
                      initWithTarget:self
                      action:@selector(twoFingerPinch:)];
    [self.view addGestureRecognizer:twoFingerPinch];
    [self.view addSubview:topView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)twoFingerPinch:(UIPinchGestureRecognizer *)recognizer
{
    //    //NSLog(@"Pinch scale: %f", recognizer.scale);
    if (recognizer.scale >1.0f && recognizer.scale < 2.5f) {
        CGAffineTransform transform = CGAffineTransformMakeScale(recognizer.scale, recognizer.scale);
        imageView.transform = transform;
    }
}

-(void)rotationChanged:(NSNotification *)notification{
    
    
    //[imageView setImage:[self rotate:[[UIDevice currentDevice] orientation]]];
    
    NSInteger toInterfaceOrientation = [[UIDevice currentDevice] orientation];
    //UIWindow *_window = [[[UIApplication sharedApplication] delegate] window];
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = CGSizeMake(screenBound.size.height, screenBound.size.width);
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        [imageView setImage:[self imageWithImage:imageView.image scaledToSize: screenSize]];
        imageView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        [imageView setImage:[self imageWithImage:imageView.image scaledToSize: screenSize]];
        imageView.transform = CGAffineTransformMakeRotation(M_PI / 2);
    }
    else {
        [imageView setImage:[self imageWithImage:imageView.image scaledToSize: screenBound.size]];
        imageView.transform = CGAffineTransformMakeRotation(0.0);
    }

}

-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToSize: (CGSize) newSize
{
    float oldValue = 0.0f;
    float scaleFactor = 0.0f;
    float newHeight = 0.0f;
    float newWidth = 0.0f;
    //NSLog(@"%f,%f",sourceImage.size.width,sourceImage.size.height);
    if (newSize.width<newSize.height) {
        oldValue = originalImage.size.width;
        scaleFactor = newSize.width / oldValue;
        newHeight = originalImage.size.height * scaleFactor;
        newWidth = oldValue * scaleFactor;
    }
    else{
        oldValue = originalImage.size.height;
        scaleFactor = newSize.height/ oldValue;
        newHeight = oldValue * scaleFactor;
        newWidth = originalImage.size.width * scaleFactor;
    }
    
    
    
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [originalImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) doDone{
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popToViewController:senderViewController animated:YES];
}
- (IBAction)doDone:(id)sender {

    //[self.view.window.rootViewController presentViewController:senderViewController animated:YES completion:nil];

}
- (IBAction)scaleImage:(UIPinchGestureRecognizer *)recognizer {
    
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

#pragma -

-(UIImage*)rotate:(UIImageOrientation)orient
{
    CGRect bnds = CGRectZero;
    UIImage* copy = nil;
    CGContextRef ctxt = nil;
    //CGImageRef imag = self.CGImage;
    CGImageRef imag = originalImage.CGImage;
    
    CGRect rect = CGRectZero;
    CGAffineTransform tran = CGAffineTransformIdentity;
    
    rect.size.width = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);
    
    bnds = rect;
    
    switch (orient)
    {
        case UIImageOrientationUp:
            // would get you an exact copy of the original
            assert(false);
            return nil;
            
        case UIImageOrientationUpMirrored:
            tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown:
            tran = CGAffineTransformMakeTranslation(rect.size.width, rect.size.height);
            tran = CGAffineTransformRotate(tran, M_PI);
            break;
            
        case UIImageOrientationDownMirrored:
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            tran = CGAffineTransformScale(tran, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeft:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeftMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height, rect.size.width);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRight:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeScale(-1.0, 1.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        default:
            // orientation value supplied is invalid
            assert(false);
            return nil;
    }
    
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
    
    switch (orient)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextScaleCTM(ctxt, -1.0, 1.0);
            CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
            break;
            
        default:
            CGContextScaleCTM(ctxt, 1.0, -1.0);
            CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
            break;
    }
    
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
    
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return copy;
}

static CGRect swapWidthAndHeight(CGRect rect)
{
    CGFloat  swap = rect.size.width;
    
    rect.size.width  = rect.size.height;
    rect.size.height = swap;
    
    return rect;
}

@end
